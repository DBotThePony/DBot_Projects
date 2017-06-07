
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
SWEP.UseHands = false
SWEP.DrawCrosshair = true
SWEP.IsTF2Weapon = true
SWEP.DamageDegradation = true

SWEP.DrawTime = 0.66
SWEP.DrawTimeAnimation = 1.16
SWEP.PreFire = 0
SWEP.CooldownTime = 0.8
SWEP.BulletRange = 32000
SWEP.BulletDamage = 65
SWEP.BulletForce = 1
SWEP.BulletHull = 1

SWEP.ViewModel = 'models/weapons/c_models/c_engineer_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_wrench/c_wrench.mdl'

SWEP.DrawAnimation = 'fj_draw'
SWEP.IdleAnimation = 'fj_idle'
SWEP.AttackAnimation = 'fj_fire'
SWEP.AttackAnimationCrit = 'fj_fire'

-- SWEP.AttackAnimationTable = {}
-- SWEP.AttackAnimationCritTable = {}

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
    @NetworkVar('Entity', 0, 'TF2WeaponModel')

SWEP.CheckNextCrit = =>
    return true if @GetCritBoosted()
    if @GetNextCrit()
        @SetNextCrit(false) if @SingleCrit
        return true
    @CheckCritical() if SERVER
    return false

SWEP.CheckNextMiniCrit = => @GetOwner()\GetMiniCritBoosted()

SWEP.Initialize = =>
    @SetPlaybackRate(0.5)
    @SendWeaponSequence(@IdleAnimation)
    @incomingFire = false
    @incomingFireTime = 0
    @damageDealtForCrit = 0
    @lastCritsTrigger = 0
    @lastCritsCheck = 0
    @incomingCrit = false
    @incomingMiniCrit = false

SWEP.WaitForAnimation = (anim = ACT_VM_IDLE, time = 0, callback = (->)) =>
    timer.Create "DTF2.WeaponAnim.#{@EntIndex()}", time, 1, ->
        return if not IsValid(@)
        return if not IsValid(@GetOwner())
        return if @GetOwner()\GetActiveWeapon() ~= @
        @SendWeaponAnim(anim)
        callback()

SWEP.WaitForAnimation2 = (anim = ACT_VM_IDLE, time = 0, callback = (->)) =>
    timer.Create "DTF2.WeaponAnim.#{@EntIndex()}", time, 1, ->
        return if not IsValid(@)
        return if not IsValid(@GetOwner())
        return if @GetOwner()\GetActiveWeapon() ~= @
        @SendWeaponAnim2(anim)
        callback()

SWEP.WaitForSequence = (anim = 0, time = 0, callback = (->)) =>
    timer.Create "DTF2.WeaponAnim.#{@EntIndex()}", time, 1, ->
        return if not IsValid(@)
        return if not IsValid(@GetOwner())
        return if @GetOwner()\GetActiveWeapon() ~= @
        @SendWeaponSequence(anim)
        callback()

SWEP.ClearTimeredAnimation = =>
    timer.Remove "DTF2.WeaponAnim.#{@EntIndex()}"

SWEP.CreateWeaponModel = =>
    if IsValid(@weaponModel)
        @SetTF2WeaponModel(@weaponModel)
        return @weaponModel
    return @GetTF2WeaponModel() if CLIENT or IsValid(@GetTF2WeaponModel())
    @weaponViewModel = ents.Create('dbot_tf_viewmodel')
    with @weaponViewModel
        \SetModel(@WorldModel)
        \SetPos(@GetPos())
        \Spawn()
        \Activate()
        \DoSetup(@)
        print @WorldModel
    @SetTF2WeaponModel(@weaponViewModel)
    return @weaponViewModel

SWEP.Deploy = =>
    @SendWeaponSequence(@DrawAnimation)
    @WaitForSequence(@IdleAnimation, @DrawTimeAnimation)
    @SetNextPrimaryFire(CurTime() + @DrawTime)
    @incomingFire = false
    if SERVER and @GetOwner()\IsPlayer()
        @CreateWeaponModel()
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
        return true
    return false

SWEP.OnMiss = =>
SWEP.OnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
    if not @incomingCrit and IsValid(hitEntity)
        @damageDealtForCrit += dmginfo\GetDamage()
    
    if (@incomingCrit or @incomingMiniCrit) and IsValid(hitEntity)
        mins, maxs = hitEntity\GetRotatedAABB(hitEntity\OBBMins(), hitEntity\OBBMaxs())
        pos = hitEntity\GetPos()
        newZ = math.max(pos.z, pos.z + mins.z, pos.z + maxs.z)
        pos.z = newZ

        effData = EffectData()
        effData\SetOrigin(pos)
        util.Effect(@incomingCrit and 'dtf2_critical_hit' or 'dtf2_minicrit', effData)
        hitEntity\EmitSound(@incomingCrit and 'DTF2_TFPlayer.CritHit' or 'DTF2_TFPlayer.CritHitMini')
    
    if @DamageDegradation and not @incomingCrit
        pos = tr.HitPos
        lpos = @GetOwner()\GetPos()
        dist = pos\DistToSqr(lpos) * 4
        dmginfo\ScaleDamage(math.Clamp(dist / 180, 0.2, 1.2))

SWEP.BulletCallback = (tr = {}, dmginfo) =>
    weapon = @GetActiveWeapon()
    weapon.bulletCallbackCalled = true

    if tr.Hit
        weapon\OnHit(tr.Entity, tr, dmginfo)
    else
        weapon\OnMiss(tr, dmginfo)

SWEP.UpdateBulletData = (bulletData = {}) =>
SWEP.AfterFire = (bulletData = {}) =>

SWEP.FireTrigger = =>
    @suppressing = true
    SuppressHostEvents(@GetOwner()) if SERVER and @GetOwner()\IsPlayer()
    @incomingFire = false
    @bulletCallbackCalled = false
    bulletData = {
        'Damage': @BulletDamage * (@incomingCrit and 3 or @incomingMiniCrit and 1.3 or 1)
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
    @AfterFire(bulletData)
    @OnMiss() if not @bulletCallbackCalled
    SuppressHostEvents(NULL) if SERVER
    @incomingCrit = false
    @incomingMiniCrit = false
    @suppressing = false

SWEP.Think = =>
    if @incomingFire and @incomingFireTime < CurTime()
        @FireTrigger()
    if CLIENT
        if @GetCritBoosted() or @GetOwner()\GetCritBoosted()
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
    @incomingCrit = @CheckNextCrit()
    @incomingMiniCrit = @CheckNextMiniCrit() if not @incomingCrit
    @SetNextPrimaryFire(CurTime() + @CooldownTime)
    @SendWeaponSequence(@AttackAnimationTable and DTF2.TableRandom(@AttackAnimationTable) or @AttackAnimation) if not @incomingCrit
    @SendWeaponSequence(@AttackAnimationCritTable and DTF2.TableRandom(@AttackAnimationCritTable) or @AttackAnimationCrit) if @incomingCrit
    @WaitForSequence(@IdleAnimation, @CooldownTime)
    @incomingFire = true
    @incomingFireTime = CurTime() + @PreFire
    @NextThink(@incomingFireTime)
    return true

SWEP.SecondaryAttack = => false
