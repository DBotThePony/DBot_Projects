
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
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.Slot = 2
SWEP.SlotPos = 16

SWEP.Primary = {
    'Ammo': 'SMG1'
    'ClipSize': 15
    'DefaultClip': 15
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
SWEP.PreFire = 0.05
SWEP.ReloadDeployTime = 0.4
SWEP.ReloadTime = 0.5
SWEP.ReloadFinishAnimTime = 0.3
SWEP.ReloadFinishAnimTimeIdle = 0.96
SWEP.ReloadBullets = 15
SWEP.TakeBulletsOnFire = 1
SWEP.CooldownTime = 0.7
SWEP.BulletDamage = 12
SWEP.DefaultSpread = Vector(0, 0, 0)
SWEP.BulletsAmount = 1

SWEP.MuzzleAttachment = 'muzzle'

SWEP.Reloadable = true

SWEP.Initialize = =>
    @isReloading = false
    @reloadNext = 0

SWEP.Reload = =>
    return false if not @Reloadable
    return false if @Clip1() == @GetMaxClip1()
    return false if @isReloading
    return false if @GetNextPrimaryFire() > CurTime()
    return false if @GetOwner()\IsPlayer() and @GetOwner()\GetAmmoCount(@Primary.Ammo) <= 0
    @isReloading = true
    @reloadNext = CurTime() + @ReloadDeployTime
    @SendWeaponAnim(ACT_RELOAD_START)
    @ClearTimeredAnimation()
    return true

SWEP.GetBulletSpread = => @DefaultSpread
SWEP.GetBulletAmount = => @BulletsAmount

SWEP.UpdateBulletData = (bulletData = {}) =>
    bulletData.Spread = @GetBulletSpread()
    bulletData.Num = @GetBulletAmount()

SWEP.BulletCallback = (tr = {}, dmginfo) =>
    weapon = @GetActiveWeapon()
    weapon.bulletCallbackCalled = true

    if tr.Hit
        weapon\OnHit(tr.Entity, tr, dmginfo)
    else
        weapon\OnMiss(tr, dmginfo)

SWEP.PlayFireSound = =>
    playSound = table.Random(@FireSounds) if @FireSounds
    @EmitSound(playSound, SNDLVL_GUNSHOT, 100, .7, CHAN_WEAPON) if playSound

SWEP.EmitMuzzleFlash = =>
    viewModel = @GetOwner()\GetViewModel()
    {:Pos, :Ang} = viewModel\GetAttachment(@LookupAttachment(@MuzzleAttachment))
    emmiter = ParticleEmitter(Pos, true)
    return if not emmiter
    for i = 1, math.random(3, 5)
        with emmiter\Add('models/effects/muzzleflash/brightmuzzle', Pos)
            \SetDieTime(0.1)
            size = math.random(3, 6) / 6
            \SetStartSize(size)
            \SetEndSize(size)
            \SetColor(255, 255, 255)
            \SetRoll(math.random(-90, 90))
    emmiter\Finish()

SWEP.PrimaryAttack = =>
    return false if @GetNextPrimaryFire() > CurTime()
    if @Clip1() <= 0
        @Reload()
        return false
    @isReloading = false
    @TakePrimaryAmmo(@TakeBulletsOnFire)
    @PlayFireSound()
    if CLIENT and @GetOwner() == LocalPlayer() and @lastMuzzle ~= FrameNumber()
        @lastMuzzle = FrameNumber()
        @EmitMuzzleFlash()
    return BaseClass.PrimaryAttack(@)
