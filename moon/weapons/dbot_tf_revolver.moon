
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
SWEP.Category = 'TF2 Spy'
SWEP.PrintName = 'Revolver'
SWEP.ViewModel = 'models/weapons/c_models/c_spy_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_revolver/c_revolver.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.SingleCrit = true

SWEP.MuzzleAttachment = 'muzzle'

SWEP.CooldownTime = 0.5
SWEP.BulletDamage = 40
SWEP.ReloadBullets = 6
SWEP.DefaultSpread = Vector(1, 1, 0) * 0.01

SWEP.FireSoundsScript = 'Weapon_Revolver.Single'
SWEP.FireCritSoundsScript = 'Weapon_Revolver.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_Revolver.Empty'

SWEP.DrawAnimation = 'draw'
SWEP.IdleAnimation = 'idle'
SWEP.AttackAnimation = 'fire'
SWEP.AttackAnimationCrit = 'fire'
SWEP.SingleReloadAnimation = true
SWEP.ReloadStart = 'reload'
SWEP.ReloadDeployTime = 1.12

SWEP.Primary = {
    'Ammo': '357'
    'ClipSize': 6
    'DefaultClip': 24
    'Automatic': true
}
