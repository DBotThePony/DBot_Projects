 
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

AccessorFunc(ENT, 'm_Attacker', 'Attacker')
AccessorFunc(ENT, 'm_Inflictor', 'Inflictor')
AccessorFunc(ENT, 'm_Weapon', 'Weapon')
AccessorFunc(ENT, 'm_dir', 'Direction')
AccessorFunc(ENT, 'm_damage', 'Damage')
AccessorFunc(ENT, 'm_ImpactFleshSound', 'ImpactFleshSound')
AccessorFunc(ENT, 'm_ImpactWorldSound', 'ImpactWorldSound')
AccessorFunc(ENT, 'm_ProjectileSpeed', 'ProjectileSpeed')
AccessorFunc(ENT, 'm_DamageDegradation', 'DamageDegradation')
AccessorFunc(ENT, 'm_DegradationDivider', 'DegradationDivider')
AccessorFunc(ENT, 'm_BlowSound', 'BlowSound')
AccessorFunc(ENT, 'm_Explosive', 'IsExplosive')
AccessorFunc(ENT, 'm_dir', 'Direction')
AccessorFunc(ENT, 'm_Direct', 'DirectHit')
AccessorFunc(ENT, 'm_DirectTarget', 'DirectHitTarget')
AccessorFunc(ENT, 'm_BlowRadius', 'BlowRadius')
AccessorFunc(ENT, 'm_BlowEffect', 'BlowEffect')
AccessorFunc(ENT, 'm_ProjectileForce', 'ProjectileForce')
AccessorFunc(ENT, 'm_AmmoType', 'AmmoType')
AccessorFunc(ENT, 'm_BulletDamageType', 'BulletDamageType')

ENT.Initialize = =>
    @SetModel(@ProjectileModel)
    @PhysicsInitSphere(@ProjectileSize)
    @initialPosition = @GetPos()
    @SetBlowRadius(@BlowRadius) if @GetBlowRadius() == nil
    @SetInflictor(@) if @GetInflictor() == nil
    @SetAttacker(@) if @GetAttacker() == nil
    @SetDamage(@ProjectileDamage) if @GetDamage() == nil
    @SetBlowEffect(@BlowEffect) if @GetBlowEffect() == nil
    @SetProjectileForce(@ProjectileForce) if @GetProjectileForce() == nil
    @SetAmmoType(@AmmoType) if @GetAmmoType() == nil
    @SetBlowSound(@BlowSound) if @GetBlowSound() == nil
    @SetProjectileSpeed(@ProjectileSpeed) if @GetProjectileSpeed() == nil
    @SetDegradationDivider(@DegradationDivider) if @GetDegradationDivider() == nil
    @SetIsExplosive(@Explosive) if @GetIsExplosive() == nil
    @SetImpactFleshSound(@ImpactFleshSound) if @GetImpactFleshSound() == nil
    @SetImpactWorldSound(@ImpactWorldSound) if @GetImpactWorldSound() == nil
    @SetDamageDegradation(@DamageDegradation) if @GetDamageDegradation() == nil
    @SetBulletDamageType(@BulletDamageType) if @GetBulletDamageType() == nil

    @explodeAt = CurTime() + @ExplodeAt if @ShouldExplode
    @removeAt = CurTime() + @RemoveTimer if @ShouldRemove

    with @phys = @GetPhysicsObject()
        \EnableMotion(true)
        \SetMass(@ProjectileMass)
        \EnableGravity(@Gravity)
        \Wake()
    
    @SetDirection(Vector(0, 0, 0))

ENT.SetDirectionFunc = ENT.SetDirection

ENT.SetDirection = (dir = Vector(0, 0, 0)) =>
    @SetDirectionFunc(dir)
    newVel = Vector(dir)
    newVel.z += @ZAddition
    @phys\SetVelocity(newVel * @GetProjectileSpeed())
    @SetAngles(dir\Angle())

ENT.Think = =>
    return @Remove() if not @phys\IsValid()
    return @Remove() if @ShouldRemove and @removeAt < CurTime()
    return @Explode() if @ShouldExplode and @explodeAt < CurTime()
    @phys\SetVelocity(@GetDirection() * @GetProjectileSpeed()) if @EndlessFlight
    if @SetupFireAngle and not @angleSetup
        @angleSetup = true
        @SetAngles(@GetDirection()\Angle())

ENT.PhysicsCollide = (data = {}, colldier) =>
    {:HitPos, :HitEntity, :HitNormal} = data
    return false if HitEntity == @GetAttacker()

    @OnCollision(HitEntity, HitNormal, HitPos)
    
    return unless @IsValid() and @GetIsFlying()
    @SetIsFlying(false)
    @OnHit(HitEntity, HitNormal, HitPos)
    @SetCollisionGroup(@ImpactCollisionGroup)

    if @GetIsExplosive()
        if @ExplodeOnEntityImpact or @ExplodeOnWorldImpact
            if IsValid(HitEntity)
                @SetDirectHit(HitEntity)
                @SetDirectHitTarget(HitEntity)
            @Explode(HitEntity, HitNormal, HitPos)
        else
            if IsValid(HitEntity)
                @EmitSound(@GetImpactFleshSound()) 
            else
                @EmitSound(@GetImpactWorldSound())
    else
        @HitEntity(HitEntity, HitNormal, HitPos)
        if IsValid(HitEntity)
            @EmitSound(@GetImpactFleshSound())
        else
            @EmitSound(@GetImpactWorldSound())

ENT.OnHit = (HitEntity, HitNormal = Vector(0, 0, 0), HitPos = @GetPos()) =>
ENT.OnCollision = (HitEntity, HitNormal = Vector(0, 0, 0), HitPos = @GetPos()) =>
ENT.OnHitAfter = (attacker, ent, dmg) ->
ENT.StoreVariables = (attacker) => {}

