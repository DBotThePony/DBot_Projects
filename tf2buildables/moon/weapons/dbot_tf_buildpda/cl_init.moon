
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

SWEP.DrawHUD = =>
	DTF2.DrawPDAHUD(@GetOwner()) if @GetBuildStatus() == @BUILD_NONE
	DTF2.DrawMetalCounter()
	DTF2.DrawBuildablesHUD()

SWEP.TriggerPlayerInput = (key = KEY_1) =>
	return if @GetBuildStatus() ~= @BUILD_NONE
	switch key
		when KEY_1
			reply = @TriggerBuildRequest(@BUILD_SENTRY)
			surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
		when KEY_2
			reply = @TriggerBuildRequest(@BUILD_DISPENSER)
			surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
		when KEY_3
			reply = @TriggerBuildRequest(@BUILD_TELE_IN)
			surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
		when KEY_4
			reply = @TriggerBuildRequest(@BUILD_TELE_OUT)
			surface.PlaySound(@INVALID_INPUT_SOUND) if not reply

hook.Add 'Think', 'DTF2.BuildPDACapture', ->
	ply = LocalPlayer()
	wep = ply\GetActiveWeapon()
	return if not IsValid(wep) or wep\GetClass() ~= 'dbot_tf_buildpda'
	for key in *checkInputs
		status1 = wep.__InputCache[key]
		status2 = input.IsKeyDown(key)

		if status1 and not status2
			wep.__InputCache[key] = false
		elseif status2 and not status1
			wep.__InputCache[key] = true
			wep\TriggerPlayerInput(key)

hook.Add 'PostDrawOpaqueRenderables', 'DTF2.BuildPDABlueprint', (a, b) ->
	return if a or b
	ply = LocalPlayer()
	wep = ply\GetActiveWeapon()
	return if not IsValid(wep) or wep\GetClass() ~= 'dbot_tf_buildpda' or wep\GetBuildStatus() == wep.BUILD_NONE or not IsValid(wep.blueprintModel)
	status, tr = wep\CalcAndCheckBuildSpot()
	pos = tr.HitPos
	diff = (pos - ply\GetPos())\Angle()
	diff.p = 0
	diff.r = 0
	wep.__smoothRotation = LerpAngle(0.1, wep.__smoothRotation, Angle(0, wep\GetBuildRotation() * 90, 0))
	diff += wep.__smoothRotation
	with wep.blueprintModel
		\FrameAdvance()
		\SetPos(pos)
		\SetAngles(diff)
		\DrawModel()
