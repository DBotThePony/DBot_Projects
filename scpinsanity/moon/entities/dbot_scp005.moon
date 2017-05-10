
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

AddCSLuaFile()

ENT.Type = 'anim'
ENT.PrintName = 'SCP-005'
ENT.Author = 'DBot'
ENT.Category = 'DBot'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true

ENT.Initialize = =>
	@SetModel('models/spartex117/key.mdl')
    if CLIENT return
	
	@SetSolid(SOLID_VPHYSICS)
	@SetMoveType(SOLID_VPHYSICS)
ENT.TryOpenDoor = (ent) =>
    ent.SCP_INSANITY_LAST_OPEN = ent.SCP_INSANITY_LAST_OPEN or 0
    if ent.SCP_INSANITY_LAST_OPEN > CurTime() return
    ent.SCP_INSANITY_LAST_OPEN = CurTime() + 5
    ent\Fire('unlock', '', 0)
    @EmitSound("npc/metropolice/gear#{math.random(1, 7)}.wav")
    timer.Simple 0.5, -> ent\Fire('Open', '', 0) if IsValid(ent)
ENT.PhysicsCollide = (data) =>
	ent = data.HitEntity
    return if not IsValid(ent)
    nClass = ent\GetClass()
    if  nClass == "func_door" or
        nClass == "func_door_rotating" or
        nClass == "prop_door_rotating" or
        nClass == "func_movelinear" or
        nClass == "prop_dynamic"
            @TryOpenDoor(ent)
