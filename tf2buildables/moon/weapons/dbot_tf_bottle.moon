
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

DEFINE_BASECLASS('dbot_tf_melee')

SWEP.Base = 'dbot_tf_melee'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Demoman'
SWEP.PrintName = 'Bottle'
SWEP.ViewModel = 'models/weapons/c_models/c_demo_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_bottle/c_bottle.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false

SWEP.MissSoundsScript = 'Weapon_Bottle.Miss'
SWEP.MissCritSoundsScript = 'Weapon_Bottle.MissCrit'
SWEP.HitSoundsScript = 'Weapon_Bottle.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_Bottle.HitFlesh'

SWEP.DrawAnimation = 'b_draw'
SWEP.IdleAnimation = 'b_idle'
SWEP.AttackAnimation = 'b_swing_a'
SWEP.AttackAnimationTable = {'b_swing_a', 'b_swing_b'}
SWEP.AttackAnimationCrit = 'b_swing_c'

SWEP.OnHit = (...) =>
	BaseClass.OnHit(@, ...)
	if SERVER and not @_bottle_Broken and @incomingCrit
		@_bottle_Broken = true
		@GetTF2WeaponModel()\SetModel('models/weapons/c_models/c_bottle/c_bottle_broken.mdl')
