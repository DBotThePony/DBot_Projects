
-- Copyright (C) 2017 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local weaponrystats = weaponrystats
local addWeaponModification, addWeaponType, checkup, checkupOwner, networkWeapon

function checkupOwner(self)
	if not IsValid(self) then return false end

	if self.weaponrystats_markDirty == nil then
		self.weaponrystats_markDirty = true
	end

	self.weaponrystats_m = self.weaponrystats_m or {}
	self.weaponrystats_t = self.weaponrystats_t or {}

	return true
end

function checkup(self)
	if not IsValid(self) then return false end
	if not checkupOwner(self:GetOwner()) then return false end
	self.weaponrystats_uid = self.weaponrystats_uid or weaponrystats.getWeaponUID(self)
	self.weaponrystats = self.weaponrystats or {}
	return true
end

function addWeaponModification(self)
	if not checkup(self) then return false end
	local owner = self:GetOwner()
	local uid = weaponrystats.getWeaponUID(self)

	local steamid = owner:SteamID()
	local class = self:GetClass()
	local rand = math.ceil(util.SharedRandom(steamid .. class .. '_modification', 1, #weaponrystats.modifications_array, os.time()) - 0.5)
	local modificationKey = weaponrystats.modifications_array[rand] or weaponrystats.modifications_array[rand + 1] or weaponrystats.modifications_array[1]
	self.weaponrystats.modification = weaponrystats.modifications[modificationKey]
	return true
end

function addWeaponType(self)
	if not checkup(self) then return false end
	local owner = self:GetOwner()
	local uid = weaponrystats.getWeaponUID(self)

	local steamid = owner:SteamID()
	local class = self:GetClass()
	local rand = math.floor(util.SharedRandom(steamid .. class .. '_type', 1, #weaponrystats.types_array, os.time()) - 0.5)
	local modificationKey = weaponrystats.types_array[rand] or weaponrystats.types_array[rand + 1] or weaponrystats.types_array[1]
	self.weaponrystats.type = weaponrystats.types[modificationKey]
	return true
end

weaponrystats.addWeaponModification = addWeaponModification
weaponrystats.addWeaponType = addWeaponType
weaponrystats.checkup = checkup
weaponrystats.checkupOwner = checkupOwner

function networkWeapon(self)
	if not checkup(self) then return end
	if self.weaponrystats.modification then self:SetDLibVar('wps_m', self.weaponrystats.modification.crc) end
	if self.weaponrystats.type then self:SetDLibVar('wps_t', self.weaponrystats.type.crc) end
end

local function networkPlayer(self)
	local weapons = self:GetWeapons()
	if not weapons then return end

	for i, weapon in ipairs(weapons) do
		networkWeapon(weapon)
	end
end

local function iterateWeapon(ply, weapon)
	if not checkup(weapon) then return end

	local markDirtyNetwork = false
	local self = weapon.weaponrystats
			
	if not self.modification then
		if addWeaponModification(weapon) then
			ply.weaponrystats_markDirty = true
		end

		markDirtyNetwork = true
	end
	
	if not self.type then
		if addWeaponType(weapon) then
			ply.weaponrystats_markDirty = true
		end

		markDirtyNetwork = true
	end

	return markDirtyNetwork
end

local function iterateWeapons(ply)
	if not IsValid(ply) then return end
	local weapons = ply:GetWeapons()

	if not weapons then return end
	local markDirtyNetwork = false

	for i, weapon in ipairs(weapons) do
		if weapon:IsValid() then
			if iterateWeapon(ply, weapon) then
				markDirtyNetwork = true
			end
		end
	end

	if markDirtyNetwork then
		networkPlayer(ply)
	end
end

weaponrystats.iterateWeapon = iterateWeapon
weaponrystats.iterateWeapons = iterateWeapons
weaponrystats.networkWeapon = networkWeapon

local function PlayerInitialSpawn(self)
	networkPlayer(self)
end

local function PlayerLoadout(self)
	timer.Simple(0, function()
		if not IsValid(self) then return end
		iterateWeapons(self)
		networkPlayer(self)
	end)
end

hook.Add('PlayerLoadout', 'WeaponryStats.Process', PlayerLoadout)

weaponrystats.PlayerInitialSpawn = PlayerInitialSpawn
weaponrystats.PlayerLoadout = PlayerLoadout

timer.Simple(0, function()
	for i, ply in ipairs(player.GetAll()) do
		local weapons = ply:GetWeapons()
		if weapons then
			for i, weapon in ipairs(weapons) do
				weapon.weaponrystats = nil
			end
		end

		PlayerInitialSpawn(ply)
		PlayerLoadout(ply)
	end
end)
