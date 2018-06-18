
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

ENT.PrintName = 'Cow Mangler Rocket Projectile'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'dbot_tf_rocket_projectile'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.BlowEffect1 = 'dtf2_mangler_explosion'
ENT.BlowEffect2 = 'dtf2_mangler_explosion_charged'
ENT.BlowSound1 = 'DTF2_Weapon_CowMangler.Explode'
ENT.BlowSound2 = 'DTF2_Weapon_CowMangler.ExplodeCharged'

ENT.BurnTime = 6

ENT.Draw = =>
	return if @particleSetup
	@particleSetup = true
	CreateParticleSystem(@, 'drg_cow_rockettrail_normal', PATTACH_ABSORIGIN_FOLLOW) if not @GetIsMiniCritical()
	CreateParticleSystem(@, 'drg_cow_rockettrail_charged', PATTACH_ABSORIGIN_FOLLOW) if @GetIsMiniCritical()

return if CLIENT
ENT.OnHit = (ent) =>
	@SetBlowSound(@GetIsMiniCritical() and @BlowSound2 or @BlowSound1)
	@SetBlowEffect(@GetIsMiniCritical() and @BlowEffect2 or @BlowEffect1)

ENT.OnHitAfter = (ent, dmg) =>
	return if not @dtf2_GetIsMiniCritical
	with ent\TF2Burn(@BurnTime)
		\SetAttacker(dmg\GetAttacker())
		\SetInflictor(dmg\GetInflictor())
