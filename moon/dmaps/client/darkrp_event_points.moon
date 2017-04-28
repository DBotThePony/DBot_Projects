
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

import hook, DMaps, DarkRP, net, surface, draw from _G
import EventPointer, Icon from DMaps

if not DarkRP return

SV_ARREST_DURATION = CreateConVar('sv_dmaps_arrest_duration', '5', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Player arrest event pointer live time in minutes')
DRAW_ARRESTS = DMaps.ClientsideOption('draw_arrests', '1', 'Draw arrest events on map')
Receive = (n, f) -> net.Receive("DMaps.DarkRP.#{n}", f)

GenerateJailIcon = (X = 0, Y = 0, size = 1, yaw = 0) ->
	rad = math.rad(yaw)
	sin, cos = math.sin(rad), math.cos(rad)

	objects = {
		{
			{x: -40, y: -40}
			{x: 45, y: -40}
			{x: 45, y: -30}
			{x: -40, y: -30}
		}

		{
			{x: -40, y: 30}
			{x: 45, y: 30}
			{x: 45, y: 40}
			{x: -40, y: 40}
		}
	}

	for i = -35, 35, 10
		data = {
			{x: i, y: -30}
			{x: i + 5, y: -30}
			{x: i + 5, y: 30}
			{x: i, y: 30}
		}

		table.insert(objects, data)

	for obj in *objects
		for data in *obj
			{:x, :y} = data
			x *= size
			y *= size
			newX = x * cos - y * sin
			newY = y * cos + x * sin
			data.x = newX + X
			data.y = newY + Y

	return objects

class ArrestEventPointer extends EventPointer
	GetRenderPriority: => -10
	@DefaultColor = Color(60, 236, 239)
	@GetDefaultTime = => @DefaultLiveTime

	@ARREST_POINTS = {}

	new: (ply = NULL, actioner = NULL, x = 0, y = 0, z = 0) =>
		@ply = ply
		@actioner = actioner

		if IsValid(ply)
			@nick = ply\Nick()
			@userid = ply\UserID()
			@steamid = ply\SteamID()
			@steamid64 = ply\SteamID64()
			@uniqueid = ply\UniqueID()
			@team = ply\Team()

		if IsValid(actioner)
			@actioner_nick = actioner\Nick()
			@actioner_userid = actioner\UserID()
			@actioner_steamid = actioner\SteamID()
			@actioner_steamid64 = actioner\SteamID64()
			@actioner_uniqueid = actioner\UniqueID()
			@actioner_team = actioner\Team()
		
		super(@nick, x, y, z, team.GetColor(@team))
		@_dPointID = table.insert(@@ARREST_POINTS, @)
		@SetLiveTime(SV_ARREST_DURATION\GetFloat() * 60)
	GetText: => "#{@nick} was arrested by #{@actioner_nick}\n#{@NiceTime()} ago#{DMaps.DeltaString(@z)}"
	OpenMenu: (menu = DermaMenu()) =>
		super(menu)
		with menu
			\AddSpacer()
			\AddOption('Copy UserID', -> SetClipboardText(tostring(@userid)))
			\AddOption('Copy SteamID', -> SetClipboardText(tostring(@steamid)))
			\AddOption('Copy SteamID64', -> SetClipboardText(tostring(@steamid64)))
			\AddOption('Copy UniqueID', -> SetClipboardText(tostring(@uniqueid)))
			\AddOption('Open steam profile', -> gui.OpenURL("http://steamcommunity.com/profiles/#{@steamid64}/"))
			\AddSpacer()
			\AddOption('Copy Arrester\'s UserID', -> SetClipboardText(tostring(@actioner_userid)))
			\AddOption('Copy Arrester\'s SteamID', -> SetClipboardText(tostring(@actioner_steamid)))
			\AddOption('Copy Arrester\'s SteamID64', -> SetClipboardText(tostring(@actioner_steamid64)))
			\AddOption('Copy Arrester\'s UniqueID', -> SetClipboardText(tostring(@actioner_uniqueid)))
			\AddOption('Open Arrester\'s steam profile', -> gui.OpenURL("http://steamcommunity.com/profiles/#{@actioner_steamid64}/"))
			\Open()
		return true
	Remove: =>
		super()
		@@ARREST_POINTS[@_dPointID] = nil

	Draw: (map) =>
		return if not DRAW_ARRESTS\GetBool()
		draw.NoTexture()
		x, y = @DRAW_X, @DRAW_Y
		@jailData = GenerateJailIcon(x, y, @size, @yaw) if not @jailData
		surface.SetDrawColor(@GetColor())
		surface.DrawPoly(obj) for obj in *@jailData
		@DrawText(map)

class UnArrestEventPointer extends EventPointer
	GetRenderPriority: => -10
	@DefaultColor = Color(41, 178, 20)
	@GetDefaultTime = => @DefaultLiveTime

	@UNARREST_POINTS = {}

	new: (ply = NULL, actioner = NULL, x = 0, y = 0, z = 0) =>
		@ply = ply
		@actioner = actioner
		@hasUnarrester = IsValid(actioner)

		if IsValid(ply)
			@nick = ply\Nick()
			@userid = ply\UserID()
			@steamid = ply\SteamID()
			@steamid64 = ply\SteamID64()
			@uniqueid = ply\UniqueID()
			@team = ply\Team()

		if IsValid(actioner)
			@actioner_nick = actioner\Nick()
			@actioner_userid = actioner\UserID()
			@actioner_steamid = actioner\SteamID()
			@actioner_steamid64 = actioner\SteamID64()
			@actioner_uniqueid = actioner\UniqueID()
			@actioner_team = actioner\Team()
		
		super(@nick, x, y, z, team.GetColor(@team))
		@_dPointID = table.insert(@@UNARREST_POINTS, @)
		@SetLiveTime(SV_ARREST_DURATION\GetFloat() * 60)
	GetText: =>
		return "#{@nick} was unarrested by #{@actioner_nick}\n#{@NiceTime()} ago#{DMaps.DeltaString(@z)}" if @hasUnarrester
		return "#{@nick} was released from jail\n#{@NiceTime()} ago#{DMaps.DeltaString(@z)}" if not @hasUnarrester
		return ''
	OpenMenu: (menu = DermaMenu()) =>
		super(menu)
		with menu
			\AddSpacer()
			\AddOption('Copy UserID', -> SetClipboardText(tostring(@userid)))
			\AddOption('Copy SteamID', -> SetClipboardText(tostring(@steamid)))
			\AddOption('Copy SteamID64', -> SetClipboardText(tostring(@steamid64)))
			\AddOption('Copy UniqueID', -> SetClipboardText(tostring(@uniqueid)))
			\AddOption('Open steam profile', -> gui.OpenURL("http://steamcommunity.com/profiles/#{@steamid64}/"))
			if @hasUnarrester
				\AddSpacer()
				\AddOption('Copy Unarrester\'s UserID', -> SetClipboardText(tostring(@actioner_userid)))
				\AddOption('Copy Unarrester\'s SteamID', -> SetClipboardText(tostring(@actioner_steamid)))
				\AddOption('Copy Unarrester\'s SteamID64', -> SetClipboardText(tostring(@actioner_steamid64)))
				\AddOption('Copy Unarrester\'s UniqueID', -> SetClipboardText(tostring(@actioner_uniqueid)))
				\AddOption('Open Unarrester\'s steam profile', -> gui.OpenURL("http://steamcommunity.com/profiles/#{@actioner_steamid64}/"))
			\Open()
		return true
	Remove: =>
		super()
		@@UNARREST_POINTS[@_dPointID] = nil

	Draw: (map) =>
		return if not DRAW_ARRESTS\GetBool()
		draw.NoTexture()
		x, y = @DRAW_X, @DRAW_Y
		@jailData = GenerateJailIcon(x, y, @size, @yaw) if not @jailData
		@crossData = {@@GenerateCross(x, y, @size, @yaw)} if not @crossData
		surface.SetDrawColor(@GetColor())
		surface.DrawPoly(obj) for obj in *@jailData
		surface.SetDrawColor(@@DefaultColor)
		surface.DrawPoly(@crossData[1])
		surface.DrawPoly(@crossData[2])
		@DrawText(map)

Receive 'playerArrested', ->
	ply = net.ReadEntity()
	actioner = net.ReadEntity()
	{:x, :y, :z} = net.ReadVector()
	return if not IsValid(ply) or not IsValid(actioner)
	map = DMaps.GetMainMap()
	return if not map
	map\AddObject(ArrestEventPointer(ply, actioner, x, y, z))

Receive 'playerUnArrested', ->
	ply = net.ReadEntity()
	isValid = net.ReadBool()
	actioner = net.ReadEntity() if isValid
	{:x, :y, :z} = net.ReadVector()
	return if not IsValid(ply)
	map = DMaps.GetMainMap()
	return if not map
	map\AddObject(UnArrestEventPointer(ply, actioner, x, y, z))

DMaps.ArrestEventPointer = ArrestEventPointer
DMaps.UnArrestEventPointer = UnArrestEventPointer

