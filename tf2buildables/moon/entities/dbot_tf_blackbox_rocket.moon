
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

ENT.PrintName = 'The Black Box Rocket Projectile'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'dbot_tf_rocket_projectile'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.BlowSound = 'DTF2_Weapon_RPG_BlackBox.Explode'

return if CLIENT
ENT.OnHit = (ent) =>
	attack = @GetAttacker()
	attack.dtf2_blackbox_hit = false

ENT.OnHitAfter = (ent) =>
	return if @dtf2_blackbox_hit
	return if @ == ent
	return unless ent\IsValid() and (ent\IsNPC() or ent\IsPlayer())
	@dtf2_blackbox_hit = true
	hp = @Health()
	mhp = @GetMaxHealth()
	return if hp >= mhp
	@SetHealth(math.Clamp(hp + 20, 0, mhp))
