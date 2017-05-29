
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

include 'shared.lua'
AddCSLuaFile 'shared.lua'

util.AddNetworkString('DTF2.SentryWing')
util.AddNetworkString('DTF2.SentryFire')

ENT.MAX_DISTANCE = 512 ^ 2
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

ENT.HULL_SIZE = 2
ENT.HULL_TRACE_MINS = Vector(-ENT.HULL_SIZE, -ENT.HULL_SIZE, -ENT.HULL_SIZE)
ENT.HULL_TRACE_MAXS = Vector(ENT.HULL_SIZE, ENT.HULL_SIZE, ENT.HULL_SIZE)

ENT.UpdateSequenceList = =>
    @BaseClass.UpdateSequenceList(@)
    @fireSequence = @LookupSequence('fire')
    @muzzle = @LookupAttachment('muzzle')
    @muzzle_l = @LookupAttachment('muzzle_l')
    @muzzle_r = @LookupAttachment('muzzle_r')

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
        @EmitSound('weapons/sentry_empty.wav')
        net.Start('DTF2.SentryFire', true)
        net.WriteEntity(@)
        net.WriteBool(false)
        net.Broadcast()
        return false
    
    @SetAmmoAmount(@GetAmmoAmount() - 1)
    @EmitSound('weapons/sentry_shoot.wav')

    @SetPoseParameter('aim_pitch', @GetAimPitch())
    @SetPoseParameter('aim_yaw', @GetAimYaw())

--     srcPos = @GetPos() + @obbcenter
--     srcAng = @currentAngle\Forward()
-- 
--     switch @GetLevel()
--         when 1
--             with @GetAttachment(@muzzle)
--                 srcPos = .Pos - Vector(0, 0, 10)
--                 srcAng = .Ang\Forward()
--         when 2
--             if @nextMuzzle
--                 with @GetAttachment(@muzzle_l)
--                     srcPos = .Pos
--                     srcAng = .Ang\Forward()
--             else
--                 with @GetAttachment(@muzzle_r)
--                     srcPos = .Pos
--                     srcAng = .Ang\Forward()
--             @nextMuzzle = not @nextMuzzle
--         when 3
--             if @nextMuzzle
--                 with @GetAttachment(@muzzle_l)
--                     srcPos = .Pos
--                     srcAng = .Ang\Forward()
--             else
--                 with @GetAttachment(@muzzle_r)
--                     srcPos = .Pos
--                     srcAng = .Ang\Forward()
--             @nextMuzzle = not @nextMuzzle

    srcPos = @GetPos()
    switch @GetLevel()
        when 1
            srcPos += Vector(0, 0, 16)
    
    bulletData = {
        Attacker: @
        Callback: @BulletHit
        Damage: @BULLET_DAMAGE
        --Dir: srcAng
        --Src: srcPos
        Dir: @currentAngle\Forward()
        Src: srcPos
    }

    @FireBullets(bulletData)
    net.Start('DTF2.SentryFire', true)
    net.WriteEntity(@)
    net.WriteBool(true)
    net.Broadcast()
    return true

ENT.BehaveUpdate = (delta) =>
    cTime = CurTime()
    return if @behavePause > cTime
    if not @IsAvaliable()
        @currentTarget = NULL
        return

    newTarget = @GetFirstVisible()
    if newTarget ~= @currentTarget
        @currentTarget = newTarget
        if IsValid(newTarget)
            net.Start('DTF2.SentryWing', true)
            net.WriteEntity(@)
            net.WriteEntity(newTarget)
            net.Broadcast()

    if IsValid(@currentTarget)
        @currentTargetPosition = @currentTarget\GetPos() + @currentTarget\OBBCenter()
        @idleWaitOnAngle = cTime + 6
        @targetAngle = (@currentTargetPosition - @GetPos() - @obbcenter)\Angle()
        @idleAngle = @targetAngle
        @idleAnim = false
        @idleDirection = false
        @idleYaw = 0
    else
        @idleAnim = true
        if @idleWaitOnAngle < cTime
            @idleAngle = @GetAngles()
        
        @idleYaw += delta * @SENTRY_SCAN_YAW_MULT if @idleDirection
        @idleYaw -= delta * @SENTRY_SCAN_YAW_MULT if not @idleDirection
        if @idleYaw > @SENTRY_SCAN_YAW_CONST or @idleYaw < -@SENTRY_SCAN_YAW_CONST
            @idleDirection = not @idleDirection
            @idlePitch += 2 if @idlePitchDirection
            @idlePitch -= 2 if not @idlePitchDirection
            @idlePitchDirection = not @idlePitchDirection if @idlePitch <= -6 or @idlePitch >= 6
            @PlayScanSound()
        {:p, :y, :r} = @idleAngle
        @targetAngle = Angle(p + @idlePitch, y + @idleYaw, r)
ENT.RunBehaviour = =>

ENT.GetEnemy = => @currentTarget
ENT.Explode = =>
    @Remove()

ENT.OnInjured = (dmg) =>
ENT.OnKilled = (dmg) =>
    hook.Run('OnNPCKilled', @, dmg\GetAttacker(), dmg\GetInflictor())
    @Explode()

ENT.Think = =>
    cTime = CurTime()
    return if @behavePause > cTime
    delta = cTime - @lastSentryThink
    @lastSentryThink = cTime
    @BaseClass.Think(@)
    if not @IsAvaliable()
        @currentTarget = NULL
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

    if IsValid(@currentTarget)
        lookingAtTarget = diffPitch ~= -2 and diffPitch ~= 2 and diffYaw ~= -2 and diffYaw ~= 2
        if lookingAtTarget
            @FireBullet()
