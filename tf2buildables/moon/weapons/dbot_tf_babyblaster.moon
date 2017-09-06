
--
-- Copyright (C) 2017 DBot
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

DEFINE_BASECLASS('dbot_tf_scattergun')

SWEP.Base = 'dbot_tf_scattergun'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Baby Face Blaster'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_pep_scattergun.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.MaxCharge = 100
SWEP.ChargeDivider = 100
SWEP.ChargeThersold = 30

SWEP.FireSoundsScript = 'Weapon_Brawler_Blaster.Single'
SWEP.FireCritSoundsScript = 'Weapon_Brawler_Blaster.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_Brawler_Blaster.Empty'

SWEP.SetupDataTables = =>
	@BaseClass.SetupDataTables(@)
	@NetworkVar('Int', 16, 'BabyCharge')

SWEP.Primary = {
	'Ammo': 'Buckshot'
	'ClipSize': 4
	'DefaultClip': 4
	'Automatic': true
}

hook.Add 'SetupMove', 'DTF2.BabyFaceBlaster', (mv, cmd) =>
	wep = @GetWeapon('dbot_tf_babyblaster')
	return if not IsValid(wep)
	mult = 1 + (wep\GetBabyCharge() - wep.ChargeThersold) / wep.ChargeDivider
	mv\SetMaxClientSpeed(mv\GetMaxClientSpeed() * mult)
	mv\SetForwardSpeed(mv\GetForwardSpeed() * mult)
	mv\SetSideSpeed(mv\GetSideSpeed() * mult)
	@__babyBlasterSpeed = @GetWalkSpeed()
	@__babyBlasterRSpeed = @GetRunSpeed()
	@SetWalkSpeed(@__babyBlasterSpeed * mult)
	@SetRunSpeed(@__babyBlasterRSpeed * mult)

hook.Add 'FinishMove', 'DTF2.BabyFaceBlaster', (mv, cmd) =>
	if @__babyBlasterSpeed
		@SetWalkSpeed(@__babyBlasterSpeed)
		@__babyBlasterSpeed = nil
	if @__babyBlasterRSpeed
		@SetRunSpeed(@__babyBlasterRSpeed)
		@__babyBlasterRSpeed = nil

if SERVER
	hook.Add 'EntityTakeDamage', 'DTF2.BabyFaceBlaster', (ent, dmg) ->
		return unless ent\IsNPC() or ent\IsPlayer() or ent.Type == 'nextbot'
		if ent\IsPlayer()
			wep = ent\GetWeapon('dbot_tf_babyblaster')
			if IsValid(wep)
				wep\SetBabyCharge(math.Clamp(wep\GetBabyCharge() - math.max(dmg\GetDamage(), 0) * 4, 0, wep.MaxCharge))
		attacker = dmg\GetAttacker()
		if IsValid(attacker) and attacker\IsPlayer()
			wep = attacker\GetWeapon('dbot_tf_babyblaster')
			if IsValid(wep)
				wep\SetBabyCharge(math.min(wep\GetBabyCharge() + math.max(dmg\GetDamage(), 0), wep.MaxCharge))
else
	SWEP.DrawHUD = =>
		DTF2.DrawCenteredBar(@GetBabyCharge() / @MaxCharge, 'Charge')
