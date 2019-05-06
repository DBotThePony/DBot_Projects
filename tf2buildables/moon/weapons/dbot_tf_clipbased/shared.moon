
--
-- Copyright (C) 2017-2019 DBotThePony

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

DEFINE_BASECLASS('dbot_tf_weapon_base')

SWEP.Base = 'dbot_tf_weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'TF2 Reloadable Weapon Base'
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.SlotPos = 16
SWEP.Slot = 3

SWEP.DrawAnimation = 'fj_draw'
SWEP.IdleAnimation = 'fj_idle'
SWEP.AttackAnimation = 'fj_fire'
SWEP.AttackAnimationCrit = 'fj_fire'
SWEP.ReloadStart = 'fj_reload_start'
SWEP.ReloadLoop = 'fj_reload_loop'
SWEP.ReloadEnd = 'fj_reload_end'

SWEP.TakeBulletsOnFire = 1
SWEP.ProjectileClass = 'dbot_tf_rocket_projectile'
SWEP.ReloadBullets = 1
SWEP.ReloadTime = 1
SWEP.ReloadDeployTime = 1
SWEP.ReloadFinishAnimTimeIdle = 1
SWEP.ReloadLoopRestart = true
SWEP.ReloadPlayExtra = false
SWEP.SingleReloadAnimation = false
SWEP.Reloadable = true

SWEP.SetupDataTables = => BaseClass.SetupDataTables(@)

SWEP.Primary = {
	'Ammo': 'SMG1'
	'ClipSize': 40
	'DefaultClip': 160
	'Automatic': true
}

SWEP.Secondary = {
	'Ammo': 'none'
	'ClipSize': -1
	'DefaultClip': 0
	'Automatic': false
}

AccessorFunc(SWEP, 'isReloading', 'IsReloading')
AccessorFunc(SWEP, 'reloadNext', 'NextReload')
AccessorFunc(SWEP, 'm_currentlyreloadable', 'CurrentlyReloadable')

SWEP.Initialize = =>
	BaseClass.Initialize(@)
	@isReloading = false
	@reloadNext = 0
	@SetCurrentlyReloadable(@Reloadable)

SWEP.Reload = =>
	return false if @Clip1() == @GetMaxClip1()
	return false if @isReloading
	return false if @GetNextPrimaryFire() > CurTime()
	return false if @GetOwner()\IsPlayer() and (@Primary.Ammo ~= 'none' and @GetOwner()\GetAmmoCount(@Primary.Ammo) <= 0)
	@isReloading = true
	@reloadNext = CurTime() + @ReloadDeployTime
	@SendWeaponSequence(@ReloadStart)
	@ClearTimeredAnimation()
	return true

SWEP.ReloadCall = =>
	oldClip = @Clip1()
	newClip = math.Clamp(oldClip + @ReloadBullets, 0, @GetMaxClip1())
	if SERVER
		@SetClip1(newClip)
		@GetOwner()\RemoveAmmo(newClip - oldClip, @Primary.Ammo) if @GetOwner()\IsPlayer() and @Primary.Ammo ~= 'none'
	return oldClip, newClip

SWEP.Think = =>
	BaseClass.Think(@)
	if (SERVER or @GetOwner() == LocalPlayer()) and @isReloading and @reloadNext < CurTime()
		if @GetOwner()\IsPlayer() and (@Primary.Ammo == 'none' or @GetOwner()\GetAmmoCount(@Primary.Ammo) > 0)
			@reloadNext = CurTime() + @ReloadTime
			oldClip, newClip = @ReloadCall()
			if not @SingleReloadAnimation
				if @ReloadLoopRestart
					@SendWeaponSequence(@ReloadLoop)
				else
					@SendWeaponSequence(@ReloadLoop) if not @reloadLoopStart
					@reloadLoopStart = true
			if newClip == @GetMaxClip1()
				@isReloading = false
				@reloadLoopStart = false
				if not @SingleReloadAnimation
					if @ReloadLoopRestart
						if @ReloadPlayExtra
							@WaitForSequence(@ReloadLoop, @ReloadTime,
								(-> if IsValid(@) then @WaitForSequence(@ReloadEnd, @ReloadFinishAnimTime,
									(-> if IsValid(@) then @WaitForSequence(@IdleAnimation, @ReloadFinishAnimTimeIdle)))))
						else
							@WaitForSequence(@ReloadEnd, @ReloadFinishAnimTime,
								(-> if IsValid(@) then @WaitForSequence(@IdleAnimation, @ReloadFinishAnimTimeIdle)))
					else
						@WaitForSequence(@ReloadEnd, @ReloadFinishAnimTime, (-> @WaitForSequence(@IdleAnimation, @ReloadFinishAnimTimeIdle) if IsValid(@)))
				else
					@SendWeaponSequence(@IdleAnimation, @ReloadFinishAnimTimeIdle)
		elseif @GetOwner()\IsPlayer() and (@Primary.Ammo ~= 'none' and @GetOwner()\GetAmmoCount(@Primary.Ammo) <= 0) or newClip == @GetMaxClip1()
			@isReloading = false
			@reloadLoopStart = false
			if not @SingleReloadAnimation
				if @ReloadLoopRestart
					@WaitForSequence(@ReloadEnd, @ReloadFinishAnimTime,
						(-> if IsValid(@) then @WaitForSequence(@IdleAnimation, @ReloadFinishAnimTimeIdle)))
				else
					@WaitForSequence(@ReloadEnd, @ReloadFinishAnimTime, (-> @WaitForSequence(@IdleAnimation, @ReloadFinishAnimTimeIdle) if IsValid(@)))
			else
				@SendWeaponSequence(@IdleAnimation, @ReloadFinishAnimTimeIdle)
	@NextThink(CurTime() + 0.1)
	return true

SWEP.Holster = => BaseClass.Holster(@)
SWEP.Deploy = =>
	BaseClass.Deploy(@)
	@isReloading = false
	@lastEmptySound = 0
	return true

SWEP.OnHit = (...) => BaseClass.OnHit(@, ...)
SWEP.OnMiss = => BaseClass.OnMiss(@)

SWEP.PlayEmptySound = =>
	@lastEmptySound = @lastEmptySound or 0
	return if @lastEmptySound > CurTime()
	@lastEmptySound = CurTime() + 1
	return @EmitSound('DTF2_' .. @EmptySoundsScript) if @EmptySoundsScript
	playSound = table.Random(@EmptySounds) if @EmptySounds
	@EmitSound(playSound, 75, 100, .7, CHAN_WEAPON) if playSound

SWEP.PrimaryAttack = =>
	return false if @GetNextPrimaryFire() > CurTime()
	if @Primary.ClipSize > 0
		if @Clip1() <= 0
			@Reload()
			@PlayEmptySound()
			return false
	else
		return false if @GetOwner()\GetAmmoCount(@Primary.Ammo) <= 0

	status = BaseClass.PrimaryAttack(@)
	return status if status == false

	@isReloading = false
	@TakePrimaryAmmo(@TakeBulletsOnFire)

	return true
