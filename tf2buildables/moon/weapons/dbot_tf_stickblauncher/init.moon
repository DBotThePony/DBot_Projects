
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

AddCSLuaFile 'cl_init.lua'
AddCSLuaFile 'shared.lua'
include 'shared.lua'

DEFINE_BASECLASS('dbot_tf_launcher')

SWEP.PrimaryAttack = =>
	status = BaseClass.PrimaryAttack(@)
	return status if status == false
	@incomingFire = true
	@incomingFireTime = CurTime() + DTF2.GrabFloat(@MAX_CHARGE_TIME)
	@SetIsCharging(true)
	@SetStickyChargeStart(CurTime())
	--@SendWeaponSequence(@CHARGE_ANIMATION)
	@SendWeaponSequence(@IdleAnimation)
	if IsFirstTimePredicted()
		@WaitForSequence(@IdleAnimation, DTF2.GrabFloat(@MAX_CHARGE_TIME))
	return true

SWEP.Holster = =>
	@incomingFire = false
	@incomingFireTime = 0
	status = BaseClass.Holster(@)
	return status if status == false
	@SetIsCharging(false)
	@SetStickyChargeStart(0)
	return true

SWEP.FireTrigger = =>
	owner = @GetOwner()
	offset = Vector(@FireOffset)
	offset\Rotate(owner\EyeAngles())
	origin = owner\EyePos() + offset
	aimPos = owner\GetEyeTrace().HitPos
	dir = aimPos - origin
	dir\Normalize()

	@PlayFireSound()
	@SendWeaponSequence(@AttackAnimation)
	@WaitForSequence(@IdleAnimation, @CooldownTime)

	with cEnt = ents.Create(@ProjectileClass)
		\SetPos(origin)
		\SetProjectileSpeed(@GetFireStrength()) if .SetProjectileSpeed
		\SetIsMiniCritical(@incomingMiniCrit)   if .SetIsMiniCritical
		\SetIsCritical(@incomingCrit)           if .SetIsCritical
		\SetOwner(@GetOwner())                  if .SetOwner
		\SetAttacker(@GetOwner())               if .SetAttacker
		\SetInflictor(@)                        if .SetInflictor
		\SetWeapon(@)                           if .SetWeapon
		\Spawn()
		\Activate()
		\SetDirection(dir)                      if .SetDirection
		\Think()
		@OnFireTriggered(cEnt)

	@incomingFire = false
	@incomingFireTime = 0
	@incomingCrit = false
	@incomingMiniCrit = false
	@SetIsCharging(false)
	@SetStickyChargeStart(0)
	@SetNextPrimaryFire(CurTime() + @CooldownTime)
	@EmitMuzzleFlash()

SWEP.SecondaryAttack = =>
	stickies = @GetOwner()\GetTFStickies()
	amount = #stickies
	return false if amount < 1
	if @lastDetonationSound < CurTime()
		@GetOwner()\EmitSound(@DETONATE_SOUND)
		@lastDetonationSound = CurTime() + 0.6
	timer.Simple 0, -> -- Prevent SuppressHostEvents()
		playSound = true
		for stick in *stickies
			if stick\IsValid()
				stick\SetPlayExplosionSound(playSound)
				stick\Explode()
				playSound = false
		timer.Simple 0.2, -> @GetOwner()\RefreshTFStickies() if @IsValid() and @GetOwner()\IsValid()
	return true
