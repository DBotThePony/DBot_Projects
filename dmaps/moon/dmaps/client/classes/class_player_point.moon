
--
-- Copyright (C) 2017-2019 DBot
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

import DMaps from _G
import DMapEntityPointer from DMaps

SHOULD_DRAW = DMaps.ClientsideOption('draw_players', '1', 'Draw players on map')
SHOULD_DRAW_INFO = DMaps.ClientsideOption('draw_players_info', '1', 'Draw players infos on map')
SHOULD_DRAW_HEALTH = DMaps.ClientsideOption('draw_players_health', '1', 'Draw players health on map')
SHOULD_DRAW_ARMOR = DMaps.ClientsideOption('draw_players_armor', '1', 'Draw players armor on map')
SHOULD_DRAW_TEAM = DMaps.ClientsideOption('draw_players_team', '1', 'Draw players teams on map')
SHOULD_DRAW_BAR = DMaps.ClientsideOption('draw_players_hpbar', '1', 'Draw players HP bars on map')

SV_SHOULD_DRAW_INFO = CreateConVar('sv_dmaps_draw_players_info', '1', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Draw players infos on map')
SV_SHOULD_DRAW_HEALTH = CreateConVar('sv_dmaps_draw_players_health', '1', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Draw players health on map')
SV_SHOULD_DRAW_ARMOR = CreateConVar('sv_dmaps_draw_players_armor', '1', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Draw players armor on map')
SV_SHOULD_DRAW_TEAM = CreateConVar('sv_dmaps_draw_players_team', '1', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Draw players teams on map')

surface.CreateFont('DMaps.PlayerInfoFont', {
	font: 'Roboto',
	size: 48
	weight: 500
})

HU_IN_METER = 40

class AppenableString
	new: (str = '') =>
		@str = str

	GetString: => @str

	append: (str = '') =>
		@str ..= '\n' .. str

	add: (...) => @append(...)
	Append: (...) => @append(...)
	Add: (...) => @append(...)
	Concat: (...) => @append(...)
	concat: (...) => @append(...)

class DMapPlayerPointer extends DMapEntityPointer
	@FONT = 'DMaps.PlayerInfoFont'
	@BACKGROUND_COLOR = Color(0, 0, 0, 150)
	@BACKGROUND_SHIFT = 4
	@UP_VECTOR = Vector(0, 0, 4000)
	@MAX_DELTA_HEIGHT = 600
	@START_FADE_HEIGHT = 200
	@FADE_VALUE_HEIGHT = 400
	@FADE_VALUE_HEIGHT_DIV = 200
	@TRIGGER_FADE_DIST = 800

	@HEALTH_COLOR_FIRST = Color(21, 225, 13)
	@HEALTH_COLOR_LAST = Color(118, 53, 49)
	@HEALTH_COLOR_BACKGROUND = Color(132, 163, 20)
	@HPBarW = 200
	@HPBarH = 10
	@HPBarShift = 90

	@__type = 'player'

	new: (ply = NULL, filter = DMaps.GetPlayerFilter()) =>
		@filter = filter(ply, @)
		super(ply)
		@draw = true
		@CalcPlayerData()
		@userid = ply\UserID()
		@steamid = ply\SteamID()
		@steamid64 = ply\SteamID64()
		@uniqueid = ply\UniqueID()

	OpenMenu: (menu = DermaMenu()) =>
		if not @GetEntity()\Alive() return false
		super(menu)
		with menu
			\AddSpacer()
			\AddOption('Copy Nickname', -> SetClipboardText(tostring(@playerName)))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Copy Steam name', -> SetClipboardText(tostring(@SteamName)))\SetIcon(table.Random(DMaps.TAGS_ICONS)) if @SteamName
			\AddOption('Copy UserID', -> SetClipboardText(tostring(@userid)))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Copy SteamID', -> SetClipboardText(tostring(@steamid)))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Copy SteamID64', -> SetClipboardText(tostring(@steamid64)))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Copy UniqueID', -> SetClipboardText(tostring(@uniqueid)))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Open steam profile', -> gui.OpenURL("http://steamcommunity.com/profiles/#{@steamid64}/"))\SetIcon('icon16/link.png')
			\AddOption('Create waypoint...', -> DMaps.WaypointAction(math.floor(@x), math.floor(@y), math.floor(@z)))\SetIcon(table.Random(DMaps.FLAGS))
			\AddOption('Navigate to...', -> DMaps.RequireNavigation(Vector(@x, @y, @z)))\SetIcon('icon16/map_go.png') if DMaps.NAV_ENABLE\GetBool()
			\AddOption('Look At', -> LocalPlayer()\SetEyeAngles((@EyePos() - LocalPlayer()\EyePos())\Angle()))\SetIcon('icon16/arrow_in.png')
			DMaps.CopyMenus(menu, @eyeX, @eyeY, @eyeZ, 'Copy using eyes pos...')
			DMaps.CopyMenus(menu, @x, @y, @z)
			\Open()
		return true

	SetEntity: (ply) =>
		super(ply)
		@filter\SetPlayer(ply)

	ShouldDraw: => @draw and SHOULD_DRAW\GetBool()

	GetEyeX: => @eyeX
	EyeX: => @eyeX
	GetEyeY: => @eyeY
	EyeY: => @eyeY
	GetEyeZ: => @eyeZ
	EyeZ: => @eyeZ
	GetEyePos: => Vector(@eyeX, @eyeY, @eyeZ)
	EyePos: => Vector(@eyeX, @eyeY, @eyeZ)
	GetRenderPriority: => 100

	CalcPlayerData: (map) =>
		ply = @entity

		ang = ply\EyeAngles!
		@playerName = ply\Nick()
		@SteamName = ply\SteamName() if ply.SteamName
		@teamID = ply\Team!
		@color = team.GetColor(@teamID)
		@teamName = team.GetName(@teamID)

		@hp = ply\Health!
		@armor = ply\Armor!
		@maxhp = ply\GetMaxHealth!

		@pitch = ang.p
		@yaw = -ang.y
		@roll = ang.r

		{:x, :y, :z} = ply\EyePos()
		@eyeX = x
		@eyeY = y
		@eyeZ = z

	Think: (map) =>
		@CURRENT_MAP = map
		super(map)

		if not IsValid(@entity) return
		@CalcPlayerData(map)
		@draw = @filter\Filter(map)

	GetPlayerInfo: =>
		str = @playerName
		if @IsNearMouse()
			str ..= "\nTeam: #{@teamName}" if SHOULD_DRAW_TEAM\GetBool() and SV_SHOULD_DRAW_TEAM\GetBool()
			str ..= "\nHP: #{@hp}/#{@maxhp}" if SHOULD_DRAW_HEALTH\GetBool() and SV_SHOULD_DRAW_HEALTH\GetBool()
			str ..= "\nArmor: #{@armor}" if SHOULD_DRAW_ARMOR\GetBool() and SV_SHOULD_DRAW_ARMOR\GetBool()
		text = AppenableString(str)
		hook.Run('DMaps.AddPlayerInfo', @, text)

		newStr = text\GetString!
		delta = @GetDeltaHeight!

		if delta > 100
			newStr ..= "\n#{math.floor(delta / HU_IN_METER * 10) / 10} meters higher"
		elseif delta < -100
			newStr ..= "\n#{math.floor(-delta / HU_IN_METER * 10) / 10} meters lower"

		return newStr

	DrawPlayerInfo: (map, x = 0, y = 0, alpha = 1) =>
		return if not SHOULD_DRAW_INFO\GetBool() or not SV_SHOULD_DRAW_INFO\GetBool()
		y += 90
		surface.SetFont(@@FONT)

		text = @GetPlayerInfo!
		w, h = surface.GetTextSize(text)

		surface.SetDrawColor(@@BACKGROUND_COLOR.r, @@BACKGROUND_COLOR.g, @@BACKGROUND_COLOR.b, @@BACKGROUND_COLOR.a * alpha)
		surface.DrawRect(x - @@BACKGROUND_SHIFT - w / 2, y - @@BACKGROUND_SHIFT, w + @@BACKGROUND_SHIFT * 2, h + @@BACKGROUND_SHIFT * 2)
		draw.DrawText(text, @@FONT, x, y, Color(@@TEXT_COLOR.r, @@TEXT_COLOR.g, @@TEXT_COLOR.b, @@TEXT_COLOR.a * alpha), TEXT_ALIGN_CENTER)

	GetDeltaHeight: => @z - @CURRENT_MAP\GetZ!

	Draw: (map) =>
		if not @GetEntity()\Alive() return
		if @entity\InVehicle()
			veh = @entity\GetVehicle()
			if IsValid(veh) and veh\GetClass() ~= 'prop_vehicle_prisoner_pod' return
		@CURRENT_MAP = map

		trig = @@generateTriangle(@DRAW_X, @DRAW_Y, @yaw, 40, 50, 130)

		newAlpha = 1
		delta = @z - map\GetZ!
		deltaAbs = math.abs(delta)

		if deltaAbs > @@MAX_DELTA_HEIGHT
			return
		elseif deltaAbs > @@START_FADE_HEIGHT
			newAlpha = math.Clamp((@@FADE_VALUE_HEIGHT - deltaAbs) / @@FADE_VALUE_HEIGHT_DIV, 0.2, 1)

		surface.SetDrawColor(@color.r, @color.g, @color.b, @color.a * newAlpha)
		surface.DrawPoly(trig)

		x, y = @DRAW_X, @DRAW_Y
		@DrawPlayerInfo(map, x, y, newAlpha)

		if SV_SHOULD_DRAW_HEALTH\GetBool() and SHOULD_DRAW_HEALTH\GetBool() and SHOULD_DRAW_BAR\GetBool()
			y -= @@HPBarShift
			div = 1
			div = @maxhp if @maxhp ~= 0
			divR = math.Clamp(@hp / div, 0, 1)
			@divRLerp = Lerp(0.1, @divRLerp or divR, divR)
			w, h = @@HPBarW, @@HPBarH
			surface.SetDrawColor(@@BACKGROUND_COLOR.r, @@BACKGROUND_COLOR.g, @@BACKGROUND_COLOR.b, @@BACKGROUND_COLOR.a * newAlpha)
			surface.DrawRect(x - w / 2 - 4, y - 2, w + 8, h + 4)
			surface.SetDrawColor(@@HEALTH_COLOR_BACKGROUND.r, @@HEALTH_COLOR_BACKGROUND.g, @@HEALTH_COLOR_BACKGROUND.b, @@HEALTH_COLOR_BACKGROUND.a * newAlpha)
			surface.DrawRect(x - w / 2, y, w, h)
			colr = DMaps.DeltaColor(@@HEALTH_COLOR_FIRST, @@HEALTH_COLOR_LAST, @divRLerp)
			colr.a *= newAlpha
			surface.SetDrawColor(colr)
			surface.DrawRect(x - w / 2, y, w * @divRLerp, h)

		@CURRENT_MAP = nil

DMaps.DMapPlayerPointer = DMapPlayerPointer
return DMapPlayerPointer
