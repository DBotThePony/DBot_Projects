
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
SWEP.Category = 'TF2 Heavy'
SWEP.PrintName = 'Fists'
SWEP.ViewModel = 'models/weapons/c_models/c_heavy_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_shovel/c_shovel.mdl'
SWEP.NoTF2ViewModel = true
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false

SWEP.MissSoundsScript = 'Weapon_Fist.Miss'
SWEP.MissCritSoundsScript = 'Weapon_Fist.MissCrit'
SWEP.HitSoundsScript = 'Weapon_Fist.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_Fist.HitFlesh'

SWEP.DrawAnimation = 'f_draw'
SWEP.IdleAnimation = 'f_idle'
SWEP.AttackAnimation = 'f_swing_left'
SWEP.AttackAnimationTable = {'f_swing_left', 'f_swing_right'}
SWEP.AttackAnimationCrit = 'f_swing_crit'

SWEP.SelectAttackAnimation = => not @secondary and 'f_swing_left' or 'f_swing_right'

SWEP.SecondaryAttack = =>
	return false if @GetNextPrimaryFire() > CurTime()
	@secondary = true
	@PrimaryAttack()
	@secondary = false
	return true
