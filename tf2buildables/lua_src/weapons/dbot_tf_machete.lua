
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
SWEP.Category = 'TF2 Sniper'
SWEP.PrintName = 'Machete'
SWEP.ViewModel = 'models/weapons/c_models/c_sniper_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_machete/c_machete.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.MissSoundsScript = 'Weapon_Machete.Miss'
SWEP.MissCritSoundsScript = 'Weapon_Machete.MissCrit'
SWEP.HitSoundsScript = 'Weapon_Machete.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_Machete.HitFlesh'

SWEP.DrawAnimation = 'm_draw'
SWEP.IdleAnimation = 'm_idle'
SWEP.AttackAnimation = 'm_swing_a'
SWEP.AttackAnimationTable = {'m_swing_a', 'm_swing_b'}
SWEP.AttackAnimationCrit = 'm_swing_c'

function SWEP.OnHit(...)
	return BaseClass.OnHit(...)
end

function SWEP:Think()
	return BaseClass.Think(self)
end
