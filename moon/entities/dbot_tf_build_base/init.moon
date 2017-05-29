
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

ATTACK_PLAYERS = CreateConVar('dtf2_attack_players', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Sentries attacks players')

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

VALID_TARGETS = {}
VALID_ALLIES = {}

isEnemy = (ent = NULL) ->
    return false if not ent\IsValid()
    return IsEnemyEntityName(ent\GetClass())

hook.Add 'Think', 'DTF2.FetchTagrets', ->
    findEnts = ents.GetAll()
    VALID_TARGETS = {}
    VALID_ALLIES = {}

    for ent in *findEnts
        if ent\IsNPC()
            center = ent\OBBCenter()
            center\Rotate(ent\GetAngles())
            npcData = {ent, ent\GetPos(), ent\OBBMins(), ent\OBBMaxs(), ent\OBBCenter(), center}
            classify = ent\Classify()
            if (classify == CLASS_PLAYER_ALLY or
                classify == CLASS_PLAYER_ALLY_VITAL or
                classify == CLASS_PLAYER_ALLY_VITAL or
                classify == CLASS_CITIZEN_PASSIVE or
                classify == CLASS_HACKED_ROLLERMINE or
                classify == CLASS_EARTH_FAUNA or
                classify == CLASS_VORTIGAUNT or
                classify == CLASS_CITIZEN_REBEL) then
                table.insert(VALID_ALLIES, npcData)
            elseif (classify == CLASS_COMBINE_HUNTER or
                classify == CLASS_SCANNER or
                classify == CLASS_ZOMBIE or
                classify == CLASS_PROTOSNIPER or
                classify == CLASS_STALKER or
                classify == CLASS_MILITARY or
                classify == CLASS_METROPOLICE or
                classify == CLASS_MANHACK or
                classify == CLASS_HEADCRAB or
                classify == CLASS_COMBINE_GUNSHIP or
                classify == CLASS_BARNACLE or
                classify == CLASS_ANTLION or
                classify == CLASS_COMBINE) then
                table.insert(VALID_TARGETS, npcData)
    
    if ATTACK_PLAYERS\GetBool()
        for ent in *player.GetAll()
            center = ent\OBBCenter()
            center\Rotate(ent\GetAngles())
            table.insert(VALID_TARGETS, {ent, ent\GetPos(), ent\OBBMins(), ent\OBBMaxs(), ent\OBBCenter(), center})

include 'shared.lua'
AddCSLuaFile 'shared.lua'

ENT.Initialize = =>
    @DrawShadow(false)
    @SetModel(@IdleModel1)
    @SetHealth(@HealthLevel1)
    @SetMaxHealth(@HealthLevel1)
    @mLevel = 1

    @PhysicsInitBox(@BuildingMins, @BuildingMaxs)
    @SetMoveType(MOVETYPE_NONE)
    @GetPhysicsObject()\EnableMotion(false)
    @obbcenter = @OBBCenter()

    @SetIsBuilding(false)
    @SetnwLevel(1)
    @SetBuildSpeedup(false)
    @lastThink = CurTime()
    @buildSpeedupUntil = 0
    @buildFinishAt = 0
    @upgradeFinishAt = 0
    @UpdateSequenceList()
    @StartActivity(ACT_OBJ_RUNNING)

ENT.GetTargetsVisible = =>
    output = {}
    pos = @GetPos()
    
    for {target, tpos, mins, maxs, center, rotatedCenter} in *VALID_TARGETS
        dist = pos\DistToSqr(tpos)
        if target\IsValid() and dist < @MAX_DISTANCE
            table.insert(output, {target, tpos, dist, rotatedCenter})
    
    table.sort output, (a, b) -> a[3] < b[3]
    newOutput = {}

    for {target, tpos, dist, center} in *output
        trData = {
            filter: @
            start: @obbcenter + pos
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
    
    for {target, tpos, mins, maxs, center, rotatedCenter} in *VALID_TARGETS
        dist = pos\DistToSqr(tpos)
        if target\IsValid() and dist < @MAX_DISTANCE
            table.insert(output, {target, tpos, dist, rotatedCenter})
    
    table.sort output, (a, b) -> a[3] < b[3]

    for {target, tpos, dist, center} in *output
        trData = {
            filter: @
            start: @obbcenter + pos
            endpos: tpos + center
            mins: @HULL_TRACE_MINS
            maxs: @HULL_TRACE_MAXS
        }

        tr = util.TraceHull(trData)
        if tr.Hit and tr.Entity == target
            return target

    return NULL

ENT.SetLevel = (val = 1, playAnimation = true) =>
    return false if val == @GetLevel()
    val = math.Clamp(math.floor(val), 1, 3)
    @SetnwLevel(val)
    @mLevel = val
    switch val
        when 1
            @SetModel(@IdleModel1)
            @SetHealth(@HealthLevel1) if @Health() == @GetMaxHealth()
            @SetMaxHealth(@HealthLevel1)
            @UpdateSequenceList()
        when 2
            @SetModel(@IdleModel2)
            @SetHealth(@HealthLevel2) if @Health() == @GetMaxHealth()
            @SetMaxHealth(@HealthLevel2)
            @UpdateSequenceList()
            @PlayUpgradeAnimation() if playAnimation
        when 3
            @SetModel(@IdleModel3)
            @SetHealth(@HealthLevel3)
            @SetMaxHealth(@HealthLevel3)
            @UpdateSequenceList()
            @PlayUpgradeAnimation() if playAnimation
    return true

ENT.PlayUpgradeAnimation = =>
    return false if @GetLevel() == 1
    @SetIsUpgrading(true)
    switch @GetLevel()
        when 2
            @upgradeFinishAt = CurTime() + @UPGRADE_TIME_2
            @SetModel(@BuildModel2)
        when 3
            @upgradeFinishAt = CurTime() + @UPGRADE_TIME_3
            @SetModel(@BuildModel3)
    @UpdateSequenceList()
    @StartActivity(ACT_OBJ_UPGRADING)
    @ResetSequence(@upgradeSequence)
    return true

ENT.DoSpeedup = (time = 1) =>
    @SetBuildSpeedup(true)
    @SetPlaybackRate(0.5)
    timer.Create "DTF2.BuildSpeedup.#{@EntIndex()}", time, 1, ->
        return if not IsValid(@)
        @SetBuildSpeedup(false)
        @SetPlaybackRate(1)

ENT.SetBuildStatus = (status = false) =>
    return false if @GetLevel() > 1
    return false if @GetIsBuilding() == status
    @SetIsBuilding(status)
    if status
        @SetModel(@BuildModel1)
        @UpdateSequenceList()
        @SetBuildSpeedup(false)
        @StartActivity(ACT_OBJ_PLACING)
        @ResetSequence(@buildSequence)
        @buildFinishAt = CurTime() + @BuildTime
        @OnBuildStart()
        @SetPlaybackRate(0.5)
    else
        @SetModel(@IdleModel1)
        @UpdateSequenceList()
        @ResetSequence(@idleSequence)
        @StartActivity(ACT_OBJ_RUNNING)
        @OnBuildFinish()
        @SetPlaybackRate(1)
    return true

ENT.OnBuildStart = => -- Override
ENT.OnBuildFinish = => -- Override
ENT.OnUpgradeFinish = => -- Override
ENT.BuildThink = => -- Override
ENT.IsAvaliable = => not @GetIsBuilding() and not @GetIsUpgrading()

ENT.Think = =>
    cTime = CurTime()
    delta = cTime - @lastThink
    @lastThink = cTime
    if @GetIsBuilding()
        if @GetBuildSpeedup()
            @buildFinishAt -= delta
        if @buildFinishAt < cTime
            @SetBuildSpeedup(false)
            @SetIsBuilding(false)
            @SetModel(@IdleModel1)
            @UpdateSequenceList()
            @StartActivity(ACT_OBJ_RUNNING)
            @ResetSequence(@idleSequence)
            @OnBuildFinish()
            @SetPlaybackRate(1)
    elseif @GetIsUpgrading()
        if @upgradeFinishAt < cTime
            @SetBuildSpeedup(false)
            @SetIsUpgrading(false)
            switch @GetLevel()
                when 2
                    @SetModel(@IdleModel2)
                when 3
                    @SetModel(@IdleModel3)
            @UpdateSequenceList()
            @StartActivity(ACT_OBJ_RUNNING)
            @ResetSequence(@idleSequence)
            @OnUpgradeFinish()
            