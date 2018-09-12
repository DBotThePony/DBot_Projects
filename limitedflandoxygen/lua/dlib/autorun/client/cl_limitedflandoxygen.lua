
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

local WATER = CreateConVar('sv_limited_oxygen', '1', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable limited oxygen')
local FLASHLIGHT = CreateConVar('sv_limited_flashlight', '1', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable limited flashlight')

local Flashlight = 100
local RFlashlight = 100
local Oxygen = 100
local ROxygen = 100

DLib.RegisterAddonName('LimitedOxygen&Flashlight')

surface.CreateFont('DBot_LimitedFlashlightAndOxygen', {
	font = 'Roboto',
	size = 14,
	weight = 500,
	extended = true,
})

net.Receive('DBot_LimitedFlashlightAndOxygen', function()
	ROxygen = net.ReadFloat()
	RFlashlight = net.ReadFloat()
end)

local DEFINED_POSITION = DLib.HUDCommons.DefinePosition('loaf', 0.5, 0.4)

local function GetAddition()
	return DHUD2 and DHUD2.GetDamageShift(3) or 0
end

local function FlashlightFunc()
	if not FLASHLIGHT:GetBool() then return end
	local x, y = DEFINED_POSITION()

	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(x - 100 + GetAddition(), y - 2 + GetAddition(), 200, 20)

	surface.SetDrawColor(200, 200, 0, 150)
	surface.DrawRect(x - 95 + GetAddition(), y + GetAddition(), 190 * Flashlight / 100, 16)

	surface.SetTextPos(x - 86 + GetAddition(), y + 1 + GetAddition())
	surface.DrawText(DLib.i18n.localize('gui.breathe.flashlight'))
end

local function OxygenFunc()
	if not WATER:GetBool() then return end
	local x, y = DEFINED_POSITION()

	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(x - 100 + GetAddition(), y - 2 + GetAddition() + 25, 200, 20)

	surface.SetDrawColor(0, 255, 255, 150)
	surface.DrawRect(x - 95 + GetAddition(), y + GetAddition() + 25, 190 * Oxygen / 100, 16)

	local text = DLib.i18n.localize('gui.breathe.oxygen')
	local w, h = surface.GetTextSize(text)
	surface.SetTextPos(x + 90 - w + GetAddition() - 10, y + 25 + GetAddition())
	surface.DrawText(text)
end

local function HUDPaint()
	if not FLASHLIGHT:GetBool() and not WATER:GetBool() then return end
	surface.SetDrawColor(255, 255, 255)
	surface.SetFont('DBot_LimitedFlashlightAndOxygen')
	surface.SetTextColor(255, 255, 255)

	if RFlashlight ~= 100 then
		FlashlightFunc()
	end

	if ROxygen ~= 100 then
		OxygenFunc()
	end
end

hook.Add('Think', 'DBot_LimitedFlashlightAndOxygen', function()
	Flashlight = Lerp(0.5, Flashlight, RFlashlight)
	Oxygen = Lerp(0.5, Oxygen, ROxygen)
end)

hook.Add('HUDPaint', 'DBot_LimitedFlashlightAndOxygen', HUDPaint)
