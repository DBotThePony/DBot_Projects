
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

hook.Add 'PreDrawPlayerHands', 'DTF2.WeaponHandsFix', (hands = NULL, viewmodel = NULL, ply = NULL, weapon = NULL) ->
    return unless IsValid(hands) or IsValid(viewmodel) or IsValid(ply) or IsValid(weapon)
    if weapon.IsTF2Weapon
        hands.__dtf2_old_model = hands.__dtf2_old_model or hands\GetModel()
        hands\SetModel(weapon.HandsModel)
    else
        if hands.__dtf2_old_model
            hands\SetModel(hands.__dtf2_old_model)
            hands.__dtf2_old_model = nil

return nil
