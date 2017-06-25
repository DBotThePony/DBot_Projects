
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

BaseClass = baseclass.Get('dbot_tf_launcher')

SWEP.Base = 'dbot_tf_launcher'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Medic'
SWEP.PrintName = 'Syringe Gun'
SWEP.ViewModel = 'models/weapons/c_models/c_medic_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_syringegun/c_syringegun.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.SingleCrit = false

SWEP.CritChance = 1
SWEP.CritExponent = 0.01
SWEP.CritExponentMax = 3

SWEP.CooldownTime = 0.1

SWEP.FireSoundsScript = 'Weapon_SyringeGun.Single'
SWEP.FireCritSoundsScript = 'Weapon_SyringeGun.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_SyringeGun.ClipEmpty'
SWEP.ProjectileClass = 'dbot_tf_syringe_projectile'

SWEP.DrawAnimation = 'sg_draw'
SWEP.IdleAnimation = 'sg_idle'
SWEP.AttackAnimation = 'sg_fire'
SWEP.AttackAnimationCrit = 'sg_fire'
SWEP.ReloadStart = 'sg_reload'
SWEP.ReloadDeployTime = 1.3
SWEP.ReloadProjectiles = 40
SWEP.SingleReloadAnimation = true

SWEP.FireOffset = Vector(10, -10, -10)

SWEP.Primary = {
    'Ammo': 'AR2'
    'ClipSize': 40
    'DefaultClip': 160
    'Automatic': true
}
