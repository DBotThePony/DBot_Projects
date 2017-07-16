
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

DEFINE_BASECLASS 'dbot_tf_build_base'

include 'shared.lua'
AddCSLuaFile 'shared.lua'

util.AddNetworkString('DTF2.SentryWing')
util.AddNetworkString('DTF2.SentryFire')

ENT.Initialize = =>
    @BaseClass.Initialize(@)
    @targetAngle = Angle(0, 0, 0)
    @currentAngle = Angle(0, 0, 0)
    @moveSpeed = 2
    @idleAnim = true
    @idleAngle = Angle(0, 0, 0)
    @idleDirection = false
    @idlePitchDirection = false
    @idlePitch = 0
    @idleYaw = 0
    @currentTarget = NULL
    @idleWaitOnAngle = 0
    @lastSentryThink = CurTime()
    @nextTargetUpdate = 0
    @lastBulletFire = 0
    @lastRocketsFire = 0
    @waitSequenceReset = 0
    @SetAmmoAmount(@MAX_AMMO_1)
    @SetHealth(@HealthLevel1)
    @SetMaxHealth(@HealthLevel1)
    @fireNext = 0
    @behavePause = 0
    @nextPoseUpdate = 0
    @muzzle = 0
    @muzzle_l = 0
    @muzzle_r = 0
    @nextMuzzle = false
    @UpdateSequenceList()
    @SetRockets(@MAX_ROCKETS)

ENT.HULL_SIZE = 2
ENT.HULL_TRACE_MINS = Vector(-ENT.HULL_SIZE, -ENT.HULL_SIZE, -ENT.HULL_SIZE)
ENT.HULL_TRACE_MAXS = Vector(ENT.HULL_SIZE, ENT.HULL_SIZE, ENT.HULL_SIZE)

ENT.PlayScanSound = =>
    switch @GetLevel()
        when 1
            @EmitSound('weapons/sentry_scan.wav')
        when 2
            @EmitSound('weapons/sentry_scan2.wav')
        when 3
            @EmitSound('weapons/sentry_scan3.wav')

ENT.BulletHit = (tr, dmg) =>
    dmg\SetDamage(@BULLET_DAMAGE)

ENT.SetLevel = (val = 1, playAnimation = true) =>
    oldLevel = @GetLevel()
    status = @BaseClass.SetLevel(@, val, playAnimation)
    return status if not status
    switch val
        when 1
            @SetAmmoAmount(@MAX_AMMO_1) if @GetAmmoAmount() == @GetMaxAmmo(oldLevel)
        when 2
            @SetAmmoAmount(@MAX_AMMO_2) if @GetAmmoAmount() == @GetMaxAmmo(oldLevel)
        when 3
            @SetAmmoAmount(@MAX_AMMO_3) if @GetAmmoAmount() == @GetMaxAmmo(oldLevel)
            
    return true

ENT.GetAdditionalVector = =>
    switch @GetLevel()
        when 1
            Vector(0, 0, 16)
        when 2
            Vector(0, 0, 20)
        when 3
            Vector(0, 0, 20)

ENT.FireBullet = (force = false) =>
    return false if @lastBulletFire > CurTime() and not force

    switch @GetLevel()
        when 1
            @lastBulletFire = CurTime() + @BULLET_RELOAD_1
        when 2
            @lastBulletFire = CurTime() + @BULLET_RELOAD_2
        when 3
            @lastBulletFire = CurTime() + @BULLET_RELOAD_3
    
    if @GetAmmoAmount() <= 0 and not force
        net.Start('DTF2.SentryFire', true)
        net.WriteEntity(@)
        net.WriteBool(false)
        net.Broadcast()
        return false
    
    @SetAmmoAmount(@GetAmmoAmount() - 1)

    @SetPoseParameter('aim_pitch', @GetAimPitch())
    @SetPoseParameter('aim_yaw', @GetAimYaw())

    srcPos = @GetPos() + @GetAdditionalVector()
    dir = @currentTargetPosition - srcPos
    dir\Normalize()
    
    bulletData = {
        Attacker: @
        Callback: @BulletHit
        Damage: @BULLET_DAMAGE
        --Dir: srcAng
        --Src: srcPos
        Dir: dir
        Src: srcPos
    }

    @AddGesture(ACT_RANGE_ATTACK1)
    @DelayGestureRemove(ACT_RANGE_ATTACK1, @BULLET_RELOAD_1)

    @FireBullets(bulletData)
    net.Start('DTF2.SentryFire', true)
    net.WriteEntity(@)
    net.WriteBool(true)
    net.Broadcast()
    return true

