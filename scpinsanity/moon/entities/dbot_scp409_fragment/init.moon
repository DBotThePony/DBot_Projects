
--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http\//www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

AddCSLuaFile 'cl_init.lua'

ENT.Type = 'anim'
ENT.PrintName = 'SCP-409 Fragment'
ENT.Author = 'DBot'
ENT.Base = 'dbot_scp409'

import CurTime, IsValid, math from _G

ENT.Initialize = =>
	@SetModel('models/props_combine/breenbust_chunk03.mdl')
	
	@PhysicsInit(SOLID_VPHYSICS)
	@SetSolid(SOLID_VPHYSICS)
	@SetMoveType(MOVETYPE_VPHYSICS)
	
	@Rem = CurTime() + 10
	@phys = IsValid(@GetPhysicsObject()) and @GetPhysicsObject()

ENT.Push = =>
	if not @phys then return
	@phys\Wake()
	@phys\SetVelocity(VectorRand() * math.random(500, 5000))

ENT.Think = =>
	@BaseClass.Think(@)
	if @Rem < CurTime() then @Remove()

ENT.Attack = (ent) =>
	point = @BaseClass.Attack(@, ent)
	if not point return
	point.Crystal = @Crystal
	return point
