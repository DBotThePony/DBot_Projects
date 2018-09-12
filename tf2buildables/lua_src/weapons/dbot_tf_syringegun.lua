
--
-- Copyright (C) 2017-2018 DBot

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.


AddCSLuaFile()

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
SWEP.ReloadBullets = 40
SWEP.SingleReloadAnimation = true

SWEP.FireOffset = Vector(10, -10, -10)

SWEP.Primary = {
	['Ammo'] = 'ammo_tf_syringe',
	['ClipSize'] = 40,
	['DefaultClip'] = 160,
	['Automatic'] = true
}
