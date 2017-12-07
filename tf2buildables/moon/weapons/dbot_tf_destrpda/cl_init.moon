
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

SWEP.DrawHUD = =>
	DTF2.DestructionPDAHUD(@GetOwner())
	DTF2.DrawMetalCounter()
	DTF2.DrawBuildablesHUD()

SWEP.TriggerPlayerInput = (key = KEY_1) =>
	switch key
		when KEY_1, 'slot1'
			reply = @TriggerDestructionRequest(@SLOT_SENTRY)
			surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
		when KEY_2, 'slot2'
			reply = @TriggerDestructionRequest(@SLOT_DISPENSER)
			surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
		when KEY_3, 'slot3'
			reply = @TriggerDestructionRequest(@SLOT_TELE_IN)
			surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
		when KEY_4, 'slot4'
			reply = @TriggerDestructionRequest(@SLOT_TELE_OUT)
			surface.PlaySound(@INVALID_INPUT_SOUND) if not reply

hook.Add 'PlayerBindPress', 'DTF2.DestructionPDACapture', (bind, isPressed) =>
	return if not isPressed
	if bind == 'slot1' or bind == 'slot2' or bind == 'slot3' or bind == 'slot4'
		wep = @GetActiveWeapon()
		return if not IsValid(wep) or wep\GetClass() ~= 'dbot_tf_destrpda'
		wep\TriggerPlayerInput(bind)
		return true
