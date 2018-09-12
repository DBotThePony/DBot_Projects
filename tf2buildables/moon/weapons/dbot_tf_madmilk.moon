

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

DEFINE_BASECLASS('dbot_tf_cleaver')

SWEP.Base = 'dbot_tf_cleaver'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Mad Milk'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_madmilk/c_madmilk.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.ProjectileRestoreTime = 10

SWEP.AttackAnimationDuration = 1
SWEP.ProjectileClass = 'dbot_milk_projectile'

SWEP.DrawHUD = => DTF2.DrawCenteredBar(@GetProjectileReady() / @ProjectileRestoreTime, 'Mad milk')

SWEP.OnProjectileRestored = =>
	if IsValid(@GetTF2WeaponModel())
		ParticleEffectAttach('energydrink_milk_splash', PATTACH_ABSORIGIN_FOLLOW, @GetTF2WeaponModel(), @GetTF2WeaponModel()\LookupAttachment('drink_spray'))
	@EmitSound('DTF2_Weapon_MadMilk.Draw')

SWEP.Deploy = =>
	@BaseClass.Deploy(@)
	if @ProjectileIsReady()
		ParticleEffectAttach('energydrink_milk_splash', PATTACH_ABSORIGIN_FOLLOW, @GetTF2WeaponModel(), @GetTF2WeaponModel()\LookupAttachment('drink_spray')) if IsValid(@GetTF2WeaponModel())
		@EmitSound('DTF2_Weapon_MadMilk.Draw')
	return true
