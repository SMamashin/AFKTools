local script_name = "AFKTools reloader"
local inicfg = require 'inicfg'
local effil = require 'effil'

local config_path = "AFKTools/afktools.ini"
local last_tg_update_id = 0
local last_vk_ts = 0
local tg_api_domain = "api.telegram.org" 

local function async_request(url)
    local func = effil.thread(function(u)
        local req = require 'requests'
        local ok, response = pcall(req.get, u, {timeout = 4})
        if ok and response.status_code == 200 then
            return response.json()
        end
        return nil
    end)
    return func(url)
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    local cfg = inicfg.load(nil, config_path)
    if not cfg then return end

    if cfg.tgnotf and cfg.tgnotf.token ~= "" then
        async_request(string.format("https://%s/bot%s/deleteWebhook", tg_api_domain, tostring(cfg.tgnotf.token):gsub("%s+", "")))
    end

    sampAddChatMessage("{FCAA4D}[" .. script_name .. "] {FFFFFF}Исправлен и запущен.", -1)

    local tg_runner = nil
    local vk_runner = nil

    while true do
        -- TELEGRAM
        if not tg_runner and cfg.tgnotf and cfg.tgnotf.token ~= "" then
            local token = tostring(cfg.tgnotf.token):gsub("%s+", "")
            local url = string.format("https://%s/bot%s/getUpdates?offset=%d&limit=1", tg_api_domain, token, last_tg_update_id + 1)
            tg_runner = async_request(url)
        end

        if tg_runner and tg_runner:status() == "completed" then
            local data = tg_runner:get()
            if data and data.result then
                for _, update in ipairs(data.result) do
                    last_tg_update_id = update.update_id
                    if update.message and update.message.text then
                        local text = update.message.text:lower()
                        local sender = tostring(update.message.from.id)
                        local target = tostring(cfg.tgnotf.user_id):gsub("%s+", "")
                        if sender == target and text == "!afkreload" then
                            reloadTargetScript("Telegram")
                        end
                    end
                end
            end
            tg_runner = nil
        end

        -- VK
        if not vk_runner and cfg.vknotf and cfg.vknotf.token ~= "" then
            local vk_token = tostring(cfg.vknotf.token):gsub("%s+", "")
            local vk_user = tostring(cfg.vknotf.user_id):gsub("%s+", "")
            local url = string.format("https://api.vk.com/method/messages.getHistory?access_token=%s&peer_id=%s&count=1&v=5.131", vk_token, vk_user)
            vk_runner = async_request(url)
        end

        if vk_runner and vk_runner:status() == "completed" then
            local data = vk_runner:get()
            if data and data.response and data.response.items and data.response.items[1] then
                local msg = data.response.items[1]
                if msg.date > last_vk_ts then
                    last_vk_ts = msg.date
                    if msg.text:lower() == "!afkreload" then
                        reloadTargetScript("VK")
                    end
                end
            end
            vk_runner = nil
        end

        wait(1500) 
    end
end

function reloadTargetScript(source)
    for _, s in ipairs(script.list()) do
        if s.filename:lower() == "afktools.lua" then
            sampAddChatMessage("{FCAA4D}[" .. script_name .. "] {FFFFFF}Релоад из {3399FF}" .. source, -1)
            s:reload()
            return
        end
    end
end