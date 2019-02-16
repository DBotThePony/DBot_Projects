
--
-- Copyright (C) 2017-2019 DBot

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

ENT.PrintName = 'Building derbis'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false

DERBIS_REMOVE_TIME = CreateConVar('tf_derbis_remove_timer', '45', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Derib removal timer') if SERVER

AccessorFunc(ENT, 'm_DerbisValue', 'DerbisValue')
AccessorFunc(ENT, 'm_dissolveAt', 'DissolveAt')

ENT.Initialize = =>
	@SetDerbisValue(15)
	-- @RealSetModel('models/buildables/gibs/sentry1_gib2.mdl')
	return if CLIENT
	@SetDissolveAt(CurTime() + DERBIS_REMOVE_TIME\GetInt())

ENT.RealSetModel = (mdl = 'models/buildables/gibs/sentry1_gib2.mdl') =>
	@SetModel(mdl)
	return if CLIENT
	@SetMoveType(MOVETYPE_VPHYSICS)
	@PhysicsInit(SOLID_VPHYSICS)
	@SetSolid(SOLID_VPHYSICS)
	@SetCollisionGroup(COLLISION_GROUP_WEAPON)
	with @phys = @GetPhysicsObject()
		\Wake() if \IsValid()

ENT.Shake = =>
	return if not IsValid(@phys)
	ang = AngleRand()
	ang.p = math.Clamp(ang.p, -180, 0)
	@phys\SetVelocity(ang\Forward() * math.random(160, 400))
	@SetAngles(ang)

ENT.Think = =>
	return false if CLIENT
	return @Remove() if not @GetDissolveAt() or @GetDissolveAt() < CurTime()
	pos = @GetPos()
	minDist = 99999
	for ply in *player.GetAll()
		dist = ply\GetPos()\Distance(pos)
		minDist = dist if minDist > dist
		if dist < 60 and DTF2.GiveAmmo(ply, @GetDerbisValue()) > 0
			@Remove()
			return false

	if minDist >= 512
		@NextThink(CurTime() + 0.75)
	else
		@NextThink(CurTime() + 0.1)

	return true
