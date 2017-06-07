
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

BaseClass = baseclass.Get('dbot_tf_ranged')

SWEP.Base = 'dbot_tf_ranged'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Scattergun'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_scattergun.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false

SWEP.SingleCrit = true

SWEP.MuzzleAttachment = 'muzzle'

SWEP.BulletDamage = 14
SWEP.BulletsAmount = 6
SWEP.ReloadBullets = 1
SWEP.DefaultSpread = Vector(1, 1, 0) * 0.05

SWEP.DefaultViewPunch = Angle(-3, 0, 0)

SWEP.FireSoundsScript = 'Weapon_Scatter_Gun.Single'
SWEP.FireCritSoundsScript = 'Weapon_Scatter_Gun.SingleCrit'
SWEP.EmptySounds = 'Weapon_Scatter_Gun.Empty'

SWEP.Primary = {
    'Ammo': 'Buckshot'
    'ClipSize': 6
    'DefaultClip': 6
    'Automatic': true
}

SWEP.CooldownTime = 0.6
SWEP.ReloadTime = 0.5
SWEP.DrawAnimation = 'sg_draw'
SWEP.IdleAnimation = 'sg_idle'
SWEP.AttackAnimation = 'sg_fire'
SWEP.AttackAnimationCrit = 'sg_fire'
SWEP.ReloadStart = 'sg_reload_start'
SWEP.ReloadLoop = 'sg_reload_loop'
SWEP.ReloadEnd = 'sg_reload_end'
