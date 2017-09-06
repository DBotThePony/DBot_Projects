
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
ENT.PrintName = 'SCP-512'
ENT.Author = 'DBot'
ENT.Category = 'SCP Insanity'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true

ENT.Initialize = =>
	@SetModel('models/umbrella.mdl')
    if CLIENT return
	
    @SetSkin(1)
	@SetSolid(SOLID_VPHYSICS)
	@SetMoveType(MOVETYPE_VPHYSICS)
    @PhysicsInit(SOLID_VPHYSICS)
    @phys = @GetPhysicsObject()
    @SetUseType(SIMPLE_USE)
    @UseTriggerBounds(true, 24)
    if IsValid(@phys)
        @phys\SetMass(32)
        @phys\Wake()
        @mins, @maxs = @OBBMins(), @OBBMaxs()
if SERVER
    ENT.Use = (ply) =>
        return if @IsPlayerHolding()
        ply\PickupObject(@) if @GetPos()\Distance(ply\GetPos()) < 130
    ENT.Think = =>
        return unless @mins or @maxs
        pos = @GetPos()
        ang = @GetAngles()
        up = ang\Up()
        start = pos + up * 30
        trData = {
            :start
            endpos: start + up * 100
            mins: @mins
            maxs: @maxs
            filter: (ent) ->
                return false if ent == @
                return true if not IsValid(ent)
                if  ent\IsPlayer() or
                    ent\IsNPC() or
                    ent\IsVehicle() or
                    ent\IsRagdoll() or
                    ent\GetClass() == 'dbot_scp512'
                    return false
                return true
        }

        tr = util.TraceHull(trData)
        return if not IsValid(tr.Entity)
        ent = tr.Entity
        phys = tr.Entity\GetPhysicsObject()
        return if not IsValid(phys)
        phys\AddVelocity(up * 200)
if CLIENT
    ENT.Draw = =>
        render.SetColorModulation(0.4, 0.4, 0.4)
        @DrawModel()
        render.SetColorModulation(1, 1, 1)
