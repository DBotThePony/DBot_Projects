
--[[
Copyright (C) 2016-2017 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local Flashlight = 100
local RFlashlight = 100
local Oxygen = 100
local ROxygen = 100

surface.CreateFont('DBot_LimitedFlashlightAndOxygen', {
	font = 'Roboto',
	size = 14,
	weight = 500,
})

net.Receive('DBot_LimitedFlashlightAndOxygen', function()
	ROxygen = net.ReadFloat()
	RFlashlight = net.ReadFloat()
end)

local DEFINED_POSITION = DLib.HUDCommons.DefinePosition('loaf', 0.5, 0.4)

local function GetAddition()
	return DHUD2 and DHUD2.GetDamageShift(3) or 0
end

local OHeight, OWidth, FHeight, FWidth

local function dosizes()
	surface.SetFont('DBot_LimitedFlashlightAndOxygen')
	OHeight, OWidth = surface.GetTextSize('Oxygen')
	FHeight, FWidth = surface.GetTextSize('Flashlight')
end

local function FlashlightFunc()
	if not OHeight then dosizes() end

	local x, y = DEFINED_POSITION()

	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(x - 100 + GetAddition(), y - 2 + GetAddition(), 200, 20)

	surface.SetDrawColor(200, 200, 0, 150)
	surface.DrawRect(x - 95 + GetAddition(), y + GetAddition(), 190 * Flashlight / 100, 16)

	surface.SetTextPos(x - 86 + GetAddition(), y + 1 + GetAddition())
	surface.DrawText('Flashlight')
end

local function OxygenFunc()
	if not OHeight then dosizes() end

	local x, y = DEFINED_POSITION()

	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(x - 100 + GetAddition(), y - 2 + GetAddition() + 25, 200, 20)

	surface.SetDrawColor(0, 255, 255, 150)
	surface.DrawRect(x - 95 + GetAddition(), y + GetAddition() + 25, 190 * Oxygen / 100, 16)

	surface.SetTextPos(x + 60 - OWidth + GetAddition(), y + 1 + GetAddition() + 25)
	surface.DrawText('Oxygen')
end

local function HUDPaint()
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
