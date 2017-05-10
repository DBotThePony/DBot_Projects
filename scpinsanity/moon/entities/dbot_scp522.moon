
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
ENT.PrintName = 'SCP-522'
ENT.Author = 'DBot'
ENT.Category = 'SCP Insanity'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true

ENT.Initialize = =>
	@SetModel('models/props_pony/carpet_round.mdl')
	if CLIENT return
	
	@SetSolid(SOLID_VPHYSICS)
	@SetMoveType(MOVETYPE_VPHYSICS)
	@PhysicsInit(SOLID_VPHYSICS)
	@phys = @GetPhysicsObject()
	@SetUseType(SIMPLE_USE)
	@UseTriggerBounds(true, 24)
	@ATTACKED_ENTITIES = {}
	@LAST_SOUND = 0
	if IsValid(@phys)
		@phys\SetMass(64)
		@phys\Wake()
		@mins, @maxs = @OBBMins(), @OBBMaxs()
if SERVER
	ENT.ClearEnts = (ent) =>
		for i, Ent in pairs @ATTACKED_ENTITIES
			unless IsValid(Ent)
				@ATTACKED_ENTITIES[i] = nil
				continue
			if Ent == ent continue
			@ATTACKED_ENTITIES[i] = nil
			if Ent.SCP522_MOVETYPE
				Ent\SetMoveType(Ent.SCP522_MOVETYPE)
				Ent.SCP522_MOVETYPE = nil
			if Ent\IsPlayer()
				Ent\SetNWEntity('SCP522.ENT', NULL)
				Ent\SetMoveType(MOVETYPE_WALK)
	ENT.Think = =>
		return unless @mins or @maxs
		pos = @GetPos()
		ang = @GetAngles()
		up = ang\Up()
		start = pos
		trData = {
			:start
			endpos: start + up * 30
			mins: @mins
			maxs: @maxs
			filter: (ent) ->
				return false if ent == @
				return true if not IsValid(ent)
				if  ent\IsPlayer() and ent\Alive() and not ent\HasGodMode() or
					ent\IsNPC() and ent\GetNPCState() ~= NPC_STATE_DEAD
					return true
				return false
		}

		tr = util.TraceHull(trData)
		ent = tr.Entity
		return if not IsValid(ent)
		hp = ent\Health()
		mhp = ent\GetMaxHealth()
		mhp = 1 if mhp == 0

		dmg = DamageInfo()
		dmg\SetDamage(math.max(mhp * 0.01, 1))
		dmg\SetAttacker(@)
		dmg\SetInflictor(@)
		dmg\SetDamageType(DMG_ACID)

		ent\TakeDamageInfo(dmg)
		if @LAST_SOUND < CurTime()
			@LAST_SOUND = CurTime() + 1
			@EmitSound("npc/barnacle/barnacle_gulp#{math.random(1, 2)}.wav")
		newHP = ent\Health()
		stage = 1 - math.Clamp(newHP / mhp, 0, 1)
		@ATTACKED_ENTITIES[ent] = ent
		
		if ent\IsPlayer()
			ent\SetNWEntity('SCP522.ENT', @)
		ent.SCP522_MOVETYPE = ent.SCP522_MOVETYPE or ent\GetMoveType()
		ent\SetMoveType(MOVETYPE_NONE)
		
		deltaPos = ent\EyePos() - pos
		ent\SetPos(pos - Vector(0, 0, (deltaPos.z + 10) * stage))
		@ClearEnts(ent)
	ENT.OnRemove = =>
		@ClearEnts()
if CLIENT
	DOWN = Vector(0, 0, 1)
	hook.Add 'PrePlayerDraw', 'SCPInsanity.SCP522', =>
		return if not IsValid(@GetNWEntity('SCP522.ENT'))
		hp = @Health()
		mhp = @GetMaxHealth()
		mhp = 1 if mhp == 0
		stage = math.Clamp(hp / mhp, 0, 1)
		pos = @EyePos()
		delta = pos.z - @GetPos().z + 10
		pos.z -= delta * stage
		dot = pos\Dot(DOWN)
		render.PushCustomClipPlane(DOWN, dot)
		@SCP522_CLIP = true
	hook.Add 'PostPlayerDraw', 'SCPInsanity.SCP522', =>
		return if not @SCP522_CLIP
		render.PopCustomClipPlane()
		@SCP522_CLIP = false
		