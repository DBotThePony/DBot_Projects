
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

DEFINE_BASECLASS('dbot_tf_melee')

SWEP.Base = 'dbot_tf_melee'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Sniper'
SWEP.PrintName = 'Machete'
SWEP.ViewModel = 'models/weapons/c_models/c_sniper_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_machete/c_machete.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.MissSoundsScript = 'Weapon_Machete.Miss'
SWEP.MissCritSoundsScript = 'Weapon_Machete.MissCrit'
SWEP.HitSoundsScript = 'Weapon_Machete.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_Machete.HitFlesh'

SWEP.DrawAnimation = 'm_draw'
SWEP.IdleAnimation = 'm_idle'
SWEP.AttackAnimation = 'm_swing_a'
SWEP.AttackAnimationTable = {'m_swing_a', 'm_swing_b'}
SWEP.AttackAnimationCrit = 'm_swing_c'

function SWEP.OnHit(...)
	return BaseClass.OnHit(...)
end

function SWEP:Think()
	return BaseClass.Think(self)
end
