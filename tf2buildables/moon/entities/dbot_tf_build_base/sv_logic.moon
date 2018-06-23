
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
	cTime = CurTime()
	for data in *@delayGestureRemove
		if data[2] < cTime
			@RemoveGesture(data[1])
	@delayGestureRemove = [data for data in *@delayGestureRemove when data[2] > cTime]

ENT.BodyUpdate = =>
	@FrameAdvance()

ENT.RunBehaviour = =>

ENT.GetEnemy = => @currentTarget

ENT.TriggerDestruction = (trigger = @GetTFPlayer()) =>
	hook.Run 'TF2BuildDestructed', @, trigger
	@Explode()

ENT.CallDestruction = =>

BOOL_OR_FUNC = (val, undef = true, ...) ->
	switch type(val)
		when 'function'
			return val(...)
		when 'nil'
			return undef
		else
			return val

ENT.CheckTarget = (target = NULL) =>
	target\IsValid() and
	not BOOL_OR_FUNC(target.IsDroneDestroyed, false, target) and
	BOOL_OR_FUNC(target.IsDestroyed, true, target) and
	BOOL_OR_FUNC(target.IsWorking, true, target) and
	(target\GetMaxHealth() <= 0 or target\Health() > 0) and
	(BOOL_OR_FUNC(target.GetMaxHP, 0, target) <= 0 or BOOL_OR_FUNC(target.GetHP, 1, target) > 0)

ENT.OnBuildStart = => -- Override
ENT.OnBuildFinish = => -- Override
ENT.OnUpgradeFinish = => -- Override

ENT.Think = =>
	cTime = CurTime()
	delta = cTime - @lastThink
	deltaSpeed = delta
	--deltaSpeed = delta * 3 if @GetAfterMove()
	@lastThink = cTime

	if @nextMarkedRebuild < CurTime()
		@RebuildMarkedList()
		@nextMarkedRebuild = CurTime() + 60
	else
		@UpdateMarkedList()

	isBuild, leftBuild, buildMult = @GetBuildingStatus()

	if isBuild
		if @GetBuildSpeedup()
			@SetBuildFinishAt(@GetBuildFinishAt() - deltaSpeed * @CURRENT_SPEEDUP_MULT)
			isBuild, leftBuild, buildMult = @GetBuildingStatus()

		if not @GetAfterMove()
			newhealth = @GetMaxHealth() * buildMult
			deltaHealth = newhealth - @__currentMeanBuildHelath
			@__currentMeanBuildHelath = newhealth
			@__currentBuildHelathBuffer += deltaHealth

			if @__currentBuildHelathBuffer > 1
				part = @__currentBuildHelathBuffer % 1
				@SetHealth(@Health() + @__currentBuildHelathBuffer - part)
				@__currentBuildHelathBuffer = part

		if leftBuild <= 0
			@SetBuildSpeedup(false)
			@SetIsBuilding(false)
			@RealSetModel(@IdleModel1)
			@UpdateSequenceList()
			@StartActivity(ACT_OBJ_RUNNING)
			@ResetSequence(@idleSequence)
			@OnBuildFinish()
			@SetPlaybackRate(1)

			if @GetAfterMove() and @GetLevel() < @GetTargetLevel()
				@SetLevel(@GetLevel() + 1)
			elseif @GetAfterMove()
				@SetAfterMove(false)
				@SetTargetLevel(0)
	elseif @GetIsUpgrading()
		if @upgradeFinishAt < cTime
			@SetBuildSpeedup(false)
			@SetIsUpgrading(false)

			switch @GetLevel()
				when 2
					@RealSetModel(@IdleModel2) if @GetModel() ~= @IdleModel2
				when 3
					@RealSetModel(@IdleModel3) if @GetModel() ~= @IdleModel3

			@UpdateSequenceList()
			@StartActivity(ACT_OBJ_RUNNING)
			@ResetSequence(@idleSequence)
			@OnUpgradeFinish()

			if @GetAfterMove() and @GetLevel() < @GetTargetLevel()
				@SetLevel(@GetLevel() + 1)
			elseif @GetAfterMove()
				@SetAfterMove(false)
				@SetTargetLevel(0)
