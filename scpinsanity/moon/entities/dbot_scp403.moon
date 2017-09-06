
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

RESET_TIMER = CreateConVar('sv_scpi_403_timer', '60', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'SCP 403 reset timer in seconds')

AddCSLuaFile()

ENT.Type = 'anim'
ENT.PrintName = 'SCP-403'
ENT.Author = 'DBot'
ENT.Category = 'SCP Insanity'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true

ENT.Initialize = =>
	@SetModel('models/zippocollectionnavy.mdl')
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
	@NextReset = CurTime()
	@ExplosionCounter = -1
if SERVER
	ENT.Think = =>
		@NextReset = CurTime() + RESET_TIMER\GetFloat()
		@NextThink(@NextReset)
		@ExplosionCounter = -1
		return true
	ENT.DoWaterEffect = =>
		trData = {
			mask: MASK_WATER + CONTENTS_TRANSLUCENT
			start: @GetPos()
			endpos: @GetPos() - Vector(0, 0, 2000)
			filter: @
		}

		ParticleEffect('water_medium', util.TraceLine(trData).HitPos, Angle(0, 0, 0))
	ENT.DoGroundEffect = (part = '100lb_ground') =>
		trData = {
			start: @GetPos()
			endpos: @GetPos() - Vector(0, 0, 2000)
			filter: @
		}

		ParticleEffect(part, util.TraceLine(trData).HitPos, Angle(0, 0, 0))
	ENT.Use = (user) =>
		@ExplosionCounter += 1
		@ExplosionCounter = 3 if @ExplosionCounter > 3
		@EmitSound('buttons/button9.wav', SNDLVL_50dB)
		pos = @GetPos()
		switch @ExplosionCounter
			when 1
				if @WaterLevel() > 0
					@DoWaterEffect()
				else
					@DoGroundEffect('100lb_ground')
				dmginfo = DamageInfo()
				dmginfo\SetAttacker(user)
				dmginfo\SetInflictor(@)
				dmginfo\SetDamage(50)
				dmginfo\SetDamageType(DMG_BLAST)
				for ent in *ents.FindInSphere(pos, 400)
					if ent ~= @ and ent ~= user and ent\GetPos()\Distance(pos) > 200
						ent\TakeDamageInfo(dmginfo)
				@EmitSound("gbombs_5/explosions/light_bomb/small_explosion_#{math.random(1, 7)}.mp3", SNDLVL_140dB) for i = 1, 3
			when 2
				if @WaterLevel() > 0
					@DoWaterEffect()
				else
					@DoGroundEffect('100lb_ground')
				dmginfo = DamageInfo()
				dmginfo\SetAttacker(user)
				dmginfo\SetInflictor(@)
				dmginfo\SetDamage(250)
				dmginfo\SetDamageType(DMG_BLAST)
				for ent in *ents.FindInSphere(pos, 1000)
					if ent ~= @ and ent ~= user and ent\GetPos()\Distance(pos) > 200
						ent\TakeDamageInfo(dmginfo)
				@EmitSound("gbombs_5/explosions/heavy_bomb/explosion_big_#{math.random(1, 7)}.mp3", SNDLVL_180dB) for i = 1, 5
			when 3
				if @WaterLevel() > 0
					@DoWaterEffect()
				else
					@DoGroundEffect('100lb_ground')
				dmginfo = DamageInfo()
				dmginfo\SetAttacker(user)
				dmginfo\SetInflictor(@)
				dmginfo\SetDamage(800)
				dmginfo\SetDamageType(DMG_BLAST)
				for ent in *ents.FindInSphere(pos, 1900)
					if ent ~= @ and ent ~= user and ent\GetPos()\Distance(pos) > 200
						ent\TakeDamageInfo(dmginfo)
				@EmitSound("gbombs_5/explosions/nuclear/fat_explosion.mp3", SNDLVL_180dB) for i = 1, 7
