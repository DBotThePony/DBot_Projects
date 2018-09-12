
--[[
Copyright (C) 2016-2018 DBot


-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

]]

net.Receive('ULXPP.sin', function()
	local status = net.ReadBool()

	if status then
		local Pos = net.ReadVector()

		hook.Add('Move', 'ULXPP_SIN', function(ply, mv)
			mv:SetOrigin(Pos + Vector(0, 0, math.sin(CurTimeL()) * 50))
			return true
		end)
	else
		hook.Remove('Move', 'ULXPP_SIN')
	end
end)

net.Receive('ULXPP.confuse', function()
	local status = net.ReadBool()

	if status then
		hook.Add('Move', 'ULXPP_CONFUSE', function(ply, mv)
			mv:SetSideSpeed(-mv:GetSideSpeed())
		end)
	else
		hook.Remove('Move', 'ULXPP_CONFUSE')
	end
end)

net.Receive('ULXPP.banish', function()
	ULXPP.BANISHED = net.ReadBool()
end)

net.Receive('ULXPP.coloredmessage', function()
	chat.AddText(net.ReadColor(), net.ReadString())
end)

net.Receive('ULXPP.Chat', function()
	chat.AddText(unpack(net.ReadTable()))
end)

net.Receive('ULXPP.Profile', function()
	for k, ply in pairs(net.ReadTable()) do
		gui.OpenURL('http://steamcommunity.com/profiles/' .. ply:SteamID64())
	end
end)

hook.Add('PostDrawHUD', '!ULXPP.Banish', function()
	if ULXPP.BANISHED then
		surface.SetDrawColor(color_black)
		surface.DrawRect(0, 0, ScrWL(), ScrHL())
		return true
	end
end, -1)

hook.Add('HUDPaint', '!ULXPP.Banish', function()
	if ULXPP.BANISHED then
		surface.SetDrawColor(color_black)
		surface.DrawRect(0, 0, ScrWL(), ScrHL())
		return true
	end
end, -1)

hook.Add('HUDShouldDraw', 'ULXPP.Banish', function(str)
	if not ULXPP.BANISHED then return end
	if str == 'CHudMenu' then return end
	if str == 'CHudChat' then return end
	if str == 'NetGraph' then return end
	if str == 'CHudGMod' then return end

	return false
end)