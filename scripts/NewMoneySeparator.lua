script_name("NewMoneySeparator v4")
script_author("bakhusse")
script_version("4")

require "lib.moonloader"
local sampev = require "samp.events"
local memory = require "memory"
local json = require "dkjson"
local imgui = require "imgui"
local inicfg = require "inicfg"

local GTA_MONEY_ADDR = 0xB7CE50
local INT32_MAX = 2147483647
local current_cash_money = 0
local current_cash_money_known = false
local is_injected = false
local cfg

local function ENABLE_CHAT()
    return cfg.main.enable_chat
end

local function ENABLE_DIALOGS()
    return cfg.main.enable_dialogs
end

local function ENABLE_TEXTDRAWS()
    return cfg.main.enable_textdraws
end

local function ENABLE_3DTEXTS()
    return cfg.main.enable_3dtexts
end

local function ENABLE_CEF_HUD()
    return cfg.main.enable_cef_hud
end

local function ENABLE_GTA_MONEY_SYNC()
    return cfg.main.enable_gta_money_sync
end

local config_dir = getWorkingDirectory() .. "\\config\\NewMoneySeparator\\"
local config_name = "NewMoneySeparator\\settings"
local default_config = {
    main = {
        menu_key = 120, -- F9
        show_menu = false,
        enable_chat = true,
        enable_dialogs = true,
        enable_textdraws = true,
        enable_3dtexts = true,
        enable_cef_hud = true,
        enable_gta_money_sync = true,
        enable_cef_global = true,
        enable_cef_inputs = true,
        enable_cef_trade = true
    },

    separators = {
        chat = ".",
        dialogs = ".",
        textdraws = ".",
        texts3d = ".",
        object_material = ".",
        cef_global = ".",
        cef_hud = " ",
        cef_inputs = " ",
        cef_trade = " ",
        gta_money = "."
    },

    prefixes = {
        chat = "$",
        dialogs = "$",
        textdraws = "$",
        texts3d = "$",
        cef_global = "$",
        cef_hud = "$",
        cef_inputs = "$",
        cef_trade = "$"
    }
}

cfg = inicfg.load(default_config, config_name)
if not doesDirectoryExist(config_dir) then
    createDirectory(config_dir)
end
inicfg.save(cfg, config_name)

local menu_state = imgui.ImBool(false)
imgui.Process = false
local sync_buffers_from_config
local save_settings
local reset_settings
local apply_custom_imgui_style

local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local function encode_separator_for_config(value)
    value = tostring(value or "")
    if value == " " then
        return "{space}"
    end
    return value
end

local function decode_separator_from_config(value)
    value = tostring(value or "")
    if value == "{space}" then
        return " "
    end
    return value
end

local function get_separator_value(value)
    return decode_separator_from_config(value)
end

local function get_cfg_separator(name)
    return get_separator_value(cfg.separators[name])
end

local function get_cfg_prefix(name)
    return tostring(cfg.prefixes[name] or "")
end

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

local function decode_json_safe(str)
    local obj = json.decode(str)
    return obj
end

