
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
	['Ammo'] = '357',
	['ClipSize'] = 6,
	['DefaultClip'] = 24,
	['Automatic'] = true
}
