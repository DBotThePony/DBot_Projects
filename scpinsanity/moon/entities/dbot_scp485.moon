
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
ENT.PrintName = 'SCP-485'
ENT.Author = 'DBot'
ENT.Category = 'SCP Insanity'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true

ENT.Initialize = =>
	@SetModel('models/props_vtmb/pen.mdl')
    if CLIENT return
	
	@SetSolid(SOLID_VPHYSICS)
	@SetMoveType(MOVETYPE_VPHYSICS)
    @PhysicsInit(SOLID_VPHYSICS)
    @phys = @GetPhysicsObject()
    @SetUseType(SIMPLE_USE)
    @UseTriggerBounds(true, 24)
    if IsValid(@phys)
        @phys\SetMass(5)
        @phys\Wake()
if SERVER
    INT = 2^31 - 1

    DAMAGE_TYPES = {
        DMG_GENERIC
        DMG_CRUSH
        DMG_BULLET
        DMG_SLASH
        DMG_VEHICLE
        DMG_BLAST
        DMG_CLUB
        DMG_ENERGYBEAM
        DMG_ALWAYSGIB
        DMG_PARALYZE
        DMG_NERVEGAS
        DMG_POISON
        DMG_ACID
        DMG_AIRBOAT
        DMG_BLAST_SURFACE
        DMG_BUCKSHOT
        DMG_DIRECT
        DMG_DISSOLVE
        DMG_DROWNRECOVER
        DMG_PHYSGUN
        DMG_PLASMA
        DMG_RADIATION
        DMG_SLOWBURN
    }

    ENT.Wreck = (ent, ply = @) =>
        ent\TakeDamage(INT, ply, @)
        
        for dtype in *DAMAGE_TYPES
            dmg = DamageInfo()
            
            dmg\SetDamage(INT)
            dmg\SetAttacker(ply)
            dmg\SetInflictor(@)
            dmg\SetDamageType(dtype)
            
            ent\TakeDamageInfo(dmg)
            
            if ent\IsPlayer()
                if not ent\Alive() break
            elseif not SCP_HaveZeroHP[ent\GetClass()]
                if ent\Health() <= 0 break 
        
        if not ent\IsPlayer()
            if ent\GetClass() == 'npc_turret_floor' or ent\GetClass() == 'npc_combinedropship'
                ent\Fire('SelfDestruct')
        else
            if ent\Alive()
                ent\Kill()
        
        @EmitSound('buttons/button9.wav', SNDLVL_50dB)

    ENT.Use = (user) =>
        if SCP_INSANITY_ATTACK_PLAYERS\GetBool()
            for ply in *player.GetAll()
                continue if SCP_INSANITY_ATTACK_NADMINS\GetBool() and ply\IsAdmin()
                continue if SCP_INSANITY_ATTACK_NSUPER_ADMINS\GetBool() and ply\IsSuperAdmin()
                continue if not ply\Alive()
                continue if ply == user
                @Wreck(ply, user)
                return
        for ent in *SCP_GetTargets(true)
            @Wreck(ent, user)
            return
        @EmitSound('buttons/button9.wav', SNDLVL_50dB)