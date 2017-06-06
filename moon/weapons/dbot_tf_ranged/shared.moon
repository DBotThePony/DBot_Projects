
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

SWEP.DefaultViewPunch = Angle(0, 0, 0)

SWEP.MuzzleAttachment = 'muzzle'

SWEP.CritChance = 2
SWEP.CritExponent = 0.05
SWEP.CritExponentMax = 10
SWEP.SingleCrit = false

SWEP.SingleReloadAnimation = false
SWEP.DrawAnimation = 'fj_draw'
SWEP.IdleAnimation = 'fj_idle'
SWEP.AttackAnimation = 'fj_fire'
SWEP.AttackAnimationCrit = 'fj_fire'
SWEP.ReloadStart = 'fj_reload_start'
SWEP.ReloadLoop = 'fj_reload_loop'
SWEP.ReloadEnd = 'fj_reload_end'

SWEP.Reloadable = true

SWEP.Initialize = =>
    BaseClass.Initialize(@)
    @isReloading = false
    @reloadNext = 0
    @lastEmptySound = 0

SWEP.Reload = =>
    return false if not @Reloadable
    return false if @Clip1() == @GetMaxClip1()
    return false if @isReloading
    return false if @GetNextPrimaryFire() > CurTime()
    return false if @GetOwner()\IsPlayer() and @GetOwner()\GetAmmoCount(@Primary.Ammo) <= 0
    @isReloading = true
    @reloadNext = CurTime() + @ReloadDeployTime
    @SendWeaponSequence(@ReloadStart)
    @ClearTimeredAnimation()
    return true

SWEP.Deploy = =>
    BaseClass.Deploy(@)
    @isReloading = false
    @lastEmptySound = 0
    return true

SWEP.GetBulletSpread = => @DefaultSpread
SWEP.GetBulletAmount = => @BulletsAmount
SWEP.GetViewPunch = => @DefaultViewPunch

SWEP.UpdateBulletData = (bulletData = {}) =>
    if CLIENT
        viewModel = @GetTF2WeaponModel()
        if muzzle = viewModel\GetAttachment(viewModel\LookupAttachment(@MuzzleAttachment))
            {:Pos, :Ang} = muzzle
            bulletData.Src = Pos
            dir = @GetOwner()\GetEyeTrace().HitPos - Pos
            dir\Normalize()
            bulletData.Dir = dir

    bulletData.Spread = @GetBulletSpread()
    bulletData.Num = @GetBulletAmount()

SWEP.BulletCallback = (tr = {}, dmginfo) =>
    weapon = @GetActiveWeapon()
    weapon.bulletCallbackCalled = true

    if tr.Hit
        weapon\OnHit(tr.Entity, tr, dmginfo)
    else
        weapon\OnMiss(tr, dmginfo)

SWEP.PlayFireSound = (isCrit = @icomingCrit) =>
    if not isCrit
        return @EmitSound(@FireSoundsScript) if @FireSoundsScript
        playSound = table.Random(@FireSounds) if @FireSounds
        @EmitSound(playSound, SNDLVL_GUNSHOT, 100, .7, CHAN_WEAPON) if playSound
    else
        return @EmitSound(@FireCritSoundsScript) if @FireCritSoundsScript
        playSound = table.Random(@FireCritSounds) if @FireCritSounds
        @EmitSound(playSound, SNDLVL_GUNSHOT, 100, .7, CHAN_WEAPON) if playSound

SWEP.PlayEmptySound = =>
    return if @lastEmptySound > CurTime()
    @lastEmptySound = CurTime() + 1
    return @EmitSound(@EmptySoundsScript) if @EmptySoundsScript
    playSound = table.Random(@EmptySounds) if @EmptySounds
    @EmitSound(playSound, 75, 100, .7, CHAN_WEAPON) if playSound

SWEP.EmitMuzzleFlash = =>
    viewModel = @GetTF2WeaponModel()
    {:Pos, :Ang} = viewModel\GetAttachment(viewModel\LookupAttachment(@MuzzleAttachment))
    emmiter = ParticleEmitter(Pos, false)
    return if not emmiter
    for i = 1, math.random(3, 5)
        with emmiter\Add('effects/muzzleflash' .. math.random(1, 4), Pos)
            \SetDieTime(0.1)
            size = math.random(20, 60) / 6
            \SetStartSize(size)
            \SetEndSize(size)
            \SetColor(255, 255, 255)
            \SetRoll(math.random(-180, 180))
    emmiter\Finish()

SWEP.PrimaryAttack = =>
    return false if @GetNextPrimaryFire() > CurTime()
    if @Clip1() <= 0
        @Reload()
        @PlayEmptySound()
        return false
    
    status = BaseClass.PrimaryAttack(@)
    return status if status == false
    
    @isReloading = false
    @TakePrimaryAmmo(@TakeBulletsOnFire)
    @PlayFireSound()

    @GetOwner()\ViewPunch(@GetViewPunch())

    if game.SinglePlayer() and SERVER
        @CallOnClient('EmitMuzzleFlash')
    if CLIENT and @GetOwner() == LocalPlayer() and @lastMuzzle ~= FrameNumber()
        @lastMuzzle = FrameNumber()
        @EmitMuzzleFlash()
    
    return true
