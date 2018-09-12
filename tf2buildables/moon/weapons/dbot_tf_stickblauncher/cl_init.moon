
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


include 'shared.lua'

DEFINE_BASECLASS('dbot_tf_launcher')

SWEP.PrimaryAttack = =>
	status = BaseClass.PrimaryAttack(@)
	return status if status == false
	@incomingFire = true
	@incomingFireTime = CurTime() + DTF2.GrabFloat(@MAX_CHARGE_TIME)
	@SetIsCharging(true)
	@SetStickyChargeStart(CurTime())
	if @chargeSound
		@chargeSound\Stop()
		@chargeSound = nil
	@chargeSound = CreateSound(@, @CHARGE_UP_SOUND)
	@chargeSound\Play()
	--@SendWeaponSequence(@CHARGE_ANIMATION)
	@SendWeaponSequence(@IdleAnimation)
	if IsFirstTimePredicted()
		@WaitForSequence(@IdleAnimation, DTF2.GrabFloat(@MAX_CHARGE_TIME))
	return true

SWEP.DrawHUD = => DTF2.DrawCenteredBar(@ChargePercent(), 'Charge - ' .. math.floor(@ChargePercent() * 100) .. '%; Stickies count: ' .. @GetStickiesCount())

SWEP.Holster = =>
	@incomingFire = false
	@incomingFireTime = 0
	status = BaseClass.Holster(@)
	return status if status == false
	@SetIsCharging(false)
	@SetStickyChargeStart(0)
	if @chargeSound
		@chargeSound\Stop()
		@chargeSound = nil
	return true

SWEP.FireTrigger = =>
	@SetIsCharging(false)
	@SetStickyChargeStart(0)
	@PlayFireSound()
	@SendWeaponSequence(@AttackAnimation)
	@WaitForSequence(@IdleAnimation, @CooldownTime)
	@incomingFire = false
	@incomingFireTime = 0
	@incomingCrit = false
	@incomingMiniCrit = false
	@SetNextPrimaryFire(CurTime() + @CooldownTime)
	@EmitMuzzleFlash()
	if @chargeSound
		@chargeSound\Stop()
		@chargeSound = nil

SWEP.SecondaryAttack = =>
	return if not IsFirstTimePredicted()
	return if @lastDetonationSound > CurTime()
	amount = @GetStickiesCount()
	return false if amount < 1
	@GetOwner()\EmitSound(@DETONATE_SOUND)
	@lastDetonationSound = CurTime() + 0.6
	return true
