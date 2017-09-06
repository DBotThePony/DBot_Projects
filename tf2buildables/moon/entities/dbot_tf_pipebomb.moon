
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

ENT.PrintName = 'Pipebomb Projectile'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'dbot_tf_projectile'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.IsTF2PipeBomb = true

ENT.ProjectileModel = 'models/weapons/w_models/w_grenade_grenadelauncher.mdl'
ENT.BlowRadius = 350
ENT.BlowEffect = 'dtf2_pipebomb_explosion'
ENT.BlowSound = 'DTF2_Weapon_Grenade_Pipebomb.Explode'
ENT.ImpactFleshSound = 'DTF2_Weapon_Grenade_Pipebomb.BounceSound'
ENT.ImpactWorldSound = 'DTF2_Weapon_Grenade_Pipebomb.BounceSound'

ENT.EndlessFlight = false
ENT.ShouldExplode = true
ENT.ExplodeAt = 2.3
ENT.TargetTakesFullDamage = true
ENT.Gravity = true
ENT.ExplodeOnWorldImpact = false

ENT.ProjectileDamage = 100
ENT.DefaultDamageBounce = 60
ENT.ProjectileSpeed = 1200

ENT.DrawEffects = {'pipebombtrail_red'}
ENT.DrawEffectsCriticals = {'critical_grenade_red'}
ENT.ZAddition = 0.14

if SERVER
	ENT.OnHit = (entHit) =>
		if not IsValid(entHit)
			@SetDamage(@DefaultDamageBounce)
