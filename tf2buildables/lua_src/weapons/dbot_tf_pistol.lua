
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

SWEP.Base = 'dbot_tf_ranged'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Engineer'
SWEP.PrintName = 'Pistol'
SWEP.ViewModel = 'models/weapons/c_models/c_engineer_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_pistol/c_pistol.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.Slot = 1

SWEP.MuzzleAttachment = 'muzzle'

SWEP.CooldownTime = 0.13
SWEP.BulletDamage = 15
SWEP.BulletsAmount = 1
SWEP.ReloadBullets = 12
SWEP.DefaultSpread = Vector(1, 1, 0) * 0.01

SWEP.FireSoundsScript = 'Weapon_Pistol.Single'
SWEP.FireCritSoundsScript = 'Weapon_Pistol.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_Pistol.ClipEmpty'

SWEP.DrawAnimation = 'pstl_draw'
SWEP.IdleAnimation = 'pstl_idle'
SWEP.AttackAnimation = 'pstl_fire'
SWEP.AttackAnimationCrit = 'pstl_fire'
SWEP.SingleReloadAnimation = true
SWEP.ReloadStart = 'pstl_reload'
SWEP.ReloadDeployTime = 1.12

SWEP.Primary = {
	['Ammo'] = 'Pistol',
	['ClipSize'] = 12,
	['DefaultClip'] = 12,
	['Automatic'] = true
}

function SWEP:DrawHUD()
	DTF2.DrawBuildablesHUD()
	DTF2.DrawMetalCounter()
end
