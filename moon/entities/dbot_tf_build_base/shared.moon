
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

ENT.Type = 'nextbot'
ENT.Base = 'base_nextbot'
ENT.IsTF2Building = true

ENT.BuildModel1 = 'models/buildables/dispenser.mdl'
ENT.BuildModel2 = 'models/buildables/dispenser_lvl2.mdl'
ENT.BuildModel3 = 'models/buildables/dispenser_lvl3.mdl'

ENT.IdleModel1 = 'models/buildables/dispenser_light.mdl'
ENT.IdleModel2 = 'models/buildables/dispenser_lvl2_light.mdl'
ENT.IdleModel3 = 'models/buildables/dispenser_lvl3_light.mdl'

ENT.HealthLevel1 = 150
ENT.HealthLevel2 = 180
ENT.HealthLevel3 = 216

ENT.BuildTime = 2

ENT.BuildingMins = Vector(-18, -18, 0)
ENT.BuildingMaxs = Vector(18, 18, 55)

ENT.Author = 'DBot'
ENT.PrintName = 'TF2 Buildable base'
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.IDLE_ANIM = 'ref'
ENT.UPGRADE_TIME_2 = 1.16
ENT.UPGRADE_TIME_3 = 1.16

ENT.REPAIR_HEALTH = 40
ENT.UPGRADE_HIT = 25
ENT.MAX_UPGRADE = 200

ENT.UPGRADE_ANIMS = true
ENT.MODEL_UPGRADE_ANIMS = true

ENT.MAX_DISTANCE = 512 ^ 2

ENT.GetLevel = => @GetnwLevel()

ENT.GibsValue = 15
-- ENT.Gibs = {}
-- ENT.ExplosionSound = 'DTF2_Building_Sentry.Explode'

ENT.GetGibs = =>
    switch type(@Gibs)
        when 'function'
            return @Gibs()
        when 'table'
            return @Gibs
        when 'nil'
            return {}

ENT.SetupDataTables = =>
    @NetworkVar('Bool', 0, 'IsBuilding')
    @NetworkVar('Bool', 2, 'IsUpgrading')
    @NetworkVar('Bool', 1, 'BuildSpeedup')
    @NetworkVar('Bool', 16, 'TeamType')
    @NetworkVar('Bool', 17, 'IsMovable')
    @NetworkVar('Int', 1, 'nwLevel')
    @NetworkVar('Int', 16, 'UpgradeAmount')
    @NetworkVar('Entity', 0, 'TFPlayer')
    @SetIsMovable(false)

ENT.SelectAttacker = => IsValid(@GetTFPlayer()) and @GetTFPlayer() or @

ENT.UpdateSequenceList = =>
    @buildSequence = @LookupSequence('build')
    @upgradeSequence = @LookupSequence('upgrade')
    @idleSequence = @LookupSequence(@IDLE_ANIM)

-- I use different priorities than original TF2 code
-- hehehe

ENT.IsAvaliable = => not @GetIsBuilding() and not @GetIsUpgrading()
ENT.IsAvaliableForRepair = => not @GetIsBuilding() and not @GetIsUpgrading()
ENT.CustomRepair = (thersold = 200, simulate = CLIENT) =>
    return 0 if thersold == 0
    weight = 0
    return weight

ENT.SimulateUpgrade = (thersold = 200, simulate = CLIENT) =>
    return 0 if thersold == 0
    weight = 0
    if @GetLevel() < 3 and @IsAvaliableForRepair()
        upgradeAmount = math.Clamp(math.min(@MAX_UPGRADE - @GetUpgradeAmount(), @UPGRADE_HIT), 0, thersold - weight)
        weight += upgradeAmount if upgradeAmount ~= 0
        @SetUpgradeAmount(@GetUpgradeAmount() + upgradeAmount) if upgradeAmount ~= 0 and not simulate
        @SetLevel(@GetLevel() + 1) if @GetUpgradeAmount() >= @MAX_UPGRADE
    return weight

ENT.SimulateRepair = (thersold = 200, simulate = CLIENT) =>
    return 0 if thersold == 0
    weight = 0
    repairHP = 0
    repairHP = math.Clamp(math.min(@GetMaxHealth() - @Health(), @REPAIR_HEALTH), 0, thersold - weight) if @IsAvaliableForRepair()

    weight += repairHP if repairHP ~= 0 
    @SetHealth(@Health() + repairHP) if repairHP ~= 0 and not simulate
    weight += @CustomRepair(thersold - weight, simulate)
    weight += @SimulateUpgrade(thersold - weight, simulate)
    return weight
