
--
-- Copyright (C) 2017-2019 DBot

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.


include 'shared.lua'

FLASH_TIME = 1.2
FOV_TIME = 0.5
FOV_STRENGTH = 60

ENT.Initialize = =>
	@BaseClass.Initialize(@)
	@targetPlayback = 1
	@currentPlayback = 1

net.Receive 'DTF2.TeleportEntity', ->
	ent = net.ReadEntity()
	entrance = net.ReadEntity()
	exit = net.ReadEntity()
	teamType = false
	teamType = entrance\GetTeamType() if IsValid(entrance)

	if IsValid(entrance)
		entrance\EmitSound(entrance.SEND_SOUND)
		CreateParticleSystem(entrance, teamType and 'teleported_blue' or 'teleported_red', PATTACH_ABSORIGIN_FOLLOW, 0)

net.Receive 'DTF2.TeleportedEntity', ->
	ent = net.ReadEntity()
	entrance = net.ReadEntity()
	exit = net.ReadEntity()
	-- spawnBread = net.ReadBool()
	teamType = false
	teamType = entrance\GetTeamType() if IsValid(entrance)

	if IsValid(ent)
		particleSystem = CreateParticleSystem(ent, teamType and 'player_recent_teleport_blue' or 'player_recent_teleport_red', PATTACH_ABSORIGIN_FOLLOW, 0)
		CreateParticleSystem(ent, 'teleported_flash', PATTACH_ABSORIGIN_FOLLOW, 0)
		timer.Simple 18, -> particleSystem\StopEmission() if particleSystem\IsValid()
		if ent == LocalPlayer()
			ent\ScreenFade(SCREENFADE.IN, color_white, FLASH_TIME, 0)
			ent.__teleFOV = RealTime() + FOV_TIME

	if IsValid(exit)
		exit\EmitSound(exit.RECEIVE_SOUND)
		CreateParticleSystem(entrance, teamType and 'teleportedin_blue' or 'teleportedin_red', PATTACH_ABSORIGIN_FOLLOW, 0)

	CreateParticleSystem(entrance, 'teleported_flash', PATTACH_ABSORIGIN_FOLLOW, 0) if IsValid(entrance)

	-- if IsValid(exit) and spawnBread
	--     tpPoint = exit\GetBreadPoint()
	--     spawnedEnts = {}
	--     for i = 1, math.random(exit.MIN_BREAD, exit.MAX_BREAD)
	--         with spawned = ents.CreateClientProp()
	--             mdl = table.Random(exit.BREAD_MODELS)
	--             \SetModel(mdl)
	--             \SetPos(tpPoint)
	--             \Spawn()
	--             \Activate()
	--             \PhysicsInit(SOLID_VPHYSICS)
	--             \SetMoveType(MOVETYPE_VPHYSICS)
	--             \SetSolid(SOLID_VPHYSICS)
	--             with \GetPhysicsObject()
	--                 \EnableMotion(true)
	--                 \Wake()
	--                 \SetVelocity(VectorRand() * math.random(160, 400))
	--             \SetMoveType(MOVETYPE_VPHYSICS)
	--             \SetSolid(SOLID_VPHYSICS)
	--             table.insert(spawnedEnts, spawned)
	--     timer.Simple math.random(exit.MIN_BREAD_TTL, exit.MAX_BREAD_TTL), -> ent\Remove() for ent in *spawnedEnts when ent\IsValid()

hook.Add 'CalcView', 'DTF2.TeleportFOV', (origin = Vector(0, 0, 0), angles = Angle(0, 0, 0), fov = 90, znear = 0, zfar = 10000) => {:origin, :angles, :znear, :zfar, fov: fov + (@__teleFOV - RealTime()) / FOV_TIME * FOV_STRENGTH} if @__teleFOV and @__teleFOV > RealTime()

ENT.ClientTeleporterThink = =>
	@MoveCategory = @GetIsExit() and @MOVE_TELE_OUT or @MOVE_TELE_IN
	if @IsValidTeleporter()
		if @ReadyToTeleport()
			if @BaseClass.IsAvaliable(@)
				if not @spinningSound
					@spinningSound = CreateSound(@, @GetSpinSound())
					@spinningSound\Play()
			else
				if @spinningSound
					@spinningSound\Stop()
					@spinningSound = nil

			if @IsAvaliable()
				if not @playedReady
					@EmitSound(@READY_SOUND)
					@playedReady = true
		else
			@playedReady = false
			if @spinningSound
				@spinningSound\Stop()
				@spinningSound = nil
	else
		if @spinningSound
			@spinningSound\Stop()
			@spinningSound = nil
		@playedReady = false

ENT.Draw = =>
	@BaseClass.Draw(@)
	if @OtherSideIsReady()
		if @IsAvaliable() and @IsValidTeleporter() and @IsEntrance()
			if not IsValid(@particlesReady)
				@particlesReady = CreateParticleSystem(@, @GetChargedEffect(), PATTACH_ABSORIGIN_FOLLOW, 0)
		else
			if IsValid(@particlesReady)
				@particlesReady\StopEmission()
				@particlesReady = nil

		if @BaseClass.IsAvaliable(@) and @IsValidTeleporter()
			if not IsValid(@particlesAvaliable)
				@particlesAvaliable = CreateParticleSystem(@, @GetAvaliableEffect(), PATTACH_ABSORIGIN_FOLLOW, 0)
		else
			if IsValid(@particlesAvaliable)
				@particlesAvaliable\StopEmission()
				@particlesAvaliable = nil
	else
		if IsValid(@particlesAvaliable)
			@particlesAvaliable\StopEmission()
			@particlesAvaliable = nil
		if IsValid(@particlesReady)
			@particlesReady\StopEmission()
			@particlesReady = nil

ENT.OnRemove = =>
	@BaseClass.OnRemove(@) if @BaseClass.OnRemove
	@spinningSound\Stop() if @spinningSound
