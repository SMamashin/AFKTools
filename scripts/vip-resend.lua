-- by Cosmo with love <3
local se = require "samp.events"

local text = nil
local attempts = 0
local ad = false

function main()
	repeat wait(0) until isSampAvailable()
	local font = renderCreateFont("Calibri", 12, 9)
	addEventHandler("onD3DPresent", function()
		if (os.clock() - (PREVIOUS_SEND or 0)) <= 1.00 then
			if text ~= nil then text = nil; return end
		end

		if text ~= nil then
			if not sampIsChatInputActive() then
				local input = getStructElement(sampGetInputInfoPtr(), 0x8, 4)
			    local X, Y = getStructElement(input, 0x8, 4) + 10, getStructElement(input, 0xC, 4)
		     	local len = renderGetFontDrawTextLength(font, text)
		     	local hei = renderGetFontDrawHeight(font) + 2

				for i = 1, 3 do
					local proc = select(2, math.modf(os.clock() * 0.7 + 0.33 * i)) * 100
					local a = 255 / 50 * proc; a = a > 255 and 510 - a or a
					renderDrawPolygon(X + (proc / 2), Y, 10, 10, 16, 0, set_alpha(0xFFFFFFFF, a))
				end
	        	renderFontDrawText(font, text, X + 65, Y - hei / 2, -1)
	        	renderFontDrawText(font, string.format("[x%s]", attempts), X + 70 + len, Y - hei / 2, 0x66FFFFFF)
	        end

	        if GLOBAL_TIMER == nil or (os.clock() - GLOBAL_TIMER) > 0.25 then
	        	sampSendChat("/vr " .. text)
	        	GLOBAL_TIMER = os.clock()
	        	attempts = attempts + 1
	        end
	    end
	end)
	wait(-1)
end

function se.onSendCommand(cmd)
	local _ad, _text = cmd:match("^/vr(a?) (.+)")
	if _text ~= nil and text ~= _text then
		if not string.find(_text, "^%s+$") then
			ad = (_ad == "a")
			attempts = 0
			text = _text
			return false
		end
	end
end

function se.onServerMessage(color, text)
	if string.find(text, "[Ошибка] {FFFFFF} После последнего сообщения в этом чате нужно подождать 3 секунды", 1, true) then
		return false
	elseif string.find(text, "[Ошибка] {FFFFFF}Для возможности повторной отправки сообщения в этот чат осталось", 1, true) then
		return false
	end

	if text:find("^Вы заглушены") or text:find("Для возможности повторной отправки сообщения в этот чат") then
		PREVIOUS_SEND = os.clock()
		text = nil
	end
end

function se.onShowDialog(id, style, title, but_1, but_2, text)
	if text ~= nil and string.find(text, "Ваше сообщение является рекламой?") then
		sampSendDialogResponse(id, ad and 1 or 0, nil, nil)
		PREVIOUS_SEND = os.clock()
		text = nil
		return false
	end
end

function set_alpha(color, alpha)
    color = bit.band(color, 0x00ffffff)
    return bit.bor(bit.lshift(alpha, 24), color)
end