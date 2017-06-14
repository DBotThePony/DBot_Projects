
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
SWEP.RandomCriticals = true
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

-- SWEP.ViewModels = {}
-- SWEP.ViewModelEffects = {}

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
    @playingEffects = {}
    @playingEffectsTable = {}

SWEP.WaitForAnimation = (anim = ACT_VM_IDLE, time = 0, callback = (->)) =>
    timer.Create "DTF2.WeaponAnim.#{@EntIndex()}", time, 1, ->
        return if not IsValid(@)
        return if not IsValid(@GetOwner())
        return if @GetOwner()\GetActiveWeapon() ~= @
        @SendWeaponAnim(anim)
        callback()

SWEP.WaitForSound = (soundPlay, time = 0, callback = (->)) =>
    timer.Create "DTF2.WeaponSound.#{@EntIndex()}", time, 1, ->
        return if not IsValid(@)
        return if not IsValid(@GetOwner())
        return if @GetOwner()\GetActiveWeapon() ~= @
        @EmitSound(soundPlay)
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

SWEP.PostModelCreated = (viewmodel = @GetOwner()\GetViewModel(), ent = @weaponModel) =>

SWEP.CreateWeaponModel = =>
    if IsValid(@TF2weaponViewModel)
        @SetTF2WeaponModel(@TF2weaponViewModel)
        with @TF2weaponViewModel
            \SetModel(@WorldModel)
            \SetPos(@GetPos())
            \DoSetup(@)
        return @TF2weaponViewModel
    return @GetTF2WeaponModel() if CLIENT or IsValid(@GetTF2WeaponModel())
    @TF2weaponViewModel = ents.Create('dbot_tf_viewmodel')
    with @TF2weaponViewModel
        \SetModel(@WorldModel)
        \SetPos(@GetPos())
        \Spawn()
        \Activate()
        \DoSetup(@)
    @SetTF2WeaponModel(@TF2weaponViewModel)
    @PostModelCreated(@GetOwner()\GetViewModel(), @TF2weaponViewModel)
    return @TF2weaponViewModel

SWEP.AddParticle = (name, attachID = 0, attach = PATTACH_ABSORIGIN_FOLLOW, offset = Vector(0, 0, 0)) =>
    return @playingEffectsTable[name] if IsValid(@playingEffectsTable[name])
    attachID = @LookupAttachment(tostring(attachID)) if type(attachID) ~= 'number'
    @playingEffectsTable[name] = CreateParticleSystem(@GetOwner()\GetViewModel(), name, attach, attachID, offset)
    table.insert(@playingEffects, @playingEffectsTable[name])
    return @playingEffectsTable[name]

SWEP.RemoveParticle = (name) =>
    return false if not IsValid(@playingEffectsTable[name])
    @playingEffectsTable[name]\StopEmissionAndDestroyImmediately()
    return true

SWEP.StopParticle = (name) =>
    return false if not IsValid(@playingEffectsTable[name])
    @playingEffectsTable[name]\StopEmission()
    return true

SWEP.Deploy = =>
    @SendWeaponSequence(@DrawAnimation)
    @WaitForSequence(@IdleAnimation, @DrawTimeAnimation)
    @SetNextPrimaryFire(CurTime() + @DrawTime)
    @incomingFire = false
    if SERVER and @GetOwner()\IsPlayer()
        @CreateWeaponModel()
    if CLIENT
        eff\StopEmissionAndDestroyImmediately() for eff in *@playingEffects when IsValid(eff)
        vm = @GetOwner()\GetViewModel()
        @playingEffects = [CreateParticleSystem(vm, effName, PATTACH_ABSORIGIN_FOLLOW, 0, Vector(0, 0, 0)) for effName in *@ViewModelEffects when type(effName) == 'string'] if @ViewModelEffects
        @playingEffectsTable = {}
    return true

SWEP.Holster = =>
    if @GetNextPrimaryFire() < CurTime()
        if CLIENT
            if @critBoostSound
                @critBoostSound\Stop()
                @critBoostSound = nil
            if @critEffect
                @critEffect\StopEmissionAndDestroyImmediately()
                @critEffect = nil
            if @critEffectGlow
                @critEffectGlow\StopEmissionAndDestroyImmediately()
                @critEffectGlow = nil
            eff\StopEmissionAndDestroyImmediately() for eff in *@playingEffects when IsValid(eff)
            @playingEffects = {}
            @playingEffectsTable = {}
        return true
    return false

SWEP.AttackAngle = (target = NULL) =>
    return 0 if not IsValid(target)
    return 0 if not IsValid(@GetOwner())
    return 0 if not target.EyeAngles
    angFirst = target\EyeAngles()
    pos = target\GetPos()
    lpos = @GetOwner()\GetPos()
    dir = lpos - pos
    ang = dir\Angle()
    ang\Normalize()
    ang.y -= angFirst.y
    return ang.y

