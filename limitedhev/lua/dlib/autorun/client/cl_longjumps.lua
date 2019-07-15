
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
local DASH_COLOR = DLib.HUDCommons.CreateColor('longjumps', 'Long Jumps Ready', 228, 218, 56)
local DASH_RECHARGING_COLOR = DLib.HUDCommons.CreateColor('longjumps_r', 'Long Jumps Recharging', 240, 81, 81)

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

local function HUDPaint()
	local ply = LocalPlayer()
	if not ply:Alive() then return end
	if not ply:IsLongJumpsModuleEquipped() then return end

	local x, y = LONG_JUMPS_POS()
	x, y = x:floor(), y:floor()
	local color = DASH_COLOR()
	local color2 = DASH_RECHARGING_COLOR()
	local num = ply:LimitedHEVGetMaxJumps() - ply:LimitedHEVGetJumps()
	local pr = ply:LimitedHEVJumpRechargeProgress()
	local w, h = ScreenSize(DASH_WIDTH):floor(), ScreenSize(DASH_HEIGHT):floor()
	local wide = (w + ScreenSize(DASH_WIDTH2):max(1) + ScreenSize(DASH_PADDING_OUTLINE * 4):max(1)):floor()

	if ply:LimitedHEVGetMaxJumps() < 6 then
		for i = 0, ply:LimitedHEVGetMaxJumps() - 1 do
			if (i + 1) == num then
				surface.SetDrawColor(color2)
				DrawOutline(x + i * wide, y)
				surface.DrawRect(x + i * wide, y + (h * (1 - pr)):ceil(), w, (h * pr):floor())
			elseif i < num then
				surface.SetDrawColor(color2)
				DrawOutline(x + i * wide, y)
			else
				surface.SetDrawColor(color)
				DrawOutline(x + i * wide, y)
				surface.DrawRect(x + i * wide, y, w, h)
			end
		end
	end
end

hook.Add('HUDPaint', 'LimitedHEVJumps', HUDPaint)
