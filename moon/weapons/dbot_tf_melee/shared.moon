
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

SWEP.Base = 'weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'TF2 Melee Base'
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.SlotPos = 16

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

SWEP.DrawTime = 0.66
SWEP.DrawTimeAnimation = 1.16
SWEP.PreSwing = 0.24
SWEP.ReloadTime = 0.96
SWEP.MeleeRange = 78

SWEP.MeleeDamage = 65

SWEP.Initialize = =>
    @SetPlaybackRate(0.5)
    @SendWeaponAnim(ACT_VM_IDLE)
    @incomingHit = false
    @incomingHitTime = 0

SWEP.WaitForAnimation = (anim = ACT_VM_IDLE, time = 0) =>
    timer.Create "DTF2.WeaponAnim.#{@EntIndex()}", time, 1, ->
        return if not IsValid(@)
        return if not IsValid(@GetOwner())
        return if @GetOwner()\GetActiveWeapon() ~= @
        @SendWeaponAnim(anim)

SWEP.Deploy = =>
    @SendWeaponAnim(ACT_VM_DRAW)
    @WaitForAnimation(ACT_VM_IDLE, @DrawTimeAnimation)
    @SetNextPrimaryFire(CurTime() + @DrawTime)
    @incomingHit = false
    return true

SWEP.Holster = =>@GetNextPrimaryFire() < CurTime()

SWEP.PlayMissSound = =>
    playSound = table.Random(@MissSounds)
    @EmitSound(playSound, 50, 100, 1, CHAN_WEAPON) if playSound

SWEP.PlayHitSound = =>
    playSound = table.Random(@HitSounds)
    @EmitSound(playSound, 50, 100, 1, CHAN_WEAPON) if playSound

SWEP.PlayFleshHitSound = =>
    playSound = table.Random(@HitSoundsFlesh)
    @EmitSound(playSound, 75, 100, 1, CHAN_WEAPON) if playSound

SWEP.OnMiss = =>
    @PlayMissSound()

SWEP.OnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
    @PlayHitSound() if not IsValid(hitEntity)
    @PlayFleshHitSound() if IsValid(hitEntity) and (hitEntity\IsPlayer() or hitEntity\IsNPC())
    dmginfo\SetDamageType(DMG_CLUB)

SWEP.BulletCallback = (tr = {}, dmginfo) =>
    weapon = @GetActiveWeapon()
    weapon.bulletCallbackCalled = true

    if tr.Hit
        weapon\OnHit(tr.Entity, tr, dmginfo)
    else
        weapon\OnMiss(tr, dmginfo)

SWEP.Think = =>
    if @incomingHit and @incomingHitTime < CurTime()
        SuppressHostEvents(@GetOwner()) if SERVER and @GetOwner()\IsPlayer()
        @incomingHit = false
        @bulletCallbackCalled = false
        bulletData = {
            'Damage': @MeleeDamage
            'Attacker': @GetOwner()
            'Callback': @BulletCallback
            'Src': @GetOwner()\EyePos()
            'Dir': @GetOwner()\GetAimVector()
            'Distance': @MeleeRange
            'HullSize': 8
        }

        @FireBullets(bulletData)
        @OnMiss() if not @bulletCallbackCalled
        SuppressHostEvents(NULL) if SERVER

SWEP.PrimaryAttack = =>
    @SetNextPrimaryFire(CurTime() + @ReloadTime)
    @SendWeaponAnim(ACT_VM_SWINGHARD)
    @WaitForAnimation(ACT_VM_IDLE, @ReloadTime)
    @incomingHit = true
    @incomingHitTime = CurTime() + @PreSwing
    @NextThink(@incomingHitTime)
    return true
SWEP.SecondaryAttack = => false
