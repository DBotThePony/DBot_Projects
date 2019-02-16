
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

SWEP.Base = 'dbot_tf_launcher'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Soldier'
SWEP.PrintName = 'Rocket Launcher'
SWEP.ViewModel = 'models/weapons/c_models/c_soldier_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.CooldownTime = 0.9

SWEP.FireSoundsScript = 'Weapon_RPG.Single'
SWEP.FireCritSoundsScript = 'Weapon_RPG.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_RPG.ClipEmpty'

SWEP.DrawAnimation = 'dh_draw'
SWEP.IdleAnimation = 'dh_idle'
SWEP.AttackAnimation = 'dh_fire'
SWEP.AttackAnimationCrit = 'dh_fire'
SWEP.ReloadStart = 'dh_reload_start'
SWEP.ReloadLoop = 'dh_reload_loop'
SWEP.ReloadEnd = 'dh_reload_finish'
SWEP.ReloadDeployTime = 0.7
SWEP.ReloadTime = 1

SWEP.Primary = {
	['Ammo'] = 'RPG_Round',
	['ClipSize'] = 4,
	['DefaultClip'] = 20,
	['Automatic'] = true
}
