
--
-- Copyright (C) 2017-2019 DBot

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
