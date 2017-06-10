

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

BaseClass = baseclass.Get('dbot_tf_bat')

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
        ballEntity = ents.Create('dbot_ball_projective')
        ballEntity\SetPos(@GetOwner()\EyePos())
        ballEntity\Spawn()
        ballEntity\Activate()
        ballEntity\SetIsCritical(incomingCrit)
        ballEntity\SetOwner(@GetOwner())
        ballEntity\SetAttacker(@GetOwner())
        ballEntity\SetInflictor(@)
        ballEntity\SetDirection(@GetOwner()\GetAimVector())
