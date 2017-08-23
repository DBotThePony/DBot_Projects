
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

BaseClass = baseclass.Get('dbot_tf_weapon_base')

checkInputs = {KEY_1, KEY_2, KEY_3, KEY_4}

SWEP.INVALID_INPUT_SOUND = 'weapons/medigun_no_target.wav'

SWEP.DrawHUD = =>
    DTF2.DestructionPDAHUD(@GetOwner())
    DTF2.DrawMetalCounter()
    DTF2.DrawBuildablesHUD()

SWEP.TriggerPlayerInput = (key = KEY_1) =>
    switch key
        when KEY_1
            reply = @TriggerDestructionRequest(@SLOT_SENTRY)
            surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
        when KEY_2
            reply = @TriggerDestructionRequest(@SLOT_DISPENSER)
            surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
        when KEY_3
            reply = @TriggerDestructionRequest(@SLOT_TELE_IN)
            surface.PlaySound(@INVALID_INPUT_SOUND) if not reply
        when KEY_4
            reply = @TriggerDestructionRequest(@SLOT_TELE_OUT)
            surface.PlaySound(@INVALID_INPUT_SOUND) if not reply

hook.Add 'Think', 'DTF2.DestructionPDACapture', ->
    ply = LocalPlayer()
    wep = ply\GetActiveWeapon()
    return if not IsValid(wep) or wep\GetClass() ~= 'dbot_tf_destrpda'
    for key in *checkInputs
        status1 = wep.__InputCache[key]
        status2 = input.IsKeyDown(key)

        if status1 and not status2
            wep.__InputCache[key] = false
        elseif status2 and not status1
            wep.__InputCache[key] = true
            wep\TriggerPlayerInput(key)