ENT.FireRocket = (force = false) =>
    return false if @lastRocketsFire > CurTime() and not force
    @lastRocketsFire = CurTime() + @ROCKETS_RELOAD
    
    return false if @GetRockets() <= 0 and not force
    
    @SetRockets(@GetRockets() - 1)

    {:Ang, :Pos} = @GetAttachment(@LookupAttachment('rocket'))
    srcPos = Pos
    dir = (@currentTargetPosition - Pos)
    dir\Normalize()
    @EmitSound(@ROCKET_SOUND, 100)
    rocket = ents.Create('dbot_sentry_rocket')
    rocket\SetPos(Pos)
    rocket.attacker = IsValid(@GetPlayer()) and @GetPlayer() or @
    rocket.vectorDir = dir
    rocket\SetAngles(dir\Angle())
    rocket\Spawn()
    rocket\Activate()
    rocket\SetOwner(@)
    @AddGesture(ACT_RANGE_ATTACK2)
    @DelayGestureRemove(ACT_RANGE_ATTACK2, @ROCKETS_RELOAD_ANIM)
    @DelaySound(1.5, "weapons/sentry_move_short1.wav")
    @DelaySound(1.75, "weapons/sentry_upgrading#{math.random(1, 7)}.wav")
    @DelaySound(2, "weapons/sentry_move_short2.wav")
    return true

ai_disabled = GetConVar('ai_disabled')

ENT.BehaveUpdate = (delta) =>
    return if ai_disabled\GetBool()
    cTime = CurTime()
    return if @behavePause > cTime

    @UpdateRelationships()
    if not @IsAvaliable()
        @currentTarget = NULL
        return

    newTarget = @GetFirstVisible()
    if newTarget ~= @currentTarget
        @currentTarget = newTarget
        @lookingAtTarget = false
        if IsValid(newTarget)
            net.Start('DTF2.SentryWing', true)
            net.WriteEntity(@)
            net.WriteEntity(newTarget)
            net.Broadcast()

    if IsValid(@currentTarget)
        @currentTargetPosition = @currentTarget\WorldSpaceCenter()
        @idleWaitOnAngle = cTime + 6
        @targetAngle = (@currentTargetPosition - @GetPos() - @GetAdditionalVector())\Angle()
        @idleAngle = @targetAngle
        @idleAnim = false
        @idleDirection = false
        @idleYaw = 0
    else
        @lookingAtTarget = false
        @idleAnim = true
        if @idleWaitOnAngle < cTime
            @idleAngle = @GetAngles()
        
        @idleYaw += delta * @SENTRY_SCAN_YAW_MULT if @idleDirection
        @idleYaw -= delta * @SENTRY_SCAN_YAW_MULT if not @idleDirection
        if @idleYaw > @SENTRY_SCAN_YAW_CONST or @idleYaw < -@SENTRY_SCAN_YAW_CONST
            @idleDirection = false if @idleYaw > @SENTRY_SCAN_YAW_CONST
            @idleDirection = true if @idleYaw < -@SENTRY_SCAN_YAW_CONST
            @idlePitch += 2 if @idlePitchDirection
            @idlePitch -= 2 if not @idlePitchDirection
            @idlePitchDirection = not @idlePitchDirection if @idlePitch <= -6 or @idlePitch >= 6
            @PlayScanSound()
        {:p, :y, :r} = @idleAngle
        @targetAngle = Angle(p + @idlePitch, y + @idleYaw, r)

    if IsValid(@currentTarget) and @lookingAtTarget
        @FireBullet()
        @FireRocket() if @GetLevel() == 3

ENT.GetEnemy = => @currentTarget
ENT.Explode = =>
    @Remove()

ENT.OnInjured = (dmg) =>
ENT.OnKilled = (dmg) =>
    hook.Run('OnNPCKilled', @, dmg\GetAttacker(), dmg\GetInflictor())
    @Explode()

ENT.Think = =>
    cTime = CurTime()
    if not @anglesUpdated
        @anglesUpdated = true
        @currentAngle = @GetAngles()
        @targetAngle = @currentAngle
    return if @behavePause > cTime
    delta = cTime - @lastSentryThink
    @lastSentryThink = cTime
    @BaseClass.Think(@)
    if not @IsAvaliable()
        @currentTarget = NULL
        @SetBodygroup(2, 0)
        return
    
    diffPitch = math.Clamp(math.AngleDifference(@currentAngle.p, @targetAngle.p), -2, 2)
    diffYaw = math.Clamp(math.AngleDifference(@currentAngle.y, @targetAngle.y), -2, 2)
    newPitch = @currentAngle.p - diffPitch * delta * @SENTRY_ANGLE_CHANGE_MULT
    newYaw = @currentAngle.y - diffYaw * delta * @SENTRY_ANGLE_CHANGE_MULT
    @currentAngle = Angle(newPitch, newYaw, 0)
    {p: cp, y: cy, r: cr} = @GetAngles()
    posePitch = math.floor(math.NormalizeAngle(cp - newPitch))
    poseYaw = math.floor(math.NormalizeAngle(cy - newYaw))
    
    @SetAimPitch(posePitch)
    @SetAimYaw(poseYaw)

    if @nextPoseUpdate < cTime
        @nextPoseUpdate = cTime + 0.5
        @SetPoseParameter('aim_pitch', @GetAimPitch())
        @SetPoseParameter('aim_yaw', @GetAimYaw())

    @lookingAtTarget = diffPitch ~= -2 and diffPitch ~= 2 and diffYaw ~= -2 and diffYaw ~= 2 and not @idleAnim
