
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
ENT.PrintName = 'SCP-998'
ENT.Author = 'DBot'
ENT.Category = 'SCP Insanity'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true

ENT.Initialize = =>
	@SetModel('models/treasurechest/treasurechest.mdl')
    if CLIENT return
	
	@SetSolid(SOLID_VPHYSICS)
	@SetMoveType(MOVETYPE_VPHYSICS)
    @PhysicsInit(SOLID_VPHYSICS)
    @phys = @GetPhysicsObject()
    @SetUseType(SIMPLE_USE)
    @UseTriggerBounds(true, 24)
    if IsValid(@phys)
        @phys\SetMass(256)
        @phys\Wake()
    @LAST_SOUND = 0
if SERVER
    ENT.Use = (ply) =>
        return if @LAST_SOUND > CurTime()
        @LAST_SOUND = CurTime() + 1
        @EmitSound('doors/latchlocked2.wav')
    ENT.OnTakeDamage = (dmg) =>
        attacker = dmg\GetAttacker()
        return unless IsValid(attacker)
        infl = dmg\GetInflictor()
        infl = @ unless IsValid(infl)

        newDMG = DamageInfo()
        newDMG\SetAttacker(@)
        newDMG\SetInflictor(infl)
        newDMG\SetDamage(dmg\GetDamage())
        newDMG\SetDamageType(dmg\GetDamageType())
        attacker\TakeDamageInfo(newDMG)
