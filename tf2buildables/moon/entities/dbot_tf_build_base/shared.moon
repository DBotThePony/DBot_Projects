
--
-- Copyright (C) 2017-2018 DBot
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

ENT.Type = 'nextbot'
ENT.Base = 'base_nextbot'
ENT.IsTF2Building = true

ENT.BuildModel1 = 'models/buildables/dispenser.mdl'
ENT.BuildModel2 = 'models/buildables/dispenser_lvl2.mdl'
ENT.BuildModel3 = 'models/buildables/dispenser_lvl3.mdl'

ENT.IdleModel1 = 'models/buildables/dispenser_light.mdl'
ENT.IdleModel2 = 'models/buildables/dispenser_lvl2_light.mdl'
ENT.IdleModel3 = 'models/buildables/dispenser_lvl3_light.mdl'

ENT.HealthLevel1 = CreateConVar('tf_build_hp1', '150', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Default Max HP for 1 level buildables')
ENT.HealthLevel2 = CreateConVar('tf_build_hp2', '180', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Default Max HP for 2 level buildables')
ENT.HealthLevel3 = CreateConVar('tf_build_hp3', '216', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Default Max HP for 3 level buildables')

ENT.BuildTime = 2

ENT.BuildingMins = Vector(-18, -18, 0)
ENT.BuildingMaxs = Vector(18, 18, 55)

ENT.HULL_TRACE_MINS = Vector(-2, -2, -2)
ENT.HULL_TRACE_MAXS = Vector(2, 2, 2)

ENT.Author = 'DBot'
ENT.PrintName = 'TF2 Buildable base'
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.IDLE_ANIM = 'ref'
ENT.UPGRADE_TIME_2 = 1.16
ENT.UPGRADE_TIME_3 = 1.16

ENT.REPAIR_HEALTH = CreateConVar('tf_build_repair', '40', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Default repair speed for buildables')
ENT.UPGRADE_HIT = CreateConVar('tf_build_upgrade', '25', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Default upgrade speed for buildables')
ENT.MAX_UPGRADE = CreateConVar('tf_build_maxupgrade', '200', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Default max upgrade for buildables')
ENT.SPEEDUP_TIME = CreateConVar('tf_build_speedup', '1.25', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Speedup time when hitting with wrench')
ENT.SPEEDUP_MULT = CreateConVar('tf_build_speedup_mult', '0.35', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Speedup multiplier')
ENT.GetMaxUpgrade = => DTF2.GrabInt(@MAX_UPGRADE)

ENT.UPGRADE_ANIMS = true
ENT.MODEL_UPGRADE_ANIMS = true

ENT.MAX_DISTANCE = 512

ENT.GetLevel = => @GetnwLevel()

ENT.GibsValue = CreateConVar('tf_build_gibs', '15', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Default gibs value for buildables')
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
	@NetworkVar('Float', 0, 'BuildFinishAt')
	@SetIsMovable(false)
	@SetBuildFinishAt(0)

ENT.SelectAttacker = => IsValid(@GetTFPlayer()) and @GetTFPlayer() or @

ENT.UpdateSequenceList = =>
	@buildSequence = @LookupSequence('build')
	@upgradeSequence = @LookupSequence('upgrade')
	@idleSequence = @LookupSequence(@IDLE_ANIM)

-- I use different priorities than original TF2 code
-- hehehe

ENT.GetMaxHP = (level = @GetLevel()) =>
	switch @GetLevel()
		when 1
			DTF2.GrabInt(@HealthLevel1)
		when 2
			DTF2.GrabInt(@HealthLevel2)
		when 3
			DTF2.GrabInt(@HealthLevel3)
		else
			DTF2.GrabInt(@HealthLevel1)

ENT.IsAvaliable = => not @GetIsBuilding() and not @GetIsUpgrading()
ENT.IsAvaliableForRepair = => not @GetIsBuilding() and not @GetIsUpgrading()
ENT.CustomRepair = (thersold = 200, simulate = CLIENT) =>
	return 0 if thersold == 0
	weight = 0
	return weight

ENT.GetBuildingStatus = =>
	if @GetIsBuilding()
		deltaBuild = math.Clamp(@GetBuildFinishAt() - CurTime(), 0, DTF2.GrabFloat(@BuildTime))
		deltaBuildMult = math.Clamp(1 - deltaBuild / DTF2.GrabFloat(@BuildTime), 0, 1)
		return true, deltaBuild, deltaBuildMult
	else
		return false, 0, 1

ENT.SimulateUpgrade = (thersold = 200, simulate = CLIENT) =>
	return 0 if thersold == 0
	weight = 0
	if @GetLevel() < 3 and @IsAvaliableForRepair()
		upgradeAmount = math.Clamp(math.min(DTF2.GrabInt(@MAX_UPGRADE) - @GetUpgradeAmount(), DTF2.GrabInt(@UPGRADE_HIT)), 0, thersold - weight)
		weight += upgradeAmount if upgradeAmount ~= 0
		@SetUpgradeAmount(@GetUpgradeAmount() + upgradeAmount) if upgradeAmount ~= 0 and not simulate
		@SetLevel(@GetLevel() + 1) if @GetUpgradeAmount() >= DTF2.GrabInt(@MAX_UPGRADE)
	return weight

ENT.SimulateRepair = (thersold = 200, simulate = CLIENT) =>
	return 0 if thersold == 0
	weight = 0
	repairHP = 0
	repairHP = math.Clamp(math.min((@GetMaxHealth() - @Health()) * 0.5, DTF2.GrabInt(@REPAIR_HEALTH) * 0.5), 0, thersold - weight) if @IsAvaliableForRepair()

	weight += math.ceil(repairHP) if repairHP ~= 0
	@SetHealth(@Health() + repairHP * 2) if repairHP ~= 0 and not simulate
	weight += @CustomRepair(thersold - weight, simulate)
	weight += @SimulateUpgrade(thersold - weight, simulate)
	return weight