local function format_number_with_separator(num, sep)
    num = math.floor(tonumber(num) or 0)
    sep = tostring(sep or "")

    if sep == "" then
        return tostring(num)
    end

    local s = tostring(num)
    local rev = s:reverse():gsub("(%d%d%d)", "%1" .. sep)
    s = rev:reverse()

    if #sep > 0 and s:sub(1, #sep) == sep then
        s = s:sub(#sep + 1)
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
    if not ENABLE_GTA_MONEY_SYNC() then
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

local function build_money(m, kk, k, sep, prefix)
    local value = format_number_with_separator(build_money_value(m, kk, k), sep or "")
    prefix = tostring(prefix or "")
    return prefix .. value
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

local function convert_money_tags(text, sep, prefix)
    if type(text) ~= "string" or text == "" then
        return text
    end

    sep = sep or "."
    prefix = tostring(prefix or "")

    text = text:gsub(":M:%s*(%d+)%s*:KK:%s*(%d+)%s*:K:%s*([%d%.]+)", function(m, kk, k)
        return build_money(m, kk, k, sep, prefix)
    end)

    text = text:gsub(":M:%s*(%d+)%s*:KK:%s*(%d+)", function(m, kk)
        return build_money(m, kk, nil, sep, prefix)
    end)

    text = text:gsub(":M:%s*(%d+)%s*:K:%s*([%d%.]+)", function(m, k)
        return build_money(m, nil, k, sep, prefix)
    end)

    text = text:gsub(":KK:%s*(%d+)%s*:K:%s*([%d%.]+)", function(kk, k)
        return build_money(nil, kk, k, sep, prefix)
    end)

    text = text:gsub(":M:%s*(%d+)", function(m)
        return build_money(m, nil, nil, sep, prefix)
    end)

    text = text:gsub(":KK:%s*(%d+)", function(kk)
        return build_money(nil, kk, nil, sep, prefix)
    end)

    text = text:gsub(":K:%s*([%d%.]+)", function(k)
        return build_money(nil, nil, k, sep, prefix)
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

    var CUSTOM_SEPARATOR = ]] .. string.format("%q", get_cfg_separator("cef_trade")) .. [[;
    var PREFIX_SYMBOL = ]] .. string.format("%q", get_cfg_prefix("cef_trade")) .. [[;

    function formatCustom(value) {
        value = Math.floor(Number(value) || 0);
        return String(value).replace(/\B(?=(\d{3})+(?!\d))/g, CUSTOM_SEPARATOR);
    }

    function formatKFieldValue(value) {
        value = Math.floor(Number(value) || 0);

        if (value <= 0) return '';

        if (value < 1000) {
            return '0.' + String(value).padStart(3, '0');
        }

        return String(value).replace(/\B(?=(\d{3})+(?!\d))/g, '.');
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
                setInputValue(input, formatKFieldValue(parts.k));
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
            valueInput.value = total > 0 ? formatCustom(total) : '';
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
            valueInput.value = formatCustom(current);
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
            valueInput.value = PREFIX_SYMBOL + formatCustom(total);
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
            var nextValue = current > 0 ? formatCustom(current) : '';
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
            var nextValue = PREFIX_SYMBOL + formatCustom(total);
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

    var CUSTOM_SEPARATOR = ]] .. string.format("%q", get_cfg_separator("cef_inputs")) .. [[;
    var PREFIX_SYMBOL = ]] .. string.format("%q", get_cfg_prefix("cef_inputs")) .. [[;

    function formatCustom(value) {
        value = Math.floor(Number(value) || 0);
        return String(value).replace(/\B(?=(\d{3})+(?!\d))/g, CUSTOM_SEPARATOR);
    }

    function formatKFieldValue(value) {
        value = Math.floor(Number(value) || 0);

        if (value <= 0) return '';

        if (value < 1000) {
            return '0.' + String(value).padStart(3, '0');
        }

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
                setInputValue(input, formatKFieldValue(parts.k));
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
        suffix.textContent = PREFIX_SYMBOL;

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

            field.value = total > 0 ? formatCustom(total) : '';
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
            field.value = formatCustom(current);
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
            var nextValue = current > 0 ? formatCustom(current) : '';
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
    if (window.__structured_money_formatter_observer) {
        try { window.__structured_money_formatter_observer.disconnect(); } catch (e) {}
        window.__structured_money_formatter_observer = null;
    }

    if (window.__structured_money_formatter_interval) {
        try { clearInterval(window.__structured_money_formatter_interval); } catch (e) {}
        window.__structured_money_formatter_interval = null;
    }

    const PREFIX_SYMBOL = ]] .. string.format("%q", get_cfg_prefix("cef_global")) .. [[;
    const CUSTOM_SEPARATOR = ]] .. string.format("%q", get_cfg_separator("cef_global")) .. [[;

    const ICON_B = '\uF267'; 
    const ICON_M = '\uF266'; 
    const ICON_K = '\uF265'; 

    function formatCustom(n) {
        n = Math.floor(Number(n) || 0);
        return String(n).replace(/\B(?=(\d{3})+(?!\d))/g, CUSTOM_SEPARATOR);
    }

    function parseNumber(str) {
        return parseInt(String(str || '').replace(/[^\d]/g, ''), 10) || 0;
    }

    function replaceMoneyTagsInText(text) {
        if (!text) return text;

        text = text.replace(
            /:M:\s*(\d+)\s*:KK:\s*(\d+)\s*:K:\s*([\d.]+)/g,
            function (_, m, kk, k) {
                var total = parseNumber(m) * 1000000000 + parseNumber(kk) * 1000000 + parseNumber(k);
                return PREFIX_SYMBOL + formatCustom(total);
            }
        );

        text = text.replace(
            /:M:\s*(\d+)\s*:KK:\s*(\d+)/g,
            function (_, m, kk) {
                var total = parseNumber(m) * 1000000000 + parseNumber(kk) * 1000000;
                return PREFIX_SYMBOL + formatCustom(total);
            }
        );

        text = text.replace(
            /:M:\s*(\d+)\s*:K:\s*([\d.]+)/g,
            function (_, m, k) {
                var total = parseNumber(m) * 1000000000 + parseNumber(k);
                return PREFIX_SYMBOL + formatCustom(total);
            }
        );

        text = text.replace(
            /:KK:\s*(\d+)\s*:K:\s*([\d.]+)/g,
            function (_, kk, k) {
                var total = parseNumber(kk) * 1000000 + parseNumber(k);
                return PREFIX_SYMBOL + formatCustom(total);
            }
        );

        text = text.replace(/:M:\s*(\d+)/g, function (_, m) {
            return PREFIX_SYMBOL + formatCustom(parseNumber(m) * 1000000000);
        });

        text = text.replace(/:KK:\s*(\d+)/g, function (_, kk) {
            return PREFIX_SYMBOL + formatCustom(parseNumber(kk) * 1000000);
        });

        text = text.replace(/:K:\s*([\d.]+)/g, function (_, k) {
            return PREFIX_SYMBOL + formatCustom(parseNumber(k));
        });

        return text;
    }

    function isClientIconSpan(el) {
        if (!el || el.nodeType !== 1 || el.tagName !== 'SPAN') return false;
        const ff = String((el.style && el.style.fontFamily) || window.getComputedStyle(el).fontFamily || '').toLowerCase();
        return ff.indexOf('client-icons') !== -1;
    }

    function getIconMultiplier(iconText) {
        iconText = String(iconText || '').trim();
        if (iconText === ICON_B) return 1000000000;
        if (iconText === ICON_M) return 1000000;
        if (iconText === ICON_K) return 1;
        return 0;
    }

    function getTextNumberPrefix(str) {
        const m = String(str || '').match(/^(\s*[\d.]+)/);
        return m ? m[1] : null;
    }

    function processTextNode(node) {
        if (!node || node.nodeType !== 3) return;
        if (!node.nodeValue) return;

        if (
            node.nodeValue.indexOf(':M:') === -1 &&
            node.nodeValue.indexOf(':KK:') === -1 &&
            node.nodeValue.indexOf(':K:') === -1
        ) {
            return;
        }

        node.nodeValue = replaceMoneyTagsInText(node.nodeValue);
    }

    function processIconMoneyGroup(root) {
        if (!root || root.nodeType !== 1) return;
        if (root.closest('.player-money__list')) return;
        if (root.closest('.trade__give-money-field-wrapper')) return;
        if (root.closest('.trade__receive-money-field-wrapper')) return;
        if (root.closest('.dialog-money__form')) return;
        if (root.closest('.money-input')) return;

        const nodes = Array.from(root.childNodes);
        let i = 0;

        while (i < nodes.length) {
            const iconNode = nodes[i];

            if (!isClientIconSpan(iconNode)) {
                i++;
                continue;
            }

            let j = i;
            let total = 0;
            let found = 0;
            let parts = [];

            while (j < nodes.length) {
                const maybeIcon = nodes[j];
                const maybeText = nodes[j + 1];

                if (!isClientIconSpan(maybeIcon)) break;
                if (!maybeText || maybeText.nodeType !== 3) break;

                const mult = getIconMultiplier(maybeIcon.textContent);
                if (!mult) break;

                const raw = getTextNumberPrefix(maybeText.nodeValue);
                if (!raw) break;

                total += parseNumber(raw) * mult;
                found++;
                parts.push({ icon: maybeIcon, text: maybeText, raw: raw });

                j += 2;
            }

            if (found > 0) {
                const result = document.createTextNode(PREFIX_SYMBOL + formatCustom(total));

                root.insertBefore(result, parts[0].icon);

                for (let k = 0; k < parts.length; k++) {
                    const p = parts[k];
                    p.icon.remove();

                    p.text.nodeValue = p.text.nodeValue.replace(p.raw, '');
                    if (!p.text.nodeValue.trim()) {
                        p.text.remove();
                    }
                }

                i = 0;
                continue;
            }

            i++;
        }
    }

    function scanRoot(root) {
        if (!root) return;

        if (root.nodeType === 3) {
            processTextNode(root);
            return;
        }

        if (root.nodeType !== 1) return;

        const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, null, false);
        let node;
        while ((node = walker.nextNode())) {
            processTextNode(node);
        }

        const all = root.querySelectorAll('*');
        processIconMoneyGroup(root);
        for (let i = 0; i < all.length; i++) {
            processIconMoneyGroup(all[i]);
        }
    }

    let timeout = null;

    const observer = new MutationObserver(function (mutations) {
        if (timeout) clearTimeout(timeout);

        timeout = setTimeout(function () {
            for (let i = 0; i < mutations.length; i++) {
                const m = mutations[i];

                if (m.type === 'childList') {
                    for (let j = 0; j < m.addedNodes.length; j++) {
                        scanRoot(m.addedNodes[j]);
                    }
                }

                if (m.type === 'characterData' && m.target) {
                    processTextNode(m.target);
                    if (m.target.parentElement) {
                        processIconMoneyGroup(m.target.parentElement);
                    }
                }
            }
        }, 60);
    });

    window.__structured_money_formatter_observer = observer;

    if (document.body) {
        observer.observe(document.body, {
            childList: true,
            subtree: true,
            characterData: true
        });

        scanRoot(document.body);
    }

    window.__structured_money_formatter_interval = setInterval(function () {
        if (!document.hidden && document.body) {
            scanRoot(document.body);
        }
    }, 2000);
})();
]]
end

