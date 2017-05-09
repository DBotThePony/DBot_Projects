
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
ENT.PrintName = 'SCP-596'
ENT.Author = 'DBot'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true

ENT.Initialize = =>
	@SetModel('models/props_combine/breenbust.mdl')
	@PhysicsInit(SOLID_VPHYSICS)
	@SetSolid(SOLID_VPHYSICS)
	@SetMoveType(MOVETYPE_VPHYSICS)
	@CurrentPly = NULL

MAX = 10 ^ 5
ENT.Think = =>
	if not IsValid(@CurrentPly) return 
	if not @CurrentPly\Alive()
        @CurrentPly = NULL
        return
	@CurrentPly\SetMaxHealth(MAX)
	@CurrentPly\SetHealth(math.min(MAX, @CurrentPly\Health() + 100))
	@TOUCH_POS = @TOUCH_POS or @GetPos()
	@CurrentPly\SetPos(@TOUCH_POS)
	@NextThink(CurTime())
	return true

ENT.PhysicsCollide = (data) =>
	ent = data.HitEntity
	if not IsValid(ent) return 
	
	if ent == @CurrentPly return 
	if not ent\IsPlayer() return 
	
	if IsValid(@CurrentPly) and @CurrentPly\Alive()
		@CurrentPly\Kill()
	
	@CurrentPly = ent
	@TOUCH_POS = ent\GetPos()
