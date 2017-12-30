
--Pickup History

--[[
Copyright (C) 2016-2018 DBot

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

local ENABLE = CreateConVar('dhud_pickuphistory', '1', FCVAR_ARCHIVE, 'Enable pickup history')
DHUD2.AddConVar('dhud_pickuphistory', 'Enable pickup history', ENABLE)

DHUD2.Pickup = DHUD2.Pickup or {}
local Hist = DHUD2.Pickup
Hist.Weapons = {}
Hist.Ammos = {}
Hist.Items = {}

function Hist.Weapon(wep)
	if not DHUD2.IsEnabled() then return end
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('pickuphistory') then return end

	local c = CurTime()

	table.insert(Hist.Weapons, {
		ent = wep,
		name = wep:GetPrintName(),
		pickup = c,
		fade = c + 7,
		startfade = c + 6,
		shift = 200,
	})

	return true
end

function Hist.Item(str)
	if not DHUD2.IsEnabled() then return end
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('pickuphistory') then return end

	local c = CurTime()

	table.insert(Hist.Items, {
		name = str,
		pickup = c,
		fade = c + 7,
		startfade = c + 6,
		shift = 200,
	})

	return true
end

function Hist.Ammo(id, num)
	if not DHUD2.IsEnabled() then return end
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('pickuphistory') then return end

	local c = CurTime()

	Hist.Ammos[id] = Hist.Ammos[id] or {
		name = id,
		pickup = c,
		fade = c + 7,
		startfade = c + 6,
		shift = 200,
		amount = 0,
		real = 0,
	}

	Hist.Ammos[id].real = Hist.Ammos[id].real + num
	Hist.Ammos[id].fade = c + 7
	Hist.Ammos[id].startfade = c + 6

	return true
end

DHUD2.CreateColor('pickup', 'Pickup History Text', 255, 255, 255, 255)

local WIDTH = 150
DHUD2.DefinePosition('pickup', ScrW() - WIDTH, ScrH() / 2 - 100)

function Hist.Tick()
	if not DHUD2.IsEnabled() then return end
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('pickuphistory') then return end

	local c = CurTime()

	for k, v in pairs(Hist.Weapons) do
		if v.fade < c then
			Hist.Weapons[k] = nil
			continue
		end

		local isFadingOut = v.startfade <= c

		if not isFadingOut then
			v.shift = Lerp(0.3 * DHUD2.Multipler, v.shift, 0)
		else
			local delta = v.fade - c
			v.shift = 200 * (1 - delta)
		end
	end

	for k, v in pairs(Hist.Ammos) do
		if v.fade < c then
			Hist.Ammos[k] = nil
			continue
		end

		local isFadingOut = v.startfade <= c

		if not isFadingOut then
			v.shift = Lerp(0.3 * DHUD2.Multipler, v.shift, 0)
		else
			local delta = v.fade - c
			v.shift = 200 * (1 - delta)
		end

		v.amount = math.ceil(Lerp(0.3 * DHUD2.Multipler, v.amount, v.real))
	end

	for k, v in pairs(Hist.Items) do
		if v.fade < c then
			Hist.Items[k] = nil
			continue
		end

		local isFadingOut = v.startfade <= c

		if not isFadingOut then
			v.shift = Lerp(0.3 * DHUD2.Multipler, v.shift, 0)
		else
			local delta = v.fade - c
			v.shift = 200 * (1 - delta)
		end
	end
end

DHUD2.CreateColor('pickup_ammo', 'Pickup Ammo sign', 150, 255, 255, 255)
DHUD2.CreateColor('pickup_weapon', 'Pickup Ammo sign', 130, 150, 255, 255)
DHUD2.CreateColor('pickup_item', 'Pickup Ammo sign', 180, 150, 230, 255)

function Hist.Draw()
	if not DHUD2.IsEnabled() then return end
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('pickuphistory') then return end

	local ShiftY = 0
	surface.SetFont('DHUD2.Default')

	local x, y = DHUD2.GetPosition('pickup')
	x = x - 20

	local bg = DHUD2.GetColor('bg')
	local ammo = DHUD2.GetColor('pickup_ammo')
	local weapon = DHUD2.GetColor('pickup_weapon')
	local item = DHUD2.GetColor('pickup_item')
	surface.SetTextColor(DHUD2.GetColor('pickup'))

	for k, v in pairs(Hist.Weapons) do
		DLib.HUDCommons.DrawCustomCenteredMatrix(x, y + ShiftY, WIDTH, -24)

		DHUD2.DrawBox(v.shift + DHUD2.GetDamageShift(), DHUD2.GetDamageShift(), WIDTH, 24, bg)
		DHUD2.DrawBox(-24 + v.shift + DHUD2.GetDamageShift(), DHUD2.GetDamageShift(), 24, 24, weapon)
		DHUD2.SimpleText(v.name, nil, 5 + v.shift + DHUD2.GetDamageShift(), 2 + DHUD2.GetDamageShift())
		ShiftY = ShiftY + 24

		DLib.HUDCommons.PopDrawMatrix()
	end

	for k, v in pairs(Hist.Items) do
		DLib.HUDCommons.DrawCustomCenteredMatrix(x, y + ShiftY, WIDTH, -24)

		DHUD2.DrawBox(v.shift + DHUD2.GetDamageShift(), DHUD2.GetDamageShift(), WIDTH, 24, bg)
		DHUD2.DrawBox(-24 + v.shift + DHUD2.GetDamageShift(), DHUD2.GetDamageShift(), 24, 24, item)
		DHUD2.SimpleText('#' .. v.name, nil, 5 + v.shift + DHUD2.GetDamageShift(), 2 + DHUD2.GetDamageShift())
		ShiftY = ShiftY + 24

		DLib.HUDCommons.PopDrawMatrix()
	end

	for k, v in pairs(Hist.Ammos) do
		DLib.HUDCommons.DrawCustomCenteredMatrix(x, y + ShiftY, WIDTH, -24)

		local name = '#' .. v.name .. '_Ammo'
		local w, h = surface.GetTextSize(name)

		DHUD2.DrawBox(v.shift + DHUD2.GetDamageShift(), DHUD2.GetDamageShift(), WIDTH, 24, bg)
		DHUD2.DrawBox(-24 + v.shift + DHUD2.GetDamageShift(), DHUD2.GetDamageShift(), 24, 24, ammo)
		DHUD2.SimpleText(name, nil, 5 + v.shift + DHUD2.GetDamageShift(), 2 + DHUD2.GetDamageShift())

		DHUD2.SimpleText(' (' .. v.amount .. ')', nil, 10 + v.shift + w + DHUD2.GetDamageShift(), 2 + DHUD2.GetDamageShift())

		ShiftY = ShiftY + 24

		DLib.HUDCommons.PopDrawMatrix()
	end

	return true
end

hook.Add('HUDAmmoPickedUp', 'DHUD2.PickupHistory', Hist.Ammo)
hook.Add('HUDItemPickedUp', 'DHUD2.PickupHistory', Hist.Item)
hook.Add('HUDWeaponPickedUp', 'DHUD2.PickupHistory', Hist.Weapon)
hook.Add('HUDDrawPickupHistory', 'DHUD2.PickupHistory', Hist.Draw)

DHUD2.VarHook('PickupHistory', Hist.Tick)
