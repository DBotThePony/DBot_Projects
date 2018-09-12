
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

ENT.PrintName = 'Syringe Projectile'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'dbot_tf_projectile'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.IsTF2Syringe = true

ENT.ProjectileModel = 'models/weapons/w_models/w_syringe_proj.mdl'
ENT.ImpactFleshEffect = 'DTF2_Weapon_Grenade_Pipebomb.BounceSound'
ENT.ImpactWorldEffect = 'DTF2_Weapon_Grenade_Pipebomb.BounceSound'

ENT.ProjectileDamage = 12
ENT.Gravity = true
ENT.EndlessFlight = false
ENT.DegradationDivider = 2048
ENT.ZAddition = 0.06
ENT.Explosive = false

ENT.DrawEffects = {}
ENT.DrawEffectsCriticals = {'critical_rocket_red'}
ENT.BulletDamageType = DMG_POISON
ENT.AmmoType = 'ammo_tf_syringe'
