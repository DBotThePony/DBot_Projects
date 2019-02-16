
--
-- Copyright (C) 2017-2019 DBot

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.


AddCSLuaFile()

ENT.PrintName = 'Projectile Base'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'base_anim'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.IsTF2Projectile = true

ENT.ProjectileModel = 'models/weapons/w_models/w_rocket.mdl'
ENT.BlowEffect = 'dtf2_rocket_explosion'
ENT.BlowSound = 'DTF2_BaseExplosionEffect.Sound'
ENT.ImpactFleshSound = 'DTF2_Weapon_Grenade_Pipebomb.BounceSound'
ENT.ImpactWorldSound = 'DTF2_Weapon_Grenade_Pipebomb.BounceSound'

ENT.ProjectileSize = 8
ENT.BlowRadius = 350
ENT.ProjectileDamage = 90
ENT.ProjectileSpeed = 1500
ENT.DegradationDivider = 1024
ENT.DamageDegradation = true
ENT.DAMAGE_DEGRADATION_RADIUS = true
ENT.EndlessFlight = true
ENT.ZAddition = 0
ENT.Gravity = false
ENT.ProjectileMass = 5
ENT.ProjectileForce = 1

ENT.Explosive = true
ENT.ExplodeOnWorldImpact = true
ENT.ExplodeOnEntityImpact = true
ENT.ImpactCollisionGroup = COLLISION_GROUP_PASSABLE_DOOR
ENT.AmmoType = ''
ENT.BulletDamageType = DMG_GENERIC

-- ENT.DrawEffects = {'rockettrail'}
-- ENT.DrawEffectsCriticals = {'critical_rocket_red'}
ENT.DisplayCriticalEffects = true

ENT.SetupFireAngle = true
ENT.ShouldExplode = false
ENT.ShouldRemove = false
ENT.ExplodeAt = 2.3
ENT.RemoveTimer = 10

ENT.TargetTakesFullDamage = false

ENT.SetupDataTables = =>
	@NetworkVar('Bool', 0, 'IsCritical')
	@NetworkVar('Bool', 1, 'IsMiniCritical')
	@NetworkVar('Bool', 2, 'IsFlying')
	@SetIsFlying(true)
