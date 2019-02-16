
--
-- Copyright (C) 2017-2019 DBot

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
SWEP.EmptySoundsScript = 'Weapon_Scatter_Gun.Empty'

SWEP.Primary = {
	['Ammo'] = 'Buckshot',
	['ClipSize'] = 6,
	['DefaultClip'] = 6,
	['Automatic'] = true
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
