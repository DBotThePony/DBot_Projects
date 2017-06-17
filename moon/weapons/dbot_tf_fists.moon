
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

BaseClass = baseclass.Get('dbot_tf_melee')

SWEP.Base = 'dbot_tf_melee'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Heavy'
SWEP.PrintName = 'Fists'
SWEP.ViewModel = 'models/weapons/c_models/c_heavy_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_shovel/c_shovel.mdl'
SWEP.NoTF2ViewModel = true
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false

SWEP.MissSoundsScript = 'Weapon_Fist.Miss'
SWEP.MissCritSoundsScript = 'Weapon_Fist.MissCrit'
SWEP.HitSoundsScript = 'Weapon_Fist.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_Fist.HitFlesh'

SWEP.DrawAnimation = 'f_draw'
SWEP.IdleAnimation = 'f_idle'
SWEP.AttackAnimation = 'f_swing_left'
SWEP.AttackAnimationTable = {'f_swing_left', 'f_swing_right'}
SWEP.AttackAnimationCrit = 'f_swing_crit'

SWEP.SecondaryAttack = => @PrimaryAttack()
