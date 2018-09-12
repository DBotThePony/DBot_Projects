
--
-- Copyright (C) 2017 DBot

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


include 'shared.lua'
AddCSLuaFile 'cl_init.lua'

import IsValid, ents, SafeRemoveEntity from _G

ENT.PhysicsCollide = (data) =>
	ent = data.HitEntity
	if not IsValid(ent) return 
	@Attack(ent)

ENT.Initialize = =>
	@SetModel('models/props_debris/barricade_short01a.mdl')
	@PhysicsInit(SOLID_VPHYSICS)
	@SetSolid(SOLID_VPHYSICS)
	@SetMoveType(MOVETYPE_NONE)

ENT.Think = =>
	for ent in *ents.FindInSphere(@GetPos(), 64)
		if IsValid(ent\GetParent()) continue 
		if ent == @ continue 
		if ent\IsPlayer()
			if not SCP_INSANITY_ATTACK_PLAYERS\GetBool() continue
			if SCP_INSANITY_ATTACK_NADMINS\GetBool() and ent\IsAdmin() continue
			if SCP_INSANITY_ATTACK_NSUPER_ADMINS\GetBool() and ent\IsSuperAdmin() continue
		if ent\Health() <= 0
			if ent\GetClass() ~= 'prop_physics' continue 
			@Attack(ent)
			SafeRemoveEntity(ent)
			continue 
		@Attack(ent)

ENT.Attack = (ent) =>
	if ent.CRYSTALIZING return 
	if ent\GetClass()\find('scp') return 
	ent.CRYSTALIZING = true
	point = ents.Create('dbot_scp409_killer')
	point\SetPos(ent\GetPos())
	point\SetParent(ent)
	point\Spawn()
	point\Activate()
	point.Crystal = @
	return point
