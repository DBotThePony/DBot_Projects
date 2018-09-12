

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

DEFINE_BASECLASS('dbot_tf_bat')

SWEP.Base = 'dbot_tf_bat'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Wrap Assasin'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_xms_giftwrap/c_xms_giftwrap.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.BulletDamage = 35 * .35
SWEP.BallRestoreTime = 15 * .75
SWEP.BallModel = 'models/weapons/c_models/c_xms_festive_ornament.mdl'

SWEP.Unavaliable_DrawAnimation = 'b_draw'
SWEP.Unavaliable_IdleAnimation = 'b_idle'

SWEP.Unavaliable_AttackAnimation = 'b_swing_a'
SWEP.Unavaliable_AttackAnimationTable = {'b_swing_a', 'b_swing_b'}
SWEP.Unavaliable_AttackAnimationCrit = 'b_swing_c'

SWEP.Avaliable_DrawAnimation = 'wb_draw'
SWEP.Avaliable_IdleAnimation = 'wb_idle'

SWEP.Avaliable_AttackAnimation = 'wb_swing_a'
SWEP.Avaliable_AttackAnimationTable = {'wb_swing_a', 'wb_swing_b'}
SWEP.Avaliable_AttackAnimationCrit = 'wb_swing_c'

SWEP.BallThrowAnimation = 'wb_fire'
SWEP.BallThrowAnimationTime = 1.2
SWEP.BallThrowSound = 'DTF2_BallBuster.HitBall'
SWEP.BallThrowSoundTime = 0.1

SWEP.HitSoundsScript = 'BallBuster.HitWorld'
SWEP.HitSoundsFleshScript = 'BallBuster.HitFlesh'

SWEP.BallIsReady = => @GetBallReady() >= @BallRestoreTime

SWEP.CheckAnimations = =>
	if @BallIsReady()
		@DrawAnimation = @Avaliable_DrawAnimation
		@IdleAnimation = @Avaliable_IdleAnimation
		@AttackAnimation = @Avaliable_AttackAnimation
		@AttackAnimationTable = @Avaliable_AttackAnimationTable
		@AttackAnimationCrit = @Avaliable_AttackAnimationCrit
	else
		@DrawAnimation = @Unavaliable_DrawAnimation
		@IdleAnimation = @Unavaliable_IdleAnimation
		@AttackAnimation = @Unavaliable_AttackAnimation
		@AttackAnimationTable = @Unavaliable_AttackAnimationTable
		@AttackAnimationCrit = @Unavaliable_AttackAnimationCrit

SWEP.Deploy = =>
	@BaseClass.Deploy(@)
	@CheckAnimations()

SWEP.PostModelCreated = (...) =>
	@BaseClass.PostModelCreated(@, ...)
	@ballViewModel = ents.Create('dbot_tf_viewmodel')
	with @ballViewModel
		\SetModel(@BallModel)
		\SetPos(@GetPos())
		\Spawn()
		\Activate()
		\DoSetup(@)
	@SetTF2BallModel(@ballViewModel)

SWEP.PostDrawViewModel = (...) =>
	@BaseClass.PostDrawViewModel(@, ...)
	return if not IsValid(@GetTF2BallModel())
	@GetTF2BallModel()\DrawModel()

SWEP.SetupDataTables = =>
	@BaseClass.SetupDataTables(@)
	@NetworkVar('Float', 16, 'BallReady')
	@NetworkVar('Entity', 16, 'TF2BallModel')

SWEP.Initialize = =>
	@BaseClass.Initialize(@)
	@SetBallReady(@BallRestoreTime)
	@lastBallThink = CurTime()
	@lastBallStatus = true

SWEP.Think = =>
	@BaseClass.Think(@)
	if SERVER
		delta = CurTime() - @lastBallThink
		@lastBallThink = CurTime()
		if @GetBallReady() < @BallRestoreTime
			@SetBallReady(math.Clamp(@GetBallReady() + delta, 0, @BallRestoreTime))
	
	old = @lastBallStatus
	newStatus = @BallIsReady()

	if old ~= newStatus
		@lastBallStatus = newStatus
		@CheckAnimations()
		@SendWeaponSequence(@IdleAnimation)
		-- surface.PlaySound() if newStatus

SWEP.DrawHUD = => DTF2.DrawCenteredBar(@GetBallReady() / @BallRestoreTime, 'Ball')

SWEP.SecondaryAttack = =>
	return false if not @BallIsReady()
	incomingCrit = @CheckNextCrit()
	@SetBallReady(0)
	@lastBallStatus = false
	@SendWeaponSequence(@BallThrowAnimation)
	@CheckAnimations()
	@WaitForSequence(@IdleAnimation, @BallThrowAnimationTime)
	@WaitForSoundSuppress(@BallThrowSound, @BallThrowSoundTime)
	return if CLIENT
	timer.Simple 0, ->
		return if not IsValid(@) or not IsValid(@GetOwner())
		ballEntity = ents.Create('dbot_ball_projectile')
		ballEntity\SetPos(@GetOwner()\EyePos())
		ballEntity\Spawn()
		ballEntity\Activate()
		ballEntity\SetIsCritical(incomingCrit)
		ballEntity\SetOwner(@GetOwner())
		ballEntity\SetAttacker(@GetOwner())
		ballEntity\SetInflictor(@)
		ballEntity\SetDirection(@GetOwner()\GetAimVector())
