
--
-- Copyright (C) 2017-2019 DBotThePony

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.


_G.DTF2 = _G.DTF2 or {}
DTF2 = _G.DTF2

include 'shared.lua'
include 'sv_pickable.lua'
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
	@speedupCache = {}
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
	currentHealthMultiplier = @GetMaxHealth() / @Health()
	currentHealthMultiplier = 1 if currentHealthMultiplier ~= currentHealthMultiplier
	switch val
		when 1
			@RealSetModel(@IdleModel1) if @GetModel() ~= @IdleModel1
			@SetHealth(DTF2.GrabInt(@HealthLevel1) * currentHealthMultiplier)
			@SetMaxHealth(DTF2.GrabInt(@HealthLevel1))
			@UpdateSequenceList()
		when 2
			@RealSetModel(@IdleModel2) if @GetModel() ~= @IdleModel2
			@SetHealth(DTF2.GrabInt(@HealthLevel2) * currentHealthMultiplier)
			@SetMaxHealth(DTF2.GrabInt(@HealthLevel2))
			@UpdateSequenceList()
			@PlayUpgradeAnimation() if playAnimation
		when 3
			@RealSetModel(@IdleModel3) if @GetModel() ~= @IdleModel3
			@SetHealth(DTF2.GrabInt(@HealthLevel3) * currentHealthMultiplier)
			@SetMaxHealth(DTF2.GrabInt(@HealthLevel3))
			@UpdateSequenceList()
			@PlayUpgradeAnimation() if playAnimation
	@CreateBullseye()
	@SetUpgradeAmount(0) if not @GetAfterMove()
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

ENT.DoSpeedup = (time = DTF2.GrabFloat(@SPEEDUP_TIME), index = NULL, strength = DTF2.GrabFloat(@SPEEDUP_MULT)) =>
	return false if not @GetIsBuilding()
	assert(IsValid(index), 'Invalid entity specified as index of speedup')

	@speedupCache[index] = strength
	@CURRENT_SPEEDUP_MULT = 0
	@CURRENT_SPEEDUP_MULT += value for key, value in pairs @speedupCache

	if not @GetAfterMove()
		@SetPlaybackRate(0.5 + 0.5 * @CURRENT_SPEEDUP_MULT)
	else
		@SetPlaybackRate(2 + 0.5 * @CURRENT_SPEEDUP_MULT)

	@SetBuildSpeedup(true)

	timer.Create "DTF2.BuildSpeedup.#{@EntIndex()}.#{index\EntIndex()}", time, 1, ->
		return if not IsValid(@)
		@speedupCache[index] = nil

		@CURRENT_SPEEDUP_MULT = 0
		@CURRENT_SPEEDUP_MULT += value for key, value in pairs @speedupCache

		@SetBuildSpeedup(false) if @CURRENT_SPEEDUP_MULT == 0
		if not @GetAfterMove()
			@SetPlaybackRate(0.5 + 0.5 * @CURRENT_SPEEDUP_MULT)
		else
			@SetPlaybackRate(2 + 0.5 * @CURRENT_SPEEDUP_MULT)

	return true

ENT.SetBuildStatus = (status = false, moved = false) =>
	return false if @GetLevel() > 1
	return false if @GetIsBuilding() == status
	@SetIsBuilding(status)

	if status
		@RealSetModel(@BuildModel1)
		@UpdateSequenceList()
		@SetBuildSpeedup(false)
		timer.Remove("DTF2.BuildSpeedup.#{@EntIndex()}.#{index\EntIndex()}") for index, value in pairs @speedupCache
		@speedupCache = {}
		@StartActivity(ACT_OBJ_PLACING)
		@ResetSequence(@buildSequence)

		@SetBuildStartedAt(CurTime())

		if not moved
			@SetBuildFinishAt(CurTime() + DTF2.GrabFloat(@BuildTime))
			@OnBuildStart()
			@SetPlaybackRate(0.5)
			@SetHealth(1)
		else
			@SetBuildFinishAt(CurTime() + DTF2.GrabFloat(@BuildTime) / 3)
			@SetPlaybackRate(1.5)

		@__targetBuildHelath = @GetMaxHealth()
		@__currentMeanBuildHelath = 1
		@__currentBuildHelathBuffer = 0
	else
		@RealSetModel(@IdleModel1)
		@UpdateSequenceList()
		@ResetSequence(@idleSequence)
		@StartActivity(ACT_OBJ_RUNNING)
		@OnBuildFinish()
		@SetPlaybackRate(1)

	return true

ENT.OnPlayerDoMove = (mover, weapon) =>
ENT.OnMoved = (mover, weapon) =>
