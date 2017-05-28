
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

ENT.Initialize = =>
    @SetModel(@BuildModel1)
    @SetHP(@HealthLevel1)
    @SetMHP(@HealthLevel1)
    @mLevel = 1

    @SetMoveType(MOVETYPE_NONE)
    @PhysicsInitBox(@BuildingMins, @BuildingMaxs)

    @SetIsBuilding(false)
    @SetnwLevel(1)
    @SetBuildSpeedup(false)
    @buildSequence = @LookupSequence('build')
    @upgradeSequence = @LookupSequence('upgrade')
    @idleSequence = @LookupSequence(@IDLE_ANIM)
    @lastThink = CurTime()
    @buildSpeedupUntil = 0
    @buildFinishAt = 0
    @upgradeFinishAt = 0

ENT.GetLevel = => @GetnwLevel()
ENT.SetLevel = (val = 1, playAnimation = true) =>
    val = math.Clamp(math.floor(val), 1, 3)
    @SetnwLevel(val)
    @mLevel = val
    switch val
        when 1
            @SetModel(@BuildModel1)
            @SetHP(@HealthLevel1)
            @SetMHP(@HealthLevel1)
            @buildSequence = @LookupSequence('build')
        when 2
            @SetModel(@BuildModel2)
            @SetHP(@HealthLevel2) if @GetHP() == @GetMHP()
            @SetMHP(@HealthLevel2)
            @upgradeSequence = @LookupSequence('upgrade')
            @PlayUpgradeAnimation() if playAnimation
        when 3
            @SetModel(@BuildModel3)
            @SetHP(@HealthLevel3)
            @SetMHP(@HealthLevel3)
            @upgradeSequence = @LookupSequence('upgrade')
            @PlayUpgradeAnimation() if playAnimation

ENT.PlayUpgradeAnimation = =>
    return false if @GetLevel() == 1
    @SetIsUpgrading(true)
    @ResetSequence(@upgradeSequence)
    switch @GetLevel()
        when 2
            @upgradeFinishAt = CurTime() + @UPGRADE_TIME_2
        when 3
            @upgradeFinishAt = CurTime() + @UPGRADE_TIME_3
    return true

ENT.SetBuildStatus = (status = false) =>
    return false if @GetLevel() > 1
    return false if @GetIsBuilding() == status
    @SetIsBuilding(status)
    if status
        @SetBuildSpeedup(false)
        @buildSpeedupUntil = 0
        @ResetSequence(@buildSequence)
        @buildFinishAt = CurTime() + @BuildTime
        @OnBuildStart()
    else
        @ResetSequence(@idleSequence)
        @OnBuildFinish()
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
        if @buildSpeedupUntil > cTime
            @buildFinishAt -= delta
        if @buildFinishAt < cTime
            @SetBuildSpeedup(false)
            @SetIsBuilding(false)
            @ResetSequence(@idleSequence)
            @OnBuildFinish()
    elseif @GetIsUpgrading()
        if @upgradeFinishAt < cTime
            @SetBuildSpeedup(false)
            @SetIsUpgrading(false)
            @ResetSequence(@idleSequence)
            @OnUpgradeFinish()