
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
local IN_DAMAGE = false

local function EntityTakeDamage(self, dmginfo)
	if IN_DAMAGE then return end
	local weapon, attacker = DLib.combat.findWeapon(dmginfo)
	if not IsValid(weapon) then return end
	if weapon.weaponrystats_bullets == CurTime() then return end
	local modif, wtype = weapon:GetWeaponModification(), weapon:GetWeaponType()

	if not modif and not wtype then return end

	if wtype then
		if wtype.isAdditional then
			local newDMG = dmginfo:Copy()
			newDMG:SetDamage(dmginfo:GetDamage() * (wtype.damage or 1))
			newDMG:SetMaxDamage(dmginfo:GetMaxDamage() * (wtype.damage or 1))
			newDMG:SetDamageType(wtype.dmgtype)

			IN_DAMAGE = true
			self:TakeDamageInfo(newDMG)
			IN_DAMAGE = false
		else
			dmginfo:SetDamage(dmginfo:GetDamage() * (wtype.damage or 1))
			dmginfo:SetDamageType(bit.bor(dmginfo:GetDamageType(), wtype.dmgtype))
		end
	end

	if modif then
		dmginfo:SetDamage(dmginfo:GetDamage() * (modif.damage or 1))
	end

	if type(attacker) == 'Player' then
		weapon.wps_dps = weapon.wps_dps or DLib.Average(10, 5)
		local avg = weapon.wps_dps
		avg.lastSend = avg.lastSend or 0

		if wtype and wtype.isAdditional then
			avg:add(dmginfo:GetDamage() + dmginfo:GetDamage() * (wtype.damage or 1))
		else
			avg:add(dmginfo:GetDamage())
		end

		if avg.lastSend < CurTime() then
			avg.lastSend = CurTime() + 1
		end

		weapon:SetDLibVar('wps_dps', math.ceil(avg:calculate()))
	end
end

weaponrystats.EntityTakeDamage = EntityTakeDamage

hook.Add('EntityTakeDamage', 'WeaponryStats.EntityTakeDamage', EntityTakeDamage)
