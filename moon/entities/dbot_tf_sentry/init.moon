
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

VALID_TARGETS = {}

isEnemy = (ent = NULL) ->
    return false if not ent\IsValid()
    return IsEnemyEntityName(ent\GetClass())

timer.Create 'DTF2.FetchTargets', 0.1, 0, ->
    VALID_TARGETS = for ent in *ents.GetAll()
        continue if not ent\IsNPC()
        continue if not isEnemy(ent)
        {ent, ent\GetPos(), ent\OBBMins(), ent\OBBMaxs(), ent\OBBCenter()}

ENT.MAX_DISTANCE = 512 ^ 2
ENT.Initialize = =>
    @BaseClass.Initialize(@)
    @targetAngle = Angle(0, 0, 0)
    @currentAngle = Angle(0, 0, 0)
    @moveSpeed = 2
    @idleAnim = true
    @idleAngle = Angle(0, 0, 0)
    @idleDirection = false
    @idleYaw = 0
    @center = @OBBCenter()
    @currentTarget = NULL
    @idleWaitOnAngle = 0
    @lastSentryThink = CurTime()
    @nextTargetUpdate = 0
    @lastBulletFire = 0
    @waitSequenceReset = 0
    @SetAmmoAmount(@MAX_AMMO_1)
    @SetHealth(@HealthLevel1)
    @SetMaxHealth(@HealthLevel1)

ENT.HULL_SIZE = 2
ENT.HULL_TRACE_MINS = Vector(-ENT.HULL_SIZE, -ENT.HULL_SIZE, -ENT.HULL_SIZE)
ENT.HULL_TRACE_MAXS = Vector(ENT.HULL_SIZE, ENT.HULL_SIZE, ENT.HULL_SIZE)

ENT.UpdateSequenceList = =>
    @BaseClass.UpdateSequenceList(@)
    @fireSequence = @LookupSequence('fire')

ENT.GetTargetsVisible = =>
    output = {}
    pos = @GetPos()

    for ply in *player.GetAll()
        ppos = ply\GetPos()
        dist = pos\DistToSqr(ppos)
        if ply ~= @GetPlayer() and dist < @MAX_DISTANCE
            table.insert(output, {ply, ppos, dist, ply\OBBCenter()})
    
    for {target, tpos, mins, maxs, center} in *VALID_TARGETS
        dist = pos\DistToSqr(tpos)
        if target\IsValid() and dist < @MAX_DISTANCE
            table.insert(output, {target, tpos, dist, center})
    
    table.sort output, (a, b) -> a[3] < b[3]
    newOutput = {}

    for {target, tpos, dist, center} in *output
        trData = {
            filter: @
            start: @center + pos
            endpos: tpos + center
            mins: @HULL_TRACE_MINS
            maxs: @HULL_TRACE_MAXS
        }

        tr = util.TraceHull(trData)
        if tr.Hit and tr.Entity == target
            table.insert(newOutput, target)

    return newOutput

ENT.GetFirstVisible = =>
    output = {}
    pos = @GetPos()

    for ply in *player.GetAll()
        ppos = ply\GetPos()
        dist = pos\DistToSqr(ppos)
        if ply ~= @GetPlayer() and dist < @MAX_DISTANCE
            table.insert(output, {ply, ppos, dist, ply\WorldSpaceCenter()})
    
    for {target, tpos, mins, maxs, center} in *VALID_TARGETS
        dist = pos\DistToSqr(tpos)
        if target\IsValid() and dist < @MAX_DISTANCE
            table.insert(output, {target, tpos, dist, center})
    
    table.sort output, (a, b) -> a[3] < b[3]

    for {target, tpos, dist, center} in *output
        trData = {
            filter: @
            start: @center + pos
            endpos: tpos + center
            mins: @HULL_TRACE_MINS
            maxs: @HULL_TRACE_MAXS
        }

        tr = util.TraceHull(trData)
        if tr.Hit and tr.Entity == target
            return target

    return NULL

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
        return false
    
    @SetAmmoAmount(@GetAmmoAmount() - 1)
    @EmitSound('weapons/sentry_shoot.wav')
        
    bulletData = {
        Attacker: @
        Callback: @BulletHit
        Damage: @BULLET_DAMAGE
        Dir: @currentAngle\Forward()
        Src: @GetPos() + @obbcenter
    }

    @FireBullets(bulletData)
    if @lastSeq ~= @fireSequence
        @ResetSequence(@fireSequence)
        @lastSeq = @fireSequence
        @waitSequenceReset = CurTime() + 1
    return true

ENT.OnLeaveGround = =>
ENT.OnLandOnGround = =>
ENT.OnStuck = =>
ENT.OnUnStuck = =>
ENT.OnContact = (victim) =>
ENT.OnOtherKilled = (victim, dmg) =>
ENT.OnIgnite = =>
ENT.OnNavAreaChanged = (old, new) =>
ENT.HandleStuck = =>
ENT.MoveToPos = (pos, options) =>

ENT.BehaveStart = =>
ENT.BehaveUpdate = (delta) =>

ENT.BodyUpdate = =>
    @FrameAdvance()

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
    delta = cTime - @lastSentryThink
    @lastSentryThink = cTime
    @BaseClass.Think(@)
    if not @IsAvaliable()
        @currentTarget = NULL
        return
    
    if @nextTargetUpdate < cTime
        @nextTargetUpdate = cTime + 0.1
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
        @idleWaitOnAngle = cTime + 2
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
            @PlayScanSound()
        {:p, :y, :r} = @idleAngle
        @targetAngle = Angle(p, y + @idleYaw, r)
    
    if @lastSeq ~= @idleSequence and @waitSequenceReset < cTime
        @ResetSequence(@idleSequence)
        @lastSeq = @idleSequence
    
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

    if IsValid(@currentTarget)
        lookingAtTarget = math.floor(diffPitch) == 0 and math.floor(diffYaw) == 0
        if lookingAtTarget
            @FireBullet()
    @NextThink(cTime)
    return true
