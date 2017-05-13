
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
