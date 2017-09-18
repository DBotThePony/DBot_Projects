
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
AddCSLuaFile 'cl_init.lua'

ATTACK_PLAYERS = CreateConVar('tf_attack_players', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Sentries attacks players')
FORGIVE = CreateConVar('tf_forgive', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Forgive attackers')
FORGIVE_TIMER = CreateConVar('tf_forgive_timer', '30', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Forgivtion timer')
UPDATE_OWNED_RELATIONSHIPS = CreateConVar('tf_attack_attackers', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Sentries should attack players who injured its owner')
UPDATE_OWNED_RELATIONSHIPS_ALL = CreateConVar('tf_attack_attackers_all', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Sentries should attack entities who are injuring their allies')

ENT.OnLeaveGround = =>
ENT.OnLandOnGround = =>
ENT.OnStuck = =>
ENT.OnUnStuck = =>
ENT.OnContact = (victim) =>
ENT.OnOtherKilled = (victim, dmg) =>
ENT.OnIgnite = =>
ENT.OnNavAreaChanged = (old, new) =>
ENT.HandleStuck = =>
ENT.MoveToPos = (pos, options) =>

ENT.BehaveStart = =>
ENT.BehaveUpdate = (delta) =>
	cTime = CurTime()
	for data in *@delayGestureRemove
		if data[2] < cTime
			@RemoveGesture(data[1])
	@delayGestureRemove = [data for data in *@delayGestureRemove when data[2] > cTime]

ENT.BodyUpdate = =>
	@FrameAdvance()

ENT.RunBehaviour = =>

ENT.GetEnemy = => @currentTarget

ENT.TriggerDestruction = (trigger = @GetTFPlayer()) =>
	hook.Run 'TF2BuildDestructed', @, trigger
	@Explode()

ENT.CallDestruction = =>

ENT.Explode = =>
	pos = @GetPos() + Vector(0, 0, 25)
	@EmitSound(@ExplosionSound) if @ExplosionSound
	for gib in *@GetGibs()
		with ent = ents.Create('dbot_tf_derbis')
			\SetPos(pos)
			\SetModel(gib)
			\Spawn()
			\Activate()
			\RealSetModel(gib)
			\SetDerbisValue(DTF2.GrabInt(@GibsValue))
			\Shake()
	@CallDestruction()
	effData = EffectData()
	effData\SetNormal(Vector(0, 0, 1))
	effData\SetOrigin(@GetPos() + Vector(0, 0, 5))
	util.Effect('dtf2_building_explosion', effData)
	@Remove()

ENT.OnInjured = (dmg) =>
	if dmg\GetAttacker() == @ or dmg\GetAttacker()\IsValid() and @IsAlly(dmg\GetAttacker())
		dmg\SetDamage(0)
		dmg\SetMaxDamage(0)

ENT.CallDestroy = (attacker = NULL, inflictor = NULL, dmg) =>
ENT.OnKilled = (dmg) =>
	hook.Run('OnNPCKilled', @, dmg\GetAttacker(), dmg\GetInflictor(), dmg)
	hook.Run('TF2BuildDestroyed', @, dmg\GetAttacker(), dmg\GetInflictor(), dmg)
	@CallDestroy(dmg\GetAttacker(), dmg\GetInflictor(), dmg)
	@Explode()

ENT.DelayGestureRemove = (gestID = ACT_INVALID, time = 0) =>
	table.insert(@delayGestureRemove, {gestID, CurTime() + time})

ENT.DelayGestureRemoveOld = (gestID = ACT_INVALID, time = 0) =>
	timer.Create "DTF2.RemoveGesture.#{@EntIndex()}.#{gestID}", time, 1, -> @RemoveGesture(gestID) if IsValid(@)

ENT.DelaySound = (time = 0, soundName = '', ...) =>
	vararg = {...}
	timer.Create "DTF2.PlaySound.#{@EntIndex()}.#{soundName}", time, 1, -> @EmitSound(soundName, unpack(vararg)) if IsValid(@)

VALID_TARGETS = {}
VALID_ALLIES = {}

isEnemy = (ent = NULL) ->
	return false if not ent\IsValid()
	return IsEnemyEntityName(ent\GetClass())

CLASS_SCIENTIST = 27
CLASS_ENEMY_GRUNT = 28
CLASS_ALIEN_ARMY = 29
CLASS_XEN_ANIMALS = 30
CLASS_XEN_ANIMALS_HEADCRAB = 31
CLASS_XEN_ANIMALS_HOSTILE = 32
CLASS_XEN_BUG = 33
CLASS_SNARK = 35

_G.DTF2 = _G.DTF2 or {}
DTF2 = _G.DTF2

ENTMETA = FindMetaTable('Entity')
NPCMETA = FindMetaTable('NPC')
ENT_GETCLASS = ENTMETA.GetClass
NPC_CLASSIFY = NPCMETA.Classify
ENT_GETPOS = ENTMETA.GetPos
ENT_OBBMINS = ENTMETA.OBBMins
ENT_OBBMAXS = ENTMETA.OBBMaxs
ENT_OBBCENTER = ENTMETA.OBBCenter
ENT_ISNPC = ENTMETA.IsNPC
NPC_ISNPC = NPCMETA.IsNPC
NPC_GETNPCSTATE = NPCMETA.GetNPCState
VECTOR_ROTATE = Vector(0, 0, 0).Rotate
ENT_GETANGLES = ENTMETA.GetAngles
DTF2_Pointer = DTF2.Pointer
table_insert = table.insert

IS_ALLY = (ent, def = false) ->
	return not ATTACK_PLAYERS\GetBool() if type(ent) == 'Player'
	return DTF2.IS_ENEMY_CLASS(ent, def) if type(ent) ~= 'NPC'
	classify = NPC_CLASSIFY(ent)
	return classify == CLASS_PLAYER_ALLY or
			classify == CLASS_PLAYER_ALLY_VITAL or
			classify == CLASS_PLAYER_ALLY_VITAL or
			classify == CLASS_CITIZEN_PASSIVE or
			classify == CLASS_HACKED_ROLLERMINE or
			classify == CLASS_SCIENTIST or
			classify == CLASS_EARTH_FAUNA or
			classify == CLASS_VORTIGAUNT or
			classify == CLASS_CITIZEN_REBEL

IS_ENEMY = (ent, def = true) ->
	return ATTACK_PLAYERS\GetBool() if type(ent) == 'Player'
	return DTF2.IS_ENEMY_CLASS(ent, def) if type(ent) ~= 'NPC'
	classify = NPC_CLASSIFY(ent)
	return classify == CLASS_COMBINE_HUNTER or
			classify == CLASS_ALIEN_ARMY or
			classify == CLASS_XEN_ANIMALS or
			classify == CLASS_XEN_ANIMALS_HOSTILE or
			classify == CLASS_XEN_ANIMALS_HEADCRAB or
			classify == CLASS_SNARK or
			classify == CLASS_XEN_BUG or
			classify == CLASS_ENEMY_GRUNT or
			classify == CLASS_SCANNER or
			classify == CLASS_ZOMBIE or
			classify == CLASS_PROTOSNIPER or
			classify == CLASS_STALKER or
			classify == CLASS_MILITARY or
			classify == CLASS_METROPOLICE or
			classify == CLASS_MANHACK or
			classify == CLASS_HEADCRAB or
			classify == CLASS_COMBINE_GUNSHIP or
			classify == CLASS_BARNACLE or
			classify == CLASS_ANTLION or
			classify == CLASS_NONE or
			classify == CLASS_COMBINE

UpdateTargetList = ->
	findEnts = ents.GetAll()
	VALID_TARGETS = {}
	VALID_ALLIES = {}

	for ent in *findEnts
		nClass = ENT_GETCLASS(ent)
		isEnemyClass = DTF2.IS_ENEMY_CLASS(nClass)
		isNPC = type(ent) == 'NPC'
		if isEnemyClass or isNPC and nClass ~= 'npc_bullseye' and NPC_GETNPCSTATE(ent) ~= NPC_STATE_DEAD
			center = ENT_OBBCENTER(ent)
			VECTOR_ROTATE(center, ENT_GETANGLES(ent))
			npcData = {ent, ENT_GETPOS(ent), ENT_OBBMINS(ent), ENT_OBBMAXS(ent), ENT_OBBCENTER(ent), center, DTF2_Pointer(ent)}
			classify = isNPC and NPC_CLASSIFY(ent) or 0
			if isEnemyClass
				VALID_TARGETS[#VALID_TARGETS + 1] = npcData
			elseif (classify == CLASS_PLAYER_ALLY or
				classify == CLASS_PLAYER_ALLY_VITAL or
				classify == CLASS_PLAYER_ALLY_VITAL or
				classify == CLASS_CITIZEN_PASSIVE or
				classify == CLASS_HACKED_ROLLERMINE or
				classify == CLASS_SCIENTIST or
				classify == CLASS_EARTH_FAUNA or
				classify == CLASS_VORTIGAUNT or
				classify == CLASS_CITIZEN_REBEL) then
				VALID_ALLIES[#VALID_ALLIES + 1] = npcData
			elseif (classify == CLASS_COMBINE_HUNTER or
				classify == CLASS_ALIEN_ARMY or
				classify == CLASS_XEN_ANIMALS or
				classify == CLASS_XEN_ANIMALS_HOSTILE or
				classify == CLASS_XEN_ANIMALS_HEADCRAB or
				classify == CLASS_SNARK or
				classify == CLASS_XEN_BUG or
				classify == CLASS_ENEMY_GRUNT or
				classify == CLASS_SCANNER or
				classify == CLASS_ZOMBIE or
				classify == CLASS_PROTOSNIPER or
				classify == CLASS_STALKER or
				classify == CLASS_MILITARY or
				classify == CLASS_METROPOLICE or
				classify == CLASS_MANHACK or
				classify == CLASS_HEADCRAB or
				classify == CLASS_COMBINE_GUNSHIP or
				classify == CLASS_BARNACLE or
				classify == CLASS_ANTLION or
				classify == CLASS_NONE or
				classify == CLASS_COMBINE) then
				VALID_TARGETS[#VALID_TARGETS + 1] = npcData
	
	if ATTACK_PLAYERS\GetBool()
		for ent in *player.GetAll()
			center = ENT_OBBCENTER(ent)
			VECTOR_ROTATE(center, ENT_GETANGLES(ent))
			table_insert(VALID_TARGETS, {ent, ENT_GETPOS(ent), ENT_OBBMINS(ent), ENT_OBBMAXS(ent), ENT_OBBCENTER(ent), center, DTF2.Pointer(ent)})
	else
		for ent in *player.GetAll()
			center = ENT_OBBCENTER(ent)
			VECTOR_ROTATE(center, ENT_GETANGLES(ent))
			table_insert(VALID_ALLIES, {ent, ENT_GETPOS(ent), ENT_OBBMINS(ent), ENT_OBBMAXS(ent), ENT_OBBCENTER(ent), center, DTF2.Pointer(ent)})

UpdateTargetListLight = ->
	VALID_TARGETS = for {ent, pos, mins, maxs, center1, center, pointer} in *VALID_TARGETS
		return UpdateTargetList() if not ent\IsValid()
		center = ENT_OBBCENTER(ent)
		VECTOR_ROTATE(center, ENT_GETANGLES(ent))
		{ent, ENT_GETPOS(ent), mins, maxs, center1, center, pointer}
	VALID_ALLIES = for {ent, pos, mins, maxs, center1, center, pointer} in *VALID_ALLIES
		return UpdateTargetList() if not ent\IsValid()
		center = ENT_OBBCENTER(ent)
		VECTOR_ROTATE(center, ENT_GETANGLES(ent))
		{ent, ENT_GETPOS(ent), mins, maxs, center1, center, pointer}

hook.Add 'Think', 'DTF2.FetchTagrets', UpdateTargetListLight
hook.Add 'PlayerSpawn', 'DTF2.UpdateTargetList', -> timer.Create 'DTF2.UpdateTargetList', 0.1, 1, UpdateTargetList
hook.Add 'PlayerDisconnected', 'DTF2.UpdateTargetList', -> timer.Create 'DTF2.UpdateTargetList', 0.1, 1, UpdateTargetList
hook.Add 'OnEntityCreated', 'DTF2.UpdateTargetList', -> timer.Create 'DTF2.UpdateTargetList', 0.1, 1, UpdateTargetList
hook.Add 'EntityRemoved', 'DTF2.UpdateTargetList', -> timer.Create 'DTF2.UpdateTargetList', 0.1, 1, UpdateTargetList
hook.Add 'OnNPCKilled', 'DTF2.UpdateTargetList', -> timer.Create 'DTF2.UpdateTargetList', 0.1, 1, UpdateTargetList

RemoveTFTarget = (target) ->
	for ent in *ents.FindByClass('dbot_tf_*')
		if ent.IsTF2Building
			ent\UnmarkEntity(target)

hook.Add 'OnNPCKilled', 'DTF2.BuildablesTargetList', (npc, attacker, inflictor) ->
	attacker\UnmarkEntity(npc) if IsValid(attacker) and attacker.IsTF2Building
	inflictor\UnmarkEntity(npc) if IsValid(inflictor) and inflictor.IsTF2Building and inflictor ~= attacker
	return

hook.Add 'PlayerDeath', 'DTF2.BuildablesTargetList', (ply, inflictor, attacker) ->
	attacker\UnmarkEntity(ply) if IsValid(attacker) and attacker.IsTF2Building
	inflictor\UnmarkEntity(ply) if IsValid(inflictor) and inflictor.IsTF2Building and inflictor ~= attacker
	RemoveTFTarget(ply)
	return

UpdateTargetList()

hook.Add 'EntityTakeDamage', 'DTF2.Bullseye', (dmg) =>
	parent = false
	if @DTF2_Parent
		return if @DTF2_LastDMG > CurTime()
		@DTF2_LastDMG = CurTime() + 0.1
		@ = @DTF2_Parent
		parent = true
	if parent
		@TakeDamageInfo(dmg)

checkFriendlyFire = (dmg) =>
	attacker = dmg\GetAttacker()
	inflictor = dmg\GetInflictor()
	if @IsTF2Building and (attacker\IsValid() and (@IsAlly(attacker) or attacker == @))
		dmg\SetDamage(0)
		dmg\SetDamageBonus(0)
		dmg\SetMaxDamage(0)
		return true
	if IsValid(attacker) and attacker.IsTF2Building and attacker\IsAlly(@)
		dmg\SetDamage(0)
		dmg\SetDamageBonus(0)
		dmg\SetMaxDamage(0)
		return true
	if IsValid(inflictor) and (inflictor.IsTF2Building and inflictor\IsAlly(@) or inflictor.IsBuildingPart and IsValid(inflictor\GetBuildableOwner()) and inflictor\GetBuildableOwner()\IsAlly(@))
		dmg\SetDamage(0)
		dmg\SetDamageBonus(0)
		dmg\SetMaxDamage(0)
		return true

hook.Add 'EntityTakeDamage', 'DTF2.BuildablesFriendlyFire', checkFriendlyFire

hook.Add 'EntityTakeDamage', 'DTF2.CheckBuildablesOwner', (dmg) =>
	return if not UPDATE_OWNED_RELATIONSHIPS\GetBool()
	attacker = dmg\GetAttacker()
	return if attacker == @ or not IsValid(attacker) or not @GetBuildedSentry or dmg\GetDamage() <= 0 or checkFriendlyFire(@, dmg)
	sentry = @GetBuildedSentry()
	dispenser = @GetBuildedDispenser()
	entrance = @GetBuildedTeleporterIn()
	exit = @GetBuildedTeleporterOut()
	sentry\MarkAsEnemy(attacker) if IsValid(sentry)
	dispenser\MarkAsEnemy(attacker) if IsValid(dispenser)
	entrance\MarkAsEnemy(attacker) if IsValid(entrance)
	exit\MarkAsEnemy(attacker) if IsValid(exit)
	return if not FORGIVE\GetBool()
	timer.Create 'DTF2.Forgive.' .. tostring(@), FORGIVE_TIMER\GetInt(), 1, ->
		return if not IsValid(attacker)
		sentry\UnmarkEntity(attacker) if IsValid(sentry)
		dispenser\UnmarkEntity(attacker) if IsValid(dispenser)
		entrance\UnmarkEntity(attacker) if IsValid(entrance)
		exit\UnmarkEntity(attacker) if IsValid(exit)
	return

ENTS_TO_CHECK = {}

hook.Add 'Think', 'DTF2.CheckBuildablesAllies', ->
	return if not UPDATE_OWNED_RELATIONSHIPS_ALL\GetBool()
	buildables = [ent for ent in *ents.FindByClass('dbot_tf_*') when ent.IsTF2Building]
	check = ENTS_TO_CHECK
	ENTS_TO_CHECK = {}
	for {victim, attacker} in *check
		for build in *buildables
			if build\IsAllyLight(victim, true) and not build\IsAllyLight(attacker, false)
				build\MarkAsEnemy(attacker)
				timer.Create("DTF2.Forgive.#{build}.#{attacker}", FORGIVE_TIMER\GetInt(), 1, -> build\UnmarkEntity(attacker) if IsValid(attacker) and IsValid(build)) if FORGIVE\GetBool()
	return

hook.Add 'EntityTakeDamage', 'DTF2.CheckBuildablesAllies', (dmg) =>
	return if not UPDATE_OWNED_RELATIONSHIPS_ALL\GetBool()
	attacker = dmg\GetAttacker()
	inflictor = dmg\GetInflictor()
	return if attacker == @ or not IsValid(attacker) or attacker.IsTF2Building or @IsTF2Building or IsValid(inflictor) and inflictor.IsTF2Building or IS_ENEMY(attacker, false) or not IS_ALLY(@) or IS_ALLY(@) and IS_ALLY(attacker)
	for {victim, attacker2} in *ENTS_TO_CHECK
		return if victim == @ and attacker2 == attacker
	table.insert(ENTS_TO_CHECK, {@, attacker})
	return

include 'shared.lua'
AddCSLuaFile 'shared.lua'

ENT.DuplicatorFunc = =>
	return if not @IsAvaliable()
	@SetLevel(@GetLevel(), false, true)

ENT.Initialize = =>
	@npc_bullseye = {}
	@DrawShadow(false)
	@SetModel(@IdleModel1)
	@SetHealth(@GetMaxHP())
	@SetMaxHealth(@GetMaxHP())
	@mLevel = 1
	@delayGestureRemove = {}

	@PhysicsInitBox(@BuildingMins, @BuildingMaxs)
	@SetMoveType(MOVETYPE_NONE)
	@GetPhysicsObject()\EnableMotion(false)
	@obbcenter = @OBBCenter()

	@SetIsBuilding(false)
	@SetnwLevel(1)
	@SetBuildSpeedup(false)
	@lastThink = CurTime()
	@buildSpeedupUntil = 0
	@upgradeFinishAt = 0
	@UpdateSequenceList()
	@StartActivity(ACT_OBJ_RUNNING)
	@CreateBullseye()
	@markedTargets = {}
	@markedAllies = {}
	@nextMarkedRebuild = CurTime() + 60
	timer.Simple 0.1, -> @DuplicatorFunc() if @IsValid()

ENT.RealSetModel = (mdl = @GetModel()) =>
	@SetModel(mdl)
	with @GetPhysicsObject()
		\EnableCollisions(false) if \IsValid()
	@PhysicsInitBox(@BuildingMins, @BuildingMaxs)
	@SetMoveType(MOVETYPE_NONE)

ENT.GetAllies = => [ent for ent in *VALID_ALLIES]
ENT.GetEnemies = => [ent for ent in *VALID_TARGETS]
ENT.GetAlliesTable = => VALID_ALLIES
ENT.GetEnemiesTable = => VALID_TARGETS

BOOL_OR_FUNC = (val, undef = true, ...) ->
	switch type(val)
		when 'function'
			return val(...)
		when 'nil'
			return undef
		else
			return val

ENT.CheckTarget = (target = NULL) =>
	target\IsValid() and
	not BOOL_OR_FUNC(target.IsDroneDestroyed, false, target) and
	BOOL_OR_FUNC(target.IsDestroyed, true, target) and
	BOOL_OR_FUNC(target.IsWorking, true, target) and
	(target\GetMaxHealth() <= 0 or target\Health() > 0) and
	(BOOL_OR_FUNC(target.GetMaxHP, 0, target) <= 0 or BOOL_OR_FUNC(target.GetHP, 1, target) > 0)

ENT.RebuildMarkedList = =>
	@markedTargets = [target for target in *@markedTargets when @CheckTarget(target[1]) and target[1] ~= @GetTFPlayer()]
	@markedAllies = [target for target in *@markedAllies when target[1]\IsValid() and target[1] ~= @GetTFPlayer()]

ENT.UpdateMarkedList = =>
	pl = @GetTFPlayer()
	@markedTargets = for {ent, pos, mins, maxs, center1, center, pointer} in *@markedTargets
		return @RebuildMarkedList() if not @CheckTarget(ent) or ent == pl
		center = ent\OBBCenter()
		center\Rotate(ent\GetAngles())
		{ent, ent\GetPos(), mins, maxs, center1, center, pointer}
	@markedAllies = for {ent, pos, mins, maxs, center1, center, pointer} in *@markedAllies
		return @RebuildMarkedList() if not ent\IsValid() or ent == pl
		center = ent\OBBCenter()
		center\Rotate(ent\GetAngles())
		{ent, ent\GetPos(), mins, maxs, center1, center, pointer}

ENT.MarkAsEnemy = (ent = NULL) =>
	return false if not @CheckTarget(ent)
	return false if ent == @GetTFPlayer()
	for target in *@markedTargets
		return false if target[1] == ent
	
	for i = 1, #@markedAllies
		if @markedAllies[i][1] == ent
			table.remove(@markedAllies, i)
			break

	center = ent\OBBCenter()
	center\Rotate(ent\GetAngles())
	return true, table.insert(@markedTargets, {ent, ent\GetPos(), ent\OBBMins(), ent\OBBMaxs(), ent\OBBCenter(), center, DTF2.Pointer(ent)})

ENT.UnmarkEntity = (ent = NULL) =>
	return false if not IsValid(ent)
	return false if ent == @GetTFPlayer()

	for i = 1, #@markedAllies
		if @markedAllies[i][1] == ent
			table.remove(@markedAllies, i)
			return true, i

	for i = 1, #@markedTargets
		if @markedTargets[i][1] == ent
			table.remove(@markedTargets, i)
			return true, i

	return false

ENT.MarkAsAlly = (ent = NULL) =>
	return false if not IsValid(ent)
	for target in *@markedAllies
		return false if target[1] == ent
	
	for i = 1, #@markedTargets
		if @markedTargets[i][1] == ent
			table.remove(@markedTargets, i)
			break

	center = ent\OBBCenter()
	center\Rotate(ent\GetAngles())
	return true, table.insert(@markedAllies, {ent, ent\GetPos(), ent\OBBMins(), ent\OBBMaxs(), ent\OBBCenter(), center, DTF2.Pointer(ent)})

ENT.IsEnemy = (target = NULL) =>
	return true if not IsValid(target)
	for ent in *@markedTargets
		return true if target == ent[1]
	for ent in *VALID_TARGETS
		return true if ent[1] == target
	return true

ENT.IsAlly = (target = NULL) =>
	return false if not IsValid(target)
	for ent in *@markedTargets
		return false if target == ent[1]
	for ent in *@markedAllies
		return true if target == ent[1]
	for ent in *VALID_ALLIES
		return true if ent[1] == target
	return false

ENT.IsEnemyLight = (target = NULL, def = true) =>
	return def if not IsValid(target)
	for ent in *@markedTargets
		return true if target == ent[1]
	return def

ENT.IsAllyLight = (target = NULL, def = false) =>
	return def if not IsValid(target)
	for ent in *@markedAllies
		return true if target == ent[1]
	return def

ENT.CreateBullseye = =>
	if @npc_bullseye
		eye\Remove() for {eye} in *@npc_bullseye when IsValid(eye)
	
	mins, maxs, center = @OBBMins(), @OBBMaxs(), @OBBCenter()

	box = {
		Vector(0, 0, mins.z)
		Vector(0, 0, maxs.z)

		Vector(mins.x, center.y, center.z)
		Vector(-mins.x, center.y, center.z)

		Vector(center.x, mins.y, center.z)
		Vector(center.x, -mins.y, center.z)
	}

	@npc_bullseye = for vec in *box
		ent = ents.Create('npc_bullseye')
		with ent
			\SetKeyValue('targetname', 'dtf2_bullseye')
			\SetKeyValue('spawnflags', '131072')
			\SetPos(@LocalToWorld(vec))
			\Spawn()
			\Activate()
			\SetCollisionGroup(COLLISION_GROUP_WORLD)
			\SetHealth(2 ^ 31 - 1)
			\SetParent(@)
			\SetNotSolid(true)
			.DTF2_Parent = @
			.DTF2_LastDMG = 0
		{ent, DTF2.Pointer(ent)}

ENT.UpdateRelationships = =>
	pointerPrefix = 'DTF2_B_P_' .. DTF2.Pointer(@) .. '_'
	for {target} in *VALID_TARGETS
		if target\IsValid() and target\IsNPC()
			target[pointerPrefix .. DTF2.Pointer(target) .. '_' .. pointer] = target\AddEntityRelationship(eye, D_HT, 0) or D_HT for {eye, pointer} in *@npc_bullseye when target[pointerPrefix .. DTF2.Pointer(target) .. '_' .. pointer] ~= D_HT
	for {target} in *VALID_ALLIES
		if target\IsValid() and target\IsNPC()
			target[pointerPrefix .. DTF2.Pointer(target) .. '_' .. pointer] = target\AddEntityRelationship(eye, D_LI, 0) or D_LI for {eye, pointer} in *@npc_bullseye when target[pointerPrefix .. DTF2.Pointer(target) .. '_' .. pointer] ~= D_LI
	for {target} in *@markedTargets
		if target\IsValid() and target\IsNPC()
			target[pointerPrefix .. DTF2.Pointer(target) .. '_' .. pointer] = target\AddEntityRelationship(eye, D_HT, 0) or D_HT for {eye, pointer} in *@npc_bullseye when target[pointerPrefix .. DTF2.Pointer(target) .. '_' .. pointer] ~= D_HT
	for {target} in *@markedAllies
		if target\IsValid() and target\IsNPC()
			target[pointerPrefix .. DTF2.Pointer(target) .. '_' .. pointer] = target\AddEntityRelationship(eye, D_LI, 0) or D_LI for {eye, pointer} in *@npc_bullseye when target[pointerPrefix .. DTF2.Pointer(target) .. '_' .. pointer] ~= D_LI

ENT.GetAlliesVisible = =>
	output = {}
	pos = @GetPos()
	mx = DTF2.GrabInt(@MAX_DISTANCE) ^ 2
	
	for {target, tpos, mins, maxs, center, rotatedCenter} in *VALID_ALLIES
		hit = false
		for target2 in *@markedTargets
			if target2[1] == target
				hit = true
				break
		if not hit
			dist = pos\DistToSqr(tpos)
			if target\IsValid() and dist < mx
				table.insert(output, {target, tpos, dist, rotatedCenter})
	
	for {target, tpos, mins, maxs, center, rotatedCenter} in *@markedAllies
		dist = pos\DistToSqr(tpos)
		if target\IsValid() and dist < mx
			table.insert(output, {target, tpos, dist, rotatedCenter})
	
	table.sort output, (a, b) -> a[3] < b[3]
	newOutput = {}
	trFilter = [eye[1] for eye in *@npc_bullseye]
	table.insert(trFilter, @)

	for {target, tpos, dist, center} in *output
		trData = {
			filter: trFilter
			start: @obbcenter + pos
			endpos: tpos + center
			mins: @HULL_TRACE_MINS
			maxs: @HULL_TRACE_MAXS
		}

		tr = util.TraceHull(trData)
		if tr.Hit and tr.Entity == target
			table.insert(newOutput, target)

	return newOutput

ENT.GetTargetsVisible = =>
	output = {}
	pos = @GetPos()
	mx = DTF2.GrabInt(@MAX_DISTANCE) ^ 2
	
	for {target, tpos, mins, maxs, center, rotatedCenter} in *VALID_TARGETS
		hit = false
		for target2 in *@markedAllies
			if target2[1] == target
				hit = true
				break
		if not hit
			dist = pos\DistToSqr(tpos)
			if target\IsValid() and dist < mx
				table.insert(output, {target, tpos, dist, rotatedCenter})
	
	for {target, tpos, mins, maxs, center, rotatedCenter} in *@markedTargets
		dist = pos\DistToSqr(tpos)
		if target\IsValid() and dist < mx
			table.insert(output, {target, tpos, dist, rotatedCenter})

	table.sort output, (a, b) -> a[3] < b[3]
	newOutput = {}
	trFilter = [eye[1] for eye in *@npc_bullseye]
	table.insert(trFilter, @)

	for {target, tpos, dist, center} in *output
		trData = {
			filter: trFilter
			start: @obbcenter + pos
			endpos: tpos + center
			mins: @HULL_TRACE_MINS
			maxs: @HULL_TRACE_MAXS
		}

		tr = util.TraceHull(trData)
		if tr.Hit and tr.Entity == target
			table.insert(newOutput, target)

	return newOutput

ENT.GetFirstVisible = (checkFor) =>
	pos = @GetPos()
	mx = DTF2.GrabInt(@MAX_DISTANCE) ^ 2

	if IsValid(checkFor)
		if checkFor\GetPos()\DistToSqr(pos) > mx
			checkFor = nil
	
	output = {}
	
	for {target, tpos, mins, maxs, center, rotatedCenter} in *VALID_TARGETS
		hit = false
		for target2 in *@markedAllies
			if target2[1] == target
				hit = true
				break
		
		if not hit
			dist = pos\DistToSqr(tpos)
			dist = 0 if target == checkFor
			if target\IsValid() and dist < mx
				table.insert(output, {target, tpos, dist, rotatedCenter})

	for {target, tpos, mins, maxs, center, rotatedCenter} in *@markedTargets
		dist = pos\DistToSqr(tpos)
		dist = 0 if target == checkFor
		if target\IsValid() and dist < mx
			table.insert(output, {target, tpos, dist, rotatedCenter})
	
	table.sort output, (a, b) -> a[3] < b[3]
	trFilter = [eye[1] for eye in *@npc_bullseye]
	table.insert(trFilter, @)
	
	for {target, tpos, dist, center} in *output
		trData = {
			filter: trFilter
			start: @obbcenter + pos
			endpos: tpos + center
			mins: @HULL_TRACE_MINS
			maxs: @HULL_TRACE_MAXS
		}

		tr = util.TraceHull(trData)
		if tr.Hit and tr.Entity == target
			return target

	return NULL

ENT.SetLevel = (val = 1, playAnimation = @UPGRADE_ANIMS, force = false) =>
	return false if not force and val == @GetLevel()
	val = math.Clamp(math.floor(val), 1, 3)
	@SetnwLevel(val)
	@mLevel = val
	switch val
		when 1
			@RealSetModel(@IdleModel1) if @GetModel() ~= @IdleModel1
			@SetHealth(DTF2.GrabInt(@HealthLevel1)) if @Health() == @GetMaxHealth()
			@SetMaxHealth(DTF2.GrabInt(@HealthLevel1))
			@UpdateSequenceList()
		when 2
			@RealSetModel(@IdleModel2) if @GetModel() ~= @IdleModel2
			@SetHealth(DTF2.GrabInt(@HealthLevel2)) if @Health() == @GetMaxHealth()
			@SetMaxHealth(DTF2.GrabInt(@HealthLevel2))
			@UpdateSequenceList()
			@PlayUpgradeAnimation() if playAnimation
		when 3
			@RealSetModel(@IdleModel3) if @GetModel() ~= @IdleModel3
			@SetHealth(DTF2.GrabInt(@HealthLevel3))
			@SetMaxHealth(DTF2.GrabInt(@HealthLevel3))
			@UpdateSequenceList()
			@PlayUpgradeAnimation() if playAnimation
	@CreateBullseye()
	@SetUpgradeAmount(0)
	return true

ENT.PlayUpgradeAnimation = (playOnModel = @MODEL_UPGRADE_ANIMS) =>
	return false if @GetLevel() == 1
	@SetIsUpgrading(true)
	switch @GetLevel()
		when 2
			@upgradeFinishAt = CurTime() + @UPGRADE_TIME_2
			@RealSetModel(@BuildModel2) if @GetModel() ~= @BuildModel2 and playOnModel
		when 3
			@upgradeFinishAt = CurTime() + @UPGRADE_TIME_3
			@RealSetModel(@BuildModel3) if @GetModel() ~= @BuildModel3 and playOnModel
	@UpdateSequenceList()
	@StartActivity(ACT_OBJ_UPGRADING) if playOnModel
	@ResetSequence(@upgradeSequence) if playOnModel
	return true

ENT.DoSpeedup = (time = DTF2.GrabFloat(@SPEEDUP_TIME), strength = DTF2.GrabFloat(@SPEEDUP_MULT)) =>
	return false if not @GetIsBuilding()
	@SetBuildSpeedup(true)
	@SetPlaybackRate(0.5 + 0.5 * strength)
	@CURRENT_SPEEDUP_MULT = strength
	timer.Create "DTF2.BuildSpeedup.#{@EntIndex()}", time, 1, ->
		return if not IsValid(@)
		@SetBuildSpeedup(false)
		@SetPlaybackRate(0.5)
	return true

ENT.SetBuildStatus = (status = false) =>
	return false if @GetLevel() > 1
	return false if @GetIsBuilding() == status
	@SetIsBuilding(status)
	if status
		@RealSetModel(@BuildModel1)
		@UpdateSequenceList()
		@SetBuildSpeedup(false)
		@StartActivity(ACT_OBJ_PLACING)
		@ResetSequence(@buildSequence)
		@SetBuildFinishAt(CurTime() + DTF2.GrabFloat(@BuildTime))
		@OnBuildStart()
		@SetPlaybackRate(0.5)
		@SetHealth(1)
	else
		@RealSetModel(@IdleModel1)
		@UpdateSequenceList()
		@ResetSequence(@idleSequence)
		@StartActivity(ACT_OBJ_RUNNING)
		@OnBuildFinish()
		@SetPlaybackRate(1)
	return true

ENT.OnBuildStart = => -- Override
ENT.OnBuildFinish = => -- Override
ENT.OnUpgradeFinish = => -- Override
ENT.Think = =>
	cTime = CurTime()
	delta = cTime - @lastThink
	@lastThink = cTime
	if @nextMarkedRebuild < CurTime()
		@RebuildMarkedList()
		@nextMarkedRebuild = CurTime() + 60
	else
		@UpdateMarkedList()
	
	isBuild, leftBuild, buildMult = @GetBuildingStatus()
	if isBuild
		if @GetBuildSpeedup()
			@SetBuildFinishAt(@GetBuildFinishAt() - delta * @CURRENT_SPEEDUP_MULT)
			isBuild, leftBuild, buildMult = @GetBuildingStatus()
		@SetHealth(math.Clamp(@GetMaxHealth() * buildMult, 1, @GetMaxHealth()))
		if leftBuild <= 0
			@SetBuildSpeedup(false)
			@SetIsBuilding(false)
			@RealSetModel(@IdleModel1)
			@UpdateSequenceList()
			@StartActivity(ACT_OBJ_RUNNING)
			@ResetSequence(@idleSequence)
			@OnBuildFinish()
			@SetPlaybackRate(1)
	elseif @GetIsUpgrading()
		if @upgradeFinishAt < cTime
			@SetBuildSpeedup(false)
			@SetIsUpgrading(false)
			switch @GetLevel()
				when 2
					@RealSetModel(@IdleModel2) if @GetModel() ~= @IdleModel2
				when 3
					@RealSetModel(@IdleModel3) if @GetModel() ~= @IdleModel3
			@UpdateSequenceList()
			@StartActivity(ACT_OBJ_RUNNING)
			@ResetSequence(@idleSequence)
			@OnUpgradeFinish()
