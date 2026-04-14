script_name("NewMoneySeparator v3")
script_author("bakhusse")
script_version("3")

require "lib.moonloader"
local sampev = require "samp.events"
local memory = require "memory"

local ENABLE_CHAT = true
local ENABLE_DIALOGS = true
local ENABLE_TEXTDRAWS = true
local ENABLE_3DTEXTS = true
local ENABLE_CEF_HUD = true
local ENABLE_GTA_MONEY_SYNC = true

local GTA_MONEY_ADDR = 0xB7CE50
local INT32_MAX = 2147483647
local current_cash_money = 0
local current_cash_money_known = false

local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

function evalcef(js, isEncoded)
    if type(js) ~= 'string' or js == '' then return false end

    local bs = raknetNewBitStream()
    local encoded = isEncoded and 1 or 0

    raknetBitStreamWriteInt8(bs, 17)
    raknetBitStreamWriteInt32(bs, 0)
    raknetBitStreamWriteInt16(bs, #js)
    raknetBitStreamWriteInt8(bs, encoded)
    raknetBitStreamWriteString(bs, js)

    raknetEmulRpcReceiveBitStream(220, bs)
    raknetDeleteBitStream(bs)

    return true
end

local function format_with_dots(num)
    num = math.floor(tonumber(num) or 0)
    local s = tostring(num)
    local rev = s:reverse():gsub("(%d%d%d)", "%1.")
    s = rev:reverse()
    if s:sub(1, 1) == "." then
        s = s:sub(2)
    end
    return s
end

local function parse_k_value(str)
    str = tostring(str or "")
    str = str:gsub("%.", "")
    return tonumber(str) or 0
end

local function clamp_int32_money(num)
    num = tonumber(num) or 0
    if num < 0 then
        num = 0
    elseif num > INT32_MAX then
        num = INT32_MAX
    end
    return math.floor(num)
end

local function sync_gta_money()
    if not ENABLE_GTA_MONEY_SYNC then
        return
    end

    if not current_cash_money_known then
        return
    end

    memory.setint32(GTA_MONEY_ADDR, clamp_int32_money(current_cash_money), true)
end

local function set_current_cash_money(num)
    num = tonumber(num) or 0
    if num < 0 then num = 0 end
    current_cash_money = math.floor(num)
    current_cash_money_known = true
end

local function build_money_value(m, kk, k)
    local total = 0

    if m then
        total = total + (tonumber(m) or 0) * 1000000000
    end

    if kk then
        total = total + (tonumber(kk) or 0) * 1000000
    end

    if k then
        total = total + parse_k_value(k)
    end

    return total
end

local function build_money(m, kk, k)
    local value = format_with_dots(build_money_value(m, kk, k))
    if value:sub(1, 1) ~= "$" then
        value = "$" .. value
    end
    return value
end

local function extract_cash_money_from_text(text)
    if type(text) ~= "string" or text == "" then
        return nil
    end

    -- Статистика / диалоги
    do
        local m, kk, k = text:match("Наличные деньги %(SA%$%)%s*:%s*:M:%s*(%d+)%s*:KK:%s*(%d+)%s*:K:%s*([%d%.]+)")
        if m or kk or k then
            return build_money_value(m, kk, k)
        end
    end

    do
        local m, kk = text:match("Наличные деньги %(SA%$%)%s*:%s*:M:%s*(%d+)%s*:KK:%s*(%d+)")
        if m or kk then
            return build_money_value(m, kk, nil)
        end
    end

    do
        local m, k = text:match("Наличные деньги %(SA%$%)%s*:%s*:M:%s*(%d+)%s*:K:%s*([%d%.]+)")
        if m or k then
            return build_money_value(m, nil, k)
        end
    end

    do
        local kk, k = text:match("Наличные деньги %(SA%$%)%s*:%s*:KK:%s*(%d+)%s*:K:%s*([%d%.]+)")
        if kk or k then
            return build_money_value(nil, kk, k)
        end
    end

    do
        local kk = text:match("Наличные деньги %(SA%$%)%s*:%s*:KK:%s*(%d+)")
        if kk then
            return build_money_value(nil, kk, nil)
        end
    end

    do
        local k = text:match("Наличные деньги %(SA%$%)%s*:%s*:K:%s*([%d%.]+)")
        if k then
            return build_money_value(nil, nil, k)
        end
    end

    do
        local m = text:match("Наличные деньги %(SA%$%)%s*:%s*:M:%s*(%d+)")
        if m then
            return build_money_value(m, nil, nil)
        end
    end

    -- Иногда может прилетать обычным форматом после замены / из других сообщений
    do
        local cash = text:match("Наличные деньги %(SA%$%)%s*:%s*([%d%.]+)")
        if cash then
            return parse_k_value(cash)
        end
    end

    -- На всякий случай ловим короткий вариант "Наличные: ..."
    do
        local cash = text:match("Наличные%s*:%s*([%d%.]+)")
        if cash then
            return parse_k_value(cash)
        end
    end

    return nil
end

local function update_money_state_from_text(text)
    local cash = extract_cash_money_from_text(text)
    if cash then
        set_current_cash_money(cash)
        sync_gta_money()
    end
end

local function convert_money_tags(text)
    if type(text) ~= "string" or text == "" then
        return text
    end

    text = text:gsub(":M:%s*(%d+)%s*:KK:%s*(%d+)%s*:K:%s*([%d%.]+)", function(m, kk, k)
        return build_money(m, kk, k)
    end)

    text = text:gsub(":M:%s*(%d+)%s*:KK:%s*(%d+)", function(m, kk)
        return build_money(m, kk, nil)
    end)

    text = text:gsub(":M:%s*(%d+)%s*:K:%s*([%d%.]+)", function(m, k)
        return build_money(m, nil, k)
    end)

    text = text:gsub(":KK:%s*(%d+)%s*:K:%s*([%d%.]+)", function(kk, k)
        return build_money(nil, kk, k)
    end)

    text = text:gsub(":M:%s*(%d+)", function(m)
        return build_money(m, nil, nil)
    end)

    text = text:gsub(":KK:%s*(%d+)", function(kk)
        return build_money(nil, kk, nil)
    end)

    text = text:gsub(":K:%s*([%d%.]+)", function(k)
        return build_money(nil, nil, k)
    end)

    return text
end

local function get_cef_trade_money_merger_js()
    return [[
(function () {
    if (window.__trade_money_merger_installed__) return;
    window.__trade_money_merger_installed__ = true;

    function parseDigits(value) {
        value = String(value || '');
        value = value.replace(/[^\d]/g, '');
        if (!value) return 0;
        return parseInt(value, 10) || 0;
    }

    function formatSpaces(value) {
        value = Math.floor(Number(value) || 0);
        return String(value).replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
    }

    function formatDots(value) {
        value = Math.floor(Number(value) || 0);
        return String(value).replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    }

    function splitMoney(total) {
        total = Math.floor(Number(total) || 0);
        if (total < 0) total = 0;

        var b = Math.floor(total / 1000000000);
        total = total % 1000000000;

        var m = Math.floor(total / 1000000);
        total = total % 1000000;

        var k = total;

        return { b: b, m: m, k: k };
    }

    var nativeInputValueSetter = Object.getOwnPropertyDescriptor(
        window.HTMLInputElement.prototype, 'value'
    ).set;

    function setInputValue(input, value) {
        nativeInputValueSetter.call(input, value);
        input.dispatchEvent(new Event('input', { bubbles: true }));
        input.dispatchEvent(new Event('change', { bubbles: true }));
    }

    function getSelectedCurrency(wrapper) {
        if (!wrapper) return '';
        var title = wrapper.querySelector('.trade-select__title');
        if (!title) return '';
        return String(title.textContent || '').trim().toLowerCase();
    }

    function isMoneySelected(wrapper) {
        return getSelectedCurrency(wrapper) === 'деньги';
    }

    function findMoneyInputs(wrapper) {
        if (!wrapper) return [];
        return Array.prototype.slice.call(wrapper.querySelectorAll('.trade-input__field'));
    }

    function hasMoneyTriplet(inputs) {
        var hasB = false, hasM = false, hasK = false;

        for (var i = 0; i < inputs.length; i++) {
            var icon = inputs[i].parentElement ? inputs[i].parentElement.querySelector('img[alt]') : null;
            var alt = icon ? String(icon.getAttribute('alt') || '') : '';

            if (alt === 'billion-icon') hasB = true;
            if (alt === 'million-icon') hasM = true;
            if (alt === 'thousand-icon') hasK = true;
        }

        return hasB && hasM && hasK;
    }

    function collectCurrentValue(inputs) {
        var b = 0, m = 0, k = 0;

        for (var i = 0; i < inputs.length; i++) {
            var input = inputs[i];
            var icon = input.parentElement ? input.parentElement.querySelector('img[alt]') : null;
            var alt = icon ? String(icon.getAttribute('alt') || '') : '';
            var val = parseDigits(input.value);

            if (alt === 'billion-icon') b = val;
            else if (alt === 'million-icon') m = val;
            else if (alt === 'thousand-icon') k = val;
        }

        return b * 1000000000 + m * 1000000 + k;
    }

    function syncToOriginalInputs(total, inputs) {
        var parts = splitMoney(total);

        for (var i = 0; i < inputs.length; i++) {
            var input = inputs[i];
            var icon = input.parentElement ? input.parentElement.querySelector('img[alt]') : null;
            var alt = icon ? String(icon.getAttribute('alt') || '') : '';

            if (alt === 'billion-icon') {
                setInputValue(input, parts.b > 0 ? String(parts.b) : '');
            } else if (alt === 'million-icon') {
                setInputValue(input, parts.m > 0 ? String(parts.m) : '');
            } else if (alt === 'thousand-icon') {
                setInputValue(input, parts.k > 0 ? formatDots(parts.k) : '');
            }
        }
    }

    function getMoneyBox(input) {
        if (!input || !input.closest) return input ? input.parentElement : null;

        return (
            input.closest('.trade-input') ||
            input.closest('.trade-input__wrapper') ||
            input.closest('.trade-input-container') ||
            input.parentElement
        );
    }

    function hideOriginalMoneyBoxes(inputs) {
        for (var i = 0; i < inputs.length; i++) {
            var box = getMoneyBox(inputs[i]);
            if (box) box.style.display = 'none';
        }
    }

    function showOriginalMoneyBoxes(inputs) {
        for (var i = 0; i < inputs.length; i++) {
            var box = getMoneyBox(inputs[i]);
            if (box) box.style.display = '';
        }
    }

    function updateMergedCurrency(wrapper, root) {
        if (!wrapper || !root) return;

        var selectTitle = wrapper.querySelector('.trade-select__title');
        var selectIcon = wrapper.querySelector('.trade-select__icon');

        var titleEl = root.querySelector('.trade__give-money-value-currency');
        var iconEl = root.querySelector('.trade__receive-money-icon');

        if (selectTitle && titleEl) {
            titleEl.textContent = selectTitle.textContent || 'деньги';
        }

        if (selectIcon && iconEl) {
            iconEl.src = selectIcon.src;
            iconEl.alt = selectIcon.alt || 'деньги';
        }
    }

    function makeGiveField(wrapper, inputs) {
        var field = document.createElement('div');
        field.className = 'trade__give-money-field trade__give-money-field--merged-give';

        field.style.width = '100%';
        field.style.display = 'flex';
        field.style.alignItems = 'center';
        field.style.justifyContent = 'space-between';
        field.style.gap = '10px';

        var valueInput = document.createElement('input');
        valueInput.className = 'trade__give-money-value';
        valueInput.placeholder = 'Введите сумму';
        valueInput.autocomplete = 'off';
        valueInput.style.flex = '1 1 auto';
        valueInput.style.minWidth = '0';
        valueInput.style.background = 'transparent';
        valueInput.style.border = 'none';
        valueInput.style.outline = 'none';

        var euroFieldRef = document.querySelector('.trade__give-money-field .trade__give-money-value');
        if (euroFieldRef) {
            var ecs = getComputedStyle(euroFieldRef);
            valueInput.style.fontFamily = ecs.fontFamily;
            valueInput.style.fontSize = ecs.fontSize;
            valueInput.style.fontWeight = ecs.fontWeight;
            valueInput.style.lineHeight = ecs.lineHeight;
            valueInput.style.color = ecs.color;
            valueInput.style.padding = ecs.padding;
            valueInput.style.margin = ecs.margin;
            valueInput.style.textAlign = ecs.textAlign;
        }

        var right = document.createElement('div');
        right.className = 'trade__receive-money-icon-wrapper';
        right.style.display = 'flex';
        right.style.alignItems = 'center';
        right.style.gap = '6px';
        right.style.flexShrink = '0';

        var title = document.createElement('span');
        title.className = 'trade__give-money-value trade__give-money-value-currency';
        title.textContent = 'деньги';

        var titleRef = wrapper.querySelector('.trade-select__title');
        if (titleRef) {
            var tcs = getComputedStyle(titleRef);
            title.style.fontFamily = tcs.fontFamily;
            title.style.fontSize = tcs.fontSize;
            title.style.fontWeight = tcs.fontWeight;
            title.style.lineHeight = tcs.lineHeight;
            title.style.color = tcs.color;
        }

        var img = document.createElement('img');
        img.className = 'trade__receive-money-icon';

        var srcRef = wrapper.querySelector('.trade-select__icon');
        if (srcRef) {
            img.src = srcRef.src;
            img.alt = srcRef.alt || 'деньги';
            var ics = getComputedStyle(srcRef);
            img.style.width = ics.width;
            img.style.height = ics.height;
            img.style.minWidth = ics.width;
        }

        right.appendChild(title);
        right.appendChild(img);

        field.appendChild(valueInput);
        field.appendChild(right);

        var updating = false;

        valueInput.addEventListener('input', function () {
            if (updating) return;
            updating = true;

            var total = parseDigits(valueInput.value);
            valueInput.value = total > 0 ? formatSpaces(total) : '';
            syncToOriginalInputs(total, inputs);

            updating = false;
        });

        valueInput.addEventListener('keydown', function (e) {
            var allowed =
                e.key === 'Backspace' ||
                e.key === 'Delete' ||
                e.key === 'Tab' ||
                e.key === 'Enter' ||
                e.key === 'ArrowLeft' ||
                e.key === 'ArrowRight' ||
                e.key === 'Home' ||
                e.key === 'End';

            if (allowed) return;
            if (/^\d$/.test(e.key)) return;

            e.preventDefault();
        });

        var current = collectCurrentValue(inputs);
        if (current > 0) {
            valueInput.value = formatSpaces(current);
        }

        updateMergedCurrency(wrapper, field);
        return field;
    }

    function makeReceiveField(wrapper, inputs) {
        var field = document.createElement('div');
        field.className = 'trade__give-money-field b trade__give-money-field--merged-receive';

        field.style.width = '100%';
        field.style.display = 'flex';
        field.style.alignItems = 'center';
        field.style.justifyContent = 'space-between';
        field.style.gap = '10px';

        var valueInput = document.createElement('input');
        valueInput.className = 'trade__give-money-value';
        valueInput.readOnly = true;
        valueInput.tabIndex = -1;
        valueInput.style.flex = '1 1 auto';
        valueInput.style.minWidth = '0';
        valueInput.style.background = 'transparent';
        valueInput.style.border = 'none';
        valueInput.style.outline = 'none';

        var euroFieldRef = document.querySelector('.trade__give-money-field .trade__give-money-value');
        if (euroFieldRef) {
            var ecs = getComputedStyle(euroFieldRef);
            valueInput.style.fontFamily = ecs.fontFamily;
            valueInput.style.fontSize = ecs.fontSize;
            valueInput.style.fontWeight = ecs.fontWeight;
            valueInput.style.lineHeight = ecs.lineHeight;
            valueInput.style.color = ecs.color;
            valueInput.style.padding = ecs.padding;
            valueInput.style.margin = ecs.margin;
            valueInput.style.textAlign = ecs.textAlign;
        }

        var right = document.createElement('div');
        right.className = 'trade__receive-money-icon-wrapper';
        right.style.display = 'flex';
        right.style.alignItems = 'center';
        right.style.gap = '6px';
        right.style.flexShrink = '0';

        var title = document.createElement('span');
        title.className = 'trade__give-money-value trade__give-money-value-currency';
        title.textContent = 'деньги';

        var titleRef = wrapper.querySelector('.trade-select__title');
        if (titleRef) {
            var tcs = getComputedStyle(titleRef);
            title.style.fontFamily = tcs.fontFamily;
            title.style.fontSize = tcs.fontSize;
            title.style.fontWeight = tcs.fontWeight;
            title.style.lineHeight = tcs.lineHeight;
            title.style.color = tcs.color;
        }

        var img = document.createElement('img');
        img.className = 'trade__receive-money-icon';

        var srcRef = wrapper.querySelector('.trade-select__icon');
        if (srcRef) {
            img.src = srcRef.src;
            img.alt = srcRef.alt || 'деньги';
            var ics = getComputedStyle(srcRef);
            img.style.width = ics.width;
            img.style.height = ics.height;
            img.style.minWidth = ics.width;
        }

        right.appendChild(title);
        right.appendChild(img);

        field.appendChild(valueInput);
        field.appendChild(right);

        function update() {
            var total = collectCurrentValue(inputs);
            valueInput.value = '$' + formatSpaces(total);
            updateMergedCurrency(wrapper, field);
        }

        update();

        return field;
    }

    function cleanupGiveWrapper(wrapper, inputs) {
        var mergedList = wrapper.querySelectorAll('.trade__give-money-field--merged-give');
        for (var i = 0; i < mergedList.length; i++) {
            mergedList[i].remove();
        }
        showOriginalMoneyBoxes(inputs);
    }

    function cleanupReceiveWrapper(wrapper, inputs) {
        var mergedList = wrapper.querySelectorAll('.trade__give-money-field--merged-receive');
        for (var i = 0; i < mergedList.length; i++) {
            mergedList[i].remove();
        }
        showOriginalMoneyBoxes(inputs);
    }

    function processGiveWrapper(wrapper) {
        if (!wrapper) return;

        var inputs = findMoneyInputs(wrapper);
        if (!inputs || inputs.length !== 3) {
            cleanupGiveWrapper(wrapper, []);
            return;
        }
        if (!hasMoneyTriplet(inputs)) {
            cleanupGiveWrapper(wrapper, inputs);
            return;
        }

        if (!isMoneySelected(wrapper)) {
            cleanupGiveWrapper(wrapper, inputs);
            return;
        }

        var merged = wrapper.querySelector('.trade__give-money-field--merged-give');
        var mergedList = wrapper.querySelectorAll('.trade__give-money-field--merged-give');
        if (mergedList.length > 1) {
            for (var x = 1; x < mergedList.length; x++) {
                mergedList[x].remove();
            }
            merged = mergedList[0];
        }

        if (!merged) {
            var unified = makeGiveField(wrapper, inputs);
            var selectBlock = wrapper.querySelector('.trade-select');

            if (selectBlock && selectBlock.parentNode === wrapper) {
                wrapper.insertBefore(unified, selectBlock);
            } else {
                wrapper.appendChild(unified);
            }

            merged = unified;
        }

        hideOriginalMoneyBoxes(inputs);

        updateMergedCurrency(wrapper, merged);

        var valueInput = merged.querySelector('input.trade__give-money-value');
        if (valueInput && document.activeElement !== valueInput) {
            var current = collectCurrentValue(inputs);
            var nextValue = current > 0 ? formatSpaces(current) : '';
            if (valueInput.value !== nextValue) {
                valueInput.value = nextValue;
            }
        }
    }

    function processReceiveWrapper(wrapper) {
        if (!wrapper) return;

        var inputs = findMoneyInputs(wrapper);
        if (!inputs || inputs.length !== 3) {
            cleanupReceiveWrapper(wrapper, []);
            return;
        }
        if (!hasMoneyTriplet(inputs)) {
            cleanupReceiveWrapper(wrapper, inputs);
            return;
        }

        if (!isMoneySelected(wrapper)) {
            cleanupReceiveWrapper(wrapper, inputs);
            return;
        }

        var merged = wrapper.querySelector('.trade__give-money-field--merged-receive');

        if (!merged) {
            var unified = makeReceiveField(wrapper, inputs);
            var selectBlock = wrapper.querySelector('.trade-select');

            if (selectBlock && selectBlock.parentNode === wrapper) {
                wrapper.insertBefore(unified, selectBlock);
            } else {
                wrapper.appendChild(unified);
            }

            merged = unified;
        }

        hideOriginalMoneyBoxes(inputs);

        updateMergedCurrency(wrapper, merged);

        var valueInput = merged.querySelector('input.trade__give-money-value');
        if (valueInput) {
            var total = collectCurrentValue(inputs);
            var nextValue = '$' + formatSpaces(total);
            if (valueInput.value !== nextValue) {
                valueInput.value = nextValue;
            }
        }
    }

    function scan() {
        var giveWrappers = document.querySelectorAll('.trade__give-money-field-wrapper');
        for (var i = 0; i < giveWrappers.length; i++) {
            processGiveWrapper(giveWrappers[i]);
        }

        var receiveWrappers = document.querySelectorAll('.trade__receive-money-field-wrapper');
        for (var j = 0; j < receiveWrappers.length; j++) {
            processReceiveWrapper(receiveWrappers[j]);
        }
    }

    setInterval(scan, 300);

    var observer = new MutationObserver(function () {
        scan();
    });

    observer.observe(document.documentElement, {
        childList: true,
        subtree: true,
        characterData: true
    });
})();
]]
end

local function get_cef_money_input_merger_js()
    return [[
(function () {
    if (window.__money_input_merger_installed__) return;
    window.__money_input_merger_installed__ = true;

    function parseDigits(value) {
        value = String(value || '');
        value = value.replace(/[^\d]/g, '');
        if (!value) return 0;
        return parseInt(value, 10) || 0;
    }

    function formatSpaces(value) {
        value = Math.floor(Number(value) || 0);
        return String(value).replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
    }

    function formatDots(value) {
        value = Math.floor(Number(value) || 0);
        return String(value).replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    }

    function splitMoney(total) {
        total = Math.floor(Number(total) || 0);
        if (total < 0) total = 0;

        var b = Math.floor(total / 1000000000);
        total = total % 1000000000;

        var m = Math.floor(total / 1000000);
        total = total % 1000000;

        var k = total;

        return { b: b, m: m, k: k };
    }

    var nativeInputValueSetter = Object.getOwnPropertyDescriptor(
        window.HTMLInputElement.prototype, 'value'
    ).set;

    function setInputValue(input, value) {
        nativeInputValueSetter.call(input, value);
        input.dispatchEvent(new Event('input', { bubbles: true }));
        input.dispatchEvent(new Event('change', { bubbles: true }));
    }

    function getMoneyBox(input) {
        if (!input || !input.closest) return input ? input.parentElement : null;
        return (
            input.closest('.money-input') ||
            input.closest('.dialog-text__input') ||
            input.parentElement
        );
    }

    function hideOriginalMoneyBoxes(inputs) {
        for (var i = 0; i < inputs.length; i++) {
            var box = getMoneyBox(inputs[i]);
            if (box) box.style.display = 'none';
        }
    }

    function showOriginalMoneyBoxes(inputs) {
        for (var i = 0; i < inputs.length; i++) {
            var box = getMoneyBox(inputs[i]);
            if (box) box.style.display = '';
        }
    }

    function collectCurrentValue(inputs) {
        var b = 0, m = 0, k = 0;

        for (var i = 0; i < inputs.length; i++) {
            var input = inputs[i];
            var icon = input.parentElement ? input.parentElement.querySelector('img[alt]') : null;
            var alt = icon ? String(icon.getAttribute('alt') || '') : '';

            var val = parseDigits(input.value);

            if (alt === 'billion-icon') b = val;
            else if (alt === 'million-icon') m = val;
            else if (alt === 'thousand-icon') k = val;
        }

        return b * 1000000000 + m * 1000000 + k;
    }

    function syncToOriginalInputs(total, inputs) {
        var parts = splitMoney(total);

        for (var i = 0; i < inputs.length; i++) {
            var input = inputs[i];
            var icon = input.parentElement ? input.parentElement.querySelector('img[alt]') : null;
            var alt = icon ? String(icon.getAttribute('alt') || '') : '';

            if (alt === 'billion-icon') {
                setInputValue(input, parts.b > 0 ? String(parts.b) : '');
            } else if (alt === 'million-icon') {
                setInputValue(input, parts.m > 0 ? String(parts.m) : '');
            } else if (alt === 'thousand-icon') {
                setInputValue(input, parts.k > 0 ? formatDots(parts.k) : '');
            }
        }
    }

    function createUnifiedInput(dialog, form, inputs) {
        var outer = document.createElement('div');
        outer.className = 'dialog-text__input b money-input--unified';

        var dialogInput = document.createElement('div');
        dialogInput.className = 'dialog-input';

        var field = document.createElement('input');
        field.type = 'text';
        field.className = 'dialog-input__field';
        field.spellcheck = false;
        field.placeholder = 'Введите сумму';
        field.autocomplete = 'off';

        var suffix = document.createElement('div');
        suffix.className = 'dialog-input__keyboard-language';
        suffix.textContent = '$';

        dialogInput.appendChild(field);
        dialogInput.appendChild(suffix);
        outer.appendChild(dialogInput);

        var refOuter = dialog.querySelector('.dialog-text__input');
        if (refOuter) {
            var outerCs = getComputedStyle(refOuter);
            outer.style.width = outerCs.width;
            outer.style.margin = outerCs.margin;
            outer.style.flex = outerCs.flex;
        } else {
            outer.style.width = '100%';
        }

        var refDialogInput = dialog.querySelector('.dialog-input');
        if (refDialogInput) {
            var wrapCs = getComputedStyle(refDialogInput);
            dialogInput.style.height = wrapCs.height;
            dialogInput.style.minHeight = wrapCs.minHeight;
            dialogInput.style.padding = wrapCs.padding;
            dialogInput.style.border = wrapCs.border;
            dialogInput.style.borderRadius = wrapCs.borderRadius;
            dialogInput.style.background = wrapCs.background;
            dialogInput.style.boxShadow = wrapCs.boxShadow;
            dialogInput.style.display = wrapCs.display;
            dialogInput.style.alignItems = wrapCs.alignItems;
        } else {
            dialogInput.style.display = 'flex';
            dialogInput.style.alignItems = 'center';
        }

        var refField = dialog.querySelector('.dialog-input__field');
        if (refField) {
            var fieldCs = getComputedStyle(refField);
            field.style.height = fieldCs.height;
            field.style.padding = fieldCs.padding;
            field.style.margin = fieldCs.margin;
            field.style.border = fieldCs.border;
            field.style.outline = 'none';
            field.style.background = fieldCs.background;
            field.style.color = fieldCs.color;
            field.style.fontFamily = fieldCs.fontFamily;
            field.style.fontSize = fieldCs.fontSize;
            field.style.fontWeight = fieldCs.fontWeight;
            field.style.lineHeight = fieldCs.lineHeight;
            field.style.textAlign = fieldCs.textAlign;
            field.style.flex = fieldCs.flex || '1 1 auto';
            field.style.minWidth = '0';
        } else {
            field.style.flex = '1 1 auto';
            field.style.minWidth = '0';
            field.style.background = 'transparent';
            field.style.border = 'none';
            field.style.outline = 'none';
        }

        var refSuffix = dialog.querySelector('.dialog-input__keyboard-language');
        if (refSuffix) {
            var suffixCs = getComputedStyle(refSuffix);
            suffix.style.minWidth = suffixCs.minWidth;
            suffix.style.width = suffixCs.width;
            suffix.style.height = suffixCs.height;
            suffix.style.display = suffixCs.display;
            suffix.style.alignItems = suffixCs.alignItems;
            suffix.style.justifyContent = suffixCs.justifyContent;
            suffix.style.padding = suffixCs.padding;
            suffix.style.margin = suffixCs.margin;
            suffix.style.borderRadius = suffixCs.borderRadius;
            suffix.style.background = suffixCs.background;
            suffix.style.color = suffixCs.color;
            suffix.style.fontFamily = suffixCs.fontFamily;
            suffix.style.fontSize = suffixCs.fontSize;
            suffix.style.fontWeight = suffixCs.fontWeight;
            suffix.style.lineHeight = suffixCs.lineHeight;
        }

        var updating = false;

        field.addEventListener('input', function () {
            if (updating) return;
            updating = true;

            var total = parseDigits(field.value);
            var start = field.selectionStart || 0;
            var oldLen = field.value.length;

            field.value = total > 0 ? formatSpaces(total) : '';
            syncToOriginalInputs(total, inputs);

            var newLen = field.value.length;
            var nextPos = start + (newLen - oldLen);

            try {
                field.setSelectionRange(nextPos, nextPos);
            } catch (e) {}

            updating = false;
        });

        field.addEventListener('keydown', function (e) {
            var allowed =
                e.key === 'Backspace' ||
                e.key === 'Delete' ||
                e.key === 'Tab' ||
                e.key === 'Enter' ||
                e.key === 'ArrowLeft' ||
                e.key === 'ArrowRight' ||
                e.key === 'Home' ||
                e.key === 'End';

            if (allowed) return;
            if (/^\d$/.test(e.key)) return;

            e.preventDefault();
        });

        var current = collectCurrentValue(inputs);
        if (current > 0) {
            field.value = formatSpaces(current);
        }

        return outer;
    }

    function cleanupMoneyDialog(dialog, inputs) {
        var mergedList = dialog.querySelectorAll('.money-input--unified');
        for (var i = 0; i < mergedList.length; i++) {
            mergedList[i].remove();
        }
        if (inputs && inputs.length) {
            showOriginalMoneyBoxes(inputs);
        }
        delete dialog.dataset.moneyMerged;
    }

    function processMoneyDialog(dialog) {
        if (!dialog) return;

        var form = dialog.querySelector('.dialog-money__form');
        if (!form) {
            cleanupMoneyDialog(dialog);
            return;
        }

        var inputs = form.querySelectorAll('.money-input__field');
        if (!inputs || inputs.length !== 3) {
            cleanupMoneyDialog(dialog, inputs);
            return;
        }

        var merged = dialog.querySelector('.money-input--unified');

        if (!merged) {
            merged = createUnifiedInput(dialog, form, inputs);
            form.appendChild(merged);
        }

        hideOriginalMoneyBoxes(inputs);

        var field = merged.querySelector('.dialog-input__field');
        if (field && document.activeElement !== field) {
            var current = collectCurrentValue(inputs);
            var nextValue = current > 0 ? formatSpaces(current) : '';
            if (field.value !== nextValue) {
                field.value = nextValue;
            }
        }

        dialog.dataset.moneyMerged = '1';
    }

    function scan() {
        var dialogs = document.querySelectorAll('.dialog');
        for (var i = 0; i < dialogs.length; i++) {
            processMoneyDialog(dialogs[i]);
        }
    }

    setInterval(scan, 400);

    var observer = new MutationObserver(function () {
        scan();
    });

    observer.observe(document.documentElement, {
        childList: true,
        subtree: true
    });
})();
]]
end

local function get_cef_structured_money_formatter_js()
    return [[
(function () {
    if (window.__structured_money_formatter_installed__) return;
    window.__structured_money_formatter_installed__ = true;

    var ICON_B = '\uF267';
    var ICON_M = '\uF266';
    var ICON_K = '\uF265';

    function parsePart(text) {
        if (!text) return 0;
        return parseInt(String(text).replace(/\./g, '').replace(/[^\d]/g, ''), 10) || 0;
    }

    function shouldSkipElement(el) {
        if (!el || !el.closest) return false;

        return !!(
            el.closest('.donate-menu') ||
            el.closest('.donate') ||
            el.closest('[class*="donate"]')
        );
    }

    function formatDots(num) {
        num = Math.floor(Number(num) || 0);
        return String(num).replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    }

    function iconToMultiplier(icon) {
        if (icon === ICON_B) return 1000000000;
        if (icon === ICON_M) return 1000000;
        return 1;
    }

    function buildByIcon(icon, rawValue) {
        var value = parsePart(rawValue);
        return '$' + formatDots(value * iconToMultiplier(icon));
    }

    function isClientIconSpan(node) {
        if (!node || node.nodeType !== 1) return false;
        if (node.tagName !== 'SPAN') return false;

        var ff = '';
        try {
            ff = window.getComputedStyle(node).fontFamily || '';
        } catch (e) {}

        ff = String(ff).toLowerCase();
        if (ff.indexOf('client-icons') === -1) return false;

        var ch = String(node.textContent || '').trim();
        return ch === ICON_B || ch === ICON_M || ch === ICON_K;
    }

    function isProcessableContainer(el) {
        if (!el || !el.childNodes || el.childNodes.length === 0) return false;

        var hasMoneyIcon = false;

        for (var i = 0; i < el.childNodes.length; i++) {
            var node = el.childNodes[i];

            if (node.nodeType === 1) {
                if (isClientIconSpan(node)) {
                    hasMoneyIcon = true;
                } else {
                    return false;
                }
            }
        }

        return hasMoneyIcon;
    }

    function processStructuredContainer(el) {
        if (!isProcessableContainer(el)) return false;

        var groups = [];
        var currentGroup = [];
        var changed = false;

        function flushGroup() {
            if (currentGroup.length === 0) return;

            var total = 0;
            for (var g = 0; g < currentGroup.length; g++) {
                total += currentGroup[g].value * currentGroup[g].multiplier;
            }

            groups.push('$' + formatDots(total));
            currentGroup = [];
        }

        for (var i = 0; i < el.childNodes.length; i++) {
            var node = el.childNodes[i];

            if (node.nodeType === 1 && isClientIconSpan(node)) {
                var icon = String(node.textContent || '').trim();
                var raw = '';
                var j = i + 1;

                while (j < el.childNodes.length) {
                    var next = el.childNodes[j];

                    if (next.nodeType === 1 && isClientIconSpan(next)) {
                        break;
                    }

                    if (next.nodeType === 3) {
                        raw += next.nodeValue || '';
                    } else if (next.nodeType === 1) {
                        raw += next.textContent || '';
                    }

                    j++;
                }

                var valueMatch = raw.match(/[\d][\d\.]*/);
                var value = valueMatch ? parsePart(valueMatch[0]) : 0;

                currentGroup.push({
                    value: value,
                    multiplier: iconToMultiplier(icon)
                });

                changed = true;

                var tail = raw.replace(/^[\s\S]*?[\d][\d\.]*/, '');

                if (tail && tail.indexOf('/') !== -1) {
                    flushGroup();
                    groups.push(' / ');
                }

                i = j - 1;
            } else if (node.nodeType === 3) {
                var text = node.nodeValue || '';
                if (text.indexOf('/') !== -1) {
                    flushGroup();
                    groups.push(' / ');
                }
            }
        }

        flushGroup();

        if (!changed) return false;

        var finalText = groups.join('');
        finalText = finalText.replace(/\s*\/\s*/g, ' / ');
        finalText = finalText.replace(/\s+/g, ' ').trim();

        if (finalText && el.textContent !== finalText) {
            el.textContent = finalText;
            return true;
        }

        return false;
    }

    function convertRawMoneyText(text) {
        if (!text || typeof text !== 'string') return text;

        text = text.replace(/:M:\s*(\d+)\s*:KK:\s*(\d+)\s*:K:\s*([\d\.]+)/g, function(_, m, kk, k) {
            return '$' + formatDots((parseInt(m, 10) || 0) * 1000000000 + (parseInt(kk, 10) || 0) * 1000000 + parsePart(k));
        });

        text = text.replace(/:M:\s*(\d+)\s*:KK:\s*(\d+)/g, function(_, m, kk) {
            return '$' + formatDots((parseInt(m, 10) || 0) * 1000000000 + (parseInt(kk, 10) || 0) * 1000000);
        });

        text = text.replace(/:M:\s*(\d+)\s*:K:\s*([\d\.]+)/g, function(_, m, k) {
            return '$' + formatDots((parseInt(m, 10) || 0) * 1000000000 + parsePart(k));
        });

        text = text.replace(/:KK:\s*(\d+)\s*:K:\s*([\d\.]+)/g, function(_, kk, k) {
            return '$' + formatDots((parseInt(kk, 10) || 0) * 1000000 + parsePart(k));
        });

        text = text.replace(/:M:\s*(\d+)/g, function(_, m) {
            return '$' + formatDots((parseInt(m, 10) || 0) * 1000000000);
        });

        text = text.replace(/:KK:\s*(\d+)/g, function(_, kk) {
            return '$' + formatDots((parseInt(kk, 10) || 0) * 1000000);
        });

        text = text.replace(/:K:\s*([\d\.]+)/g, function(_, k) {
            return '$' + formatDots(parsePart(k));
        });

        return text;
    }

    function processRawTextElement(el) {
        if (shouldSkipElement(el)) return false;
        if (!el || !el.childNodes || el.childNodes.length !== 1) return false;
        if (!el.firstChild || el.firstChild.nodeType !== 3) return false;

        var oldText = el.textContent || '';
        if (!oldText) return false;

        if (
            oldText.indexOf(':M:') === -1 &&
            oldText.indexOf(':KK:') === -1 &&
            oldText.indexOf(':K:') === -1
        ) {
            return false;
        }

        var newText = convertRawMoneyText(oldText);
        if (newText !== oldText) {
            el.textContent = newText;
            return true;
        }

        return false;
    }

    function scan() {
        if (!document.body) return;

        var nodes = document.querySelectorAll('div, span, p, td, strong, b');

        for (var i = 0; i < nodes.length; i++) {
            processStructuredContainer(nodes[i]);
            processRawTextElement(nodes[i]);
        }
    }

    setInterval(scan, 400);

    var observer = new MutationObserver(function () {
        scan();
    });

    observer.observe(document.documentElement, {
        childList: true,
        subtree: true,
        characterData: true
    });
})();
]]
end

local function get_cef_money_inject_js()
    return [[
(function () {
    if (window.__money_separator_installed__) return;
    window.__money_separator_installed__ = true;

    function parsePart(text) {
        if (!text) return 0;
        return parseInt(String(text).replace(/\./g, '').replace(/[^\d]/g, ''), 10) || 0;
    }

    function formatSpaces(num) {
        num = Math.floor(Number(num) || 0);
        return String(num).replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
    }

    function findMoneyItem(alt) {
        var img = document.querySelector('img[alt="' + alt + '"]');
        if (!img) return null;

        var item = img.closest('.player-money__item');
        if (!item) return null;

        var value = item.querySelector('.player-money__item-value');
        if (!value) return null;

        return {
            img: img,
            item: item,
            value: value
        };
    }

    function getMoneyRoot() {
        var thousand = findMoneyItem('thousand-icon');
        if (!thousand) return null;

        var list = thousand.item.closest('.player-money__list');
        if (!list) return null;

        var wrap = list.parentElement;
        if (!wrap) return null;

        return {
            thousand: thousand,
            list: list,
            wrap: wrap
        };
    }

    function ensureCustomNode(root) {
        var custom = root.wrap.querySelector('.money-separator-custom-total');
        if (custom) return custom;

        custom = document.createElement('div');
        custom.className = 'money-separator-custom-total';
        custom.style.display = 'flex';
        custom.style.alignItems = 'center';
        custom.style.gap = '10px';
        custom.style.width = '100%';

        var iconWrap = document.createElement('div');
        iconWrap.className = 'money-separator-custom-total__icon-wrap';
        iconWrap.style.width = '36px';
        iconWrap.style.height = '36px';
        iconWrap.style.minWidth = '36px';
        iconWrap.style.borderRadius = '50%';
        iconWrap.style.background = '#72F05A';
        iconWrap.style.display = 'flex';
        iconWrap.style.alignItems = 'center';
        iconWrap.style.justifyContent = 'center';
        iconWrap.style.boxShadow = '0 1px 4px rgba(0,0,0,0.35)';

        var iconText = document.createElement('span');
        iconText.className = 'money-separator-custom-total__icon-text';
        iconText.textContent = '$';
        iconText.style.color = '#1B3A1A';
        iconText.style.fontWeight = '700';
        iconText.style.fontSize = '24px';
        iconText.style.lineHeight = '1';
        iconText.style.fontFamily = 'Arial, Helvetica, sans-serif';

        iconWrap.appendChild(iconText);

        var value = document.createElement('p');
        value.className = 'money-separator-custom-total__value';

        if (root.thousand.value) {
            var cs = getComputedStyle(root.thousand.value);

            value.style.margin = cs.margin;
            value.style.whiteSpace = 'nowrap';

            value.style.fontFamily = cs.fontFamily;
            value.style.fontSize = cs.fontSize;
            value.style.fontWeight = cs.fontWeight;
            value.style.lineHeight = cs.lineHeight;
            value.style.letterSpacing = cs.letterSpacing;

            value.style.color = cs.color;
            value.style.textShadow = cs.textShadow;
        } else {
            value.style.margin = '0';
            value.style.whiteSpace = 'nowrap';
        }

        custom.appendChild(iconWrap);
        custom.appendChild(value);
        root.wrap.appendChild(custom);

        return custom;
    }

    function updateMoneyHud() {
        var billion = findMoneyItem('billion-icon');
        var million = findMoneyItem('million-icon');
        var thousand = findMoneyItem('thousand-icon');
        var root = getMoneyRoot();

        if (!thousand || !root) return;

        var b = billion ? parsePart(billion.value.textContent) : 0;
        var m = million ? parsePart(million.value.textContent) : 0;
        var k = parsePart(thousand.value.textContent);

        var total = b * 1000000000 + m * 1000000 + k;
        var formatted = formatSpaces(total);

        var custom = ensureCustomNode(root);
        var customValue = custom.querySelector('.money-separator-custom-total__value');
        if (customValue && customValue.textContent !== formatted) {
            customValue.textContent = formatted;
        }

        root.list.style.display = 'none';
        custom.style.display = 'flex';
    }

    setInterval(updateMoneyHud, 300);
})();
]]
end

local function try_evalcef(js)
    if type(evalcef) == "function" then
        local ok = pcall(evalcef, js)
        return ok
    end

    return false
end

local function inject_cef_money_separator(silent)
    if not ENABLE_CEF_HUD then
        return
    end

    local ok = try_evalcef(get_cef_money_inject_js())
    if not silent then
        if ok then
            sampAddChatMessage("[NewMoneySeparator v3] CEF HUD hook injected.", 0x66CCFF)
        else
            sampAddChatMessage("[NewMoneySeparator v3] evalcef() not found, CEF HUD skipped.", 0xAAAAAA)
        end
    end
end

local function inject_cef_global_money_formatter(silent)
    local ok = try_evalcef(get_cef_structured_money_formatter_js())
    if not silent then
        if ok then
            sampAddChatMessage("[NewMoneySeparator v3] Global CEF formatter injected.", 0x66CCFF)
        else
            sampAddChatMessage("[NewMoneySeparator v3] Global CEF formatter failed.", 0xAAAAAA)
        end
    end
end

local function inject_cef_money_input_merger(silent)
    local ok = try_evalcef(get_cef_money_input_merger_js())
    if not silent then
        if ok then
            sampAddChatMessage("[NewMoneySeparator v3] Money input merger injected.", 0x66CCFF)
        else
            sampAddChatMessage("[NewMoneySeparator v3] Money input merger failed.", 0xAAAAAA)
        end
    end
end

local function inject_cef_trade_money_merger(silent)
    local ok = try_evalcef(get_cef_trade_money_merger_js())
    if not silent then
        if ok then
            sampAddChatMessage("[NewMoneySeparator v3] Trade money merger injected.", 0x66CCFF)
        else
            sampAddChatMessage("[NewMoneySeparator v3] Trade money merger failed.", 0xAAAAAA)
        end
    end
end

function main()
    repeat wait(100) until isSampAvailable()
    sampAddChatMessage("[NewMoneySeparator v3] Загружен.", 0x66CCFF)

    if ENABLE_CEF_HUD then
        lua_thread.create(function()
            wait(5000)
            inject_cef_money_separator(false)
            inject_cef_global_money_formatter(false)
            inject_cef_money_input_merger(false)
            inject_cef_trade_money_merger(false)

            while true do
                wait(5000)
                if isSampAvailable() then
                    inject_cef_money_separator(true)
                    inject_cef_global_money_formatter(true)
                    inject_cef_money_input_merger(true)
                    inject_cef_trade_money_merger(true)
                end
            end
        end)
    end

    if ENABLE_GTA_MONEY_SYNC then
        lua_thread.create(function()
            while true do
                wait(500)
                sync_gta_money()
            end
        end)
    end

    wait(-1)
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if not ENABLE_DIALOGS then return end

    update_money_state_from_text(title)
    update_money_state_from_text(button1)
    update_money_state_from_text(button2)
    update_money_state_from_text(text)

    title = convert_money_tags(title)
    button1 = convert_money_tags(button1)
    button2 = convert_money_tags(button2)
    text = convert_money_tags(text)

    return {dialogId, style, title, button1, button2, text}
end

function sampev.onServerMessage(color, text)
    if not ENABLE_CHAT then return end

    update_money_state_from_text(text)
    text = convert_money_tags(text)
    return {color, text}
end

function sampev.onShowTextDraw(id, data)
    if not ENABLE_TEXTDRAWS then return end
    if data and data.text then
        update_money_state_from_text(data.text)
        data.text = convert_money_tags(data.text)
        return {id, data}
    end
end

function sampev.onTextDrawSetString(id, text)
    if not ENABLE_TEXTDRAWS then return end
    update_money_state_from_text(text)
    text = convert_money_tags(text)
    return {id, text}
end

function sampev.onCreate3DText(id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text)
    if not ENABLE_3DTEXTS then return end
    if type(text) ~= "string" or text == "" then return end

    update_money_state_from_text(text)
    text = convert_money_tags(text)

    return {id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text}
end