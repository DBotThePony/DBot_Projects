
--
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


AddCSLuaFile()

SWEP.Base = 'dbot_tf_pistol'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = "Pretty Boy's PocketPistol"
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_pep_pistol/c_pep_pistol.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.CooldownTime = 0.13 * 1.25

if SERVER
	hook.Add 'EntityTakeDamage', 'DTF2.PrettyBoyPistol', (ent, dmg) ->
		attacker = dmg\GetAttacker()
		if IsValid(attacker) and attacker\IsPlayer()
			wep = attacker\GetWeapon('dbot_tf_pep')
			if IsValid(wep)
				with attacker
					hp = \Health()
					mhp = \GetMaxHealth()
					\SetHealth(math.Clamp(hp + 5, 0, mhp)) if hp < mhp
		
		if ent\IsPlayer() and IsValid(ent\GetWeapon('dbot_tf_pep'))
			if dmg\IsFallDamage()
				dmg\SetDamage(0)
				dmg\SetMaxDamage(0)
			else
				dmg\ScaleDamage(1.2)
