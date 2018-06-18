
--
-- Copyright (C) 2017-2018 DBot
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

DEFINE_BASECLASS('dbot_tf_melee')

SWEP.Base = 'dbot_tf_melee'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Demoman'
SWEP.PrintName = 'Bottle'
SWEP.ViewModel = 'models/weapons/c_models/c_demo_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_bottle/c_bottle.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false

SWEP.MissSoundsScript = 'Weapon_Bottle.Miss'
SWEP.MissCritSoundsScript = 'Weapon_Bottle.MissCrit'
SWEP.HitSoundsScript = 'Weapon_Bottle.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_Bottle.HitFlesh'

SWEP.DrawAnimation = 'b_draw'
SWEP.IdleAnimation = 'b_idle'
SWEP.AttackAnimation = 'b_swing_a'
SWEP.AttackAnimationTable = {'b_swing_a', 'b_swing_b'}
SWEP.AttackAnimationCrit = 'b_swing_c'

SWEP.OnHit = (...) =>
	BaseClass.OnHit(@, ...)
	if SERVER and not @_bottle_Broken and @incomingCrit
		@_bottle_Broken = true
		@GetTF2WeaponModel()\SetModel('models/weapons/c_models/c_bottle/c_bottle_broken.mdl')
