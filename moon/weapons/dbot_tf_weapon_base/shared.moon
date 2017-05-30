
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

BaseClass = baseclass.Get('weapon_base')

SWEP.Base = 'weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'TF2 Weapon Base'
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.UseHands = true
SWEP.DrawCrosshair = true

SWEP.DrawTime = 0.66
SWEP.DrawTimeAnimation = 1.16
SWEP.PreFire = 0
SWEP.CooldownTime = 0.96
SWEP.BulletRange = 32000
SWEP.BulletDamage = 65
SWEP.BulletForce = 1
SWEP.BulletHull = 1

SWEP.AttackAnimation = ACT_VM_PRIMARYATTACK

SWEP.Initialize = =>
    @SetPlaybackRate(0.5)
    @SendWeaponAnim(ACT_VM_IDLE)
    @incomingFire = false
    @incomingFireTime = 0

SWEP.WaitForAnimation = (anim = ACT_VM_IDLE, time = 0, callback = (->)) =>
    timer.Create "DTF2.WeaponAnim.#{@EntIndex()}", time, 1, ->
        return if not IsValid(@)
        return if not IsValid(@GetOwner())
        return if @GetOwner()\GetActiveWeapon() ~= @
        @SendWeaponAnim(anim)
        callback()

SWEP.ClearTimeredAnimation = =>
    timer.Remove "DTF2.WeaponAnim.#{@EntIndex()}"

SWEP.Deploy = =>
    @SendWeaponAnim(ACT_VM_DRAW)
    @WaitForAnimation(ACT_VM_IDLE, @DrawTimeAnimation)
    @SetNextPrimaryFire(CurTime() + @DrawTime)
    @incomingFire = false
    return true

SWEP.Holster = => @GetNextPrimaryFire() < CurTime()

SWEP.OnMiss = =>
SWEP.OnHit = (hitEntity = NULL, tr = {}, dmginfo) =>

SWEP.BulletCallback = (tr = {}, dmginfo) =>
    weapon = @GetActiveWeapon()
    weapon.bulletCallbackCalled = true

    if tr.Hit
        weapon\OnHit(tr.Entity, tr, dmginfo)
    else
        weapon\OnMiss(tr, dmginfo)

SWEP.UpdateBulletData = (bulletData = {}) =>

SWEP.Think = =>
    if @incomingFire and @incomingFireTime < CurTime()
        @suppressing = true
        SuppressHostEvents(@GetOwner()) if SERVER and @GetOwner()\IsPlayer()
        @incomingFire = false
        @bulletCallbackCalled = false
        bulletData = {
            'Damage': @BulletDamage
            'Attacker': @GetOwner()
            'Callback': @BulletCallback
            'Src': @GetOwner()\EyePos()
            'Dir': @GetOwner()\GetAimVector()
            'Distance': @BulletRange
            'HullSize': @BulletHull
            'Force': @BulletForce
        }

        @UpdateBulletData(bulletData)

        @FireBullets(bulletData)
        @OnMiss() if not @bulletCallbackCalled
        SuppressHostEvents(NULL) if SERVER
        @suppressing = false

SWEP.PrimaryAttack = =>
    @SetNextPrimaryFire(CurTime() + @CooldownTime)
    @SendWeaponAnim(@AttackAnimation)
    @WaitForAnimation(ACT_VM_IDLE, @CooldownTime)
    @incomingFire = true
    @incomingFireTime = CurTime() + @PreFire
    @NextThink(@incomingFireTime)
    return true

SWEP.SecondaryAttack = => false
