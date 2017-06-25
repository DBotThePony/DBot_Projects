
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

game.AddAmmoType({
    name: 'ammo_tf_syringe'
    dmgtype: DMG_POISON
    tracer: TRACER_NONE
    plydmg: 12
    npcdmg: 12
    force: 0
    minsplash: 0
    maxsplash: 0
})

game.AddAmmoType({
    name: 'ammo_tf_flame'
    dmgtype: DMG_BURN
    tracer: TRACER_NONE
    plydmg: 14
    npcdmg: 14
    force: 0
    minsplash: 0
    maxsplash: 0
})
