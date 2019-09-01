
-- Copyright (C) 2016-2019 DBot

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

local LONG_JUMPS_POS = DLib.HUDCommons.Position2.DefinePosition('longjumps', 0.7, 0.91, false)
local LONG_JUMPS_POS_FX = DLib.HUDCommons.Position2.DefinePosition('longjumps_fx', 0.8, 0.91, false)
local DASH_COLOR = DLib.HUDCommons.CreateColor('longjumps', 'Long Jumps Ready', 228, 218, 56)
local DASH_RECHARGING_COLOR = DLib.HUDCommons.CreateColor('longjumps_r', 'Long Jumps Recharging', 240, 81, 81)

local DASH_COLOR_FX = DLib.HUDCommons.CreateColor('longjumps_fx', 'Long Jumps Ready (BAHUDFX)', 255, 176, 0)
local DASH_RECHARGING_COLOR_FX = DLib.HUDCommons.CreateColor('longjumps_fx_r', 'Long Jumps Recharging (BAHUDFX)', 185, 45, 45)

local DASH_HEIGHT = 24
local DASH_WIDTH = 5
local DASH_WIDTH2 = 1
local DASH_PADDING_OUTLINE = 1

local ScreenSize = ScreenSize
local surface = surface

local function DrawOutline(x, y)
	local lineWidth = ScreenSize(DASH_WIDTH2):max(1):floor()
	local w, h = ScreenSize(DASH_WIDTH):floor(), ScreenSize(DASH_HEIGHT):floor()
	--local padding = ScreenSize(DASH_PADDING_OUTLINE):max(1):floor()
	local padding = 0

	surface.DrawRect(x - padding, y - padding, w + padding * 2, lineWidth)
	surface.DrawRect(x - padding, y - padding, lineWidth, h + padding * 2)
	surface.DrawRect(x + w + padding, y - padding, lineWidth, h + padding * 2 + 2)
	surface.DrawRect(x - padding, y + h + padding, w + padding * 2, lineWidth)
end

surface.DLibCreateFont('MaxLongJumpsCounter', {
	size = 14,
	font = 'Roboto'
})

local function HUDPaint(inside)
	if not inside and BOREAL_ALYPH_HUD and BOREAL_ALYPH_HUD:IsEnabled() then return end
	local ply = LocalPlayer()
	if not ply:Alive() then return end
	if not ply:IsLongJumpsModuleEquipped() then return end

	local x, y, color, color2

	if inside then
		x, y = LONG_JUMPS_POS_FX()
		color = DASH_COLOR_FX()
		color2 = DASH_RECHARGING_COLOR_FX()
	else
		x, y = LONG_JUMPS_POS()
		color = DASH_COLOR()
		color2 = DASH_RECHARGING_COLOR()
	end

	x, y = x:floor(), y:floor()

	local num = ply:GetMaxLongJumps() - ply:GetLongJumpCount()
	local pr = ply:LongJumpRechargeProgress()
	local w, h = ScreenSize(DASH_WIDTH):floor(), ScreenSize(DASH_HEIGHT):floor()
	local wide = (w + ScreenSize(DASH_WIDTH2):max(1) + ScreenSize(DASH_PADDING_OUTLINE * 4):max(1)):floor()

	if ply:GetMaxLongJumps() < 6 then
		for i = 0, ply:GetMaxLongJumps() - 1 do
			if (i + 1) == num then
				surface.SetDrawColor(color_black)
				DrawOutline(x + i * wide + 1, y + 1)

				surface.SetDrawColor(color2)
				DrawOutline(x + i * wide, y)

				surface.DrawRect(x + i * wide, y + (h * (1 - pr)):ceil(), w, (h * pr):floor())
			elseif i < num then
				surface.SetDrawColor(color_black)
				DrawOutline(x + i * wide + 1, y + 1)

				surface.SetDrawColor(color2)
				DrawOutline(x + i * wide, y)
			else
				surface.SetDrawColor(color_black)
				DrawOutline(x + i * wide + 1, y + 1)

				surface.SetDrawColor(color)
				DrawOutline(x + i * wide, y)

				surface.DrawRect(x + i * wide, y, w, h)
			end
		end
	else
		if num == 0 then
			surface.SetDrawColor(color_black)
			DrawOutline(x + 1, y + 1)

			surface.SetDrawColor(color)
			DrawOutline(x, y)
			surface.DrawRect(x, y, w, h)
		else
			surface.SetDrawColor(color_black)
			DrawOutline(x + 1, y + 1)

			surface.SetDrawColor(color2)
			DrawOutline(x, y)
			surface.DrawRect(x, y + (h * (1 - pr)):ceil(), w, (h * pr):floor())
		end

		surface.SetFont('MaxLongJumpsCounter')

		surface.SetTextColor(color_black)
		surface.SetTextPos(x + wide + 2, y + wide / 2 + 2)
		surface.DrawText('x' .. ply:GetLongJumpCount())

		surface.SetTextColor(color_white)
		surface.SetTextPos(x + wide, y + wide / 2)
		surface.DrawText('x' .. ply:GetLongJumpCount())
	end
end

hook.Add('HUDPaint', 'LimitedHEVJumps', function()
	HUDPaint(false)
end)

timer.Simple(0, function()
	if not BOREAL_ALYPH_HUD then return end

	BOREAL_ALYPH_HUD:AddFXPaintHook('LongJumpsModule', function()
		HUDPaint(true)
	end)
end)
