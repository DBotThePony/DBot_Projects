
--
-- Copyright (C) 2017-2018 DBot

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

ENT.PrintName = 'Iron Bomber Projectile'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'dbot_tf_projectile'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.IsTF2PipeBomb = true

ENT.ProjectileModel = 'models/workshop/weapons/c_models/c_quadball/w_quadball_grenade.mdl'
ENT.BlowRadius = 350 * 0.85
ENT.BlowEffect = 'dtf2_pipebomb_explosion'
ENT.BlowSound = 'DTF2_Weapon_Grenade_Pipebomb.Explode'
ENT.ImpactFleshSound = 'DTF2_Weapon_Grenade_Pipebomb.BounceSound'
ENT.ImpactWorldSound = 'DTF2_Weapon_Grenade_Pipebomb.BounceSound'

ENT.EndlessFlight = false
ENT.ShouldExplode = true
ENT.ExplodeAt = 2.3 * 0.7
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
			@phys\SetVelocity(Vector())
