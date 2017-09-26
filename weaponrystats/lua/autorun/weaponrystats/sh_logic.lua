
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

local function EntityFireBullets(self, bulletData)
	if type(self) ~= 'Weapon' and type(bulletData.Attacker) == 'Player' then return end

	local findWeapon, findOwner

	if type(self) == 'Player' then
		findOwner = self
		findWeapon = self:GetActiveWeapon()
	elseif type(self) == 'Weapon' then
		findWeapon = self
		findOwner = self:GetOwner()
	end

	if not IsValid(findWeapon) or not IsValid(findOwner) then return end
	local modif, wtype = findWeapon:GetWeaponModification(), findWeapon:GetWeaponType()
	if not modif and not wtype then return end
	findWeapon.weaponrystats_bullets = CurTime()

	if wtype then
		local oldCallback = bulletData.Callback

		if wtype.isAdditional then
			function bulletData.Callback(attacker, tr, dmginfo, ...)
				if IsValid(tr.Entity) then
					local newDMG = DamageInfo()
					newDMG:SetAttacker(dmginfo:GetAttacker())
					newDMG:SetInflictor(dmginfo:GetInflictor())
					newDMG:SetDamage(dmginfo:GetDamage() * (wtype.damage or 1))
					newDMG:SetMaxDamage(dmginfo:GetMaxDamage() * (wtype.damage or 1))
					newDMG:SetReportedPosition(dmginfo:GetReportedPosition())
					newDMG:SetDamagePosition(dmginfo:GetDamagePosition())
					newDMG:SetDamageType(wtype.dmgtype)
					tr.Entity:TakeDamageInfo(newDMG)
				end

				if oldCallback then oldCallback(attacker, tr, dmginfo, ...) end
			end
		else
			bulletData.Damage = bulletData.Damage * (wtype.damage or 1)
			bulletData.Force = bulletData.Force * (wtype.force or 1)

			function bulletData.Callback(attacker, tr, dmginfo, ...)
				dmginfo:SetDamageType(wtype.dmgtype)
				if oldCallback then oldCallback(attacker, tr, dmginfo, ...) end
			end
		end
	end

	if modif then
		bulletData.Damage = bulletData.Damage * (modif.damage or 1)
		bulletData.Force = bulletData.Force * (modif.force or 1)
	end

	return true
end

weaponrystats.EntityFireBullets = EntityFireBullets

hook.Add('EntityFireBullets', 'WeaponryStats.EntityFireBullets', EntityFireBullets)
