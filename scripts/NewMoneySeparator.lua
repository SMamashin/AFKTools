script_name("Arizona Money Separator")
script_author("bakhusse")
script_version("1.0")

require "lib.moonloader"
local sampev = require "samp.events"

local ENABLE_CHAT = true
local ENABLE_DIALOGS = true
local ENABLE_TEXTDRAWS = true

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

local function build_money(m, kk, k)
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

    return format_with_dots(total)
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

function main()
    repeat wait(100) until isSampAvailable()
    sampAddChatMessage("[NewMoneySeparator] Загружен.", 0x66CCFF)
    wait(-1)
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if not ENABLE_DIALOGS then return end

    title = convert_money_tags(title)
    button1 = convert_money_tags(button1)
    button2 = convert_money_tags(button2)
    text = convert_money_tags(text)

    return {dialogId, style, title, button1, button2, text}
end

function sampev.onServerMessage(color, text)
    if not ENABLE_CHAT then return end

    text = convert_money_tags(text)
    return {color, text}
end

function sampev.onShowTextDraw(id, data)
    if not ENABLE_TEXTDRAWS then return end
    if data and data.text then
        data.text = convert_money_tags(data.text)
        return {id, data}
    end
end

function sampev.onTextDrawSetString(id, text)
    if not ENABLE_TEXTDRAWS then return end
    text = convert_money_tags(text)
    return {id, text}
end