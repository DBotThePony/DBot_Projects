
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
ENT.PrintName = 'SCP-689'
ENT.Author = 'DBot'
ENT.Category = 'DBot'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true

ENT.Initialize = =>
	@SetModel('models/props_lab/huladoll.mdl')
	@PhysicsInitBox(Vector(-4, -4, 0), Vector(4, 4, 16))
	@SetMoveType(MOVETYPE_NONE)
	@SetCollisionGroup(COLLISION_GROUP_WEAPON)
	@TARGETS = {}

interval = (val, min, max) -> val > min and val <= max

ENT.CanSeeMe = (ply) =>
	if ply\IsPlayer() and not ply\Alive() return false
	
	lpos = @GetPos()
	pos = ply\GetPos()
	epos = ply\EyePos()
	eyes = ply\EyeAngles()
	ang = (lpos - pos)\Angle()
	
	if lpos\Distance(epos) > 6000 return false
	
	diffPith = math.AngleDifference(ang.p, eyes.p)
	diffYaw = math.AngleDifference(ang.y, eyes.y)
	diffRoll = math.AngleDifference(ang.r, eyes.r)
	
	if ply\IsPlayer() then
		cond = (not interval(diffYaw, -60, 60) or not interval(diffPith, -45, 45))
		if cond return false
	elseif ply\IsNPC() then
		if ply\GetNPCState() == NPC_STATE_DEAD return false
		cond = (not interval(diffYaw, -50, 50) or not interval(diffPith, -45, 45))
		if cond return false
	else
		cond = (not interval(diffYaw, -50, 50) or not interval(diffPith, -45, 45))
		if cond return false

	hit = false
	
	tr = util.TraceLine({
		start: epos,
		endpos: lpos,
		filter: (ent) ->
			if ent == self
                hit = true
                return true
			if ent == ply return false
			
			if not IsValid(ent) return true
			if ent\IsPlayer() return false
			if ent\IsNPC() return false
			if ent\IsVehicle() return false
			
			if ent\GetClass() == 'dbot_scp173' return false
			if ent\GetClass() == 'dbot_scp173p' return false
			
			return true
	})
	
	if not hit return false
	@TARGETS[ply] = ply
	return true

INT = 2 ^ 31 - 1

DAMAGE_TYPES = {
	DMG_GENERIC,
	DMG_CRUSH,
	DMG_BULLET,
	DMG_SLASH,
	DMG_VEHICLE,
	DMG_BLAST,
	DMG_CLUB,
	DMG_ENERGYBEAM,
	DMG_ALWAYSGIB,
	DMG_PARALYZE,
	DMG_NERVEGAS,
	DMG_POISON,
	DMG_ACID,
	DMG_AIRBOAT,
	DMG_BLAST_SURFACE,
	DMG_BUCKSHOT,
	DMG_DIRECT,
	DMG_DISSOLVE,
	DMG_DROWNRECOVER,
	DMG_PHYSGUN,
	DMG_PLASMA,
	DMG_RADIATION,
	DMG_SLOWBURN,
}

ENT.Wreck = (ply) =>
	@EmitSound('snap.wav', 100)
	ply\TakeDamage(INT, self, self)
	
	for dtype in *DAMAGE_TYPES
		dmg = DamageInfo()
		
		dmg\SetDamage(INT)
		dmg\SetAttacker(self)
		dmg\SetInflictor(self)
		dmg\SetDamageType(dtype)
		
		ply\TakeDamageInfo(dmg)
		
		if ply\IsPlayer()
			if not ply\Alive() break
		elseif not SCP_HaveZeroHP[ply\GetClass()]
			if ply\Health() <= 0 break
	
	if not ply\IsPlayer()
		if ply\GetClass() == 'npc_turret_floor' or ply\GetClass() == 'npc_combinedropship'
			ply\Fire('SelfDestruct')
	else
		if ply\Alive() then ply\Kill()
	
	if not ply\IsPlayer()
		ply.SCP_SLAYED = true

ENT.Think = =>
	if IsValid(@Attacking)
		@AttackAt = @AttackAt or 0
		if @AttackAt > CurTime() return
		
		@AttackAt = nil
		@SetPos(@Attacking\GetPos())
		@Wreck(@Attacking)
		@Attacking = nil
		@LastPos = nil
		return
	elseif @LastPos
		@SetPos(@LastPos)
		@LastPos = nil
	
	for ply in *SCP_GetTargets()
		if ply == PLY continue
		if @CanSeeMe(ply)
            return
	
	lpos = @GetPos()
	min = 99999
	
	for k, v in pairs @TARGETS
		if not IsValid(v)
			@TARGETS[k] = nil
			continue
		
		if v\IsPlayer()
			if not v\Alive()
				@TARGETS[k] = nil
				continue
			
			if v\InVehicle()
				if v\GetVehicle()\GetParent() == self -- DSit
					@Wreck(v)
					@TARGETS[k] = nil
					continue
	
	ply = table.Random(@TARGETS)
	if not ply return
	@Attacking = ply
	@LastPos = lpos
	@AttackAt = CurTime() + math.random(3, 8)
	@SetPos(Vector(0, 0, -16000))
