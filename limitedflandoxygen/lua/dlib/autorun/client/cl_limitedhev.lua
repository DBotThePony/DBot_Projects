
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

local WATER = CreateConVar('sv_limited_oxygen', '1', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable limited oxygen')
local FLASHLIGHT = CreateConVar('sv_limited_flashlight', '1', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable limited flashlight')

local LocalPlayer = LocalPlayer
local hook = hook
local net = net
local math = math
local Lerp = Lerp
local surface = surface

local FLASHLIGHT_POWER, REAL_FLASHLIGHT_POWER = 100, 100
local SUIT_POWER, REAL_SUIT_POWER = 100, 100

local plyMeta = FindMetaTable('Player')

function plyMeta:LimitedHEVGetPowerFillage()
	if self ~= LocalPlayer() then return 1 end
	return REAL_SUIT_POWER / 100
end

function plyMeta:LimitedHEVGetFlashlightFillage()
	if self ~= LocalPlayer() then return 1 end
	return REAL_FLASHLIGHT_POWER / 100
end

function plyMeta:LimitedHEVGetPower()
	if self ~= LocalPlayer() then return 100 end
	return REAL_SUIT_POWER
end

function __LimitedHev_SetSuitPower(num)
	REAL_SUIT_POWER = num:clamp(0, 100)
end

function plyMeta:LimitedHEVGetFlashlight()
	if self ~= LocalPlayer() then return 100 end
	return REAL_FLASHLIGHT_POWER
end

DLib.RegisterAddonName('Limited HEV')

surface.DLibCreateFont('LimitedHEVPowerFont', {
	font = 'Roboto',
	size = 10,
	weight = 500,
	extended = true,
})

net.Receive('LimitedHEVPower', function()
	REAL_SUIT_POWER = net.ReadFloat()
	REAL_FLASHLIGHT_POWER = net.ReadFloat()
end)

local DEFINED_POSITION = DLib.HUDCommons.Position2.DefinePosition('limitedhev', 0.5, 0.4)
local BAR_WIDTH = 120

local function FlashlightFunc(x, y)
	if not FLASHLIGHT:GetBool() or hook.Run('HUDShouldDraw', 'LimitedHEVFlashlight') == false then return x, y end

	local text = DLib.i18n.localize('gui.hev.flashlight')
	local w, h = surface.GetTextSize(text)
	local bw = ScreenSize(BAR_WIDTH):max(w + 8)
	local padding = ScreenSize(1):max(2)
	local wpadding = ScreenSize(3):max(5)

	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(x - bw / 2 - wpadding, y - padding, bw + wpadding * 2, h + padding * 2)

	surface.SetDrawColor(200, 200, 0, 150)
	surface.DrawRect(x - bw / 2, y, bw * FLASHLIGHT_POWER / 100, h)

	surface.SetTextPos(x - w / 2, y + padding)
	surface.DrawText(text)

	return x, y + h + ScreenSize(4)
end

local function PowerFunc(x, y)
	if not WATER:GetBool() or hook.Run('HUDShouldDraw', 'LimitedHEVPower') == false then return x, y end

	local text = DLib.i18n.localize('gui.hev.power')
	local w, h = surface.GetTextSize(text)
	local bw = ScreenSize(BAR_WIDTH):max(w + 8)
	local padding = ScreenSize(1):max(2)
	local wpadding = ScreenSize(3):max(5)

	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(x - bw / 2 - wpadding, y - padding, bw + wpadding * 2, h + padding * 2)

	surface.SetDrawColor(181, 217, 83, 150)
	surface.DrawRect(x - bw / 2, y, bw * SUIT_POWER / 100, h)

	surface.SetTextPos(x - w / 2, y + padding)
	surface.DrawText(text)

	return x, y + ScreenSize(4)
end

local function HUDPaint()
	if not FLASHLIGHT:GetBool() and not WATER:GetBool() then return end
	if not LocalPlayer():Alive() then return end
	if not LocalPlayer():IsSuitEquipped() then return end

	surface.SetDrawColor(255, 255, 255)
	surface.SetFont('LimitedHEVPowerFont')
	surface.SetTextColor(255, 255, 255)

	local x, y = DEFINED_POSITION()

	if REAL_FLASHLIGHT_POWER ~= 100 then
		x, y = FlashlightFunc(x, y)
	end

	if REAL_SUIT_POWER ~= 100 then
		PowerFunc(x, y)
	end
end

local function Think()
	local ftime = FrameTime() * 22
	FLASHLIGHT_POWER = Lerp(ftime, FLASHLIGHT_POWER, REAL_FLASHLIGHT_POWER)
	SUIT_POWER = Lerp(ftime, SUIT_POWER, REAL_SUIT_POWER)
end

hook.Add('Think', 'LimitedHEVPower', Think)
hook.Add('HUDPaint', 'LimitedHEVPower', HUDPaint)
