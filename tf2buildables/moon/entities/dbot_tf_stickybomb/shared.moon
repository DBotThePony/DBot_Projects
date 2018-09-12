
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


DEFINE_BASECLASS('dbot_tf_projectile')
AddCSLuaFile()

ENT.PrintName = 'Stickybomb Projectile'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'dbot_tf_projectile'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.IsTF2StickyBomb = true

ENT.ProjectileModel = 'models/weapons/w_models/w_stickybomb.mdl'
ENT.BlowRadius = 350
ENT.BlowEffect = 'dtf2_pipebomb_explosion'
ENT.BlowSound = 'DTF2_Weapon_Grenade_Pipebomb.Explode'
ENT.ImpactFleshSound = 'DTF2_Weapon_Grenade_Pipebomb.BounceSound'
ENT.ImpactWorldSound = 'DTF2_Weapon_Grenade_Pipebomb.BounceSound'

ENT.GIBS = {
	'models/weapons/w_models/w_stickybomb_gib1.mdl'
	'models/weapons/w_models/w_stickybomb_gib2.mdl'
	'models/weapons/w_models/w_stickybomb_gib3.mdl'
	'models/weapons/w_models/w_stickybomb_gib4.mdl'
	'models/weapons/w_models/w_stickybomb_gib5.mdl'
	'models/weapons/w_models/w_stickybomb_gib6.mdl'
}

ENT.MIN_GIBS = 1
ENT.MAX_GIBS = 3
ENT.GIBS_TTL = 15

ENT.DamageDegradation = false
ENT.DAMAGE_DEGRADATION_RADIUS = true

ENT.EndlessFlight = false
ENT.ShouldExplode = false
ENT.ExplodeOnEntityImpact = false
ENT.ExplodeOnWorldImpact = false
ENT.Gravity = true

ENT.ProjectileDamage = 80
ENT.DefaultDamageBounce = 60
ENT.ProjectileSpeed = 800
ENT.ProjectileSize = 6

ENT.MAX_STICKIES = 8
ENT.HANDLE_MAX_STICKIES = CreateConVar('tf_finite_stickies', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Set to 0 to make infinite placeable sticky bombs')
ENT.ACTIVATE_TIMER = 0.7

ENT.DrawEffects = {'pipebombtrail_red'}
ENT.DrawEffectsCriticals = {'critical_grenade_red'}
ENT.ZAddition = 0.18

entMeta = FindMetaTable('Entity')

EntityClass = 
	GetTFStickiesCount: (mclass = 'dbot_tf_stickybomb', def = 0) => @GetNWInt('DTF2.Stickies.' .. mclass, def)
	GetTFStickCount: (mclass = 'dbot_tf_stickybomb', def = 0) => @GetNWInt('DTF2.Stickies.' .. mclass, def)
	GetTFStickyBombCount: (mclass = 'dbot_tf_stickybomb', def = 0) => @GetNWInt('DTF2.Stickies.' .. mclass, def)
	GetTFStickyBombsCount: (mclass = 'dbot_tf_stickybomb', def = 0) => @GetNWInt('DTF2.Stickies.' .. mclass, def)

entMeta[k] = v for k, v in pairs EntityClass
