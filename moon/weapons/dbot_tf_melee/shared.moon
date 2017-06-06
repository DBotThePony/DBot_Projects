
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

BaseClass = baseclass.Get('dbot_tf_weapon_base')

SWEP.Base = 'dbot_tf_weapon_base'
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
SWEP.PreFire = 0.24
SWEP.BulletRange = 78
SWEP.BulletDamage = 65
SWEP.BulletForce = 20
SWEP.AttackAnimation = ACT_VM_HITCENTER
SWEP.AttackAnimationCrit = ACT_VM_SWINGHARD
SWEP.BulletHull = 8

SWEP.PlayMissSound = =>
    if not @icomingCrit
        return @EmitSound(@MissSoundsScript) if @MissSoundsScript
        playSound = table.Random(@MissSounds)
        @EmitSound(playSound, 50, 100, 1, CHAN_WEAPON) if playSound
    else
        return @EmitSound(@MissCritSoundsScript) if @MissCritSoundsScript
        playSound = table.Random(@MissSoundsCrit)
        @EmitSound(playSound, 50, 100, 1, CHAN_WEAPON) if playSound

SWEP.PlayHitSound = =>
    return @EmitSound(@HitSoundsScript) if @HitSoundsScript
    playSound = table.Random(@HitSounds)
    @EmitSound(playSound, 50, 100, 1, CHAN_WEAPON) if playSound

SWEP.PlayFleshHitSound = =>
    return @EmitSound(@HitSoundsFleshScript) if @HitSoundsFleshScript
    playSound = table.Random(@HitSoundsFlesh)
    @EmitSound(playSound, 75, 100, 1, CHAN_WEAPON) if playSound

SWEP.OnMiss = =>
    @PlayMissSound()

SWEP.OnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
    BaseClass.OnHit(@, hitEntity, tr, dmginfo)
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

