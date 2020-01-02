
--[[
Copyright (C) 2016-2019 DBotThePony


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

local function TryDrop(ply, weaponArray)
	local weaponArray = weaponArray or GetDroppableWeapons(ply)
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
			ply:RemoveAmmo(ammo1, type1)
			checkedAmmo[type1] = true
		end

		if not checkedAmmo[type2] then
			ammo2 = math.max(ply:GetAmmoCount(type2), 0)
			ply:RemoveAmmo(ammo2, type2)
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
	local weapons = GetDroppableWeapons(ply)

	if #weapons == 0 then
		DarkRP.notify(ply, 1, 4, 'You have no weapons that you can drop!')
		return ''
	end

    ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)

	timer.Simple(1, function()
		if not IsValid(ply) or not ply:Alive() or IsValid(ply:GetObserverTarget()) then return end
		local crate = TryDrop(ply, weapons)
		if not crate then return end
		crate:SetPos(crate:GetPos() + ply:GetAimVector() * 60)
		-- crate:SetOwner(ply)
		-- crate:DropToFloor()
	end)

	return ''
end

timer.Simple(0, function()
	if not DarkRP then return end

	DarkRP.defineChatCommand('dropweapons', Command, 1.5)
	hook.Add('DoPlayerDeath', 'DBot.DeathWeaponCrate', DoPlayerDeath)
end)
