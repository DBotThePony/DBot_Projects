
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

SWEP.Base = 'dbot_tf_ranged'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Engineer'
SWEP.PrintName = 'Shotgun'
SWEP.ViewModel = 'models/weapons/c_models/c_engineer_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_shotgun/c_shotgun.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.SingleCrit = true

SWEP.MuzzleAttachment = 'muzzle'
SWEP.MuzzleEffect = 'muzzle_shotgun'

SWEP.BulletDamage = 9
SWEP.BulletsAmount = 6
SWEP.ReloadBullets = 1
SWEP.DefaultSpread = Vector(1, 1, 0) * 0.05

SWEP.DefaultViewPunch = Angle(-3, 0, 0)

SWEP.FireSoundsScript = 'Weapon_Shotgun.Single'
SWEP.FireCritSoundsScript = 'Weapon_Shotgun.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_Shotgun.Empty'

SWEP.DrawAnimation = 'fj_draw'
SWEP.IdleAnimation = 'fj_idle'
SWEP.AttackAnimation = 'fj_fire'
SWEP.AttackAnimationCrit = 'fj_fire'
SWEP.ReloadStart = 'fj_reload_start'
SWEP.ReloadLoop = 'fj_reload_loop'
SWEP.ReloadEnd = 'fj_reload_end'

SWEP.Primary = {
    ['Ammo'] = 'Buckshot',
    ['ClipSize'] = 6,
    ['DefaultClip'] = 6,
    ['Automatic'] = true
}

function SWEP:DrawHUD()
    DTF2.DrawBuildablesHUD()
    DTF2.DrawMetalCounter()
end
