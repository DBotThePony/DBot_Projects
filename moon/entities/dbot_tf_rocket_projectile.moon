
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

ENT.PrintName = 'Rocket Projectile'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'base_anim'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.RocketModel = 'models/weapons/w_models/w_rocket.mdl'
ENT.RocketSize = 8
ENT.BlowRadius = 350
ENT.RocketDamage = 90
ENT.BlowEffect = 'dtf2_rocket_explosion'
ENT.PhysicsSpeed = 1500
ENT.ExplosionEffect = 'DTF2_BaseExplosionEffect.Sound'

ENT.IsTF2Rocket = true

if SERVER
    AccessorFunc(ENT, 'm_Attacker', 'Attacker')
    AccessorFunc(ENT, 'm_Inflictor', 'Inflictor')
    AccessorFunc(ENT, 'm_blowRadius', 'BlowRadius')
    AccessorFunc(ENT, 'm_dir', 'Direction')
    AccessorFunc(ENT, 'm_damage', 'Damage')
    AccessorFunc(ENT, 'm_blowEffect', 'BlowEffect')
    AccessorFunc(ENT, 'm_physSpeed', 'PhysicsSpeed')
    AccessorFunc(ENT, 'm_expEffect', 'ExplosionEffect')

ENT.SetupDataTables = =>
    @NetworkVar('Bool', 0, 'IsCritical')
    @NetworkVar('Bool', 1, 'IsMiniCritical')

ENT.Initialize = =>
    @SetModel(@RocketModel)
    return if CLIENT
    @PhysicsInitSphere(@RocketSize)
    @initialPosition = @GetPos()

    @SetBlowRadius(@BlowRadius)
    @SetDirection(Vector(0, 0, 0))
    @SetInflictor(@)
    @SetAttacker(@)
    @SetDamage(@RocketDamage)
    @SetBlowEffect(@BlowEffect)
    @SetPhysicsSpeed(@PhysicsSpeed)
    @SetExplosionEffect(@ExplosionEffect)

    with @phys = @GetPhysicsObject()
        \EnableMotion(true)
        \SetMass(1)
        \EnableGravity(false)
        \Wake()

if SERVER
    ENT.Think = =>
        return @Remove() if not @phys\IsValid()
        @phys\SetVelocity(@GetDirection() * @GetPhysicsSpeed())
        if not @angleSetup
            @angleSetup = true
            @SetAngles(@GetDirection()\Angle())

    ENT.PhysicsCollide = (data = {}, colldier) =>
        {:HitPos, :HitEntity, :HitNormal} = data
        return false if HitEntity == @GetAttacker()

        @SetSolid(SOLID_NONE)
        @EmitSound(@GetExplosionEffect())
        mult = @GetIsCritical() and 3 or @GetIsMiniCritical() and 1.3 or 1
        degradation = 1
        degradation = 1 - math.Clamp(@initialPosition\Distance(HitPos) / 1024 - .2, -0.1, @GetIsMiniCritical() and 0.3 or 0.6) if not @GetIsCritical()

        attacker = @GetAttacker()
        inflictor = @GetInflictor()
        blow = @GetBlowRadius()
        GetIsCritical = @GetIsCritical()
        GetIsMiniCritical = @GetIsMiniCritical()
        incomingDamage = @GetDamage() * mult * degradation
        timer.Simple 0, ->
            self = attacker
            @dtf2_incomingDamage = incomingDamage
            @dtf2_hitPos = HitPos
            @dtf2_blowRadius = blow
            @dtf2_rocket = true
            @dtf2_GetIsCritical = GetIsCritical
            @dtf2_GetIsMiniCritical = GetIsMiniCritical
            util.BlastDamage(inflictor, attacker, HitPos - HitNormal * 50, incomingDamage, blow * 3)
            @dtf2_rocket = false

        effData = EffectData()
        effData\SetNormal(-HitNormal)
        effData\SetOrigin(HitPos - HitNormal * 12)
        util.Effect(@GetBlowEffect(), effData)
        @Remove()
    
    hook.Add 'EntityTakeDamage', 'DTF2.RocketProjectile', (ent, dmg) ->
        if attacker = dmg\GetAttacker()
            if attacker\IsValid() and attacker.dtf2_rocket
                dmg\SetDamage(attacker.dtf2_incomingDamage * (1 - math.Clamp(attacker.dtf2_hitPos\Distance(ent\GetPos()) / attacker.dtf2_blowRadius / 2, 0, 1))) if not attacker.dtf2_GetIsCritical
                if attacker.dtf2_GetIsCritical
                    DTF2.PlayCritEffect(ent)
                elseif attacker.dtf2_GetIsMiniCritical
                    DTF2.PlayMiniCritEffect(ent)
                elseif ent\IsMarkedForDeath()
                    DTF2.PlayMiniCritEffect(ent)
                    dmg\ScaleDamage(1.3)
else
    ENT.Draw = =>
        @DrawModel()
        return if @particle
        @particle = CreateParticleSystem(@, 'rockettrail', PATTACH_ABSORIGIN_FOLLOW)
        @particle2 = CreateParticleSystem(@, 'critical_rocket_red', PATTACH_ABSORIGIN_FOLLOW) if @GetIsCritical()
