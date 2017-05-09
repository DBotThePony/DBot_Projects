
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


include 'shared.lua'
AddCSLuaFile 'cl_init.lua'

ENT.Initialize = =>
	@SetModel('models/new173/new173.mdl')
	
	@Killer = ents.Create('dbot_scp173_killer')
	@Killer\SetPos(@GetPos())
	@Killer\Spawn()
	@Killer\Activate()
	@Killer\SetParent(@)
	
	@PhysicsInitBox(Vector(-16, -16, 0), Vector(16, 16, 80))
	@SetMoveType(MOVETYPE_NONE)
	@SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	@LastMove = 0
	@JumpTries = 0

interval = (val, min, max) -> val > min and val <= max
ENT.GetRealAngle = (pos) => (@GetPos() - pos)\Angle()
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
	
	if ply\IsPlayer()
		cond = (not interval(diffYaw, -70, 70) or not interval(diffPith, -60, 60))
		if cond
			return false
	elseif ply\IsNPC()
		if ply\GetNPCState() == NPC_STATE_DEAD
			return false
		
		cond = (not interval(diffYaw, -50, 50) or not interval(diffPith, -45, 45))
		
		if cond
			return false
	else
		cond = (not interval(diffYaw, -50, 50) or not interval(diffPith, -45, 45))
		if cond
			return false
	hit = false
	
	tr = util.TraceLine({
		start: epos,
		endpos: lpos + Vector(0, 0, 40),
		filter: (ent) ->
			if ent == @
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

	return hit


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

ENT.Wreck = (ply) =>
	if SCP_NoKill
		if ply.SCP_Killed return 
		ply.SCP_Killed = true
		
		@EmitSound('snap.wav', 100)
		
		if ply\IsPlayer()
			PrintMessage(HUD_PRINTTALK, ply\Nick() .. ' should be dead now, but he is not :c')
		else
			ply.SCP_SLAYED = true
		return
	
	ply\TakeDamage(INT, @, @Killer)
	
	for k, v in pairs(DAMAGE_TYPES) do
		dmg = DamageInfo()
		
		dmg\SetDamage(INT)
		dmg\SetAttacker(@)
		dmg\SetInflictor(@Killer)
		dmg\SetDamageType(v)
		
		ply\TakeDamageInfo(dmg)
		
		if ply\IsPlayer()
			if not ply\Alive() break
		elseif not SCP_HaveZeroHP[ply\GetClass()]
			if ply\Health() <= 0 break 
	
	if not ply\IsPlayer()
		if ply\GetClass() == 'npc_turret_floor' or ply\GetClass() == 'npc_combinedropship'
			ply\Fire('SelfDestruct')
	else
		if ply\Alive()
            ply\Kill() 
	
	@EmitSound('snap.wav', 100)
	
	if not ply\IsPlayer()
		ply.SCP_SLAYED = true

ENT.Jumpscare = =>
	lpos = @GetPos()
	rand = table.Random(SCP_GetTargets())
	
	rpos = rand\GetPos()
	rang = rand\EyeAngles()
	newpos = rpos - rang\Forward() * math.random(40, 120)
	newang = (rpos - lpos)\Angle()
	
	newang.p = 0
	newang.r = 0
	
	@SetPos(newpos)
	@SetAngles(newang)

ENT.TryMoveTo = (pos) =>
	tr = util.TraceHull({
		start: @GetPos()
		endpos: pos
        mins: @OBBMins()
		maxs: @OBBMaxs()
		filter: (ent) ->
			if ent == @ return false
			if not IsValid(ent) return true
			if ent\IsPlayer() return false
			if ent\IsNPC() return false
			if ent\IsVehicle() return false
			if ent\GetClass() == 'dbot_scp173' return false
			return true
	})
	
	@SetPos(tr.HitPos + tr.HitNormal)

ENT.TurnTo = (pos) =>
	ang = @GetRealAngle(pos)
	
	ang.p = 0
	ang.r = 0
	
	@SetAngles(ang)


ENT.RealDropToFloor = =>
	@TryMoveTo(@GetPos() + Vector(0, 0, -8000))

ENT.Think = =>
	if CLIENT return 
	
	plys = SCP_GetTargets()
	for ply in *plys
		if @CanSeeMe(ply)
			@RealDropToFloor()
			return
	
	lpos = @GetPos()
	local plyTarget
	min = 99999
	
	for ply in *plys
        if ply\IsPlayer()
            if not ply\Alive() continue
            if ply\InVehicle()
                if ply\GetVehicle()\GetParent() == @
                    @Wreck(ply)
                    continue
		
		dist = ply\GetPos()\Distance(lpos)
		if dist < min
			plyTarget = ply
			min = dist
	
	if not plyTarget return
	
	if @LastMove + 10 - CurTime() < 0
		@Jumpscare()
		@LastMove = CurTime()
		return
	
	@LastMove = CurTime()
	
	pos = plyTarget\GetPos()
	@TurnTo(pos)
	
	lerp = LerpVector(0.3, lpos, pos)
	start = lpos + Vector(0, 0, 40)
	filter = {@, plyTarget}
	
	table.insert(filter, val) for val in *ents.FindByClass('dbot_scp173')
	table.insert(filter, val) for val in *player.GetAll()
	
	tr = util.TraceHull({
		start: start
		endpos: lerp + @OBBMaxs()
		filter: filter
		mins: @OBBMins()
		maxs: @OBBMaxs()
	})
	
	if tr.Hit and not IsValid(tr.Entity) and start == tr.HitPos
		@Jumpscare()
	
	if not tr.Hit
		@SetPos(lerp)
	else
		@SetPos(tr.HitPos)
	
	if @GetPos()\Distance(lpos) < 5
		@JumpTries = @JumpTries + 1
		
		if @JumpTries > 10
			@Jumpscare()
			return
	else
		@JumpTries = 0
	
	if @GetPos()\Distance(pos) < 128
		@Wreck(plyTarget)
