
--
-- Copyright (C) 2017-2019 DBotThePony

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

ENT.PrintName = 'Sentry Rockets'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'base_anim'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.IsBuildingPart = true
ENT.m_BuildableOwner = NULL
ENT.ROCKETS_MODEL = 'models/buildables/sentry3_rockets.mdl'

AccessorFunc(ENT, 'm_BuildableOwner', 'BuildableOwner')
AccessorFunc(ENT, 'm_Attacker', 'Attacker')
AccessorFunc(ENT, 'm_Inflictor', 'Inflictor')
AccessorFunc(ENT, 'm_FireDir', 'FireDirection')

ENT.Initialize = =>
	@SetModel(@ROCKETS_MODEL)
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

if CLIENT
	ENT.Think = =>
		@renderAng = @renderAng or @GetAngles()
		@renderAng.r += FrameTime() * 400
		@renderAng\Normalize()
		@SetRenderAngles(@renderAng)
else
	ENT.Think = =>
		with @phys
			return @Remove() if not \IsValid()
			\SetVelocity(@GetFireDirection() * 1500)
			--ang = @GetAngles()
			--up = ang\Up()
			--right = ang\Right()
			--\AddAngleVelocity((up + right) * 400)

ENT.ROCKET_DAMAGE = CreateConVar('tf_dbg_srocket_damage', '128', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Sentry rockets damage')
ENT.PhysicsCollide = (data = {}, colldier) =>
	{:HitPos, :HitEntity, :HitNormal} = data
	return false if HitEntity == @attacker
	@SetSolid(SOLID_NONE)

	grabDamage = DTF2.GrabFloat(@ROCKET_DAMAGE)
	grabDamage = hook.Run('DTF2_GetSentryRocketDamage', @, grabDamage) or grabDamage

	util.BlastDamage(IsValid(@GetInflictor()) and @GetInflictor() or @, IsValid(@GetAttacker()) and @GetAttacker() or @, HitPos + HitNormal, 64, grabDamage)
	effData = EffectData()
	effData\SetNormal(-HitNormal)
	effData\SetOrigin(HitPos - HitNormal)
	util.Effect('sentry_rocket_explosion', effData)
	util.Decal('DTF2_SentryRocketExplosion', HitPos - HitNormal, HitPos + HitNormal)
	@Remove()
