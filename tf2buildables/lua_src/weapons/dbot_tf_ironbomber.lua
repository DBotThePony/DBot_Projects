
--
-- Copyright (C) 2017-2019 DBotThePony

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
SWEP.Category = 'TF2 Demoman'
SWEP.PrintName = 'Iron Bomber'
SWEP.ViewModel = 'models/weapons/c_models/c_demo_arms.mdl'
SWEP.WorldModel = 'models/workshop/weapons/c_models/c_quadball/c_quadball.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.CooldownTime = 0.7

SWEP.FireSoundsScript = 'Weapon_GrenadeLauncher.Single'
SWEP.FireCritSoundsScript = 'Weapon_GrenadeLauncher.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_GrenadeLauncher.ClipEmpty'
SWEP.ProjectileClass = 'dbot_tf_ironbomberb'

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
	['Ammo'] = 'Grenade',
	['ClipSize'] = 4,
	['DefaultClip'] = 16,
	['Automatic'] = true
}
