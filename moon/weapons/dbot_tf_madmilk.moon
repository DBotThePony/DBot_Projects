

--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

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
