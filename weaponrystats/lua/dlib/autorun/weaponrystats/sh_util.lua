
-- Copyright (C) 2017-2018 DBot

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
local uidCache = {}
local weaponMeta = FindMetaTable('Weapon')

function weaponMeta:ApplyClipModifications()
	if self.weaponrystats_clipApplied then return end
	local modif, wtype = self:GetWeaponModification(), self:GetWeaponType()
	if not modif or not wtype then return end
	self.weaponrystats_clipApplied = true
	local shouldBeAutomatic = modif.speed * wtype.speed >= 1.3

	if self.Primary and self.Primary.ClipSize and self.Primary.ClipSize > 0 then
		self.Primary.ClipSize = math.ceil(self.Primary.ClipSize * modif.clip * wtype.clip)
		self.Primary.Automatic = self.Primary.Automatic or shouldBeAutomatic
	end

	if self.Secondary and self.Secondary.ClipSize and self.Secondary.ClipSize > 0 then
		self.Secondary.ClipSize = math.ceil(self.Secondary.ClipSize * modif.clip * wtype.clip)
		self.Secondary.Automatic = self.Secondary.Automatic or shouldBeAutomatic
	end
end

DLib.nw.pool('wps_m', net.WriteString, net.ReadString, 0)
DLib.nw.pool('wps_t', net.WriteString, net.ReadString, 0)

function weaponMeta:GetWeaponModification()
	if CLIENT then
		return weaponrystats.modifications_hash[self:DLibVar('wps_m')]
	else
		return self.weaponrystats and self.weaponrystats.modification
	end
end

function weaponMeta:GetWeaponType()
	if CLIENT then
		return weaponrystats.types_hash[self:DLibVar('wps_t')]
	else
		return self.weaponrystats and self.weaponrystats.type
	end
end

function weaponrystats.uidToNumber(num)
	return tonumber(num) - 2 ^ 31
end

function weaponrystats.numberToUID(num)
	return tostring(tonumber(num) + 2 ^ 31)
end

function weaponrystats.getWeaponUID(self)
	local class = self:GetClass()

	if not uidCache[class] then
		uidCache[class] = util.CRC(class)
	end

	return uidCache[class]
end

function weaponrystats.getWeaponUIDForSave(self)
	return weaponrystats.uidToNumber(getWeaponUID(self))
end

weaponrystats.NOTIFY_CONSOLE = 0
weaponrystats.NOTIFY_CHAT = 1
weaponrystats.NOTIFY_BOTH = 2

DLib.CMessage(weaponrystats, 'WeaponryStats')
