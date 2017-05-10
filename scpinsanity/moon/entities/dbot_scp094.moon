
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

SPEED = CreateConVar('sv_scpi_094_speed', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Period of SCP 094 growth')
SIZE = CreateConVar('sv_scpi_094_size', '0.5', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Size of SCP 094 growth')
MAX_SIZE = CreateConVar('sv_scpi_094_maxsize', '60', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Max size of SCP 094')

ENT.Type = 'anim'
ENT.PrintName = 'SCP-094'
ENT.Author = 'DBot'
ENT.Category = 'SCP Insanity'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true

ENT.Initialize = =>
	@SetModel('models/combine_helicopter/helicopter_bomb01.mdl')
	if CLIENT return
	@SIZE = 1
	@NEXT_SIZE_CHANGE = CurTime() + SPEED\GetFloat()
	@SetModelScale(0.4 * @SIZE)
	
	@SetUseType(SIMPLE_USE)
	@SetMoveType(MOVETYPE_NONE)
	@PhysicsInitSphere(8 * @SIZE, 'water')
	@phys = @GetPhysicsObject()
	if IsValid(@phys)
		@phys\SetMass(50000)
		@phys\Sleep()
		@phys\EnableMotion(false)
if SERVER
	damage = 2 ^ 31 - 1
	ENT.Wreck = (ent) =>
		return if ent\IsWeapon() or ent\CreatedByMap()
		if ent\IsNPC() or ent\IsPlayer()
			ent\GodDisable() if ent\IsPlayer()
			newDMG = DamageInfo()
			newDMG\SetAttacker(@)
			newDMG\SetInflictor(@)
			newDMG\SetDamage(damage)
			newDMG\SetDamageType(DMG_REMOVENORAGDOLL + DMG_DISSOLVE)
			ent\TakeDamageInfo(newDMG)
			ent\KillSilent() if ent\IsPlayer() and ent\Alive()
			@EmitSound('physics/flesh/flesh_bloody_break.wav', SNDLVL_140dB)
		@EmitSound("physics/concrete/rock_impact_hard#{math.random(1, 6)}.wav", SNDLVL_140dB)
		SafeRemoveEntity(ent)
	ENT.PhysicsCollide = (data) =>
		ent = data.HitEntity
		return unless IsValid(ent)
		@Wreck(ent)
	ENT.Think = =>
		if @NEXT_SIZE_CHANGE < CurTime() and @SIZE < MAX_SIZE\GetFloat()
			@SIZE += SIZE\GetFloat()
			@NEXT_SIZE_CHANGE = CurTime() + SPEED\GetFloat()
			@PhysicsInitSphere(8 * @SIZE, 'water')
			@SetModelScale(0.4 * @SIZE)
			@phys = @GetPhysicsObject()
			if IsValid(@phys)
				@phys\SetMass(50000)
				@phys\Sleep()
			
			hits = {}
			trData = {
				start: @GetPos()
				endpos: @GetPos() + Vector(0, 0, 10)
				mins: @OBBMins() * 2
				maxs: @OBBMaxs() * 2
				mask: CONTENTS_HITBOX + CONTENTS_MONSTER
				filter: (ent) ->
					return false if ent == @
					return false if not IsValid(ent)
					table.insert(hits, ent)
					return false
			}
			util.TraceHull(trData)
			@Wreck(ent) for ent in *hits
		@phys\EnableMotion(false) if IsValid(@phys)
if CLIENT
	import render, Material from _G
	import SuppressEngineLighting, ModelMaterialOverride, ResetModelLighting, SetColorModulation from render
	debugwtite = Material('models/debug/debugwhite')
	ENT.Draw = =>
		SuppressEngineLighting(true)
		ModelMaterialOverride(debugwtite)
		ResetModelLighting(1, 1, 1)
		render.SetColorModulation(0, 0, 0)
		@DrawModel()
		render.SetColorModulation(1, 1, 1)
		ModelMaterialOverride()
		SuppressEngineLighting(false)
