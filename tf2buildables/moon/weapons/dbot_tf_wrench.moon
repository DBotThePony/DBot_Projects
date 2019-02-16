
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

SWEP.Base = 'dbot_tf_melee'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Engineer'
SWEP.PrintName = 'Wrench'
SWEP.ViewModel = 'models/weapons/c_models/c_engineer_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_wrench/c_wrench.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.DrawAnimation = 'pdq_draw'
SWEP.IdleAnimation = 'pdq_idle_tap'
SWEP.AttackAnimation = 'pdq_swing_a'
SWEP.AttackAnimationTable = {'pdq_swing_a', 'pdq_swing_b'}
SWEP.AttackAnimationCrit = 'pdq_swing_c'

SWEP.MissSoundsScript = 'Weapon_Wrench.Miss'
SWEP.MissCritSoundsScript = 'Weapon_Wrench.MissCrit'
SWEP.HitSoundsScript = 'Weapon_Wrench.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_Wrench.HitFlesh'

SWEP.DrawHUD = =>
	DTF2.DrawMetalCounter()
	DTF2.DrawBuildablesHUD()

SWEP.OnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
	return @BaseClass.OnHit(@, hitEntity, tr, dmginfo) if not hitEntity.IsTF2Building or SERVER and not hitEntity\IsAlly(@GetOwner())
	return if CLIENT
	dmginfo\SetDamage(0)
	dmginfo\SetDamageType(0)
	if hitEntity\DoSpeedup(nil, @GetOwner())
		@EmitSoundServerside('Weapon_Wrench.HitBuilding_Success')
		return
	amount = hitEntity\SimulateRepair(@GetOwner()\GetTF2Metal())
	if amount > 0
		@GetOwner()\SimulateTF2MetalRemove(amount)
		@EmitSoundServerside('Weapon_Wrench.HitBuilding_Success')
	else
		@EmitSoundServerside('Weapon_Wrench.HitBuilding_Failure')
