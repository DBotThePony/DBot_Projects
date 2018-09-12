
--
-- Copyright (C) 2017-2018 DBot

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
			@__currentBuildHelathBuffer += deltaHealth * 1.02

			if @__currentBuildHelathBuffer > 1
				part = @__currentBuildHelathBuffer % 1
				@SetHealth((@Health() + @__currentBuildHelathBuffer - part)\min(@GetMaxHealth())\ceil())
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
