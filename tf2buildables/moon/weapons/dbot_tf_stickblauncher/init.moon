
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
