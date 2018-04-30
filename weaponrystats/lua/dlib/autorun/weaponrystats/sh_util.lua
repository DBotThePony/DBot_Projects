
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

local function checkup(self)
	local status = true

	if self.Primary and self.__wpClipSizeM ~= self.Primary.ClipSize then
		self.weaponrystats_clipApplied = false
		status = false
	end

	if self.Secondary and self.Secondary.ClipSize > 0 and self.__wpClipSize2M ~= self.Secondary.ClipSize then
		self.weaponrystats_clipApplied = false
		status = false
	end

	return status
end

function weaponMeta:ApplyClipModifications()
	if not weaponrystats.ENABLED:GetBool() then return end
	if self.IsTFA and self:IsTFA() then return end -- no.
	local self2 = self
	local self = self2:GetTable()
	if not self.Primary and not self.Secondary then return end
	if self.weaponrystats_clipApplied and checkup(self) then return end
	local modif, wtype = self2:GetWeaponModification(), self2:GetWeaponType()
	if not modif or not wtype then return end
	self.weaponrystats_clipApplied = true
	local shouldBeAutomatic = modif.speed * wtype.speed >= 1.3

	if self.Primary and self.Primary.ClipSize and self.Primary.ClipSize > 0 then
		self.__wpClipSize = self.Primary.ClipSize
		self.Primary.ClipSize = math.ceil(self.Primary.ClipSize * modif.clip * wtype.clip):max(1)
		self2:SetClip1(self.Primary.ClipSize)
		self.__wpClipSizeM = self.Primary.ClipSize
		self.Primary.Automatic = self.Primary.Automatic or shouldBeAutomatic
	end

	if self.Secondary and self.Secondary.ClipSize and self.Secondary.ClipSize > 0 then
		self.__wpClipSize2 = self.Secondary.ClipSize
		self.Secondary.ClipSize = math.ceil(self.Secondary.ClipSize * modif.clip * wtype.clip):max(1)
		self2:SetClip2(self.Secondary.ClipSize)
		self.__wpClipSize2M = self.Secondary.ClipSize
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
