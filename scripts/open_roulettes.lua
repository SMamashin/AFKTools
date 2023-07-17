--REQUIRE
require "lib.moonloader"
local   ev          = require 'lib.samp.events'
local   imgui       = require 'imgui'
local   inicfg      = require 'inicfg'
local   encoding    = require("encoding")
encoding.default    = 'CP1251'
u8 = encoding.UTF8


--VARIABLES
local sw, sh = getScreenResolution() 
local active_standart, active_mask, active_platina, active_donate, active_tainik, active_birth = false, false, false, false, false, false
local work = false

local fix = false


local cfg = inicfg.load({
    roulletes = {
        standart = false,
        platina = false,
        mask = false,
        donate = false,
        tainik = false,
        birth = false
    }, 
    wait = {
        time = 5
    }
}, 'opening_roulettes')

if not doesFileExist('opening_roulettes.ini') then
    inicfg.save(cfg, 'opening_roulettes.ini')
end

local checkbox_standart = imgui.ImBool(cfg.roulletes.standart)
local checkbox_donate   = imgui.ImBool(cfg.roulletes.donate)
local checkbox_mask     = imgui.ImBool(cfg.roulletes.mask)
local checkbox_platina  = imgui.ImBool(cfg.roulletes.platina)
local checkbox_tainik   = imgui.ImBool(cfg.roulletes.tainik)
local checkbox_birth    = imgui.ImBool(cfg.roulletes.birth)
local main_window       = imgui.ImBool(false)
local waiting           = imgui.ImBuffer(tostring(cfg.wait.time), 256)

local textdraw = {
    [1] = {_, _, 1000},
    [2] = {_, _, 1000},
    [3] = {_, _, 1000},
    [4] = {_, _, 1000},
    [5] = {_, _, 1000},
    [6] = {_, _, 1000},
} 


function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(80) end

    sampRegisterChatCommand('boxset', 
    function()
        main_window.v = not main_window.v 
        imgui.Process = main_window.v
    end)

    while true do
        wait(0)

        if work then 
            sampSendClickTextdraw(65535)
            wait(355)
            fix = true
            sampSendChat("/donate")
            wait(3000)
            fix = false
            sampSendChat('/invent')
            wait(400)
            for i = 1, 6 do
                if not work then break end
                sampSendClickTextdraw(textdraw[i][1])
                wait(textdraw[i][3])
                sampSendClickTextdraw(textdraw[i][2])
                wait(textdraw[i][3])
            end
            wait(100)
            sampSendClickTextdraw(65535)
            wait(waiting.v*60000)
        end

    end
end

function imgui.TextQuestion(text)
    imgui.TextDisabled(u8'(?)')
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip() 
    end 
end

