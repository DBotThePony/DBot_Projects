
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
	@KnownEntities = {} -- Redefine in subclasses

	@DefaultRange = 1024
	@DefaultRangeQ = @DefaultRange ^ 2

	@Color = Color(200, 200, 200)
	@ColorRModulation = @Color.r / 255
	@ColorGModulation = @Color.g / 255
	@ColorBModulation = @Color.b / 255
	@ColorAModulation = @Color.a / 255

	@BackgroundColor = Color(0, 0, 0, 100)
	@TextColor = Color(255, 255, 255)
	@Font = 'DMaps.EntityInfoPoint'

	@Material = Material('models/debug/debugwhite')

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

		lpos = LocalPlayer()\GetPos()
		dist = @GetPos()\Distance(lpos)
		delta = @z - lpos.z
		text = "#{@@Name}\n#{math.floor(dist / DMaps.HU_IN_METRE * 10) / 10} metres away #{@GetText() or ''}"
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

class HealthKitPoint extends DisplayedEntityBase
	@Entity = 'item_healthkit'
	@Name = 'Health kit'

	@Color = Color(30, 200, 30)
	@ColorRModulation = @Color.r / 255
	@ColorGModulation = @Color.g / 255
	@ColorBModulation = @Color.b / 255
	@ColorAModulation = @Color.a / 255

DMaps.RegisterMapEntity({'darkrp', 'sandbox'}, HealthKitPoint)
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
