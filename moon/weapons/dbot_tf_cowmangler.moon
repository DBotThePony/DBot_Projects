
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

BaseClass = baseclass.Get('dbot_tf_rocket_launcher')

SWEP.Base = 'dbot_tf_rocket_launcher'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Soldier'
SWEP.PrintName = 'Cow Mangler 5000'
SWEP.ViewModel = 'models/weapons/c_models/c_soldier_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_drg_cowmangler/c_drg_cowmangler.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.RandomCriticals = false

SWEP.ProjectileClass = 'dbot_tf_cow_rocket'

SWEP.FireSoundsScript = 'Weapon_CowMangler.Single'
SWEP.FireCritSoundsScript = 'Weapon_CowMangler.Single'

SWEP.AttackAnimationSuper = 'mangler_fire_super'
SWEP.ReloadStart = 'mangler_reload_start'
SWEP.ReloadLoop = 'mangler_reload_loop'
SWEP.ReloadEnd = 'mangler_reload_finish'

SWEP.Primary = {
    'Ammo': 'none'
    'ClipSize': 4
    'DefaultClip': -1
    'Automatic': true
}
