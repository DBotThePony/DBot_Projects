
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
