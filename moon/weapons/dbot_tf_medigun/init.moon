
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

AddCSLuaFile 'cl_init.lua'
AddCSLuaFile 'shared.lua'
include 'shared.lua'

DEFINE_BASECLASS('dbot_tf_weapon_base')

SWEP.Initialize = =>
	BaseClass.Initialize(@)
	@currentTargetLastVisible = 0
	@lastMedigunThink = CurTime()

SWEP.Deploy = =>
	@lastMedigunThink = CurTime()
	return BaseClass.Deploy(@)

SWEP.SelectTarget = (ent = NULL) =>
	return if ent == @GetHealTarget()
	@SetHealTarget(ent)
	@currentTargetLastVisible = CurTime() + @MAX_TARGET_NOT_REACHABLE
	-- @GetOwner()\EmitSound(@HEALING_SOUND)
	@isHealing = true
	@SendWeaponSequence(@AttackAnimation)
	@WaitForSequence(@HEALING_LOOP, @WAIT_FOR_LOOP)
	@beamEntity\Remove() if IsValid(@beamEntity)
	with @beamEntity = ents.Create('dbot_info_medibeam')
		\SetPos(@GetOwner()\GetPos() + @GetOwner()\OBBCenter())
		\Spawn()
		\Activate()
		\SetParent(@GetOwner())
		\SetEntityTarget(ent)

SWEP.CanHealTarget = (ent = NULL) =>
	return false if not IsValid(ent)
	return false if not DTF2.IsAlly(ent, nil, false) and type(ent) ~= 'Player'
	return @IsTargetVisible(ent)

SWEP.Holster = =>
	status = BaseClass.Holster(@)
	return status if not status
	@Distrupt() if IsValid(@GetHealTarget())
	@beamEntity\Remove() if IsValid(@beamEntity)
	return status

SWEP.OnRemove = =>
	BaseClass.OnRemove(@) if BaseClass.OnRemove
	@beamEntity\Remove() if IsValid(@beamEntity)

SWEP.PrimaryAttack = =>
	return if @GetNextPrimaryFire() > CurTime()
	@SetNextPrimaryFire(CurTime() + @TARGET_CHANGE_COOLDOWN)
	target = @GetHealTarget()
	if IsValid(target)
		target2 = @FindTarget()
		return true if target2 == target
		if IsValid(target2)
			timer.Simple 0, -> @SelectTarget(target2)
		else
			timer.Simple 0, -> @SetHealTarget(NULL)
		return true
	else
		target = @FindTarget()
		return false if not IsValid(target)
		timer.Simple 0, -> @SelectTarget(target)
		return true

SWEP.Distrupt = =>
	@SetHealTarget(NULL)
	@SendWeaponSequence(@HEALING_END)
	@WaitForSequence(@IdleAnimation, @WAIT_FOR_LOOP)
	-- @GetOwner()\EmitSound(@HEALING_DISTRUPT)

SWEP.Think = =>
	time = CurTime()
	delta = time - @lastMedigunThink
	@lastMedigunThink = time
	status = BaseClass.Think(@)
	target = @GetHealTarget()
	if IsValid(target)
		if type(target) == 'Player'
			if target\Alive()
				if @IsTargetVisible(target)
					@currentTargetLastVisible = CurTime() + @MAX_TARGET_NOT_REACHABLE
				elseif @currentTargetLastVisible < CurTime()
					@Distrupt()
			else
				@Distrupt()
		else
			if target\Health() > 0
				if @IsTargetVisible(target)
					@currentTargetLastVisible = CurTime() + @MAX_TARGET_NOT_REACHABLE
				elseif @currentTargetLastVisible < CurTime()
					@Distrupt()
			else
				@Distrupt()
	elseif @isHealing
		@isHealing = false
		@Distrupt()
	target = @GetHealTarget()
	if IsValid(target)
		toheal = target\SimulateTFOverheal(@CalculateHealSpeed((target.dtf2_lastMedigunDamageReceived or 0) - CurTime()) * delta, DTF2.GrabFloat(@OVERHEAL_MAX))
		hook.Run 'TFHealed', @GetOwner(), target, toheal, @ if toheal > 0
	return status

hook.Add 'EntityTakeDamage', 'TF.Medigun', (dmg) =>
	return if dmg\GetDamage() <= 0
	@dtf2_lastMedigunDamageReceived = CurTime() + 10
