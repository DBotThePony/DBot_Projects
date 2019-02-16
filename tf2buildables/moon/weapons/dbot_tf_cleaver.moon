

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

DEFINE_BASECLASS('dbot_tf_weapon_base')

SWEP.Base = 'dbot_tf_weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Flying Guillotine'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_sd_cleaver/v_sd_cleaver.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.ProjectileRestoreTime = 10

SWEP.IdleAnimation = 'ed_idle'
SWEP.DrawAnimation = 'ed_draw'
SWEP.AttackAnimation = 'ed_throw'
SWEP.AttackAnimationCrit = 'ed_throw'

SWEP.AttackAnimationDuration = 1
SWEP.ProjectileClass = 'dbot_cleaver_projectile'

SWEP.ProjectileIsReady = => @GetProjectileReady() >= @ProjectileRestoreTime
SWEP.PreDrawViewModel = (vm) => @vmModel = vm

SWEP.Primary = {
	'Ammo': 'none'
	'ClipSize': -1
	'DefaultClip': 0
	'Automatic': true
}

SWEP.Secondary = {
	'Ammo': 'none'
	'ClipSize': -1
	'DefaultClip': 0
	'Automatic': false
}

SWEP.SetupDataTables = =>
	BaseClass.SetupDataTables(@)
	@NetworkVar('Float', 16, 'ProjectileReady')
	@NetworkVar('Float', 17, 'HideProjectile') -- fuck singleplayer

SWEP.Initialize = =>
	BaseClass.Initialize(@)
	@SetProjectileReady(@ProjectileRestoreTime)
	@lastProjectileThink = CurTime()
	@lastProjectileStatus = true
	@SetHideProjectile(0)

SWEP.Think = =>
	BaseClass.Think(@)
	if SERVER
		delta = CurTime() - @lastProjectileThink
		@lastProjectileThink = CurTime()
		if @GetProjectileReady() < @ProjectileRestoreTime
			@SetProjectileReady(math.Clamp(@GetProjectileReady() + delta, 0, @ProjectileRestoreTime))

	old = @lastProjectileStatus
	newStatus = @ProjectileIsReady()
	doDraw = not newStatus and @GetHideProjectile() < CurTime()
	@SetHideVM(doDraw)
	@vmModel\SetNoDraw(doDraw) if IsValid(@vmModel)

	if old ~= newStatus
		@lastProjectileStatus = newStatus
		if newStatus
			@SendWeaponSequence(@DrawAnimation)
			@OnProjectileRestored() if @OnProjectileRestored
			@WaitForSequence(@IdleAnimation, @AttackAnimationDuration)

SWEP.DrawHUD = => DTF2.DrawCenteredBar(@GetProjectileReady() / @ProjectileRestoreTime, 'Cleaver')
SWEP.PrimaryAttack = =>
	return false if not @ProjectileIsReady()
	incomingCrit = @CheckNextCrit()
	@SetProjectileReady(0)
	@lastProjectileStatus = false
	@SendWeaponSequence(@AttackAnimation)
	@WaitForSequence(@IdleAnimation, @AttackAnimationDuration)
	@SetHideProjectile(CurTime() + @AttackAnimationDuration)
	return if CLIENT
	timer.Simple 0, ->
		return if not IsValid(@) or not IsValid(@GetOwner())
		with ents.Create(@ProjectileClass)
			\SetPos(@GetOwner()\EyePos())
			\Spawn()
			\Activate()
			\SetIsCritical(incomingCrit)
			\SetOwner(@GetOwner())
			\SetAttacker(@GetOwner())
			\SetInflictor(@)
			\SetDirection(@GetOwner()\GetAimVector())
