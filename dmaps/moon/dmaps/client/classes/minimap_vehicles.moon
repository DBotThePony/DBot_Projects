
--
-- Copyright (C) 2017-2019 DBotThePony
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
import DisplayedEntityBase from DMaps

POINTER_COLOR = DMaps.CreateColor(80, 80, 200, 'local_player', 'Local player arrow')

POINTS_ENABLED = DMaps.ClientsideOption('entities', '1', 'Draw ANY entities on map')
VEHICLE_POINTS_ENABLED = DMaps.ClientsideOption('vehicles', '1', 'Enable map vehicles display')
SV_POINTS_ENABLED = CreateConVar('sv_dmaps_entities', '1', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable map entities display')
SV_VEHICLE_POINTS_ENABLED = CreateConVar('sv_dmaps_vehicles', '1', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable map vehicles display')

SV_UNDRIVEN_RANGE = CreateConVar('sv_dmaps_vehicles_undriven', '512', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Undriven vehicle map track range')
SV_DRIVEN_RANGE = CreateConVar('sv_dmaps_vehicles_driven', '3000', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Driven vehicle map track range')

surface.CreateFont('DMaps.VehicleInfos', {
	font: 'Roboto'
	size: 48
	weight: 500
})

class VehiclePointer extends DisplayedEntityBase
	@Name = 'Perfectly generic Vehicle'
	@Font = 'DMaps.VehicleInfos'
	@PHypo = 40
	@PShift = 50
	@PHeight = 140

	@DistNotDriven = 512
	@DistNotDrivenQ = @DistNotDriven ^ 2
	@DistDriven = 3000
	@DistDrivenQ = @DistDriven ^ 2
	@ManualRange = true
	@Setup()

	hook.Add 'Think', 'DMaps.VehiclePointer', ->
		@DistNotDriven = SV_UNDRIVEN_RANGE\GetInt()
		@DistNotDrivenQ = @DistNotDriven ^ 2
		@DistDriven = SV_DRIVEN_RANGE\GetInt()
		@DistDrivenQ = @DistDriven ^ 2

	@BACKGROUND_COLOR = Color(0, 0, 0, 150)
	@TEXT_COLOR = Color(255, 255, 255)

	GetRenderPriority: => 21
	ShouldDraw: (map) => map\PrefferDraw(@x, @y, @z, 4)
	ShouldDrawText: (map) => map\PrefferDraw(@x, @y, @z, 1.5)

	@__Vehicle_Names = {}

	@GetVehicleName = (model = '') => @__Vehicle_Names[model] or 'Vehicle'
	GetVehicleName: => @@GetVehicleName(@model)
	@RegisterVehicleName = (models = {}, names = {'Perfectly generic Vehicle'}) =>
		models = {models} if type(models) ~= 'table'
		names = {names} if type(names) ~= 'table'
		@__Vehicle_Names[models[i]\lower()] = (names[i] or names[1] or 'Perfectly generic Vehicle') for i = 1, #models

	new: (entity = NULL) =>
		super(entity)
		@model = entity\GetModel()\lower()
		@mins, @maxs = entity\OBBMins(), entity\OBBMaxs()
		@size = math.Clamp(@mins\Distance(@maxs) / 200, 0.4, 3)
		@color = Color(88, 211, 179)
		@lineColor = Color(128, 248, 180)
		@CalcColor()

	CalcColor: =>
		bytes = {string.byte(@model, 1, #@model)}
		r = 0
		g = 0
		b = 0
		for byte in *bytes
			if byte > 127
				r += byte * 0.5 + byte % 12 - byte % 5 + 17
			if byte > 96 and byte < 140
				g += byte * 0.7 + byte % 8 - byte % 9 + 4
			if byte > 80 and byte < 128
				b += byte * 0.4 + byte % 3 - byte % 10 + 12
		r, g, b = math.floor(r), math.floor(g), math.floor(b)
		r = math.Clamp(r % 255, 0, 255)
		g = math.Clamp(g % 255, 0, 255)
		b = math.Clamp(b % 255, 0, 255)
		@color = Color(r, g, b)

	OpenMenu: (menu = DermaMenu()) =>
		super(menu)
		with menu
			\AddOption('Copy vehicle name', -> SetClipboardText(tostring(@GetVehicleName())))
			\AddOption('Copy vehicle model', -> SetClipboardText(tostring(@model)))
			if @isDriven
				ply = @driver
				\AddSpacer()
				\AddOption('Copy Driver\'s Steam name', -> SetClipboardText(tostring(ply\SteamName()))) if ply.SteamName
				\AddOption('Copy Driver\'s UserID', -> SetClipboardText(tostring(ply\UserID())))
				\AddOption('Copy Driver\'s SteamID', -> SetClipboardText(tostring(ply\SteamID())))
				\AddOption('Copy Driver\'s SteamID64', -> SetClipboardText(tostring(ply\SteamID64())))
				\AddOption('Copy Driver\'s UniqueID', -> SetClipboardText(tostring(ply\UniqueID())))
				\AddOption('Open Driver\'s Steam profile', -> gui.OpenURL("http://steamcommunity.com/profiles/#{ply\SteamID64()}/"))
			\Open()
		return true

	Think: (map) =>
		return if not POINTS_ENABLED\GetBool()
		return if not SV_POINTS_ENABLED\GetBool()
		return if not VEHICLE_POINTS_ENABLED\GetBool()
		return if not SV_VEHICLE_POINTS_ENABLED\GetBool()
		super(map)

		if IsValid(@entity)
			lpos = LocalPlayer()\GetPos()
			@driver = @entity\GetDriver()
			@isDriven = IsValid(@driver)
			if @isDriven
				if @driver ~= LocalPlayer()
					@lineColor = team.GetColor(@entity\GetDriver()\Team())
				else
					@lineColor = Color(POINTER_COLOR())
			dist = @GetPos()\DistToSqr(lpos)
			if not @isDriven and dist > @@DistNotDrivenQ
				@Remove()
				return
			elseif @isDriven and dist > @@DistDrivenQ
				@Remove()
				return

	@generateTriangleStrip = (X = 0, Y = 0, ang = 0, hypo = 20, myShift = 30, height = 70) =>
		sin = math.sin(math.rad(ang))
		cos = math.cos(math.rad(ang))

		hH = height * .1

		X -= myShift * cos
		Y -= myShift * sin

		trigData = {
			{x: hH * 2, y: 0}
			{x: hH * 1.3, y: -hypo * .3}
			{x: height - height * .2, y: -hypo * .2}
			{x: height, y: 0}
			{x: height - height * .2, y: hypo * .2}
			{x: hH * 1.3, y: hypo * .3}
			{x: hH * 2, y: 0}
		}

		for data in *trigData
			{:x, :y} = data
			newX = x * cos - y * sin
			newY = y * cos + x * sin
			data.x = newX + X
			data.y = newY + Y

		return trigData

	Draw: (map) => -- Override
		return if not POINTS_ENABLED\GetBool()
		return if not SV_POINTS_ENABLED\GetBool()
		return if not VEHICLE_POINTS_ENABLED\GetBool()
		return if not SV_VEHICLE_POINTS_ENABLED\GetBool()
		draw.NoTexture()
		multiplier = @size
		trig = @@generateTriangle(@DRAW_X, @DRAW_Y, @yaw - 90, @@PHypo * multiplier, @@PShift * multiplier, @@PHeight * multiplier)
		surface.SetDrawColor(@color)
		surface.DrawPoly(trig)

		if @isDriven
			trig = @@generateTriangleStrip(@DRAW_X, @DRAW_Y, @yaw - 90, @@PHypo * multiplier, @@PShift * multiplier, @@PHeight * multiplier)
			surface.SetDrawColor(@lineColor)
			surface.DrawPoly(trig)
			lastX, lastY = trig[1].x, trig[1].y
			for data in *trig
				surface.DrawLine(lastX, lastY, data.x, data.y)
				lastX, lastY = data.x, data.y

		if not @ShouldDrawText(map) return
		lpos = LocalPlayer()\GetPos()
		dist = lpos\Distance(@GetPos())
		deltaZ = lpos.z - @z
		text = "#{@GetVehicleName()} - #{DMaps.FormatMetre(dist)} #{@GetText() or ''}"
		text ..= "\n#{DMaps.FormatMetre(deltaZ)} lower" if deltaZ > 200
		text ..= "\n#{DMaps.FormatMetre(-deltaZ)} upper" if -deltaZ > 200

		if IsValid(@driver)
			text ..= "\nDriver: #{@driver\Nick()}"

		x, y = @DRAW_X, @DRAW_Y
		surface.SetDrawColor(@@BACKGROUND_COLOR)
		surface.SetFont(@@Font)
		y -= 30
		w, h = surface.GetTextSize(text)
		y -= h
		surface.DrawRect(x - 4 - w / 2, y - 4, w + 8, h + 8)
		draw.DrawText(text, @@Font, x, y, @@TEXT_COLOR, TEXT_ALIGN_CENTER)

DMaps.RegisterVehicleName = (...) -> VehiclePointer\RegisterVehicleName(...)
DMaps.VehiclePointer = VehiclePointer

timer.Simple 0, ->
	timer.Simple 0, ->
		for k, {:Name, :Model} in pairs list.Get('Vehicles')
			DMaps.RegisterVehicleName(Model, Name)

hook.Add 'DMaps.DispalyedEntitiesUpdate', 'DMaps.Vehicles', (list, lpos) ->
	return if not POINTS_ENABLED\GetBool()
	return if not SV_POINTS_ENABLED\GetBool()
	return if not VEHICLE_POINTS_ENABLED\GetBool()
	return if not SV_VEHICLE_POINTS_ENABLED\GetBool()

	for {ent, mClass, pos, mdl, dist} in *list
		if IsValid(ent) and ent\IsVehicle() and mClass ~= 'prop_vehicle_prisoner_pod'
			drv = IsValid(ent\GetDriver())
			if drv and dist <= VehiclePointer.DistNotDrivenQ and not (drv and dist > VehiclePointer.DistDrivenQ)
				VehiclePointer\AddEntity(ent)
