
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

include 'shared.lua'

DEFINE_BASECLASS('dbot_tf_weapon_base')

SWEP.CanHealTarget = (ent = NULL) =>
	return false if not IsValid(ent) or type(ent) ~= 'Player'
	return @IsTargetVisible(ent)

SWEP.PrimaryAttack = =>
	return if @GetNextPrimaryFire() > CurTime()
	@SetNextPrimaryFire(CurTime() + @TARGET_CHANGE_COOLDOWN)
	return if not IsFirstTimePredicted()
	target = @GetHealTarget()
	if not IsValid(target)
		target = @FindTarget()
		if not IsValid(target)
			@GetOwner()\EmitSound(@MISSING_TARGET)
			return false
		@SendWeaponSequence(@AttackAnimation)
		@WaitForSequence(@HEALING_LOOP, @WAIT_FOR_LOOP)
		return true
	return true

SWEP.Think = =>
	target = @GetHealTarget()
	--if IsValid(target)
	--	if not @healingSound
	--		@healingSound = CreateSound(@, @HEALING_LOOP)
	--		@healingSound\Play()
	--else
	--	if @healingSound
	--		@healingSound\Stop()
	--		@healingSound = nil
	return BaseClass.Think(@)
