

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
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Bat'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_bat.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false

SWEP.BulletDamage = 35
SWEP.BulletForce = 5
SWEP.PreFire = 0.14
SWEP.CooldownTime = 0.5

SWEP.MissSoundsScript = 'Weapon_Bat.Miss'
SWEP.MissCritSoundsScript = 'Weapon_Bat.MissCrit'
SWEP.HitSoundsScript = 'Weapon_Bat.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_Bat.HitFlesh'

SWEP.DrawAnimation = 'b_draw'
SWEP.IdleAnimation = 'b_idle'

SWEP.AttackAnimation = 'b_swing_a'
SWEP.AttackAnimationTable = {'b_swing_a', 'b_swing_b'}
SWEP.AttackAnimationCrit = 'b_swing_c'