function imgui.OnDrawFrame()
    if not main_window.v then imgui.Process = false end
    if main_window.v then
    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2 , sh / 2), imgui.Cond.FirsUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(430, 220), imgui.Cond.FirstUseEver)
    imgui.Begin(u8'Сборщик рулеток', main_window, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
    imgui.Checkbox(u8'Стандартный сундук', checkbox_standart)
    if checkbox_standart.v then 
        cfg.roulletes.standart = true
        inicfg.save(cfg, 'opening_roulettes.ini')
    else
        cfg.roulletes.standart = false
        inicfg.save(cfg, 'opening_roulettes.ini')
    end
    imgui.Checkbox(u8'Сундук Илона Маска', checkbox_mask)
    if checkbox_mask.v then 
        cfg.roulletes.mask = true
        inicfg.save(cfg, 'opening_roulettes.ini')
    else
        cfg.roulletes.mask = false
        inicfg.save(cfg, 'opening_roulettes.ini')
    end
    imgui.Checkbox(u8'Платиновый сундук', checkbox_platina)
    if checkbox_platina.v then 
        cfg.roulletes.platina = true
        inicfg.save(cfg, 'opening_roulettes.ini')
    else
        cfg.roulletes.platina = false
        inicfg.save(cfg, 'opening_roulettes.ini')
    end
    imgui.Checkbox(u8'Донатный сундук', checkbox_donate)
    if checkbox_donate.v then 
        cfg.roulletes.donate = true
        inicfg.save(cfg, 'opening_roulettes.ini')
    else
        cfg.roulletes.donate = false
        inicfg.save(cfg, 'opening_roulettes.ini')
    end
    imgui.Checkbox(u8'Тайник Лос-Сантоса', checkbox_tainik)
    if checkbox_tainik.v then 
        cfg.roulletes.tainik = true
        inicfg.save(cfg, 'opening_roulettes.ini')
    else
        cfg.roulletes.tainik = false
        inicfg.save(cfg, 'opening_roulettes.ini')
    end
    imgui.Checkbox(u8'Сундук 8-ой годовщины', checkbox_birth)
    if checkbox_birth.v then 
        cfg.roulletes.birth = true
        inicfg.save(cfg, 'opening_roulettes.ini')
    else
        cfg.roulletes.birth = false
        inicfg.save(cfg, 'opening_roulettes.ini')
    end
    imgui.PushItemWidth(30)
    imgui.InputText(u8"Задержка", waiting, imgui.InputTextFlags.CharsDecimal)
    if waiting.v then
    cfg.wait.time = waiting.v
    inicfg.save(cfg, 'opening_roulettes.ini')
    end
    imgui.SameLine()
    imgui.TextQuestion(u8'Указывается в минутах. Стандартное значение 5 минут.')
    imgui.PopItemWidth()
    imgui.NewLine()
    if work then 
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.96, 0.16, 0.16, 0.85))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.85, 0.12, 0.12, 1.00))
        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.73, 0.11, 0.11, 1.00))
    else
        local colors = imgui.GetStyle().Colors
        local clr = imgui.Col
        imgui.PushStyleColor(imgui.Col.Button, colors[clr.Button] )
        imgui.PushStyleColor(imgui.Col.ButtonHovered, colors[clr.ButtonHovered])
        imgui.PushStyleColor(imgui.Col.ButtonActive, colors[clr.ButtonActive])
    end
    if imgui.Button(u8(work and 'Отключить' or 'Запустить'), imgui.ImVec2(100, 30)) then 
        if work == false then 
            if checkbox_standart.v == false and checkbox_platina.v == false and checkbox_mask.v == false and checkbox_donate.v == false and checkbox_birth.v == false then
                sampAddChatMessage('<<WARNING>> {ffffff}Не выбран ни один сундук для его открытия. Выберите какой сундук открывать.', 0xff0000)
                if waiting.v == '' then sampAddChatMessage('<<WARNING>> {ffffff}Не указана задержка', 0xff0000) end
            elseif waiting.v == '' then sampAddChatMessage('<<WARNING>> {ffffff}Не указана задержка', 0xff0000) 
            else
            work = true
            sampAddChatMessage('<<TURN ON>> {ffffff}Запустил открытие сундуков с задержкой: '..waiting.v..' минут.', 0xaaff00)
            end
        else
            work = false
            sampAddChatMessage('<<DISABLE>> {ffffff}Вы отключили сборщика рулеток.', 0xFA8072)
        end
    end 
    imgui.PopStyleColor(3)
    imgui.End()
    end
end

function ev.onShowTextDraw(id, data)
    if work then
        if checkbox_standart.v and data.modelId == 19918 then textdraw[1][1] = id  end
        if checkbox_platina.v and data.modelId == 1353 then textdraw[2][1] = id  end
        if checkbox_mask.v and data.modelId == 1733 then textdraw[3][1] = id  end
        if checkbox_donate.v and data.modelId == 19613 then textdraw[4][1] = id  end
        if checkbox_birth.v and data.modelId == 2923 then textdraw[5][1] = id  end
        if checkbox_tainik.v and data.modelId == 2887 then textdraw[6][1] = id  end
        if checkbox_birth.v and data.text == 'RUN' then sampSendClickTextdraw(2134) end --
        if checkbox_birth.v and data.text == 'ADD VIP' then sampSendClickTextdraw(2143) end --
        if data.text == 'USE' or data.text == '…CЊO‡’€O‹AЏ’' then 
            textdraw[1][2] = id + 1
            textdraw[2][2] = id + 1
            textdraw[3][2] = id + 1
            textdraw[4][2] = id + 1
            textdraw[5][2] = id + 1 
            textdraw[6][2] = id + 1
        end
    end
end

