
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

ENT.PrintName = 'Piepomb Projectile'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'base_anim'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.IsTF2PipeBomb = true

ENT.GrenadeModel = 'models/weapons/w_models/w_grenade_grenadelauncher.mdl'
ENT.BlowRadius = 350
ENT.BlowEffect = 'dtf2_pipebomb_explosion'
ENT.ExplosionEffect = 'DTF2_Weapon_Grenade_Pipebomb.Explode'
ENT.BounceEffect = 'DTF2_Weapon_Grenade_Pipebomb.BounceSound'

ENT.SetupDataTables = =>
    @NetworkVar('Bool', 0, 'IsFlying')
    @NetworkVar('Bool', 1, 'IsCritical')
    @NetworkVar('Bool', 2, 'IsMiniCritical')
    @SetIsFlying(true)

if SERVER
    AccessorFunc(ENT, 'm_Attacker', 'Attacker')
    AccessorFunc(ENT, 'm_Inflictor', 'Inflictor')
    AccessorFunc(ENT, 'm_blowRadius', 'BlowRadius')
    AccessorFunc(ENT, 'm_dir', 'Direction')
    AccessorFunc(ENT, 'm_damage', 'Damage')
    AccessorFunc(ENT, 'm_blowEffect', 'BlowEffect')
    AccessorFunc(ENT, 'm_expEffect', 'ExplosionEffect')
    AccessorFunc(ENT, 'm_PipebombForce', 'PipebombForce')
    AccessorFunc(ENT, 'm_BounceEffect', 'BounceEffect')

ENT.DefaultDamage = 100
ENT.DefaultDamageBounce = 60
ENT.RemoveTimer = 10
ENT.PipebombForce = 1200
ENT.LiveTime = 2.3

ENT.Initialize = =>
    @SetModel(@GrenadeModel)
    return if CLIENT
    @removeAt = CurTime() + @RemoveTimer

    @PhysicsInitSphere(8)
    @SetBlowRadius(@BlowRadius)
    @SetInflictor(@)
    @SetAttacker(@)
    @SetDamage(@DefaultDamage)
    @SetBlowEffect(@BlowEffect)
    @SetExplosionEffect(@ExplosionEffect)
    @SetPipebombForce(@PipebombForce)
    @SetBounceEffect(@BounceEffect)
    @explodeAt = CurTime() + @LiveTime

    with @phys = @GetPhysicsObject()
        \EnableMotion(true)
        \EnableDrag(false)
        \SetMass(5)
        \Wake()

ENT.Draw = =>
    @DrawModel()
    if not @particles
        @particles = CreateParticleSystem(@, 'pipebombtrail_red', PATTACH_ABSORIGIN_FOLLOW, 0)
        @particles2 = CreateParticleSystem(@, 'critical_grenade_red', PATTACH_ABSORIGIN_FOLLOW, 0) if @GetIsCritical()

ENT.RotateAngle = Angle(0, 0, 0)
ENT.SetDirection = (dir = Vector(0, 0, 0)) =>
    newVel = Vector(dir)
    newVel.z += 0.18
    @phys\SetVelocity(newVel * @GetPipebombForce())
    newDir = Vector(dir)
    newDir\Rotate(@RotateAngle)
    @SetAngles(newDir\Angle())

if SERVER
    ENT.Think = => @Explode() if @explodeAt < CurTime()
    ENT.OnHit = (ent) =>
    ENT.OnHitAfter = (ent, dmg) =>
    ENT.Explode = (HitEntity) =>
        return if @exploded
        @exploded = true

        @OnHit(HitEntity)
        @SetSolid(SOLID_NONE)
        @EmitSound(@GetExplosionEffect())
        mult = @GetIsCritical() and 3 or @GetIsMiniCritical() and 1.3 or 1

        attacker = @GetAttacker()
        inflictor = @GetInflictor()
        blow = @GetBlowRadius()
        GetIsCritical = @GetIsCritical()
        GetIsMiniCritical = @GetIsMiniCritical()
        incomingDamage = @GetDamage() * mult
        toCallAfter = @OnHitAfter
        dtf2_hitPos = @GetPos()
        directHit = @directHit
        timer.Simple 0.1, ->
            self = attacker
            @dtf2_incomingDamage = incomingDamage
            @dtf2_hitPos = dtf2_hitPos
            @dtf2_blowRadius = blow
            @dtf2_pipebomb = true
            @dtf2_pipebomb_directHit = directHit
            @dtf2_pipebomb_directHit_HitEntity = HitEntity
            @dtf2_pipebomb_toCallAfter = toCallAfter
            @dtf2_GetIsCritical = GetIsCritical
            @dtf2_GetIsMiniCritical = GetIsMiniCritical
            util.BlastDamage(inflictor, attacker, dtf2_hitPos, incomingDamage, blow * 3)
            @dtf2_pipebomb = false

        effData = EffectData()
        effData\SetNormal(Vector(0, 0, 1))
        effData\SetOrigin(@GetPos())
        util.Effect(@GetBlowEffect(), effData)
        @Remove()

    hook.Add 'EntityTakeDamage', 'DTF2.PipebombProjectile', (ent, dmg) ->
        if attacker = dmg\GetAttacker()
            if attacker\IsValid() and attacker.dtf2_pipebomb
                attacker\dtf2_pipebomb_toCallAfter(ent, dmg)
                if not attacker.dtf2_pipebomb_directHit or attacker.dtf2_pipebomb_directHit_HitEntity ~= ent
                    dmg\SetDamage(attacker.dtf2_incomingDamage * (1 - math.Clamp(attacker.dtf2_hitPos\Distance(ent\GetPos()) / attacker.dtf2_blowRadius / 2, 0, 1))) if not attacker.dtf2_GetIsCritical
                else
                    dmg\SetDamage(attacker.dtf2_incomingDamage)
                if attacker.dtf2_GetIsCritical
                    DTF2.PlayCritEffect(ent)
                elseif attacker.dtf2_GetIsMiniCritical
                    DTF2.PlayMiniCritEffect(ent)
                elseif ent\IsMarkedForDeath()
                    DTF2.PlayMiniCritEffect(ent)
                    dmg\ScaleDamage(1.3)
    
    hook.Add 'EntityTakeDamage', 'DTF2.PipebombProjectileFix', (ent, dmg) ->
        attacker = dmg\GetAttacker()
        return if not IsValid(attacker)
        return if not attacker.IsTF2PipeBomb
        return if dmg\GetDamageType() ~= DMG_CRUSH
        dmg\SetDamage(0)
        dmg\SetMaxDamage(0)

    ENT.PhysicsCollide = (data = {}, colldier) =>
        {:HitEntity} = data
        return if not @GetIsFlying()
        return false if HitEntity == @GetAttacker()
        if IsValid(HitEntity)
            @directHit = true
            @Explode(HitEntity)
        else
            @SetDamage(@DefaultDamageBounce)
            @EmitSound(@GetBounceEffect()) if @GetIsFlying()
            @SetIsFlying(false)
