
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
ENT.BlowRadius = 128
ENT.RocketDamage = 64
ENT.BlowEffect = 'dtf2_rocket_explosion'
ENT.PhysicsSpeed = 1500
ENT.ExplosionEffect = 'DTF2_BaseExplosionEffect.Sound'

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
        \SetMass(5)
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
        mult = @GetIsCritical() and 3 or @GetIsMiniCritical() and 1.3 or 1
        util.BlastDamage(@GetInflictor(), @GetAttacker(), HitPos + HitNormal, @GetDamage() * mult, @GetBlowRadius())

        effData = EffectData()
        effData\SetNormal(-HitNormal)
        effData\SetOrigin(HitPos - HitNormal)
        util.Effect(@GetBlowEffect(), effData)

        @EmitSound(@GetExplosionEffect())
        @Remove()
else
    ENT.Draw = =>
        @DrawModel()
        return if @particle
        @particle = CreateParticleSystem(@, 'rockettrail', PATTACH_ABSORIGIN_FOLLOW)
        @particle2 = CreateParticleSystem(@, 'critical_rocket_red', PATTACH_ABSORIGIN_FOLLOW) if @GetIsCritical()
