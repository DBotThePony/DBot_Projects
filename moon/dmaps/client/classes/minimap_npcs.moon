
--
-- Copyright (C) 2017 DBot
-- 
-- Licensed under the Apache License, Version 2.0 (the 'License');
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an 'AS IS' BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 

import DMaps, timer, CreateConVar, draw, surface, Color from _G
import DisplayedEntityBase, DeathPointer from DMaps

POINTS_ENABLED = DMaps.ClientsideOption('entities', '1', 'Draw ANY entities on map')
NPC_POINTS_ENABLED = DMaps.ClientsideOption('npcs', '1', 'Enable map NPCs display')
SV_POINTS_ENABLED = CreateConVar('sv_dmaps_entities', '1', {FCVAR_REPLICATED, FCVAR_ARCHIVE}, 'Enable map entities display')
SV_NPC_POINTS_ENABLED = CreateConVar('sv_dmaps_npcs', '1', {FCVAR_REPLICATED, FCVAR_ARCHIVE}, 'Enable map NPCs display')

DRAW_DEATHPOINTS_NPCS = DMaps.ClientsideOption('draw_deathpoints_npc', '1', 'Draw NPCs deathpoints on map')

surface.CreateFont('DMaps.NPCInfoPoint', {
	font: 'Roboto'
	size: 18
	weight: 500
})

class NPCDeathPoint extends DeathPointer
	@Font = 'DMaps.NPCInfoPoint'
	@FontSmaller = 'DMaps.NPCInfoPoint'
	@FontSmall = 'DMaps.NPCInfoPoint'
	@FontTiny = 'DMaps.NPCInfoPoint'

	new: (point) =>
		super(point\GetNPCName(), point.x, point.y, point.z)
		@SetYaw(point.eyesYaw)
		@SetLiveTime(@@GetDefaultTime() * point\GetNPCSize())
		@SetSize(point\GetNPCSize() * 0.5)
	Draw: (map) =>
		return if not DRAW_DEATHPOINTS_NPCS\GetBool()
		super(map)

class NPCPointer extends DisplayedEntityBase
	@Name = 'Perfectly generic NPC'
	@Color = Color(170, 170, 170)
	@TextBackgroundColor = Color(0, 0, 0, 150)
	@TextColor = Color(255, 255, 255)
	@Font = 'DMaps.NPCInfoPoint'
	@PHypo = 15
	@PShift = 15
	@PHeight = 50
	@Setup()

	GetRenderPriority: => 20

	@__NPCs_Names = {}
	@__NPCs_Friendly = {}
	@__NPCs_Enemy = {}
	@__NPCs_Sizes = {}

	new: (...) =>
		super(...)
		@eyesYaw = 0
	
	@CheckNPC: (npc, nClass) => true
	@GetNPCSize: (nClass = '') => @__NPCs_Sizes[nClass] or 1
	GetNPCSize: => @@GetNPCSize(@GetClass())
	@RegisterSizeMultiplier: (nClass = {}, size = 1) =>
		nClass = {nClass} if type(nClass) ~= 'table'
		@__NPCs_Sizes[c] = size for c in *nClass
	
	@GetNPCName: (nClass = '') =>  @__NPCs_Names[nClass] or nClass
	GetNPCName: => @@GetNPCName(@GetClass())
	@RegisterNPCName = (npcs = {}, names = {}) =>
		npcs = {npcs} if type(npcs) ~= 'table'
		names = {names} if type(names) ~= 'table'
		@__NPCs_Names[ent] = (names[i] or 'Perfectly generic NPCS') for i, ent in pairs npcs
	
	@RegisterNPC = (npcs = {}, tp = false) =>
		npcs = {npcs} if type(npcs) ~= 'table'
		if tp
			for npc in *npcs
				@__NPCs_Friendly[npc] = true
				@__NPCs_Enemy[npc] = nil
		else
			for npc in *npcs
				@__NPCs_Friendly[npc] = nil
				@__NPCs_Enemy[npc] = true
	
	Think: (map) =>
		return if not POINTS_ENABLED\GetBool()
		return if not SV_POINTS_ENABLED\GetBool()
		return if not NPC_POINTS_ENABLED\GetBool()
		return if not SV_NPC_POINTS_ENABLED\GetBool()
		if @entity.__DMaps_Died and DRAW_DEATHPOINTS_NPCS\GetBool()
			point = NPCDeathPoint(@)
			map\AddObject(point)
			@entity.__dmaps_ignore = true
			@Remove()
			return
		super(map)
		@eyesYaw = @entity\EyeAngles().y if IsValid(@entity)
	
	Draw: (map) => -- Override
		return if not POINTS_ENABLED\GetBool()
		return if not SV_POINTS_ENABLED\GetBool()
		return if not NPC_POINTS_ENABLED\GetBool()
		return if not SV_NPC_POINTS_ENABLED\GetBool()
		draw.NoTexture()
		multiplier = @GetNPCSize()
		trig = @@generateTriangle(@DRAW_X, @DRAW_Y, -@eyesYaw, @@PHypo * multiplier, @@PShift * multiplier, @@PHeight * multiplier)
		surface.SetDrawColor(@@Color)
		surface.DrawPoly(trig)
		lpos = LocalPlayer()\GetPos()
		dist = lpos\Distance(@GetPos())
		deltaZ = lpos.z - @z
		name = @GetNPCName()
		text = "#{name} - #{DMaps.FormatMetre(dist)} #{@GetText() or ''}"
		text ..= "\n#{DMaps.FormatMetre(deltaZ)} lower" if deltaZ > 200
		text ..= "\n#{DMaps.FormatMetre(-deltaZ)} upper" if -deltaZ > 200

		x, y = @DRAW_X, @DRAW_Y
		surface.SetDrawColor(@@TextBackgroundColor)
		surface.SetFont(@@Font)
		y -= 30
		w, h = surface.GetTextSize(text)
		y -= h
		surface.DrawRect(x - 4 - w / 2, y - 4, w + 8, h + 8)
		draw.DrawText(text, @@Font, x, y, @@TextColor, TEXT_ALIGN_CENTER)

