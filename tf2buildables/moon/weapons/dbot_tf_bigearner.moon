
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

DEFINE_BASECLASS('dbot_tf_knife')

SWEP.Base = 'dbot_tf_knife'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Spy'
SWEP.PrintName = 'Big Earner'
SWEP.ViewModel = 'models/weapons/c_models/c_spy_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_switchblade/c_switchblade.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.RandomCriticals = false

SWEP.MissSoundsScript = 'Weapon_Knife.Miss'
SWEP.MissCritSoundsScript = 'Weapon_Knife.MissCrit'
SWEP.HitSoundsScript = 'Icicle.HitWorld'
SWEP.HitSoundsFleshScript = 'Icicle.HitFlesh'
SWEP.ICE_SOUND = 'DTF2_Icicle.TurnToIce'
SWEP.MELT_SOUND = 'DTF2_Icicle.Melt'

SWEP.DrawAnimation = 'eternal_draw'
SWEP.IdleAnimation = 'eternal_idle'
SWEP.AttackAnimation = 'eternal_stab_a'
SWEP.AttackAnimationTable = {'eternal_stab_a', 'eternal_stab_b'}
SWEP.AttackAnimationCrit = 'eternal_stab_c'

SWEP.BackstabAnimation = 'eternal_backstab'
SWEP.BackstabAnimationUp = 'eternal_backstab_up'
SWEP.BackstabAnimationDown = 'eternal_backstab_down'
SWEP.BackstabAnimationIdle = 'eternal_backstab_idle'

SWEP.Deploy = =>
	BaseClass.Deploy(@)
	return true if CLIENT
	with @GetOwner()
		if not .DTF2_BigEarnerHealthDecreased
			.DTF2_BigEarnerHealthDecreased = true
			\SetMaxHealth(\GetMaxHealth() * 0.8)
			\SetHealth(\Health() * 0.8)
	return true

SWEP.OnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
	if IsValid(hitEntity) and SERVER and @isOnBack
		hook.Run 'DTF2.BigEarnerHit', @GetOwner(), @
	BaseClass.OnHit(@, hitEntity, tr, dmginfo)

if SERVER
	hook.Add 'PlayerSpawn', 'DTF2.BigEarner', => @DTF2_BigEarnerHealthDecreased = false
