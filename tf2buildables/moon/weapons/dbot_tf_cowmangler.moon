
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

DEFINE_BASECLASS('dbot_tf_rocket_launcher')

SWEP.Base = 'dbot_tf_rocket_launcher'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Soldier'
SWEP.PrintName = 'Cow Mangler 5000'
SWEP.ViewModel = 'models/weapons/c_models/c_soldier_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_drg_cowmangler/c_drg_cowmangler.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.RandomCriticals = false
SWEP.ReloadPlayExtra = true

SWEP.ProjectileClass = 'dbot_tf_cow_rocket'
SWEP.ChargeTime = 2

SWEP.FireSoundsScript = 'Weapon_CowMangler.Single'
SWEP.FireCritSoundsScript = 'Weapon_CowMangler.Single'
SWEP.SingleCharged = 'DTF2_Weapon_CowMangler.SingleCharged'
SWEP.ChargingSound = 'DTF2_Weapon_CowMangler.Charging'
SWEP.ReloadSound = 'DTF2_Weapon_CowMangler.WorldReload'

SWEP.AttackAnimationSuper = 'mangler_fire_super'
SWEP.ReloadStart = 'mangler_reload_start'
SWEP.ReloadLoop = 'mangler_reload_loop'
SWEP.ReloadEnd = 'mangler_reload_finish'

SWEP.ViewModelEffects = {'drg_cow_idle'}

SWEP.Primary = {
	'Ammo': 'none'
	'ClipSize': 4
	'DefaultClip': 4
	'Automatic': true
}

AccessorFunc(SWEP, 'isCharging', 'IsCharging')

SWEP.Initialize = =>
	@BaseClass.Initialize(@)
	@isCharging = false

SWEP.PrimaryAttack = =>
	return false if @isCharging
	return @BaseClass.PrimaryAttack(@)

SWEP.Holster = =>
	return false if @isCharging
	return @BaseClass.Holster(@)

SWEP.SecondaryAttack = =>
	return false if @isCharging
	return false if @Clip1() ~= @GetMaxClip1()
	@SetIsReloading(false)
	@SetIsCharging(true)
	@SendWeaponSequence(@AttackAnimationSuper)
	@SetIncomingFire(true)
	@SetIncomingFireTime(CurTime() + @ChargeTime)
	@EmitSound(@ChargingSound)
	@AddParticle('drg_cow_muzzleflash_charged') if CLIENT
	return true

SWEP.ReloadCall = =>
	SuppressHostEvents(@GetOwner()) if SERVER and @GetOwner()\IsPlayer()
	@EmitSound(@ReloadSound)
	SuppressHostEvents(NULL) if SERVER and @GetOwner()\IsPlayer()
	return @BaseClass.ReloadCall(@)


hook.Add 'SetupMove', 'DTF2.CowMangler', (mv, cmd) =>
	wep = @GetWeapon('dbot_tf_cowmangler')
	return if not IsValid(wep)
	return if not wep.GetIsCharging or not wep\GetIsCharging()
	mv\SetMaxClientSpeed(90)

if CLIENT
	SWEP.FireTrigger = =>
		if @isCharging
			@isCharging = false
			@SetClip1(0)
			@Reload()
			@StopParticle('drg_cow_muzzleflash_charged')
		@BaseClass.FireTrigger(@)
	return

SWEP.OnFireTriggered = (projectile = NULL) =>
	if @isCharging
		@SetClip1(0)
		@EmitSound(@SingleCharged)
		projectile\SetIsMiniCritical(true)
		@isCharging = false
		@Reload()
