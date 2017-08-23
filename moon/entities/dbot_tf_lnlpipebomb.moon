
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

ENT.PrintName = 'Loch-n-Load Projectile'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'dbot_tf_pipebomb'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.IsTF2PipeBomb = true
ENT.ProjectileSpeed = 1500
ENT.BlowRadius = 300

if SERVER
    ENT.OnHit = (entHit) =>
        if not DTF2.IsValidTarget(entHit)
            @Remove()
            eff = EffectData()
            eff\SetOrigin(@GetPos())
            util.Effect('StunstickImpact', eff)
    
    ENT.OnHitAfter = (attacker, ent, dmg) ->
        if ent.IsTF2Building
            dmg\ScaleDamage(1.25)
