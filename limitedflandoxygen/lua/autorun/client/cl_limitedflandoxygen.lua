
--[[
Copyright (C) 2016 DBot

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
local UseDHUD2 = DHUD2 ~= nil

local POSITION_X = CreateConVar('cl_limited_posx', '50', {FCVAR_ARCHIVE}, 'Percent of X position on screen for draw')
local POSITION_Y = CreateConVar('cl_limited_posy', '40', {FCVAR_ARCHIVE}, 'Percent of X position on screen for draw')

surface.CreateFont('DBot_LimitedFlashlightAndOxygen', {
	font = 'Roboto',
	size = 14,
	weight = 500,
})

net.Receive('DBot_LimitedFlashlightAndOxygen', function()
	ROxygen = net.ReadFloat()
	RFlashlight = net.ReadFloat()
end)

local X, Y = ScrW() * POSITION_X:GetFloat() / 100, ScrH() * POSITION_Y:GetFloat() / 100

if UseDHUD2 then
	DHUD2.DefinePosition('oxygenandflashlight', X, Y)
end

local function Changed()
	X, Y = ScrW() * POSITION_X:GetFloat() / 100, ScrH() * POSITION_Y:GetFloat() / 100
	
	if UseDHUD2 then
		DHUD2.DefinePosition('oxygenandflashlight', X, Y)
	end
end

cvars.AddChangeCallback('cl_limited_posx', Changed, 'LimitedFLAndOxygen')
cvars.AddChangeCallback('cl_limited_posy', Changed, 'LimitedFLAndOxygen')

local function GetAddition()
	return UseDHUD2 and DHUD2.GetDamageShift(3) or 0
end

local OHeight, OWidth, FHeight, FWidth

timer.Simple(0, function()
	surface.SetFont('DBot_LimitedFlashlightAndOxygen')
	OHeight, OWidth = surface.GetTextSize('Oxygen')
	FHeight, FWidth = surface.GetTextSize('Flashlight')
end)

local function FlashlightFunc()
	local x, y = X, Y + 30
	
	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(x - 100 + GetAddition(), y - 2 + GetAddition(), 200, 20)
	
	surface.SetDrawColor(200, 200, 0, 150)
	surface.DrawRect(x - 95 + GetAddition(), y + GetAddition(), 190 * Flashlight / 100, 16)
	
	surface.SetTextPos(x - FWidth + GetAddition(), y + 2 + GetAddition())
	surface.DrawText('Flashlight')
end

local function OxygenFunc()
	local x, y = X, Y
	
	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(x - 100 + GetAddition(), y - 2 + GetAddition(), 200, 20)
	
	surface.SetDrawColor(0, 255, 255, 150)
	surface.DrawRect(x - 95 + GetAddition(), y + GetAddition(), 190 * Oxygen / 100, 16)
	
	surface.SetTextPos(x - OWidth / 2 + GetAddition(), y + 2 + GetAddition())
	surface.DrawText('Oxygen')
end

local function HUDPaint()
	surface.SetDrawColor(255, 255, 255)
	surface.SetFont('DBot_LimitedFlashlightAndOxygen')
	surface.SetTextColor(255, 255, 255)
	
	if UseDHUD2 then
		X, Y = DHUD2.GetPosition('oxygenandflashlight')
	end
	
	if RFlashlight ~= 100 then
		FlashlightFunc()
	end
	
	if ROxygen ~= 100 then
		OxygenFunc()
	end
end

local function Populate(Panel)
	if not IsValid(Panel) then return end
	Panel:NumSlider('Position X', 'cl_limited_posx', 0, 100, 0)
	Panel:NumSlider('Position Y', 'cl_limited_posy', 0, 100, 0)
end

hook.Add('PopulateToolMenu', 'DBot_LimitedFlashlightAndOxygen', function()
	spawnmenu.AddToolMenuOption('Utilities', 'User', 'DBot_LimitedFlashlightAndOxygen', 'Oxygen/Fl display', '', '', Populate)
end)

hook.Add('PostDHUD2Init', 'DBot_LimitedFlashlightAndOxygen', function()
	UseDHUD2 = true
	DHUD2.DefinePosition('oxygenandflashlight', X, Y)
end)

hook.Add('Think', 'DBot_LimitedFlashlightAndOxygen', function()
	Flashlight = Lerp(0.5, Flashlight, RFlashlight)
	Oxygen = Lerp(0.5, Oxygen, ROxygen)
end)

hook.Add('HUDPaint', 'DBot_LimitedFlashlightAndOxygen', HUDPaint)
