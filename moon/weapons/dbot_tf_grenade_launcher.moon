
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
SWEP.Category = 'TF2 Demoman'
SWEP.PrintName = 'Grenade Launcher'
SWEP.ViewModel = 'models/weapons/c_models/c_demo_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_grenadelauncher/c_grenadelauncher.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.CooldownTime = 0.7

SWEP.FireSoundsScript = 'Weapon_GrenadeLauncher.Single'
SWEP.FireCritSoundsScript = 'Weapon_GrenadeLauncher.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_GrenadeLauncher.ClipEmpty'
SWEP.ProjectileClass = 'dbot_tf_pipebomb'

SWEP.DrawAnimation = 'g_draw'
SWEP.IdleAnimation = 'g_idle'
SWEP.AttackAnimation = 'g_fire'
SWEP.AttackAnimationCrit = 'g_fire'
SWEP.ReloadStart = 'g_reload_start'
SWEP.ReloadLoop = 'g_reload_loop'
SWEP.ReloadEnd = 'g_reload_end'
SWEP.ReloadDeployTime = 0.8
SWEP.ReloadTime = 0.65
SWEP.ReloadPlayExtra = true

SWEP.FireOffset = Vector(10, -10, -10)

SWEP.Primary = {
    'Ammo': 'Grenade'
    'ClipSize': 4
    'DefaultClip': 16
    'Automatic': true
}