net.Receive 'DMaps.NPCDeath', ->
	ent = net.ReadEntity()
	ent.__DMaps_Died = true if IsValid(ent)

class FriendlyNPCPointer extends NPCPointer
	@Name = 'Perfectly generic friendly NPC'
	@Color = Color(106, 199, 12)
	@HealthBarColorBG = Color(209, 223, 187)
	@HealthBarColorFirst = Color(128, 206, 73)
	@HealthBarColorLast = Color(213, 77, 56)
	@DefaultRange = 2048
	@PHypo = 20
	@PShift = 20
	@PHeight = 80

	@HPBarW = 100
	@HPBarH = 10

	GetRenderPriority: => 25
	
	@Setup()

	new: (...) =>
		super(...)
		@HP = 0
		@MHP = 0
	
	Think: (map) =>
		super(map)
		if IsValid(@entity)
			@HP = @entity\Health()
			@MHP = @entity\GetMaxHealth()

	GetText: => "(#{@HP}/#{@MHP} HP)"

	Draw: (map) => -- Override
		return if not POINTS_ENABLED\GetBool()
		return if not SV_POINTS_ENABLED\GetBool()
		return if not NPC_POINTS_ENABLED\GetBool()
		return if not SV_NPC_POINTS_ENABLED\GetBool()
		super(map)
		x, y = @DRAW_X, @DRAW_Y
		y += 40
		div = 1
		div = @MHP if @MHP ~= 0
		divR = math.Clamp(@HP / div, 0, 1)
		@divRLerp = Lerp(0.1, @divRLerp or divR, divR)
		w, h = @@HPBarW, @@HPBarH
		surface.SetDrawColor(@@TextBackgroundColor)
		surface.DrawRect(x - w / 2 - 4, y - 2, w + 8, h + 4)
		surface.SetDrawColor(@@HealthBarColorBG)
		surface.DrawRect(x - w / 2, y, w, h)
		colr = DMaps.DeltaColor(@@HealthBarColorFirst, @@HealthBarColorLast, @divRLerp)
		surface.SetDrawColor(colr)
		surface.DrawRect(x - w / 2, y, w * @divRLerp, h)

	@CheckNPC: (npc, nClass) =>
		if @__NPCs_Friendly[nClass] return true
		return false

class EnemyNPCPointer extends NPCPointer
	@Name = 'Perfectly generic enemy NPC'
	@Color = Color(216, 85, 40)
	@DefaultRange = 512
	@PHypo = 20
	@PShift = 20
	@PHeight = 80

	GetRenderPriority: => 26
	
	@Setup()

	new: (...) =>
		super(...)
	
	@CheckNPC: (npc, nClass) =>
		if @__NPCs_Enemy[nClass] return true
		return false

DMaps.NPCPointer = NPCPointer
DMaps.FriendlyNPCPointer = FriendlyNPCPointer
DMaps.EnemyNPCPointer = EnemyNPCPointer

