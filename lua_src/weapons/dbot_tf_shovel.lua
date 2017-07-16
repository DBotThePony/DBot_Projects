
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

AddCSLuaFile()

SWEP.Base = 'dbot_tf_melee'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Soldier'
SWEP.PrintName = 'The Shovel'
SWEP.ViewModel = 'models/weapons/c_models/c_soldier_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_shovel/c_shovel.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false

SWEP.MissSoundsScript = 'Weapon_Shovel.Miss'
SWEP.MissCritSoundsScript = 'Weapon_Shovel.MissCrit'
SWEP.HitSoundsScript = 'Weapon_Shovel.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_Shovel.HitFlesh'

SWEP.DrawAnimation = 's_draw'
SWEP.IdleAnimation = 's_idle'
SWEP.AttackAnimation = 's_swing_a'
SWEP.AttackAnimationTable = {'s_swing_a', 's_swing_b'}
SWEP.AttackAnimationCrit = 's_swing_c'
