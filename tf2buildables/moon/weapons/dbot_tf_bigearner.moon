
--
-- Copyright (C) 2017-2018 DBot
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