local function get_cef_money_inject_js()
    return [[
(function () {
    if (window.__money_separator_interval__) {
        try { clearInterval(window.__money_separator_interval__); } catch (e) {}
        window.__money_separator_interval__ = null;
    }

    var oldCustom = document.querySelector('.money-separator-custom-total');
    if (oldCustom) {
        oldCustom.remove();
    }

    window.__money_separator_installed__ = true;

    function parsePart(text) {
        if (!text) return 0;
        return parseInt(String(text).replace(/\./g, '').replace(/[^\d]/g, ''), 10) || 0;
    }

    var CUSTOM_SEPARATOR = ]] .. string.format("%q", get_cfg_separator("cef_hud")) .. [[;
    var PREFIX_SYMBOL = ]] .. string.format("%q", get_cfg_prefix("cef_hud")) .. [[;

    function formatCustom(num) {
        num = Math.floor(Number(num) || 0);
        return String(num).replace(/\B(?=(\d{3})+(?!\d))/g, CUSTOM_SEPARATOR);
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
        custom.style.gap = PREFIX_SYMBOL !== '' ? '10px' : '0px';
        custom.style.width = '100%';

        var iconWrap = null;

        if (PREFIX_SYMBOL !== '') {
            iconWrap = document.createElement('div');
            iconWrap.className = 'money-separator-custom-total__icon-wrap';
            iconWrap.style.width = '1.3vw';
            iconWrap.style.height = '1.3vw';
            iconWrap.style.minWidth = '22px';
            iconWrap.style.minHeight = '22px';
            iconWrap.style.borderRadius = '50%';
            iconWrap.style.background = '#72F05A';
            iconWrap.style.display = 'flex';
            iconWrap.style.alignItems = 'center';
            iconWrap.style.justifyContent = 'center';
            iconWrap.style.boxShadow = '0 1px 4px rgba(0,0,0,0.35)';

            var iconText = document.createElement('span');
            iconText.className = 'money-separator-custom-total__icon-text';
            iconText.textContent = PREFIX_SYMBOL;
            iconText.style.color = '#1B3A1A';
            iconText.style.fontWeight = '700';
            iconText.style.fontSize = '1vw';
            iconText.style.lineHeight = '1';
            iconText.style.fontFamily = 'Arial, Helvetica, sans-serif';

            iconWrap.appendChild(iconText);
        }

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

        if (iconWrap) {
            custom.appendChild(iconWrap);
        }
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
        var formatted = formatCustom(total);

        var custom = ensureCustomNode(root);
        var customValue = custom.querySelector('.money-separator-custom-total__value');
        if (customValue && customValue.textContent !== formatted) {
            customValue.textContent = formatted;
        }

        root.list.style.display = 'none';
        custom.style.display = 'flex';
    }

    updateMoneyHud();
    window.__money_separator_interval__ = setInterval(updateMoneyHud, 1000);
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
    if not ENABLE_CEF_HUD() then
        return
    end

    local ok = try_evalcef(get_cef_money_inject_js())
    if not silent then
        if ok then
        else
            sampAddChatMessage("[NewMoneySeparator v4] evalcef() not found, CEF HUD skipped.", 0xAAAAAA)
        end
    end
end

local function inject_cef_global_money_formatter(silent)
    local ok = try_evalcef(get_cef_structured_money_formatter_js())
    if not silent then
        if ok then
        else
            sampAddChatMessage("[NewMoneySeparator v4] Global CEF formatter failed.", 0xAAAAAA)
        end
    end
end

local function inject_cef_money_input_merger(silent)
    local ok = try_evalcef(get_cef_money_input_merger_js())
    if not silent then
        if ok then
        else
            sampAddChatMessage("[NewMoneySeparator v4] Money input merger failed.", 0xAAAAAA)
        end
    end
end

local function inject_cef_trade_money_merger(silent)
    local ok = try_evalcef(get_cef_trade_money_merger_js())
    if not silent then
        if ok then
        else
            sampAddChatMessage("[NewMoneySeparator v4] Trade money merger failed.", 0xAAAAAA)
        end
    end
end

local function reload_separator_script()
    sampAddChatMessage("[NewMoneySeparator v4] Перезагрузка скрипта...", 0x66CCFF)
    is_injected = false
    thisScript():reload()
end

local function unload_separator_script()
    sampAddChatMessage("[NewMoneySeparator v4] Выгрузка скрипта... Рекомендуется переподключиться. Для повторного запуска используйте CTRL+R", 0x66CCFF)
    is_injected = false
    thisScript():unload()
end

local function inject_cef_multiple()
    lua_thread.create(function()
        wait(5000)
        if sampGetGamestate() ~= 3 then return end

        inject_all_cef(false)

        for i = 1, 8 do
            wait(2500)
            if sampGetGamestate() ~= 3 then
                return
            end
            inject_all_cef(true)
        end
    end)
end

local function reinject_cef_hooks()
    sampAddChatMessage("[NewMoneySeparator v4] Повторный инжект CEF-хуков...", 0x66CCFF)
    apply_custom_imgui_style()
    inject_all_cef(false)

    lua_thread.create(function()
        for i = 1, 5 do
            wait(1500)
            if sampGetGamestate() ~= 3 then return end
            inject_all_cef(true)
        end
    end)
end

local function raknet_read_uint8(bs)
    return raknetBitStreamReadInt8(bs)
end

local function raknet_read_uint16(bs)
    local v = raknetBitStreamReadInt16(bs)
    return v < 0 and (v + 0x10000) or v
end

local function raknet_read_uint32(bs)
    local v = raknetBitStreamReadInt32(bs)
    return v < 0 and (v + 0x100000000) or v
end

local function raknet_read_string(bs, len)
    if len <= 0 then return "" end
    return raknetBitStreamReadString(bs, len)
end

local function raknet_read_encoded_string(bs, len)
    if len <= 0 then return "" end
    return raknetBitStreamDecodeString(bs, len + 1)
end

local function raknet_read_maybe_encoded(bs)
    local length = raknet_read_uint16(bs)
    local encoded = raknet_read_uint8(bs)

    if length <= 0 then
        return ""
    end

    if encoded == 0 then
        return raknet_read_string(bs, length)
    else
        return raknet_read_encoded_string(bs, length)
    end
end

local function update_money_state_from_arizona_display_text(text)
    if type(text) ~= "string" or text == "" then
        return false
    end

    if not text:find("event.player.updateMoney", 1, true) then
        return false
    end

    local json_part = text:match("`(.*)`")
    if not json_part or json_part == "" then
        return false
    end

    local ok, decoded = pcall(decode_json_safe, json_part)
    if not ok or type(decoded) ~= "table" then
        return false
    end

    local money = tonumber(decoded[1])
    if not money then
        return false
    end

    if money < 0 then
        money = 0
    end

    set_current_cash_money(money)
    sync_gta_money()
    return true
end

local add_handler = addEventHandler or registerHandler

add_handler("onReceivePacket", function(id, bs)
    if id ~= 220 then
        return
    end

    raknetBitStreamIgnoreBits(bs, 8)

    local packet_id = raknet_read_uint8(bs)
    if packet_id ~= 17 then
        return
    end

    local _server_id = raknet_read_uint32(bs)
    local text = raknet_read_maybe_encoded(bs)

    update_money_state_from_arizona_display_text(text)
end)

function sampev.onResetPlayerMoney()
    return false
end

function sampev.onGivePlayerMoney(money)
    return false
end

local function toggle_menu()
    local new_state = not menu_state.v
    menu_state.v = new_state
    imgui.Process = new_state

    if new_state then
        apply_custom_imgui_style()
        sync_buffers_from_config()
    end
end

function main()
    repeat wait(100) until isSampAvailable()
    apply_custom_imgui_style()
    sampAddChatMessage("[NewMoneySeparator v4] Ожидание подключения...", 0x66CCFF)

    sampRegisterChatCommand("nms.reload", reload_separator_script)
    sampRegisterChatCommand("nms.unload", unload_separator_script)
    sampRegisterChatCommand("nms.inject", reinject_cef_hooks)
    sampRegisterChatCommand("nms.menu", toggle_menu)
    sampRegisterChatCommand("nms.reset", reset_settings)
    sync_buffers_from_config()
    
    lua_thread.create(function()
        while true do
            wait(1000)

            if sampGetGamestate() == 3 and not is_injected then
                is_injected = true
                apply_custom_imgui_style()
                inject_cef_multiple()
            end

            if sampGetGamestate() ~= 3 then
                is_injected = false
            end
        end
    end)

    if ENABLE_GTA_MONEY_SYNC() then
        lua_thread.create(function()
            while true do wait(1000) sync_gta_money() end
        end)
    end
    wait(-1)
end

function inject_all_cef(silent)
    if cfg.main.enable_cef_hud then
        inject_cef_money_separator(silent)
    end

    if cfg.main.enable_cef_global then
        inject_cef_global_money_formatter(silent)
    end

    if cfg.main.enable_cef_inputs then
        inject_cef_money_input_merger(silent)
    end

    if cfg.main.enable_cef_trade then
        inject_cef_trade_money_merger(silent)
    end

    if not silent then
        sampAddChatMessage("[NewMoneySeparator v4] Все системы запущены.", 0x66CCFF)
    end
end

local sep_chat = imgui.ImBuffer(8)
local sep_dialogs = imgui.ImBuffer(8)
local sep_textdraws = imgui.ImBuffer(8)
local sep_3dtexts = imgui.ImBuffer(8)
local sep_object = imgui.ImBuffer(8)
local sep_cef_global = imgui.ImBuffer(8)
local sep_cef_hud = imgui.ImBuffer(8)
local sep_cef_inputs = imgui.ImBuffer(8)
local sep_cef_trade = imgui.ImBuffer(8)

local prefix_chat = imgui.ImBuffer(16)
local prefix_dialogs = imgui.ImBuffer(16)
local prefix_textdraws = imgui.ImBuffer(16)
local prefix_3dtexts = imgui.ImBuffer(16)
local prefix_cef_global = imgui.ImBuffer(16)
local prefix_cef_hud = imgui.ImBuffer(16)
local prefix_cef_inputs = imgui.ImBuffer(16)
local prefix_cef_trade = imgui.ImBuffer(16)

local cb_enable_chat = imgui.ImBool(cfg.main.enable_chat)
local cb_enable_dialogs = imgui.ImBool(cfg.main.enable_dialogs)
local cb_enable_textdraws = imgui.ImBool(cfg.main.enable_textdraws)
local cb_enable_3dtexts = imgui.ImBool(cfg.main.enable_3dtexts)
local cb_enable_cef_hud = imgui.ImBool(cfg.main.enable_cef_hud)
local cb_enable_gta_money_sync = imgui.ImBool(cfg.main.enable_gta_money_sync)
local cb_enable_cef_global = imgui.ImBool(cfg.main.enable_cef_global)
local cb_enable_cef_inputs = imgui.ImBool(cfg.main.enable_cef_inputs)
local cb_enable_cef_trade = imgui.ImBool(cfg.main.enable_cef_trade)

sync_buffers_from_config = function()
    sep_chat.v = decode_separator_from_config(cfg.separators.chat)
    sep_dialogs.v = decode_separator_from_config(cfg.separators.dialogs)
    sep_textdraws.v = decode_separator_from_config(cfg.separators.textdraws)
    sep_3dtexts.v = decode_separator_from_config(cfg.separators.texts3d)
    sep_object.v = decode_separator_from_config(cfg.separators.object_material)
    sep_cef_global.v = decode_separator_from_config(cfg.separators.cef_global)
    sep_cef_hud.v = decode_separator_from_config(cfg.separators.cef_hud)
    sep_cef_inputs.v = decode_separator_from_config(cfg.separators.cef_inputs)
    sep_cef_trade.v = decode_separator_from_config(cfg.separators.cef_trade)

    prefix_chat.v = tostring(cfg.prefixes.chat or "")
    prefix_dialogs.v = tostring(cfg.prefixes.dialogs or "")
    prefix_textdraws.v = tostring(cfg.prefixes.textdraws or "")
    prefix_3dtexts.v = tostring(cfg.prefixes.texts3d or "")
    prefix_cef_global.v = tostring(cfg.prefixes.cef_global or "")
    prefix_cef_hud.v = tostring(cfg.prefixes.cef_hud or "")
    prefix_cef_inputs.v = tostring(cfg.prefixes.cef_inputs or "")
    prefix_cef_trade.v = tostring(cfg.prefixes.cef_trade or "")

    cb_enable_chat.v = cfg.main.enable_chat
    cb_enable_dialogs.v = cfg.main.enable_dialogs
    cb_enable_textdraws.v = cfg.main.enable_textdraws
    cb_enable_3dtexts.v = cfg.main.enable_3dtexts
    cb_enable_cef_hud.v = cfg.main.enable_cef_hud
    cb_enable_gta_money_sync.v = cfg.main.enable_gta_money_sync
    cb_enable_cef_global.v = cfg.main.enable_cef_global
    cb_enable_cef_inputs.v = cfg.main.enable_cef_inputs
    cb_enable_cef_trade.v = cfg.main.enable_cef_trade

end

save_settings = function()
    cfg.main.enable_chat = cb_enable_chat.v
    cfg.main.enable_dialogs = cb_enable_dialogs.v
    cfg.main.enable_textdraws = cb_enable_textdraws.v
    cfg.main.enable_3dtexts = cb_enable_3dtexts.v
    cfg.main.enable_cef_hud = cb_enable_cef_hud.v
    cfg.main.enable_gta_money_sync = cb_enable_gta_money_sync.v
    cfg.main.enable_cef_global = cb_enable_cef_global.v
    cfg.main.enable_cef_inputs = cb_enable_cef_inputs.v
    cfg.main.enable_cef_trade = cb_enable_cef_trade.v

    cfg.prefixes.chat = tostring(prefix_chat.v or "")
    cfg.prefixes.dialogs = tostring(prefix_dialogs.v or "")
    cfg.prefixes.textdraws = tostring(prefix_textdraws.v or "")
    cfg.prefixes.texts3d = tostring(prefix_3dtexts.v or "")
    cfg.prefixes.cef_global = tostring(prefix_cef_global.v or "")
    cfg.prefixes.cef_hud = tostring(prefix_cef_hud.v or "")
    cfg.prefixes.cef_inputs = tostring(prefix_cef_inputs.v or "")
    cfg.prefixes.cef_trade = tostring(prefix_cef_trade.v or "")

    cfg.separators.chat = encode_separator_for_config(sep_chat.v)
    cfg.separators.dialogs = encode_separator_for_config(sep_dialogs.v)
    cfg.separators.textdraws = encode_separator_for_config(sep_textdraws.v)
    cfg.separators.texts3d = encode_separator_for_config(sep_3dtexts.v)
    cfg.separators.object_material = encode_separator_for_config(sep_object.v)
    cfg.separators.cef_global = encode_separator_for_config(sep_cef_global.v)
    cfg.separators.cef_hud = encode_separator_for_config(sep_cef_hud.v)
    cfg.separators.cef_inputs = encode_separator_for_config(sep_cef_inputs.v)
    cfg.separators.cef_trade = encode_separator_for_config(sep_cef_trade.v)

    inicfg.save(cfg, config_name)
end

apply_custom_imgui_style = function()
    local style = imgui.GetStyle()
    local colors = style.Colors

    style.WindowPadding = imgui.ImVec2(12, 12)
    style.FramePadding = imgui.ImVec2(10, 6)
    style.ItemSpacing = imgui.ImVec2(10, 8)
    style.ItemInnerSpacing = imgui.ImVec2(6, 6)
    style.IndentSpacing = 20
    style.ScrollbarSize = 12
    style.GrabMinSize = 10

    style.WindowRounding = 10
    style.ChildWindowRounding = 8
    style.FrameRounding = 6
    style.ScrollbarRounding = 8
    style.GrabRounding = 6

    colors[imgui.Col.Text]                 = imgui.ImVec4(0.95, 0.96, 0.98, 1.00)
    colors[imgui.Col.TextDisabled]         = imgui.ImVec4(0.55, 0.58, 0.62, 1.00)
    colors[imgui.Col.WindowBg]             = imgui.ImVec4(0.10, 0.11, 0.13, 0.98)
    colors[imgui.Col.ChildWindowBg]        = imgui.ImVec4(0.14, 0.15, 0.18, 1.00)
    colors[imgui.Col.PopupBg]              = imgui.ImVec4(0.12, 0.13, 0.16, 0.98)
    colors[imgui.Col.Border]               = imgui.ImVec4(0.20, 0.22, 0.27, 0.80)
    colors[imgui.Col.BorderShadow]         = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)

    colors[imgui.Col.FrameBg]              = imgui.ImVec4(0.16, 0.17, 0.21, 1.00)
    colors[imgui.Col.FrameBgHovered]       = imgui.ImVec4(0.20, 0.22, 0.28, 1.00)
    colors[imgui.Col.FrameBgActive]        = imgui.ImVec4(0.24, 0.27, 0.34, 1.00)

    colors[imgui.Col.TitleBg]              = imgui.ImVec4(0.09, 0.10, 0.12, 1.00)
    colors[imgui.Col.TitleBgActive]        = imgui.ImVec4(0.12, 0.13, 0.16, 1.00)
    colors[imgui.Col.TitleBgCollapsed]     = imgui.ImVec4(0.09, 0.10, 0.12, 0.75)

    colors[imgui.Col.MenuBarBg]            = imgui.ImVec4(0.14, 0.15, 0.18, 1.00)
    colors[imgui.Col.ScrollbarBg]          = imgui.ImVec4(0.10, 0.11, 0.13, 1.00)
    colors[imgui.Col.ScrollbarGrab]        = imgui.ImVec4(0.27, 0.30, 0.36, 1.00)
    colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.34, 0.37, 0.44, 1.00)
    colors[imgui.Col.ScrollbarGrabActive]  = imgui.ImVec4(0.40, 0.44, 0.52, 1.00)

    colors[imgui.Col.CheckMark]            = imgui.ImVec4(0.33, 0.72, 1.00, 1.00)
    colors[imgui.Col.SliderGrab]           = imgui.ImVec4(0.33, 0.72, 1.00, 1.00)
    colors[imgui.Col.SliderGrabActive]     = imgui.ImVec4(0.20, 0.62, 0.95, 1.00)

    colors[imgui.Col.Button]               = imgui.ImVec4(0.18, 0.20, 0.25, 1.00)
    colors[imgui.Col.ButtonHovered]        = imgui.ImVec4(0.24, 0.28, 0.34, 1.00)
    colors[imgui.Col.ButtonActive]         = imgui.ImVec4(0.17, 0.47, 0.76, 1.00)

    colors[imgui.Col.Header]               = imgui.ImVec4(0.18, 0.20, 0.25, 1.00)
    colors[imgui.Col.HeaderHovered]        = imgui.ImVec4(0.24, 0.28, 0.34, 1.00)
    colors[imgui.Col.HeaderActive]         = imgui.ImVec4(0.17, 0.47, 0.76, 1.00)

    colors[imgui.Col.Separator]            = imgui.ImVec4(0.22, 0.24, 0.29, 1.00)
    colors[imgui.Col.SeparatorHovered]     = imgui.ImVec4(0.33, 0.72, 1.00, 0.78)
    colors[imgui.Col.SeparatorActive]      = imgui.ImVec4(0.33, 0.72, 1.00, 1.00)

    colors[imgui.Col.ResizeGrip]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[imgui.Col.ResizeGripHovered]    = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[imgui.Col.ResizeGripActive]     = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)

end

function imgui.OnDrawFrame()
    if not imgui.Process then return end
    apply_custom_imgui_style()

    imgui.SetNextWindowSize(imgui.ImVec2(760, 600), imgui.Cond.FirstUseEver)
    local sw, sh = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2((sw - 760) / 2, (sh - 600) / 2), imgui.Cond.FirstUseEver)

    if imgui.Begin(
        u8"NewMoneySeparator v4",
        menu_state,
        imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize
    ) then
        imgui.TextColored(imgui.ImVec4(0.33, 0.72, 1.00, 1.00), u8"Настройки форматирования денег")
        imgui.TextDisabled(u8"Пустой разделитель = число без разделения")
        imgui.Separator()
        imgui.Spacing()

        imgui.BeginChild("##left_panel", imgui.ImVec2(360, -28), true)

        imgui.Text(u8"Модули")
        imgui.Separator()
        imgui.Checkbox(u8"Чат", cb_enable_chat)
        imgui.Checkbox(u8"Диалоги", cb_enable_dialogs)
        imgui.Checkbox(u8"TextDraw", cb_enable_textdraws)
        imgui.Checkbox(u8"3D Text", cb_enable_3dtexts)
        imgui.Checkbox(u8"CEF HUD", cb_enable_cef_hud)
        imgui.Checkbox(u8"Стандартный худ", cb_enable_gta_money_sync)
        imgui.Checkbox(u8"CEF глобальный", cb_enable_cef_global)
        imgui.Checkbox(u8"CEF ввод в диалоге", cb_enable_cef_inputs)
        imgui.Checkbox(u8"CEF Трейд", cb_enable_cef_trade)

        imgui.Spacing()
        imgui.Text(u8"Символ / префикс")
        imgui.Separator()

        imgui.PushItemWidth(140)
        imgui.InputText(u8"Чат##prefix_chat", prefix_chat)
        imgui.InputText(u8"Диалоги##prefix_dialogs", prefix_dialogs)
        imgui.InputText(u8"TextDraw##prefix_td", prefix_textdraws)
        imgui.InputText(u8"3D Text##prefix_3d", prefix_3dtexts)
        imgui.InputText(u8"CEF глобальный##prefix_cef_global", prefix_cef_global)
        imgui.InputText(u8"CEF HUD##prefix_cef_hud", prefix_cef_hud)
        imgui.InputText(u8"CEF ввод в диалоге##prefix_cef_inputs", prefix_cef_inputs)
        imgui.InputText(u8"CEF Трейд##prefix_cef_trade", prefix_cef_trade)
        imgui.PopItemWidth()

        imgui.EndChild()

        imgui.SameLine()

        imgui.BeginChild("##right_panel", imgui.ImVec2(0, -28), true)

        imgui.Text(u8"SAMP разделители")
        imgui.Separator()

        imgui.PushItemWidth(140)
        imgui.InputText(u8"Чат##sep_chat", sep_chat)
        imgui.InputText(u8"Диалоги##sep_dialogs", sep_dialogs)
        imgui.InputText(u8"TextDraw##sep_td", sep_textdraws)
        imgui.InputText(u8"3D Text##sep_3d", sep_3dtexts)
        imgui.InputText(u8"Object Material##sep_obj", sep_object)

        imgui.Spacing()
        imgui.Text(u8"CEF разделители")
        imgui.Separator()

        imgui.InputText(u8"CEF глобальный##sep_cef_g", sep_cef_global)
        imgui.InputText(u8"CEF HUD##sep_cef_hud", sep_cef_hud)
        imgui.InputText(u8"CEF ввод в диалоге##sep_cef_inputs", sep_cef_inputs)
        imgui.InputText(u8"CEF Трейд##sep_cef_trade", sep_cef_trade)
        imgui.PopItemWidth()

        imgui.Spacing()
        imgui.TextDisabled(u8"Пример:")
        imgui.BulletText(u8"'.'  -> 1.234.567")
        imgui.BulletText(u8"', ' -> 1,234,567")
        imgui.BulletText(u8"' '  -> 1 234 567")
        imgui.BulletText(u8"пусто -> 1234567")

        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()

    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.17, 0.47, 0.76, 1.00))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.24, 0.57, 0.88, 1.00))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.12, 0.39, 0.65, 1.00))

    if imgui.Button(u8"Сохранить", imgui.ImVec2(140, 34)) then
        save_settings()
        reinject_cef_hooks()
        sampAddChatMessage("[NewMoneySeparator v4] Настройки сохранены.", 0x66CCFF)
    end

