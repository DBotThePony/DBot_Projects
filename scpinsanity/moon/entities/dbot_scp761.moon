
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

-- Code is used from the original trampoline

AddCSLuaFile()

ENT.Type = 'anim'
ENT.PrintName = 'SCP-761'
ENT.Author = 'DBot and MacDGuy/Voided'
ENT.Category = 'SCP Insanity'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true

ENT.Initialize = =>
	@SetModel('models/gmod_tower/trampoline.mdl')
	@trampoline_seq = @LookupSequence('bounce')
	if CLIENT return
	
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
	util.AddNetworkString('SCPInsanity.761Boing')
	EmptyVector = Vector()
	ENT.PhysicsCollide = (data, collider) =>
        ent = data.HitEntity
		{:HitNormal, :HitPos, :TheirOldVelocity} = data
        return if not IsValid(ent)

        norm = HitNormal * -1
        dot = @GetUp()\Dot(HitNormal)

        scale = math.random(1, 1.5)
        dist = 250 * scale
        pitch = 100 * scale

        mulNorm = norm * dist
		mulNorm.z = -mulNorm.z if mulNorm.z < 0
		phys = if ent\IsPlayer() or ent\IsNPC() then ent else ent\GetPhysicsObject()
		phys\SetVelocity(mulNorm) if IsValid(phys)
        @ResetSequence(@trampoline_seq)

		net.Start('SCPInsanity.761Boing')
		net.WriteEntity(@)
		net.WriteVector(HitPos)
		net.WriteNormal(HitNormal)
		net.WriteUInt(pitch, 8)
		net.Broadcast()

		if TheirOldVelocity\Length() > 400
			ent\SetPos(@GetPos() + VectorRand() * math.random(160, 400))
		
		@phys\SetVelocity(EmptyVector) if IsValid(phys)
if CLIENT
	net.Receive 'SCPInsanity.761Boing', ->
		ent = net.ReadEntity()
		return unless IsValid(ent)
		ent\ResetSequence(ent.trampoline_seq)
		vOffset = net.ReadVector()
        vNorm = net.ReadNormal()
		pitch = net.ReadUInt(8)
		ent\EmitSound('gmodtower/misc/boing.wav', 85, pitch)

        NumParticles = 0
    
        emitter = ParticleEmitter(vOffset)
        for i = 0, NumParticles
            particle = emitter\Add('sprites/star', vOffset)
            continue unless particle
			angle = vNorm\Angle()
			vel = angle\Forward() * math.random(0, 200) + angle\Right() * math.random(-200, 200) + angle\Up() * math.random(-200, 200)
			particle\SetVelocity(vel)
			particle\SetLifeTime(0)
			particle\SetDieTime(1)
			particle\SetStartAlpha(255)
			particle\SetEndAlpha(0)
			particle\SetStartSize(8)
			particle\SetEndSize(2)

			col = Color(255, 0, 0)
			if i > 2 then
				col = Color(255, 255, 0)
				col.g = col.g - math.random(0, 50)
			particle\SetColor(col.r, col.g, math.random(0, 50))
			particle\SetRoll(math.random(0, 360))
			particle\SetRollDelta(math.random(-2, 2))
			particle\SetAirResistance(100)
			particle\SetGravity(vNorm * 15)
        emitter\Finish()
