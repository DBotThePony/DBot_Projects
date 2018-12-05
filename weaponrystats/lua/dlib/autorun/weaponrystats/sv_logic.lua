
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
local IN_DAMAGE = false

local function EntityTakeDamage(self, dmginfo)
	if not weaponrystats.ENABLED:GetBool() then return end
	if IN_DAMAGE then return end
	local weapon, attacker = DLib.combat.findWeapon(dmginfo)
	if not IsValid(weapon) then return end
	if weapon.weaponrystats_bullets == CurTimeL() then return end
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
		weapon.wps_dps = weapon.wps_dps or DLib.Collector(200, 1)
		local avg = weapon.wps_dps
		avg.lastSend = avg.lastSend or 0

		if wtype and wtype.isAdditional then
			avg:add(dmginfo:GetDamage() + dmginfo:GetDamage() * (wtype.damage or 1))
		else
			avg:add(dmginfo:GetDamage())
		end

		if avg.lastSend < CurTimeL() then
			avg.lastSend = CurTimeL() + 0.2
		end

		weapon:SetNWString('wps_dps', math.ceil(avg:calculate()))
	end
end

weaponrystats.EntityTakeDamage = EntityTakeDamage

hook.Add('EntityTakeDamage', 'WeaponryStats.EntityTakeDamage', EntityTakeDamage)
