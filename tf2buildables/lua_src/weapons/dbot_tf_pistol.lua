
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