imgui.PopStyleColor(3)

        imgui.SameLine()

        if imgui.Button(u8"Сбросить", imgui.ImVec2(110, 34)) then
            reset_settings()
        end

        imgui.EndChild()
    end

    if not menu_state.v then
        imgui.Process = false
    end

    imgui.SetCursorPosY(imgui.GetWindowHeight() - 28)
    imgui.Separator()

    local footer_text = u8"v4 © манул бахус"
    local text_size = imgui.CalcTextSize(footer_text)
    local win_w = imgui.GetWindowWidth()
    local win_h = imgui.GetWindowHeight()

    imgui.SetCursorPos(imgui.ImVec2(
        (win_w - text_size.x) * 0.5,
        win_h - text_size.y - 10
    ))
    imgui.TextDisabled(footer_text)

    imgui.End()
end

reset_settings = function()
    cfg = inicfg.load(default_config, config_name)
    inicfg.save(cfg, config_name)
    sync_buffers_from_config()
    imgui.Process = menu_state.v
    sampAddChatMessage("[NewMoneySeparator v4] Настройки сброшены.", 0x66CCFF)
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if not ENABLE_DIALOGS() then return end

    update_money_state_from_text(title)
    update_money_state_from_text(button1)
    update_money_state_from_text(button2)
    update_money_state_from_text(text)

    title = convert_money_tags(title, get_cfg_separator("dialogs"), get_cfg_prefix("dialogs"))
    button1 = convert_money_tags(button1, get_cfg_separator("dialogs"), get_cfg_prefix("dialogs"))
    button2 = convert_money_tags(button2, get_cfg_separator("dialogs"), get_cfg_prefix("dialogs"))
    text = convert_money_tags(text, get_cfg_separator("dialogs"), get_cfg_prefix("dialogs"))

    return {dialogId, style, title, button1, button2, text}
