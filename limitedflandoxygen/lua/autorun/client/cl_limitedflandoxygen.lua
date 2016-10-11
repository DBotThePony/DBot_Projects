
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
local Oxygen = 100
local UseDHUD2 = DHUD2 ~= nil

surface.CreateFont('DBot_LimitedFlashlightAndOxygen', {
	font = 'Roboto',
	size = 14,
	weight = 500,
})

net.Receive('DBot_LimitedFlashlightAndOxygen', function()
	Oxygen = net.ReadFloat()
	Flashlight = net.ReadFloat()
end)

local X, Y = ScrW() / 2, ScrH() / 2 - 200

if UseDHUD2 then
	DHUD2.DefinePosition('oxygenandflashlight', X, Y)
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
	surface.DrawRect(x - 200, y - 2, 400, 20)
	
	surface.SetDrawColor(200, 200, 0, 150)
	surface.DrawRect(x - 195, y, 390 * Flashlight / 100, 16)
	
	surface.SetTextPos(x - FWidth, y + 2)
	surface.DrawText('Flashlight')
end

local function OxygenFunc()
	local x, y = X, Y
	
	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(x - 200, y - 2, 400, 20)
	
	surface.SetDrawColor(0, 255, 255, 150)
	surface.DrawRect(x - 195, y, 390 * Oxygen / 100, 16)
	
	surface.SetTextPos(x - OWidth / 2, y + 2)
	surface.DrawText('Oxygen')
end

local function HUDPaint()
	surface.SetDrawColor(255, 255, 255)
	surface.SetFont('DBot_LimitedFlashlightAndOxygen')
	surface.SetTextColor(255, 255, 255)
	
	if UseDHUD2 then
		X, Y = DHUD2.GetPosition('oxygenandflashlight')
	end
	
	if Flashlight ~= 100 then
		FlashlightFunc()
	end
	
	if Oxygen ~= 100 then
		OxygenFunc()
	end
end

hook.Add('PostDHUD2Init', 'DBot_LimitedFlashlightAndOxygen', function()
	UseDHUD2 = true
	DHUD2.DefinePosition('oxygenandflashlight', X, Y)
end)

hook.Add('HUDPaint', 'DBot_LimitedFlashlightAndOxygen', HUDPaint)
