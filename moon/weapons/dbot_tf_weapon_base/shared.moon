
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
SWEP.IsTF2Weapon = true

SWEP.DrawTime = 0.66
SWEP.DrawTimeAnimation = 1.16
SWEP.PreFire = 0
SWEP.CooldownTime = 0.96
SWEP.BulletRange = 32000
SWEP.BulletDamage = 65
SWEP.BulletForce = 1
SWEP.BulletHull = 1

SWEP.ViewModel = 'models/weapons/c_models/c_wrench/c_wrench.mdl'
SWEP.HandsModel = 'models/weapons/c_models/c_engineer_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_wrench/c_wrench.mdl'

SWEP.AttackAnimation = ACT_VM_PRIMARYATTACK
SWEP.AttackAnimationCrit = ACT_VM_PRIMARYATTACK
SWEP.CritChance = 4
SWEP.CritExponent = 0.1
SWEP.CritExponentMax = 12
SWEP.SingleCrit = true
SWEP.CritDuration = 4
SWEP.CritsCooldown = 2
SWEP.CritsCheckCooldown = 0

SWEP.SetupDataTables = =>
    @NetworkVar('Bool', 0, 'NextCrit')
    @NetworkVar('Bool', 1, 'CritBoosted')
    @NetworkVar('Bool', 2, 'TeamType')
    @NetworkVar('Float', 0, 'CriticalsDuration')

SWEP.CheckNextCrit = =>
    return true if @GetCritBoosted()
    if @GetNextCrit()
        @SetNextCrit(false) if @SingleCrit
        return true
    @CheckCritical() if SERVER
    return false

SWEP.Initialize = =>
    @SetPlaybackRate(0.5)
    @SendWeaponAnim(ACT_VM_IDLE)
    @incomingFire = false
    @incomingFireTime = 0
    @damageDealtForCrit = 0
    @lastCritsTrigger = 0
    @lastCritsCheck = 0

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
    if SERVER and @GetOwner()\IsPlayer()
        hands = @GetOwner()\GetHands()
        if IsValid(hands)
            hands.__dtf2_old_model = hands.__dtf2_old_model or hands\GetModel()
            hands\SetModel(@HandsModel)
    return true

SWEP.Holster = =>
    if @GetNextPrimaryFire() < CurTime()
        if @critBoostSound
            @critBoostSound\Stop()
            @critBoostSound = nil
        if @critEffect
            @critEffect\StopEmissionAndDestroyImmediately()
            @critEffect = nil
        if @critEffectGlow
            @critEffectGlow\StopEmissionAndDestroyImmediately()
            @critEffectGlow = nil
        if SERVER and @GetOwner()\IsPlayer()
            hands = @GetOwner()\GetHands()
            if IsValid(hands)
                hands\SetModel(hands.__dtf2_old_model or hands\GetModel())
                hands.__dtf2_old_model = nil
        return true
    return false

SWEP.OnMiss = =>
SWEP.OnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
    if not @icomingCrit and IsValid(hitEntity)
        @damageDealtForCrit += dmginfo\GetDamage()
    
    if @icomingCrit and IsValid(hitEntity)
        mins, maxs = hitEntity\GetRotatedAABB(hitEntity\OBBMins(), hitEntity\OBBMaxs())
        pos = hitEntity\GetPos()
        newZ = math.max(pos.z, pos.z + mins.z, pos.z + maxs.z)
        pos.z = newZ

        effData = EffectData()
        effData\SetOrigin(pos)
        util.Effect('dtf2_critical_hit', effData)
        hitEntity\EmitSound('TFPlayer.CritHit')

SWEP.BulletCallback = (tr = {}, dmginfo) =>
    weapon = @GetActiveWeapon()
    weapon.bulletCallbackCalled = true

    if tr.Hit
        weapon\OnHit(tr.Entity, tr, dmginfo)
    else
        weapon\OnMiss(tr, dmginfo)

SWEP.UpdateBulletData = (bulletData = {}) =>

SWEP.FireTrigger = =>
    @suppressing = true
    SuppressHostEvents(@GetOwner()) if SERVER and @GetOwner()\IsPlayer()
    @incomingFire = false
    @bulletCallbackCalled = false
    bulletData = {
        'Damage': @BulletDamage * (@icomingCrit and 3 or 1)
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
    @icomingCrit = false
    @suppressing = false

SWEP.Think = =>
    if @incomingFire and @incomingFireTime < CurTime()
        @FireTrigger()
    if CLIENT
        if @GetCritBoosted()
            if not @critBoostSound
                @critBoostSound = CreateSound(@, 'Weapon_General.CritPower')
                @critBoostSound\Play()
            if @GetOwner() == LocalPlayer()
                if not @critEffect
                    @critEffect = CreateParticleSystem(@GetOwner()\GetViewModel(), @GetTeamType() and 'critgun_weaponmodel_blu' or 'critgun_weaponmodel_red', PATTACH_ABSORIGIN_FOLLOW, 0, Vector(0, 0, 0))
                if not @critEffectGlow
                    @critEffectGlow = CreateParticleSystem(@GetOwner()\GetViewModel(), @GetTeamType() and 'critgun_weaponmodel_blu_glow' or 'critgun_weaponmodel_red_glow', PATTACH_ABSORIGIN_FOLLOW, 0, Vector(0, 0, 0))
        else
            if @critBoostSound
                @critBoostSound\Stop()
                @critBoostSound = nil
            if @critEffect
                @critEffect\StopEmissionAndDestroyImmediately()
                @critEffect = nil
            if @critEffectGlow
                @critEffectGlow\StopEmissionAndDestroyImmediately()
                @critEffectGlow = nil

SWEP.PrimaryAttack = =>
    return false if @GetNextPrimaryFire() > CurTime()
    @icomingCrit = @CheckNextCrit()
    @SetNextPrimaryFire(CurTime() + @CooldownTime)
    @SendWeaponAnim(@AttackAnimation) if not @icomingCrit
    @SendWeaponAnim(@AttackAnimationCrit) if @icomingCrit
    @WaitForAnimation(ACT_VM_IDLE, @CooldownTime)
    @incomingFire = true
    @incomingFireTime = CurTime() + @PreFire
    @NextThink(@incomingFireTime)
    return true

SWEP.SecondaryAttack = => false