ENT.HitCallback = (ent, attacker, dmg) ->
    attacker\dtf2_projectile_toCallAfter(ent, dmg)
    --if not attacker.dtf2_GetIsCritical
    --    dmg\SetDamage(attacker.dtf2_incomingDamage * (1 - math.Clamp(attacker.dtf2_hitPos\Distance(ent\GetPos()) / attacker.dtf2_blowRadius / 2, 0, 1)))
    if attacker.dtf2_TargetTakesFullDamage and attacker.dtf2_DirectHitTarget == ent
        dmg\SetDamage(attacker.dtf2_incomingDamage)
    if attacker.dtf2_GetIsCritical
        DTF2.PlayCritEffect(ent)
    elseif attacker.dtf2_GetIsMiniCritical
        DTF2.PlayMiniCritEffect(ent)
    elseif ent\IsMarkedForDeath()
        DTF2.PlayMiniCritEffect(ent)
        dmg\ScaleDamage(1.3)
    if IsValid(attacker.dtf2_weapon)
        attacker.dtf2_weapon\AddDamageDealt(dmg\GetDamage())

ENT.BulletCallback = (tr, dmg) =>
    dmg\SetAttacker(@GetAttacker())
    dmg\SetInflictor(@GetInflictor())
    dmg\SetDamageType(@GetBulletDamageType())
    ent = tr.Entity
    return if not IsValid(ent)
    if @GetIsCritical()
        DTF2.PlayCritEffect(ent)
    elseif @GetIsMiniCritical()
        DTF2.PlayCritEffect(ent)
    if weapon = @GetWeapon()
        if IsValid(weapon)
            weapon\AddDamageDealt(dmg\GetDamage())

ENT.HitEntity = (HitEntity, HitNormal = Vector(0, 0, 0), HitPos = @GetPos()) =>
    mult = @GetIsCritical() and 3 or @GetIsMiniCritical() and 1.3 or 1
    degradation = 1
    if not @GetIsCritical() and @GetDamageDegradation()
        degradation = 1 - math.Clamp(@initialPosition\Distance(HitPos) / @GetDegradationDivider() - .2, -0.1, @GetIsMiniCritical() and 0.1 or 0.3)

    bulletData = {
        Callback: @BulletCallback
        Damage: @GetDamage() * mult * degradation
        Force: @GetProjectileForce()
        Distance: 40
        Src: HitPos - HitNormal
        Dir: HitNormal
        AmmoType: @GetAmmoType()
    }

    @FireBullets(bulletData)
    @Remove()

ENT.Explode = (HitEntity, HitNormal = Vector(0, 0, 0), HitPos = @GetPos()) =>
    @SetSolid(SOLID_NONE)
    @EmitSound(@GetBlowSound())
    mult = @GetIsCritical() and 3 or @GetIsMiniCritical() and 1.3 or 1
    degradation = 1
    if not @GetIsCritical() and @GetDamageDegradation()
        degradation = 1 - math.Clamp(@initialPosition\Distance(HitPos) / @GetDegradationDivider() - .2, -0.1, @GetIsMiniCritical() and 0.1 or 0.3)

    attacker = @GetAttacker()
    inflictor = @GetInflictor()
    blow = @GetBlowRadius()
    GetIsCritical = @GetIsCritical()
    GetIsMiniCritical = @GetIsMiniCritical()
    incomingDamage = @GetDamage() * mult * degradation
    toCallAfter = @OnHitAfter
    HitCallback = @HitCallback
    DirectHit = @GetDirectHit()
    DirectHitTarget = @GetDirectHitTarget()
    TargetTakesFullDamage = @TargetTakesFullDamage
    stored = @StoreVariables(attacker)
    weapon = @GetWeapon()
    timer.Simple 0.1, ->
        self = attacker
        @dtf2_incomingDamage = incomingDamage
        @dtf2_hitPos = HitPos
        @dtf2_blowRadius = blow
        @dtf2_projectile = true
        @dtf2_projectile_toCallAfter = toCallAfter
        @dtf2_GetIsCritical = GetIsCritical
        @dtf2_GetIsMiniCritical = GetIsMiniCritical
        @dtf2_HitCallback = HitCallback
        @dtf2_DirectHit = DirectHit
        @dtf2_DirectHitTarget = DirectHitTarget
        @dtf2_TargetTakesFullDamage = TargetTakesFullDamage
        @dtf2_weapon = weapon
        @[key] = val for key, val in pairs stored
        util.BlastDamage(inflictor, attacker, HitPos - HitNormal * 50, incomingDamage, blow * 3)
        @dtf2_projectile = false

    effData = EffectData()
    effData\SetNormal(-HitNormal)
    effData\SetOrigin(HitPos - HitNormal * 12)
    util.Effect(@GetBlowEffect(), effData)
    @Remove()

hook.Add 'EntityTakeDamage', 'DTF2.ProjectileExplosion', (ent, dmg) ->
    if attacker = dmg\GetAttacker()
        if attacker\IsValid() and attacker.dtf2_projectile
            attacker.dtf2_HitCallback(ent, attacker, dmg)

hook.Add 'EntityTakeDamage', 'DTF2.ProjectileExplosionFix', (ent, dmg) ->
    attacker = dmg\GetAttacker()
    return if not IsValid(attacker)
    return if not attacker.IsTF2Projectile
    return if dmg\GetDamageType() ~= DMG_CRUSH
    dmg\SetDamage(0)
    dmg\SetMaxDamage(0)
