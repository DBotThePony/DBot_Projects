
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

DEFINE_BASECLASS('dbot_tf_ranged')

SWEP.Base = 'dbot_tf_ranged'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Sniper'
SWEP.PrintName = 'The SMG'
SWEP.ViewModel = 'models/weapons/c_models/c_sniper_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_smg/c_smg.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.SingleCrit = false

SWEP.CritChance = 1
SWEP.CritExponent = 0.05
SWEP.CritExponentMax = 2

SWEP.MuzzleAttachment = 'muzzle'

SWEP.CooldownTime = 0.1
SWEP.BulletDamage = 8
SWEP.ReloadBullets = 25
SWEP.DefaultSpread = Vector(1, 1, 0) * 0.02

SWEP.FireSoundsScript = 'Weapon_SMG.Single'
SWEP.FireCritSoundsScript = 'Weapon_SMG.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_SMG.Empty'

SWEP.DrawAnimation = 'smg_draw'
SWEP.IdleAnimation = 'smg_idle'
SWEP.AttackAnimation = 'smg_fire'
SWEP.AttackAnimationCrit = 'smg_fire'
SWEP.SingleReloadAnimation = true
SWEP.ReloadStart = 'smg_reload'
SWEP.ReloadDeployTime = 1.12

SWEP.Primary = {
	['Ammo'] = 'SMG1',
	['ClipSize'] = 25,
	['DefaultClip'] = 75,
	['Automatic'] = true
}
