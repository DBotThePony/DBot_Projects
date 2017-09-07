
--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

include 'shared.lua'
AddCSLuaFile 'shared.lua'
AddCSLuaFile 'cl_init.lua'

util.AddNetworkString('DTF2.TeleportedEntity')
util.AddNetworkString('DTF2.TeleportEntity')

ENT.Initialize = =>
	@BaseClass.Initialize(@)
	@currentTeleTarget = NULL
	@currentTeleTimer = 0
	@targetPlayback = 1
	@currentPlayback = 1

ENT.SelectLevel = (target) =>
	lvl1, lvl2 = target\GetLevel(), @GetLevel()
	if lvl1 > lvl2
		@SetLevel(lvl1, false)
		@SetUpgradeAmount(target\GetUpgradeAmount())
	elseif lvl1 < lvl2
		target\SetLevel(lvl2, false)
		target\SetUpgradeAmount(@GetUpgradeAmount())
	else
		upgrade = math.max(@GetUpgradeAmount(), target\GetUpgradeAmount())
		@SetUpgradeAmount(upgrade)
		target\SetUpgradeAmount(upgrade)

ENT.SetupAsExit = (entrance = NULL) =>
	@SetIsExit(true)
	return if not IsValid(entrance)
	entrance\SetExit(@)
	entrance\SetTeamType(@GetTeamType())
	@SetEntrance(entrance)
	@SelectLevel(entrance)

ENT.SetupAsEntrance = (exit = NULL) =>
	@SetIsExit(false)
	return if not IsValid(exit)
	exit\SetIsExit(true)
	exit\SetEntrance(@)
	exit\SetTeamType(@GetTeamType())
	@SetExit(exit)
	@SelectLevel(exit)

ENT.DetectStanding = =>
	pos = @GetPos() + Vector(0, 0, 4)
	endpos = pos + Vector(0, 0, 20)
	mins, maxs = @BuildingMins, @BuildingMaxs
	t = util.TraceHull({start: pos, :endpos, :mins, :maxs, filter: @})
	return IsValid(t.Entity) and @IsAlly(t.Entity), t

ENT.DoReset = => @SetResetAt(CurTime() + @GetReloadTime())

ENT.TriggerTeleport = (ent = NULL, force = false) =>
	return false if @GetIsExit() or not IsValid(ent) or not @HasExit() or not force and not @IsAlly(ent)
	net.Start('DTF2.TeleportEntity', true)
	net.WriteEntity(ent)
	net.WriteEntity(@)
	net.WriteEntity(@GetExit())
	net.Broadcast()
	@SetUses(@GetUses() + 1)
	@isTeleporting = true
	timer.Simple DTF2.GrabFloat(@TELE_DELAY), ->
		return if not @IsValid()
		@isTeleporting = false
		return if not IsValid(@GetExit())
		@DoReset()
		@GetExit()\TriggerReceive(ent, force)
		net.Start('DTF2.TeleportedEntity', true)
		net.WriteEntity(ent)
		net.WriteEntity(@)
		net.WriteEntity(@GetExit())
		-- net.WriteBool(math.random(1, 100) > 50)
		net.Broadcast()

DAMAGE_TYPES = {
	DMG_GENERIC
	DMG_CRUSH
	DMG_BULLET
	DMG_SLASH
	DMG_VEHICLE
	DMG_BLAST
	DMG_ENERGYBEAM
	DMG_PARALYZE
	DMG_NERVEGAS
	DMG_POISON
	DMG_AIRBOAT
	DMG_BUCKSHOT
	DMG_DIRECT
	DMG_PHYSGUN
	DMG_RADIATION
}

ENT.OnBuildFinish = => @SetResetAt(CurTime())
ENT.OnUpgradeFinish = => @SetResetAt(CurTime())

ENT.CallDestroy = (attacker = NULL, inflictor = NULL, dmg) =>
	hook.Run('TF2TeleporterDestroyed', @, attacker, inflictor, dmg)

