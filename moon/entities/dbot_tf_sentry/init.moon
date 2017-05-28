
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

util.AddNetworkString('DTF2.SentryWing')

VALID_TARGETS = {}

isEnemy = (ent = NULL) ->
    return false if not ent\IsValid()
    return IsEnemyEntityName(ent\GetClass())

timer.Create 'DTF2.FetchTargets', 0.5, 0, ->
    VALID_TARGETS = for ent in *ents.GetAll()
        continue if not ent\IsNPC()
        continue if not isEnemy(ent)
        {ent, ent\GetPos(), ent\OBBMins(), ent\OBBMaxs(), ent\OBBCenter()}

ENT.MAX_DISTANCE = 512 ^ 2
ENT.Initialize = =>
    @BaseClass.Initialize(@)
    @targetAngle = Angle(0, 0, 0)
    @currentAngle = Angle(0, 0, 0)
    @moveSpeed = 0.1
    @idleAnim = true
    @idleAngle = Angle(0, 0, 0)
    @idleDirection = false
    @idleYaw = 0
    @center = @OBBCenter()
    @currentTarget = NULL
    @idleWaitOnAngle = 0
    @lastSentryThink = CurTime()

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
            endpos: center + tpos
        }

        tr = util.TraceLine(trData)
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
            table.insert(output, {ply, ppos, dist, ply\OBBCenter()})
    
    for {target, tpos, mins, maxs, center} in *VALID_TARGETS
        dist = pos\DistToSqr(tpos)
        if target\IsValid() and dist < @MAX_DISTANCE
            table.insert(output, {target, tpos, dist, center})
    
    table.sort output, (a, b) -> a[3] < b[3]

    for {target, tpos, dist, center} in *output
        trData = {
            filter: @
            start: @center + pos
            endpos: center + tpos
        }

        tr = util.TraceLine(trData)
        if tr.Hit and tr.Entity == target
            return target

    return NULL

ENT.Think = =>
    cTime = CurTime()
    delta = cTime - @lastSentryThink
    @lastSentryThink = cTime
    @BaseClass.Think(@)
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
        @idleWaitOnAngle = cTime + 2
        @targetAngle = (@GetPos() - @currentTarget\GetPos())\Angle()
        @idleAngle = @targetAngle
        @idleAnim = false
        @idleDirection = false
        @idleYaw = 0
    else
        @idleAnim = true
        if @idleWaitOnAngle < cTime
            @idleAngle = Angle(0, 0, 0)
        
        @idleYaw += delta if @idleDirection
        @idleYaw -= delta if not @idleDirection
        @idleDirection = not @idleDirection if @idleYaw > 30 or @idleYaw < -30
        {:p, :y, :r} = @idleAngle
        @targetAngle = Angle(p, y + @idleYaw, r)
    @currentAngle = LerpAngle(@moveSpeed, @currentAngle, @targetAngle)
    {:p, :y, :r} = @currentAngle
    @SetPoseParameter('aim_yaw', y)
    @SetPoseParameter('aim_pitch', p)