DMaps.NPCsHandlers = {FriendlyNPCPointer, EnemyNPCPointer}
DMaps.GetNPCName = (...) -> NPCPointer\GetNPCName(...)
DMaps.GetNPCSize = (...) -> NPCPointer\GetNPCSize(...)
DMaps.RegisterNPCName = (...) -> NPCPointer\RegisterNPCName(...)
DMaps.RegisterNPC = (...) -> NPCPointer\RegisterNPC(...)
DMaps.RegisterSizeMultiplier = (...) -> NPCPointer\RegisterSizeMultiplier(...)

DMaps.RegisterNPCHandler = (handler = NPCPointer) ->
	for pHandler in *DMaps.NPCsHandlers
		if pHandler == handler return
		if pHandler.__name == handler.__name return
	table.insert(DMaps.NPCsHandlers, handler)

do -- Using default npcs lua file lol
	AddNPC = (data) ->
		DMaps.RegisterNPCName(data.Class, data.Name)
		DMaps.RegisterNPC(data.Class, data.Type) if data.Type ~= nil
		DMaps.RegisterSizeMultiplier(data.Class, data.Size) if data.Size ~= nil

	AddNPC({Name: 'Alyx Vance', Class: 'npc_alyx', Type: true})
	AddNPC({Name: 'Barney Calhoun', Class: 'npc_barney', Type: true})
	AddNPC({Name: 'Wallace Breen', Class: 'npc_breen'})
	AddNPC({Name: 'Dog', Class: 'npc_dog', Type: true, Size: 2})
	AddNPC({Name: 'Eli Vance', Class: 'npc_eli', Type: true})
	AddNPC({Name: 'G-Man', Class: 'npc_gman', Type: true})
	AddNPC({Name: 'Dr. Isaac Kleiner', Class: 'npc_kleiner', Type: true})
	AddNPC({Name: 'Dr. Judith Mossman', Class: 'npc_mossman', Type: true})
	AddNPC({Name: 'Vortigaunt', Class: 'npc_vortigaunt', Type: true})
	AddNPC({Name: 'Citizen', Class: 'npc_citizen', Type: true})
	AddNPC({Name: 'Dr. Arne Magnusson', Class: 'npc_magnusson', Type: true})
	AddNPC({Name: 'Fisherman', Class: 'npc_fisherman', Type: true})
	AddNPC({Name: 'Zombie', Class: 'npc_zombie', Type: false})
	AddNPC({Name: 'Zombie Torso', Class: 'npc_zombie_torso', Type: false})
	AddNPC({Name: 'Poison Zombie', Class: 'npc_poisonzombie', Type: false})
	AddNPC({Name: 'Antlion', Class: 'npc_antlion', Type: false})
	AddNPC({Name: 'Antlion Guard', Class: 'npc_antlionguard', Type: false, Size: 2})
	AddNPC({Name: 'Barnacle', Class: 'npc_barnacle', Type: false, Size: 0.8})
	AddNPC({Name: 'Fast Zombie', Class: 'npc_fastzombie', Type: false})
	AddNPC({Name: 'Headcrab', Class: 'npc_headcrab', Type: false})
	AddNPC({Name: 'Poison Headcrab', Class: 'npc_headcrab_black', Type: false})
	AddNPC({Name: 'Fast Headcrab', Class: 'npc_headcrab_fast', Type: false})
	AddNPC({Name: 'Fast Zombie Torso', Class: 'npc_fastzombie_torso', Type: false})
	AddNPC({Name: 'Antlion Guardian', Class: 'npc_antlionguard', Type: false})
	AddNPC({Name: 'Antlion Grub', Class: 'npc_antlion_grub', Type: false})
	AddNPC({Name: 'Antlion Worker', Class: 'npc_antlion_worker', Type: false})
	AddNPC({Name: 'Zombine', Class: 'npc_zombine', Type: false})
	AddNPC({Name: 'Father Grigori', Class: 'npc_monk', Type: true})
	AddNPC({Name: 'Crow', Class: 'npc_crow', Size: 0.4})
	AddNPC({Name: 'Pigeon', Class: 'npc_pigeon', Size: 0.4})
	AddNPC({Name: 'Seagull', Class: 'npc_seagull', Size: 0.4})
	AddNPC({Name: 'Metro Police', Class: 'npc_metropolice', Type: false})
	AddNPC({Name: 'Rollermine', Class: 'npc_rollermine', Type: false})
	AddNPC({Name: 'Turret', Class: 'npc_turret_floor', Type: false})
	AddNPC({Name: 'Combine Soldier', Class: 'npc_combine_s', Type: false})
	AddNPC({Name: 'City Scanner', Class: 'npc_cscanner', Type: false})
	AddNPC({Name: 'Shield Scanner', Class: 'npc_clawscanner', Type: false})
	AddNPC({Name: 'Combine Gunship', Class: 'npc_combinegunship', Type: false})
	AddNPC({Name: 'Combine Dropship', Class: 'npc_combinedropship', Type: false})
	AddNPC({Name: 'Hunter-Chopper', Class: 'npc_helicopter', Type: false})
	AddNPC({Name: 'Camera', Class: 'npc_combine_camera', Type: false, Size: 0.6})
	AddNPC({Name: 'Ceiling Turret', Class: 'npc_turret_ceiling', Type: false})
	AddNPC({Name: 'Strider', Class: 'npc_strider', Type: false, Size: 3})
	AddNPC({Name: 'Stalker', Class: 'npc_stalker', Type: false})
	AddNPC({Name: 'Manhack', Class: 'npc_manhack', Type: false, Size: 0.4})
	AddNPC({Name: 'Hunter', Class: 'npc_hunter', Type: false, Size: 1.2})

	AddNPC({Name: 'Alien Grunt', Class: 'monster_alien_grunt', Type: false})
	AddNPC({Name: 'Nihilanth', Class: 'monster_nihilanth', Type: false, Size: 5})
	AddNPC({Name: 'Tentacle', Class: 'monster_tentacle', Type: false, Size: 2})
	AddNPC({Name: 'Alien Slave', Class: 'monster_alien_slave', Type: false})
	AddNPC({Name: 'Gonarch', Class: 'monster_bigmomma', Type: false})
	AddNPC({Name: 'Bullsquid', Class: 'monster_bullchicken', Type: false})
	AddNPC({Name: 'Gargantua', Class: 'monster_gargantua', Type: false})
	AddNPC({Name: 'Assassin', Class: 'monster_human_assassin', Type: false})
	AddNPC({Name: 'Baby Crab', Class: 'monster_babycrab', Type: false, Size: 0.3})
	AddNPC({Name: 'Grunt', Class: 'monster_human_grunt', Type: false})
	AddNPC({Name: 'Cockroach', Class: 'monster_cockroach', Type: false})
	AddNPC({Name: 'Houndeye', Class: 'monster_houndeye', Type: false, Size: 0.8})
	AddNPC({Name: 'Scientist', Class: 'monster_scientist', Type: true})
	AddNPC({Name: 'Snark', Class: 'monster_snark', Type: false, Size: 0.3})
	AddNPC({Name: 'Zombie', Class: 'monster_zombie', Type: false})
	AddNPC({Name: 'Headcrab', Class: 'monster_headcrab', Type: false})
	AddNPC({Name: 'Controller', Class: 'monster_alien_controller', Type: true})
	AddNPC({Name: 'Security Officer', Class: 'monster_barney', Type: true})

	AddNPC({Name: 'Turret', Class: 'monster_turret', Type: false})
	AddNPC({Name: 'Mini Turret', Class: 'monster_miniturret', Type: false})
	AddNPC({Name: 'Sentry', Class: 'monster_sentry', Type: false})

	timer.Simple 0, ->
		for k, {:Name, :Class} in pairs list.Get('NPC')
			if not Name continue
			if not NPCPointer.__NPCs_Names[Class]
				DMaps.RegisterNPCName(Class, Name)