function ev.onShowDialog(dialogId, style, title, b1, b2, text)
    if fix and text:find("Курс пополнения счета") then
		sampSendDialogResponse(dialogId, 0, 0, "")
		sampAddChatMessage("{ffffff} inventory {ff0000}fixed{ffffff}!",-1)   
		return false
	end
    if dialogId == 0 and text:find('{ff0000}К сожалению сундук сейчас открыть не получится') and work then
        work = false
        main_window.v = false
        sampAddChatMessage('<<WARNING>> {ffffff}Вы зашли без лаунчера/обхода, открытие рулеток невозможно!', 0xff0000)
    end
    if dialogId == 0 and text:find('Удача!') then 
        sampAddChatMessage('[INFORMATION] {FFFFFF}Использовав сундук с рулетками, вам выпало {FF9A00}х4 пополнение счета.', 0x0DFF00)
        sampSendDialogResponse(id, 0, _, _)
        return false
    end
    if dialogId == 0 and text:find('Граффити') then 
        sampSendDialogResponse(id, 0, _, _)
        return false
    end
    if dialogId == 0 and text:find('Вы выиграли') then 
        sampSendDialogResponse(id, 0, _, _)
        return false
    end
end
function ev.onServerMessage(color,text)
    if checkbox_birth.v then
        if text:find('Вы выиграли') then
            sampSendClickTextdraw(65535)
        end
        if text:find('Крутить рулетку можно 1 раз') then
            sampSendClickTextdraw(65535)
        end
    end
end

function BH_theme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
 
    style.WindowPadding = ImVec2(6, 4)
    style.WindowRounding = 5.0
    style.ChildWindowRounding = 5.0
    style.FramePadding = ImVec2(5, 2)
    style.FrameRounding = 5.0
    style.ItemSpacing = ImVec2(7, 5)
    style.ItemInnerSpacing = ImVec2(1, 1)
    style.TouchExtraPadding = ImVec2(0, 0)
    style.IndentSpacing = 6.0
    style.ScrollbarSize = 12.0
    style.ScrollbarRounding = 5.0
    style.GrabMinSize = 20.0
    style.GrabRounding = 2.0
    style.WindowTitleAlign = ImVec2(0.5, 0.5)

    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.28, 0.30, 0.35, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.16, 0.18, 0.22, 1.00)
    colors[clr.ChildWindowBg]          = ImVec4(0.19, 0.22, 0.26, 1)
    colors[clr.PopupBg]                = ImVec4(0.05, 0.05, 0.10, 0.90)
    colors[clr.Border]                 = ImVec4(0.19, 0.22, 0.26, 1.00)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]                = ImVec4(0.19, 0.22, 0.26, 1.00)
    colors[clr.FrameBgHovered]         = ImVec4(0.22, 0.25, 0.30, 1.00)
    colors[clr.FrameBgActive]          = ImVec4(0.22, 0.25, 0.29, 1.00)
    colors[clr.TitleBg]                = ImVec4(0.19, 0.22, 0.26, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.19, 0.22, 0.26, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.19, 0.22, 0.26, 0.59)
    colors[clr.MenuBarBg]              = ImVec4(0.19, 0.22, 0.26, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.20, 0.25, 0.30, 0.60)
    colors[clr.ScrollbarGrab]          = ImVec4(0.41, 0.55, 0.78, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.49, 0.63, 0.86, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.49, 0.63, 0.86, 1.00)
    colors[clr.ComboBg]                = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.CheckMark]              = ImVec4(0.90, 0.90, 0.90, 0.50)
    colors[clr.SliderGrab]             = ImVec4(1.00, 1.00, 1.00, 0.30)
    colors[clr.SliderGrabActive]       = ImVec4(0.80, 0.50, 0.50, 1.00)
    colors[clr.Button]                 = ImVec4(0.41, 0.55, 0.78, 1.00)
    colors[clr.ButtonHovered]          = ImVec4(0.49, 0.62, 0.85, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.49, 0.62, 0.85, 1.00)
    colors[clr.Header]                 = ImVec4(0.19, 0.22, 0.26, 1.00)
    colors[clr.HeaderHovered]          = ImVec4(0.22, 0.24, 0.28, 1.00)
    colors[clr.HeaderActive]           = ImVec4(0.22, 0.24, 0.28, 1.00)
    colors[clr.Separator]              = ImVec4(0.41, 0.55, 0.78, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.41, 0.55, 0.78, 1.00)
    colors[clr.SeparatorActive]        = ImVec4(0.41, 0.55, 0.78, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.41, 0.55, 0.78, 1.00)
    colors[clr.ResizeGripHovered]      = ImVec4(0.49, 0.61, 0.83, 1.00)
    colors[clr.ResizeGripActive]       = ImVec4(0.49, 0.62, 0.83, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.55, 0.78, 1.00)
    colors[clr.CloseButtonHovered]     = ImVec4(0.50, 0.63, 0.84, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.41, 0.55, 0.78, 1.00)
    colors[clr.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.41, 0.55, 0.78, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.16, 0.18, 0.22, 0.76)
end
BH_theme()
