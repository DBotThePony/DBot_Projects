
--
-- Copyright (C) 2017-2018 DBot
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
