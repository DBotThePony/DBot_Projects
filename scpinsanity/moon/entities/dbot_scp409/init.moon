
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
	for k, v in pairs(ents.FindInSphere(@GetPos(), 64)) do
		if IsValid(v\GetParent()) continue 
		if v == self continue 
		if v\Health() <= 0
			if v\GetClass() ~= 'prop_physics' continue 
			@Attack(v)
			SafeRemoveEntity(v)
			continue 
		@Attack(v)

ENT.Attack = (ent) =>
	if ent.CRYSTALIZING return 
	if ent\GetClass()\find('scp') return 
	ent.CRYSTALIZING = true
	point = ents.Create('dbot_scp409_killer')
	point\SetPos(ENT.GetPos())
	point\SetParent(ent)
	point\Spawn()
	point\Activate()
	point.Crystal = self
	return point
