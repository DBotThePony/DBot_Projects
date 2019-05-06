
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


include 'shared.lua'

DEFINE_BASECLASS('dbot_tf_weapon_base')

checkInputs = {KEY_1, KEY_2, KEY_3, KEY_4}

SWEP.INVALID_INPUT_SOUND = 'weapons/medigun_no_target.wav'

SWEP.Think = =>
	BaseClass.Think(@)
	build = @GetBuildStatus()

	if build ~= @BUILD_NONE
		if not IsValid(@blueprintModel)
			with @blueprintModel = ClientsideModel(@SENTRY_BLUEPRINT, RENDERGROUP_OTHER)
				\SetNoDraw(true)
				\DrawShadow(false)
				\SetPos(LocalPlayer()\GetPos())

		moving = build == @MOVE_DISPENSER or build == @MOVE_TELE_IN or build == @MOVE_SENTRY or build == @MOVE_TELE_OUT
		if not @__interruptNextRotate and moving
			@__interruptNextRotate = CurTime() + 0.2
			@SetBuildRotation(0)
		elseif @__interruptNextRotate and not moving
			@__interruptNextRotate = nil

		status, tr = @CalcAndCheckBuildSpot()
		seq = status and 0 or 1

		with @blueprintModel
			switch build
				when @BUILD_SENTRY, @MOVE_SENTRY
					\SetModel(@GetBuildSentryBlueprint()) if \GetModel() ~= @GetBuildSentryBlueprint()
				when @BUILD_DISPENSER, @MOVE_DISPENSER
					\SetModel(@DISPENSER_BLUEPRINT) if \GetModel() ~= @DISPENSER_BLUEPRINT
				when @BUILD_TELE_IN, @MOVE_TELE_IN
					\SetModel(@TELE_IN_BLUEPRINT) if \GetModel() ~= @TELE_IN_BLUEPRINT
				when @BUILD_TELE_OUT, @MOVE_TELE_OUT
					\SetModel(@TELE_OUT_BLUEPRINT) if \GetModel() ~= @TELE_OUT_BLUEPRINT
			\SetSequence(seq) if \GetSequence() ~= seq

SWEP.OnRemove = =>
	BaseClass.OnRemove(@) if BaseClass.OnRemove
	@blueprintModel\Remove() if IsValid(@blueprintModel)
	@sphereModel\Remove() if IsValid(@sphereModel)

SWEP.DrawHUD = =>
	DTF2.DrawPDAHUD(@GetOwner()) if @GetBuildStatus() == @BUILD_NONE
	DTF2.DrawMetalCounter()
	DTF2.DrawBuildablesHUD()

SWEP.TriggerPlayerInput = (key = KEY_1) =>
	return if @GetBuildStatus() ~= @BUILD_NONE
	switch key
		when KEY_1, 'slot1'
			reply = @TriggerBuildRequest(@BUILD_SENTRY)
			surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
			return reply
		when KEY_2, 'slot2'
			reply = @TriggerBuildRequest(@BUILD_DISPENSER)
			surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
			return reply
		when KEY_3, 'slot3'
			reply = @TriggerBuildRequest(@BUILD_TELE_IN)
			surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
			return reply
		when KEY_4, 'slot4'
			reply = @TriggerBuildRequest(@BUILD_TELE_OUT)
			surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
			return reply

PlayerBindPress = (bind, isPressed) =>
	return if not isPressed
	if bind == 'slot1' or bind == 'slot2' or bind == 'slot3' or bind == 'slot4'
		wep = @GetActiveWeapon()
		return if not IsValid(wep) or wep\GetClass() ~= 'dbot_tf_buildpda'
		return true if wep\TriggerPlayerInput(bind)

hook.Add 'PlayerBindPress', 'DTF2.BuildPDACapture', PlayerBindPress, -2

PostDrawTranslucentRenderables = (a, b) ->
	return if a or b
	ply = LocalPlayer()
	wep = ply\GetActiveWeapon()
	return if not IsValid(wep) or wep\GetClass() ~= 'dbot_tf_buildpda' or wep\GetBuildStatus() == wep.BUILD_NONE or not IsValid(wep.blueprintModel)
	status, tr = wep\CalcAndCheckBuildSpot()
	pos = tr.HitPos
	diff = (pos - ply\GetPos())\Angle()
	diff.p = 0
	diff.r = 0
	wep.__smoothRotation = LerpAngle(0.1, wep.__smoothRotation or Angle(0, 0, 0), Angle(0, wep\GetBuildRotation() * 90, 0))
	diff += wep.__smoothRotation
	with wep.blueprintModel
		\FrameAdvance()
		\SetPos(pos)
		\SetAngles(diff)
		\DrawModel()

hook.Add 'PostDrawTranslucentRenderables', 'DTF2.BuildPDABlueprint', PostDrawTranslucentRenderables, -2
