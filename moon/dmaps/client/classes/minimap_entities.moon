
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

import DMaps, ents, IsValid, type, table, timer, engine from _G
import render, surface, math, Color, color_white from _G
import DMapEntityPointer from DMaps

surface.CreateFont('DMaps.EntityInfoPoint', {
	font: 'Roboto',
	size: 20
	weight: 500
})

class DisplayedEntityBase extends DMapEntityPointer
	@Entity = 'generic'
	@Name = 'Perfectly generic item'
	@INSTANCES = {}
	@DefaultRange = 1024
	@DisplayText = true

	@Color = Color(200, 200, 200)

	@Setup = =>
		@ColorRModulation = @Color.r / 255
		@ColorGModulation = @Color.g / 255
		@ColorBModulation = @Color.b / 255
		@ColorAModulation = @Color.a / 255
		@KnownEntities = {}
		@DefaultRangeQ = @DefaultRange ^ 2

		Ents = @Entity
		Ents = {Ents} if type(Ents) ~= 'table'
		Names = @Name
		Names = {Names} if type(Names) ~= 'table'
		@DefaultName = Names[1]
		@NamesMap = {ent, Names[i] for i, ent in pairs Ents}
	@Setup()

	@BackgroundColor = Color(0, 0, 0, 100)
	@TextColor = Color(255, 255, 255)
	@Font = 'DMaps.EntityInfoPoint'

	@Material = CreateMaterial('DMaps.MapEntityPoint', 'VertexLitGeneric', {'$basetexture': 'models/debug/debugwhite'})

	@AddEntity = (ent) =>
		if @KnownEntities[ent] return
		@(ent)
	
	@DoGC = =>
		for ent, obj in pairs @KnownEntities
			obj\Remove() if not IsValid(ent)

	timer.Create('DMaps.DisplayedEntityGC', 60, 0, -> @DoGC())

	new: (entity = NULL) =>
		super(entity)
		@@KnownEntities[entity] = @ if IsValid(entity)
		@_TABLE_ID = table.insert(@@INSTANCES, @)
		hook.Run('DMaps.EntityPointCreated', @)
	
	Think: (map) =>
		@CURRENT_MAP = map
		if @GetPos()\DistToSqr(LocalPlayer()\GetPos()) > @@DefaultRangeQ
			@Remove()
			return
		super(map)
	Draw: (map) => -- Override
		@CURRENT_MAP = map
		render.SuppressEngineLighting(true)
		render.SetBlend(@@ColorAModulation)
		render.SetMaterial(@@Material)
		render.MaterialOverride(@@Material)
		render.SetColorModulation(@@ColorRModulation, @@ColorGModulation, @@ColorBModulation)
		@entity\DrawModel()
		render.MaterialOverride()
		render.SetBlend(1)
		render.SetColorModulation(1, 1, 1)
		render.SuppressEngineLighting(false)

		if not @@DisplayText return
		lpos = LocalPlayer()\GetPos()
		dist = @GetPos()\Distance(lpos)
		delta = @z - lpos.z
		text = "#{@@NamesMap[@GetClass()] or @@DefaultName}\n#{math.floor(dist / DMaps.HU_IN_METRE * 10) / 10} metres away #{@GetText() or ''}"
		text ..= "\n#{math.floor(delta / DMaps.HU_IN_METRE * 10) / 10} metres upper" if delta > DMaps.HU_IN_METRE * 1.5
		text ..= "\n#{math.floor(-delta / DMaps.HU_IN_METRE * 10) / 10} metres lower" if -delta > DMaps.HU_IN_METRE * 1.5

		x, y = @DRAW_X, @DRAW_Y
		surface.SetDrawColor(@@BackgroundColor)
		surface.SetFont(@@Font)
		y -= 40
		w, h = surface.GetTextSize(text)
		surface.DrawRect(x - 4 - w / 2, y - 4, w + 8, h + 8)
		draw.DrawText(text, @@Font, x, y, @@TextColor, TEXT_ALIGN_CENTER)

	GetText: => -- Override
	Remove: =>
		@@KnownEntities[@entity] = nil
		@@INSTANCES[@_TABLE_ID] = nil
		hook.Run('DMaps.EntityPointRemoved', @)
		super()

DMaps.DisplayedEntityBase = DisplayedEntityBase

