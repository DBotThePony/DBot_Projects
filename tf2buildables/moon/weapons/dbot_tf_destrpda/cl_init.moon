
--
-- Copyright (C) 2017-2019 DBot

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

SWEP.DrawHUD = =>
	DTF2.DestructionPDAHUD(@GetOwner())
	DTF2.DrawMetalCounter()
	DTF2.DrawBuildablesHUD()

SWEP.TriggerPlayerInput = (key = KEY_1) =>
	switch key
		when KEY_1, 'slot1'
			reply = @TriggerDestructionRequest(@SLOT_SENTRY)
			surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
			return reply
		when KEY_2, 'slot2'
			reply = @TriggerDestructionRequest(@SLOT_DISPENSER)
			surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
			return reply
		when KEY_3, 'slot3'
			reply = @TriggerDestructionRequest(@SLOT_TELE_IN)
			surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
			return reply
		when KEY_4, 'slot4'
			reply = @TriggerDestructionRequest(@SLOT_TELE_OUT)
			surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
			return reply

hook.Add 'PlayerBindPress', 'DTF2.DestructionPDACapture', (bind, isPressed) =>
	return if not isPressed
	if bind == 'slot1' or bind == 'slot2' or bind == 'slot3' or bind == 'slot4'
		wep = @GetActiveWeapon()
		return if not IsValid(wep) or wep\GetClass() ~= 'dbot_tf_destrpda'
		return true if wep\TriggerPlayerInput(bind)