ENT.CallDestruction = =>
	tele2 = @GetConnectedTeleporter()
	if IsValid(tele2)
		tele2\SetLevel(1, false)
		tele2\SetUpgradeAmount(0)

TELEFRAG = CreateConVar('tf_teleport_telefrag', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Allow to telefrag')

ENT.TriggerReceive = (ent = NULL, force = false) =>
	return false if not force and (not @IsAlly(ent) or not @GetIsExit()) or not IsValid(ent)
	pos = @GetStandPos()
	mins, maxs = ent\OBBMins(), ent\OBBMaxs()

	if TELEFRAG\GetBool()
		targets = {}
		trData = {
			start: pos
			endpos: pos + Vector(0, 0, 24)
			mask: MASK_SOLID
			:mins, :maxs
			filter: (entHit) -> 
				return false if entHit == @ or entHit == ent or not IsValid(entHit)
				table.insert(targets, entHit) if not @IsAlly(entHit)
				return false
		}

		util.TraceHull(trData)
		for tr in *targets
			dmg = tr\Health() * 6
			for dmgtype in *DAMAGE_TYPES
				newDMG = DamageInfo()
				newDMG\SetAttacker(ent)
				newDMG\SetInflictor(@)
				newDMG\SetDamage(dmg)
				newDMG\SetMaxDamage(dmg)
				newDMG\SetReportedPosition(pos)
				newDMG\SetDamagePosition(pos)
				newDMG\SetDamageType(dmgtype)
				tr\TakeDamageInfo(newDMG)

	ent\SetPos(pos)

	if ent\IsPlayer()
		ent\SetEyeAngles(@GetTeleAngles())
	else
		ent\SetAngles(@GetTeleAngles())
	
	@DoReset()
	
	if @SPAWN_BREAD\GetBool() and math.random(1, 100) < @BREAD_CHANCE\GetInt()
		tpPoint = @GetBreadPoint()
		spawnedEnts = {}
		for i = 1, math.random(DTF2.GrabInt(@MIN_BREAD), DTF2.GrabInt(@MAX_BREAD))
			with spawned = ents.Create('prop_physics')
				mdl = table.Random(@BREAD_MODELS)
				\SetModel(mdl)
				\SetPos(tpPoint)
				\SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				\Spawn()
				\Activate()
				\SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				with \GetPhysicsObject()
					\EnableMotion(true)
					\Wake()
					\SetVelocity(VectorRand() * math.random(160, 400))
				table.insert(spawnedEnts, spawned)
		timer.Simple math.random(DTF2.GrabInt(@MIN_BREAD_TTL), DTF2.GrabInt(@MAX_BREAD_TTL)), -> ent\Remove() for ent in *spawnedEnts when ent\IsValid()

ENT.BehaveUpdate = (delta) =>
	return if @isTeleporting
	if not @IsAvaliable()
		@currentTeleTarget = NULL
		@currentTeleTimer = 0
		return
	
	if not @ReadyToTeleport()
		@ResetSequence(0) if @GetSequence() ~= 0
		@currentTeleTarget = NULL
		@currentTeleTimer = 0
		return
	
	@ResetSequence(2) if @GetSequence() ~= 2
	@UpdateRelationships()
	isAlly, tr = @DetectStanding()
	if not isAlly
		@currentTeleTarget = NULL
		@currentTeleTimer = 0
		return
	
	ent = tr.Entity
	return if ent\IsPlayer() and ent\InVehicle()
	if @currentTeleTarget ~= ent
		@currentTeleTarget = ent
		@currentTeleTimer = 0
	
	@currentTeleTimer += delta
	if @currentTeleTimer > DTF2.GrabFloat(@TELE_WAIT)
		@TriggerTeleport(ent)
		@currentTeleTarget = NULL
		@currentTeleTimer = 0