end

function sampev.onSetObjectMaterialText(id, data)
    if not data or type(data.text) ~= "string" or data.text == "" then return end

    update_money_state_from_text(data.text)

    data.text = data.text:gsub("\nKK%s+(%d+)", function(kk)
        return "\n" .. build_money(nil, kk, nil, get_cfg_separator("object_material"), get_cfg_prefix("textdraws"))
    end)

    data.text = data.text:gsub("\nM%s+(%d+)", function(m)
        return "\n" .. build_money(m, nil, nil, get_cfg_separator("object_material"), get_cfg_prefix("textdraws"))
    end)

    data.text = data.text:gsub("\nK%s+([%d%.]+)", function(k)
        return "\n" .. build_money(nil, nil, k, get_cfg_separator("object_material"), get_cfg_prefix("textdraws"))
    end)

    data.text = convert_money_tags(data.text, get_cfg_separator("object_material"), get_cfg_prefix("textdraws"))

    return { id, data }
end

function sampev.onSetPlayerObjectMaterialText(id, data)
    if not data or type(data.text) ~= "string" or data.text == "" then return end

    update_money_state_from_text(data.text)
    data.text = convert_money_tags(data.text, get_cfg_separator("object_material"), get_cfg_prefix("textdraws"))

    return { id, data }
end

function sampev.onServerMessage(color, text)
    if not ENABLE_CHAT() then return end

    update_money_state_from_text(text)
    text = convert_money_tags(text, get_cfg_separator("chat"), get_cfg_prefix("chat"))
    return {color, text}
end

function sampev.onShowTextDraw(id, data)
    if not ENABLE_TEXTDRAWS() then return end
    if data and data.text then
        update_money_state_from_text(data.text)
        data.text = convert_money_tags(data.text, get_cfg_separator("textdraws"), get_cfg_prefix("textdraws"))
        return {id, data}
    end
end

function sampev.onTextDrawSetString(id, text)
    if not ENABLE_TEXTDRAWS() then return end
    update_money_state_from_text(text)
    text = convert_money_tags(text, get_cfg_separator("textdraws"), get_cfg_prefix("textdraws"))
    return {id, text}
end

function sampev.onCreate3DText(id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text)
    if not ENABLE_3DTEXTS() then return end
    if type(text) ~= "string" or text == "" then return end

    update_money_state_from_text(text)
    text = convert_money_tags(text, get_cfg_separator("texts3d"), get_cfg_prefix("texts3d"))

    return {id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text}
end