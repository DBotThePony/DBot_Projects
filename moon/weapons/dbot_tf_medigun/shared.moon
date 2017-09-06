
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

DEFINE_BASECLASS('dbot_tf_weapon_base')

SWEP.Base = 'dbot_tf_weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Medigun'
SWEP.PrintName = 'Medigun'
SWEP.ViewModel = 'models/weapons/c_models/c_medic_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_medigun/c_medigun.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.IS_MEDIGUN = true

SWEP.MAX_UBERCHARGE = 100
SWEP.MIN_HULL = Vector(-2, -2, 0)
SWEP.MAX_HULL = Vector(2, 2, 0)
SWEP.MAX_HEAL_DISTANCE = 256
SWEP.MAX_INITIAL_DISTANCE = 192
SWEP.MAX_TARGET_NOT_REACHABLE = 2

SWEP.HEALING_SOUND = 'DTF2_WeaponMedigun.Healing'
SWEP.HEALING_DISTRUPT = 'DTF2_WeaponMedigun.HealingDisrupt'
SWEP.CHARGED_SOUND = 'DTF2_WeaponMedigun.Charged'
SWEP.MISSING_TARGET = 'DTF2_WeaponMedigun.NoTarget'

SWEP.DrawAnimation = 'draw'
SWEP.IdleAnimation = 'idle'
SWEP.AttackAnimation = 'fire_on'
SWEP.AttackAnimationCrit = 'fire_on'
SWEP.HEALING_LOOP = 'fire_loop'
SWEP.HEALING_END = 'fire_off'

SWEP.OVERHEAL_MAX = 1.5
SWEP.HEAL_RATE = 25
SWEP.TARGET_CHANGE_COOLDOWN = 0.5
SWEP.WAIT_FOR_LOOP = 0.6

SWEP.Primary = {
	'Ammo': 'none'
	'ClipSize': -1
	'DefaultClip': 0
	'Automatic': true
}

SWEP.Secondary = {
	'Ammo': 'none'
	'ClipSize': -1
	'DefaultClip': 0
	'Automatic': false
}

SWEP.SetupDataTables = =>
	BaseClass.SetupDataTables(@)
	@NetworkVar('Entity', 4, 'HealTarget')
	@NetworkVar('Float', 4, 'Ubercharge')
	@NetworkVar('Bool', 5, 'UberchargeIsActive')
	@SetHealTarget(NULL)
	@SetUbercharge(0)
	@SetUberchargeIsActive(false)

SWEP.CalculateHealSpeed = (lastTimeReceived = 0) =>
	healRate = DTF2.GrabFloat(@HEAL_RATE)
	return healRate * 3 if lastTimeReceived <= 0
	return healRate if lastTimeReceived >= 10
	return healRate * (3 - lastTimeReceived / 5)

SWEP.FindTarget = =>
	ply = @GetOwner()
	return NULL if not IsValid(ply)
	eyePos = ply\EyePos()
	eyeAng = ply\EyeAngles()
	trData = {
		mins: @MIN_HULL
		maxs: @MAX_HULL
		filter: {@, ply}
		start: eyePos
		endpos: eyePos + eyeAng\Forward() * DTF2.GrabFloat(@MAX_INITIAL_DISTANCE)
	}
	tr = util.TraceHull(trData)
	return @CanHealTarget(tr.Entity) and tr.Entity or NULL, tr

SWEP.IsTargetVisible = (ent = NULL) =>
	return false if not IsValid(ent) or not IsValid(@GetOwner()) or ent\GetPos()\Distance(@GetOwner()\GetPos()) >= DTF2.GrabFloat(@MAX_HEAL_DISTANCE)
	center = ent\OBBCenter() + ent\GetPos()
	ply = @GetOwner()
	lpos = ply\OBBCenter() + ply\GetPos()
	trData = {
		mins: @MIN_HULL
		maxs: @MAX_HULL
		filter: {@, ply}
		mask: MASK_BLOCKLOS
		start: lpos
		endpos: center
	}

	trData2 = {
		mins: @MIN_HULL
		maxs: @MAX_HULL
		filter: {@, ply}
		start: lpos
		endpos: center
	}

	tr = util.TraceHull(trData)
	tr2 = util.TraceHull(trData2)
	return not tr.Hit and tr2.Entity == ent, tr2, tr
