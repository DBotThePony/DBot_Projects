
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

local function GetDroppableWeapons(ply)
	local weaponArray = {}
	local active = ply:GetActiveWeapon()

	for k, weapon in pairs(ply:GetWeapons()) do
		if weapon ~= active then
			local found = true
			if GAMEMODE.Config.restrictdrop then
				found = false

				for k, v in pairs(CustomShipments) do
					if v.entity == weapon:GetClass() then
						found = true
						break
					end
				end
			end

			if found then
				local canDrop = hook.Run('canDropWeapon', ply, weapon)
				if canDrop ~= false then
					table.insert(weaponArray, weapon)
				end
			end
		end
	end

	return weaponArray
end

local function TryDrop(ply)
	local weaponArray = GetDroppableWeapons(ply)

	if #weaponArray == 0 then return end

	local crate = ents.Create('dbot_wcrate')
	crate:SetPos(ply:EyePos())
	crate:Spawn()
	crate:Activate()

	local checkedAmmo = {}

	for k, weapon in ipairs(weaponArray) do
		local w = crate:AddGun(weapon:GetClass())

		local type1 = weapon:GetPrimaryAmmoType()
		local type2 = weapon:GetSecondaryAmmoType()

		local ammo1, ammo2 = 0, 0

		if not checkedAmmo[type1] then
			ammo1 = math.max(ply:GetAmmoCount(type1), 0)
			checkedAmmo[type1] = true
		end

		if not checkedAmmo[type2] then
			ammo2 = math.max(ply:GetAmmoCount(type2), 0)
			checkedAmmo[type2] = true
		end

		local clip1 = math.max(weapon:Clip1(), 0)
		local clip2 = math.max(weapon:Clip2(), 0)

		w.Model = weapon:GetModel()
		w.Clip1 = clip1
		w.Clip2 = clip2
		w.Ammo1 = ammo1
		w.Ammo2 = ammo2
		w.AmmoID1 = type1
		w.AmmoID2 = type2

		weapon:Remove()
	end

	return crate
end

local function DoPlayerDeath(ply)
	if not (GAMEMODE.Config.dropweapondeath or ply.dropWeaponOnDeath) then return end
	TryDrop(ply)
end

local empty = function() end

local function Command(ply)
	if #GetDroppableWeapons(ply) == 0 then
		DarkRP.notify(ply, 1, 4, 'You have no weapons that you can drop!')
		return ''
	end

	umsg.Start("anim_dropitem")
		umsg.Entity(ply)
	umsg.End()

	ply.anim_DroppingItem = true

	timer.Simple(1, function()
		if not IsValid(ply) or not ply:Alive() or ply:GetObserverTarget() then return end
		local crate = TryDrop(ply)
		if not crate then return end
		crate:SetPos(crate:GetPos() + ply:GetAimVector() * 60)
	end)

	return ''
end

timer.Simple(0, function()
	DarkRP.defineChatCommand('dropweapons', Command, 1.5)
	hook.Add('DoPlayerDeath', 'DBot.DeathWeaponCrate', DoPlayerDeath)
end)
