
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

SWEP.Base = 'dbot_tf_shotgun'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Pyro'
SWEP.PrintName = 'Reserve Shooter'
SWEP.ViewModel = 'models/weapons/c_models/c_pyro_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false

SWEP.FireSoundsScript = 'Weapon_Reserve_Shooter.Single'
SWEP.FireCritSoundsScript = 'Weapon_Reserve_Shooter.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_Reserve_Shooter.Empty'

SWEP.DrawAnimation = 'draw'
SWEP.IdleAnimation = 'idle'
SWEP.AttackAnimation = 'fire'
SWEP.AttackAnimationCrit = 'fire'
SWEP.ReloadStart = 'reload_start'
SWEP.ReloadLoop = 'reload_loop'
SWEP.ReloadEnd = 'reload_end'

SWEP.PreOnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
	if IsValid(hitEntity) and (hitEntity\IsNPC() or hitEntity\IsPlayer()) and not hitEntity\OnGround() and not @GetIncomingCrit()
		@SetSuppressEffects(false)
		@ThatWasMinicrit() if SERVER

SWEP.Primary = {
	'Ammo': 'Buckshot'
	'ClipSize': 4
	'DefaultClip': 32
	'Automatic': true
}
