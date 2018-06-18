
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

_G.DTF2 = _G.DTF2 or {}
DTF2 = _G.DTF2

include 'shared.lua'
AddCSLuaFile 'cl_init.lua'

ENT.DuplicatorFunc = =>
	return if not @IsAvaliable()
	@SetLevel(@GetLevel(), false, true)

ENT.Initialize = =>
	@npc_bullseye = {}
	@DrawShadow(false)
	@SetModel(@IdleModel1)
	@SetHealth(@GetMaxHP())
	@SetMaxHealth(@GetMaxHP())
	@mLevel = 1
	@delayGestureRemove = {}

	@PhysicsInitBox(@BuildingMins, @BuildingMaxs)
	@SetMoveType(MOVETYPE_NONE)
	@GetPhysicsObject()\EnableMotion(false)
	@obbcenter = @OBBCenter()
	@SetBloodColor(BLOOD_COLOR_MECH)

	@SetIsBuilding(false)
	@SetnwLevel(1)
	@SetBuildSpeedup(false)
	@lastThink = CurTime()
	@buildSpeedupUntil = 0
	@upgradeFinishAt = 0
	@UpdateSequenceList()
	@StartActivity(ACT_OBJ_RUNNING)
	@CreateBullseye()
	@markedTargets = {}
	@markedAllies = {}
	@nextMarkedRebuild = CurTime() + 60
	timer.Simple 0.1, -> @DuplicatorFunc() if @IsValid()

include 'sv_target.lua'

ENT.RealSetModel = (mdl = @GetModel()) =>
	@SetModel(mdl)
	with @GetPhysicsObject()
		\EnableCollisions(false) if \IsValid()
	@PhysicsInitBox(@BuildingMins, @BuildingMaxs)
	@SetMoveType(MOVETYPE_NONE)

ENT.GetAllies = => [ent for ent in *VALID_ALLIES]
ENT.GetEnemies = => [ent for ent in *VALID_TARGETS]
ENT.GetAlliesTable = => VALID_ALLIES
ENT.GetEnemiesTable = => VALID_TARGETS

include 'sv_logic.lua'
include 'sv_functions.lua'

ENT.SetLevel = (val = 1, playAnimation = @UPGRADE_ANIMS, force = false) =>
	return false if not force and val == @GetLevel()
	val = math.Clamp(math.floor(val), 1, 3)
	@SetnwLevel(val)
	@mLevel = val
	switch val
		when 1
			@RealSetModel(@IdleModel1) if @GetModel() ~= @IdleModel1
			@SetHealth(DTF2.GrabInt(@HealthLevel1)) if @Health() == @GetMaxHealth()
			@SetMaxHealth(DTF2.GrabInt(@HealthLevel1))
			@UpdateSequenceList()
		when 2
			@RealSetModel(@IdleModel2) if @GetModel() ~= @IdleModel2
			@SetHealth(DTF2.GrabInt(@HealthLevel2)) if @Health() == @GetMaxHealth()
			@SetMaxHealth(DTF2.GrabInt(@HealthLevel2))
			@UpdateSequenceList()
			@PlayUpgradeAnimation() if playAnimation
		when 3
			@RealSetModel(@IdleModel3) if @GetModel() ~= @IdleModel3
			@SetHealth(DTF2.GrabInt(@HealthLevel3))
			@SetMaxHealth(DTF2.GrabInt(@HealthLevel3))
			@UpdateSequenceList()
			@PlayUpgradeAnimation() if playAnimation
	@CreateBullseye()
	@SetUpgradeAmount(0)
	return true

ENT.PlayUpgradeAnimation = (playOnModel = @MODEL_UPGRADE_ANIMS) =>
	return false if @GetLevel() == 1
	@SetIsUpgrading(true)
	switch @GetLevel()
		when 2
			@upgradeFinishAt = CurTime() + @UPGRADE_TIME_2
			@RealSetModel(@BuildModel2) if @GetModel() ~= @BuildModel2 and playOnModel
		when 3
			@upgradeFinishAt = CurTime() + @UPGRADE_TIME_3
			@RealSetModel(@BuildModel3) if @GetModel() ~= @BuildModel3 and playOnModel
	@UpdateSequenceList()
	@StartActivity(ACT_OBJ_UPGRADING) if playOnModel
	@ResetSequence(@upgradeSequence) if playOnModel
	return true

ENT.DoSpeedup = (time = DTF2.GrabFloat(@SPEEDUP_TIME), strength = DTF2.GrabFloat(@SPEEDUP_MULT)) =>
	return false if not @GetIsBuilding()
	@SetBuildSpeedup(true)
	@SetPlaybackRate(0.5 + 0.5 * strength)
	@CURRENT_SPEEDUP_MULT = strength
	timer.Create "DTF2.BuildSpeedup.#{@EntIndex()}", time, 1, ->
		return if not IsValid(@)
		@SetBuildSpeedup(false)
		@SetPlaybackRate(0.5)
	return true

ENT.SetBuildStatus = (status = false) =>
	return false if @GetLevel() > 1
	return false if @GetIsBuilding() == status
	@SetIsBuilding(status)
	if status
		@RealSetModel(@BuildModel1)
		@UpdateSequenceList()
		@SetBuildSpeedup(false)
		@StartActivity(ACT_OBJ_PLACING)
		@ResetSequence(@buildSequence)
		@SetBuildFinishAt(CurTime() + DTF2.GrabFloat(@BuildTime))
		@OnBuildStart()
		@SetPlaybackRate(0.5)
		@SetHealth(1)
	else
		@RealSetModel(@IdleModel1)
		@UpdateSequenceList()
		@ResetSequence(@idleSequence)
		@StartActivity(ACT_OBJ_RUNNING)
		@OnBuildFinish()
		@SetPlaybackRate(1)
	return true
