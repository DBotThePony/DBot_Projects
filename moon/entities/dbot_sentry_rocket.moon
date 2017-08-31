
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

ENT.PrintName = 'Sentry Rockets'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'base_anim'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.IsBuildingPart = true
ENT.m_BuildableOwner = NULL

AccessorFunc(ENT, 'm_BuildableOwner', 'BuildableOwner')
AccessorFunc(ENT, 'm_Attacker', 'Attacker')
AccessorFunc(ENT, 'm_Inflictor', 'Inflictor')
AccessorFunc(ENT, 'm_FireDir', 'FireDirection')

ENT.Initialize = =>
	@SetModel('models/buildables/sentry3_rockets.mdl')
	return if CLIENT
	@SetInflictor(@) if not @GetInflictor()
	@SetAttacker(@) if not @GetAttacker()
	@PhysicsInitSphere(12)
	@SetFireDirection(Vector(0, 0, 0)) if not @GetFireDirection()
	with @phys = @GetPhysicsObject()
		\EnableMotion(true)
		\SetMass(5)
		\EnableGravity(false)
		\Wake()

ENT.Think = =>
	return if CLIENT
	return @Remove() if not @phys\IsValid()
	@phys\SetVelocity(@GetFireDirection() * 1500)

ENT.PhysicsCollide = (data = {}, colldier) =>
	{:HitPos, :HitEntity, :HitNormal} = data
	return false if HitEntity == @attacker
	@SetSolid(SOLID_NONE)
	util.BlastDamage(IsValid(@GetInflictor()) and @GetInflictor() or @, IsValid(@GetAttacker()) and @GetAttacker() or @, HitPos + HitNormal, 64, 128)
	effData = EffectData()
	effData\SetNormal(-HitNormal)
	effData\SetOrigin(HitPos - HitNormal)
	util.Effect('sentry_rocket_explosion', effData)
	util.Decal('DTF2_SentryRocketExplosion', HitPos - HitNormal, HitPos + HitNormal)
	@Remove()
