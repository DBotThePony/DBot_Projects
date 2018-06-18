
--
-- Copyright (C) 2017-2018 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

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
