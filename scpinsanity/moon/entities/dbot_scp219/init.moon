
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

AddCSLuaFile('cl_init.lua')
include('shared.lua')

do
    model = 'models/props_wasteland/laundry_washer003.mdl'
    ENT.ModelsToSpawn = {}
	for x = 0, 1
        for y = -1, 1
            for z = 0, 1
                table.insert(ENT.ModelsToSpawn, {:model, pos: Vector(x * 100 - 200, y * 40, z * 40)})

do
	height = 80

	table.insert(ENT.ModelsToSpawn, {
		model: 'models/props_junk/ibeam01a.mdl'
		pos: Vector(-50, 60, height)
		ang: Angle(90, 0, 0)
	})

	table.insert(ENT.ModelsToSpawn, {
		model: 'models/props_junk/ibeam01a.mdl'
		pos: Vector(-50, -60, height)
		ang: Angle(90, 0, 0)
	})

	table.insert(ENT.ModelsToSpawn, {
		model: 'models/props_junk/ibeam01a.mdl'
		pos: Vector(-260, -60, height)
		ang: Angle(90, 0, 0)
	})

	table.insert(ENT.ModelsToSpawn, {
		model: 'models/props_junk/ibeam01a.mdl'
		pos: Vector(-260, 60, height)
		ang: Angle(90, 0, 0)
	})

ENT.PISTONS_START = #ENT.ModelsToSpawn + 1

do
    model = 'models/props_wasteland/laundry_washer003.mdl'
    for x = 0, 1
        for y = -1, 1
            table.insert(ENT.ModelsToSpawn, {:model, pos: Vector(x * 100 - 200, y * 40, 200)})

ENT.PISTONS_END = #ENT.ModelsToSpawn
ENT.PISTON_MAX = 200
ENT.PISTON_MIN = 100

for i = 0, 3
	table.insert(ENT.ModelsToSpawn, {
		model: 'models/props_lab/harddrive02.mdl'
		pos: Vector(0, 0, -i * 8)
		ang: Angle(0, 0, 90)
	})

ENT.MovePistonTo = (z) =>
	lpos = @GetPos()
    vec = Vector(0, 0, z)
	
	for i = @PISTONS_START, @PISTONS_END
		ent = @props[i]
		ent\SetPos(ent.RealPos + vec)

ENT.CreatePart = (num) =>
	data = @ModelsToSpawn[num]
	ent = ents.Create('prop_physics')
	
	lang = @GetAngles()
	{:x, :y, :z} = data.pos
	newpos = Vector(x, y, z)
	newpos\Rotate(lang)
	
	ent\SetPos(@GetPos() + newpos)
	
	if data.ang then
		ent\SetAngles(lang + data.ang)
	else
		ent\SetAngles(lang)
	
	ent\SetModel(data.model)
	ent\Spawn()
	ent\Activate()
	ent.RealPos = data.pos
	ent\SetParent(self)
	
	if ent.CPPISetOwner then
		ent\CPPISetOwner(@CPPIGetOwner())
	
	@props[num] = ent

ENT.CheckParts = =>
	for k, v in pairs(@ModelsToSpawn)
		if not IsValid(@props[k]) then
			@CreatePart(k)

ENT.Initialize = =>
	@SetModel('models/props_lab/monitor02.mdl')
	
	@PhysicsInit(SOLID_VPHYSICS)
	@SetSolid(SOLID_VPHYSICS)
	@SetMoveType(MOVETYPE_VPHYSICS)
	
	@props = {}
	
	@strength = 1
	@stamp = 0
	@nextpunch = 0
	@shift = 0
	@rshift = 0
	@lerpval = 0.05

ENT.OnTakeDamage = (dmg) =>
	if not @enabled return
	@HP = @HP - dmg\GetDamage()
	if @HP <= 0 then @Shutdown()

ENT.Shutdown = =>
	@enabled = false
	@rshift = 0
	@lerpval = 0.01
	@EmitSound('ambient/machines/thumper_shutdown1.wav', SNDLVL_180dB)

ENT.Enable = (strength, time) =>
	strength = math.Clamp(strength or 1, 1, 50)
	time = math.Clamp(time or 15, 5, 600)
	
	@enabled = true
	@stamp = CurTime() + time
	@strength = strength
	@nextpunch = CurTime() + 2
	@HP = 100
	
	@EmitSound('ambient/machines/thumper_startup1.wav', SNDLVL_180dB)
	str = 'Piston Resonator (SCP-219) activated with strength of ' .. strength .. ' amp and time ' .. time
	
	PrintMessage(HUD_PRINTCONSOLE, str)
	PrintMessage(HUD_PRINTTALK, str)
	PrintMessage(HUD_PRINTCENTER, str)

ENT.Punch = =>
	for i = 1, @strength * 3
		@EmitSound('ambient/machines/thumper_hit.wav', SNDLVL_180dB)
	
	for ent in *ents.GetAll()
		if ent == self or ent\GetParent() == self continue
		phys = ent\GetPhysicsObject()
		if not IsValid(phys) continue
		
		if not ent\IsPlayer() and not ent\IsNPC()
			phys\AddVelocity(VectorRand() * @strength * 200)
		else
			if ent\IsPlayer()
				if not SCP_INSANITY_ATTACK_PLAYERS\GetBool() continue
				if SCP_INSANITY_ATTACK_NADMINS\GetBool() and ent\IsAdmin() continue
				if SCP_INSANITY_ATTACK_NSUPER_ADMINS\GetBool() and ent\IsSuperAdmin() continue
				ent\SetMoveType(MOVETYPE_WALK)
				ent\ExitVehicle()
			ent\SetVelocity(VectorRand() * @strength * 200)

ENT.Think = =>
	@CheckParts()
	
	if @enabled and @stamp < CurTime()
		@Shutdown()
	
	if @enabled
		if @nextpunch - 0.3 < CurTime() and not @readysound
			@rshift = 0
			@readysound = true
			@EmitSound('ambient/machines/thumper_top.wav', 150)
		
		if @nextpunch - 0.8 < CurTime() and not @readyanim then
			@rshift = 0
			@lerpval = 0.05
			@readyanim = true
		
		if @nextpunch < CurTime() then
			@Punch()
			@readysound = false
			@readyanim = false
			@rshift = -130
			@lerpval = 0.3
			@nextpunch = CurTime() + 2
			util.ScreenShake(@GetPos(), @strength * 5, 5, 1, @strength * 400)
	
	@shift = Lerp(@lerpval, @shift, @rshift)
	@MovePistonTo(@shift)
	
	@SetUseType(SIMPLE_USE)
	
	@NextThink(CurTime())
	return true

util.AddNetworkString('SCP-219Menu')

net.Receive 'SCP-219Menu', (len, ply) ->
	ent = net.ReadEntity()
	str = net.ReadUInt(32)
	time = net.ReadUInt(32)
	
	if not IsValid(ent) return
	if ent\GetPos()\Distance(ply\GetPos()) > 128 return
	
	if ent.enabled return
	
	ent\Enable(str, time)

ENT.Use = (ply) =>
	if @enabled return
	net.Start('SCP-219Menu')
	net.WriteEntity(self)
	net.Send(ply)