SWEP.AttackingAtSpine = (target = NULL) =>
    ang = @AttackAngle(target)
    return ang < -90 or ang > 90

SWEP.PreOnMiss = =>
SWEP.OnMiss = =>
SWEP.PostOnMiss = =>
SWEP.PreOnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
SWEP.PostOnHit = (hitEntity = NULL, tr = {}, dmginfo) =>

SWEP.DisplayCritEffect = (hitEntity) =>
    mins, maxs = hitEntity\GetRotatedAABB(hitEntity\OBBMins(), hitEntity\OBBMaxs())
    pos = hitEntity\GetPos()
    newZ = math.max(pos.z, pos.z + mins.z, pos.z + maxs.z)
    pos.z = newZ

    effData = EffectData()
    effData\SetOrigin(pos)
    util.Effect(@incomingCrit and 'dtf2_critical_hit' or 'dtf2_minicrit', effData)
    hitEntity\EmitSound(@incomingCrit and 'DTF2_TFPlayer.CritHit' or 'DTF2_TFPlayer.CritHitMini')

SWEP.OnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
    if not @incomingCrit and IsValid(hitEntity)
        @damageDealtForCrit += dmginfo\GetDamage()
    
    if (@incomingCrit or @incomingMiniCrit) and IsValid(hitEntity)
        @DisplayCritEffect(hitEntity)
    
    if @DamageDegradation and not @incomingCrit
        pos = tr.HitPos
        lpos = @GetOwner()\GetPos()
        dist = pos\DistToSqr(lpos) * 4
        dmginfo\ScaleDamage(math.Clamp(dist / 180, 0.2, 1.2))

SWEP.BulletCallback = (tr = {}, dmginfo) =>
    weapon = @GetActiveWeapon()
    dmginfo\SetInflictor(weapon)
    weapon.bulletCallbackCalled = true
    weapon.currentHitEntity = tr.Entity
    weapon.currentDMGInfo = dmginfo
    if IsValid(tr.Entity) and tr.Entity\IsMarkedForDeath()
        weapon\ThatWasMinicrit()
    weapon\PreOnHit(tr.Entity, tr, dmginfo)
    weapon\OnHit(tr.Entity, tr, dmginfo)
    weapon.onHitCalled = true
    weapon\PostOnHit(tr.Entity, tr, dmginfo)

SWEP.UpdateBulletData = (bulletData = {}) =>
SWEP.AfterFire = (bulletData = {}) =>

SWEP.ThatWasMinicrit = (hitEntity = @currentHitEntity, dmginfo = @currentDMGInfo) =>
    return if @incomingCrit or @incomingMiniCrit
    @incomingMiniCrit = true
    @DisplayCritEffect(hitEntity) if @onHitCalled
    dmginfo\ScaleDamage(1.3)

SWEP.ThatWasCrit = (hitEntity = @currentHitEntity, dmginfo = @currentDMGInfo) =>
    return if @incomingCrit
    @incomingCrit = true
    @DisplayCritEffect(hitEntity) if @onHitCalled
    if @incomingMiniCrit
        dmginfo\ScaleDamage(1 / 1.3)
        @incomingMiniCrit = false
    dmginfo\ScaleDamage(3)

SWEP.PreFireTrigger = =>
    @suppressing = true
    SuppressHostEvents(@GetOwner()) if SERVER and @GetOwner()\IsPlayer()

SWEP.PostFireTrigger = =>
    SuppressHostEvents(NULL) if SERVER
    @suppressing = false

SWEP.FireTrigger = =>
    @bulletCallbackCalled = false
    @onHitCalled = false
    bulletData = {
        'Damage': @BulletDamage * (@incomingCrit and 3 or @incomingMiniCrit and 1.3 or 1)
        'Callback': @BulletCallback
        'Src': @GetOwner()\EyePos()
        'Dir': @GetOwner()\GetAimVector()
        'Distance': @BulletRange
        'HullSize': @BulletHull
        'Force': @BulletForce
    }

    @UpdateBulletData(bulletData)

    @GetOwner()\FireBullets(bulletData)
    @AfterFire(bulletData)
    if not @bulletCallbackCalled
        @PreOnMiss()
        @OnMiss()
        @PostOnMiss()


AccessorFunc(SWEP, 'incomingFire', 'IncomingFire')
AccessorFunc(SWEP, 'incomingFireTime', 'IncomingFireTime')

SWEP.Think = =>
    if @incomingFire and @incomingFireTime < CurTime()
        @incomingFire = false
        @PreFireTrigger()
        @FireTrigger()
        @PostFireTrigger()
        @incomingCrit = false
        @incomingMiniCrit = false
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