DMaps.RegisteredMapEntities = {}
DMaps.RegisteredMapEntities_map = {}
DMaps.RegisterMapEntity = (gamemodes = {}, mclass = DisplayedEntityBase) ->
	entsArray = mclass.Entity
	entsArray = {entsArray} if type(entsArray) ~= 'table'
	for g in *gamemodes
		DMaps.RegisteredMapEntities[g] = DMaps.RegisteredMapEntities[g] or {}
		DMaps.RegisteredMapEntities_map[g] = DMaps.RegisteredMapEntities_map[g] or {}

		table.insert(DMaps.RegisteredMapEntities[g], mclass)
		DMaps.RegisteredMapEntities_map[g][e] = mclass for e in *entsArray

DMaps.RegisterMapEntityEasy = (gamemodes = {}, classes = {}, names = {}, color = Color(200, 200, 200)) ->
	local cName
	if type(classes) == 'table'
		cName = classes[1]
	else
		cName = classes
	
	cName = "E#{cName}Point"
	newClass = class extends DisplayedEntityBase
		@Entity = classes
		@Name = names
		@Color = color
		@Setup()
	newClass.__name = cName
	DMaps.RegisterMapEntity(gamemodes, newClass)
	return newClass

easyToRegister = {
	{
		{'item_healthkit'}
		{'Health Kit'}
		Color(30, 200, 30)
	}

	{
		{'item_healthvial'}
		{'Health Vial'}
		Color(30, 200, 30)
	}

	{
		{'item_battery'}
		{'Battery'}
		Color(0, 190, 255)
	}

	{
		{'grenade_helicopter', 'npc_grenade_frag'}
		{'Helicopter grenade', 'Armed Grenade'}
		Color(250, 102, 102)
	}

	{
		{'combine_mine'}
		{'Combine mine'}
		Color(250, 102, 102)
	}

	{
		{'sent_ball'}
		{'Bouncy Ball'}
		Color(0, 255, 230)
	}
}

HL2Ammo = {
	'item_ammo_ar2': 'AR2 Ammo'
	'item_ammo_ar2_large': 'AR2 Ammo (Large)'

	'item_ammo_pistol': 'Pistol Ammo'
	'item_ammo_pistol_large': 'Pistol Ammo (Large)'

	'item_ammo_357': '357 Ammo'
	'item_ammo_357_large': '357 Ammo (Large)'

	'item_ammo_smg1': 'SMG Ammo'
	'item_ammo_smg1_large': 'SMG Ammo (Large)'

	'item_ammo_smg1_grenade': 'SMG Grenade'
	'item_ammo_crossbow': 'Crossbow Bolts'
	'item_box_buckshot': 'Shotgun Ammo'
	'item_ammo_ar2_altfire': 'AR2 Orb'
	'item_rpg_round': 'RPG Rocket'
}

for id, name in pairs HL2Ammo
	table.insert(easyToRegister, {{id}, {name}, Color(255, 160, 0)})

DMaps.DisplayedEntitiesDefaultClasses = {}

for {classes, names, color} in *easyToRegister
	reg = DMaps.RegisterMapEntityEasy({'darkrp', 'sandbox'}, classes, names, color)
	DMaps.DisplayedEntitiesDefaultClasses[cls] = reg for cls in *classes

DMaps.RegisterMapEntity({'darkrp', 'sandbox'}, DefaultClass) for k, DefaultClass in pairs DMaps.DisplayedEntitiesDefaultClasses
hook.Run('DMaps.RegisterMapEntities', DMaps.RegisterMapEntity, DisplayedEntityBase)

timer.Create 'DMaps.DispalyedEntitiesUpdate', 1, 0, ->
	gm = engine.ActiveGamemode()
	if not DMaps.RegisteredMapEntities_map[gm] return
	avaliable = DMaps.RegisteredMapEntities_map[gm]

	lplayer = LocalPlayer()
	lpos = lplayer\GetPos()

	for ent in *ents.GetAll()
		if not IsValid(ent) continue
		mClass = ent\GetClass()
		if not mClass continue
		if not avaliable[mClass] continue
		if ent\GetSolid() == SOLID_NONE continue
		pos = ent\GetPos()
		if not pos continue
		if pos\DistToSqr(lpos) > avaliable[mClass].DefaultRangeQ continue
		avaliable[mClass]\AddEntity(ent)