hook.Run('DMaps.RegisterNPCsDictionary', DMaps.RegisterNPC)
hook.Run('DMaps.RegisterNPCsHandlers', DMaps.RegisterNPCHandler)

DMaps.IgnoreNPCs = {
	npc_bullseye: true
	npc_grenade_frag: true
}

timer.Create 'DMaps.DispalyedNPCSUpdate', 0.5, 0, ->
	return if not POINTS_ENABLED\GetBool()
	return if not SV_POINTS_ENABLED\GetBool()
	return if not NPC_POINTS_ENABLED\GetBool()
	return if not SV_NPC_POINTS_ENABLED\GetBool()
	lpos = LocalPlayer()\GetPos()

	for ent in *DMaps.__lastEntsGetAll
		if not IsValid(ent) continue
		nClass = ent\GetClass()
		if not nClass continue
		if DMaps.IgnoreNPCs[nClass] continue
		if not ent\IsNPC() continue
		if ent.__dmaps_ignore continue
		pos = ent\GetPos()
		if not pos continue

		dist = pos\DistToSqr(lpos)
		hit = false
		for handler in *DMaps.NPCsHandlers
			reply = handler\CheckNPC(ent, nClass)
			if dist > handler.DefaultRangeQ and reply
				hit = true
				break
			elseif not reply
				continue
			handler\AddEntity(ent)
			hit = true
			break
		
		if hit continue
		if dist > NPCPointer.DefaultRangeQ continue
		NPCPointer\AddEntity(ent)