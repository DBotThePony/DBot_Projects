
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
