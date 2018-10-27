
-- Copyright (C) 2017-2018 DBot

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

function weaponMeta:GetWeaponModification()
	if CLIENT then
		return weaponrystats.modifications_hash[self:GetNW2String('wps_m')]
	else
		return self.weaponrystats and self.weaponrystats.modification
	end
end

function weaponMeta:GetWeaponType()
	if CLIENT then
		return weaponrystats.types_hash[self:GetNW2String('wps_t')]
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
