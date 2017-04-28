
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
import EventPointer, Icon from DMaps

SV_DEATH_POINT_DURATION = CreateConVar('sv_dmaps_deathpoints_duration', '15', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Player death point live time in minutes')
DRAW_DEATHPOINTS = DMaps.ClientsideOption('draw_deathpoints', '1', 'Draw deathpoints on map')
DRAW_DEATHPOINTS_PLAYERS = DMaps.ClientsideOption('draw_deathpoints_player', '1', 'Draw player deathpoints on map')

class DeathPointer extends EventPointer
	GetRenderPriority: => -10
	@TextColor = Color(200, 200, 200)
	@BackgroundColor = Color(0, 0, 0, 150)
	@DefaultColor = Color(233, 89, 89)
	@GetDefaultTime = => @DefaultLiveTime

	@DEATH_POINTS = {}

	new: (name = 'Perfectly generic death', x = 0, y = 0, z = 0, color = @@DefaultColor, yaw = 0, size = 1) =>
		super(name, x, y, z, color)
		@_dPointID = table.insert(@@DEATH_POINTS, @)
	GetText: => "#{@GetName()} died #{@NiceTime()} ago#{DMaps.DeltaString(@z)}"
	Remove: =>
		super()
		@@DEATH_POINTS[@_dPointID] = nil

	Draw: (map) =>
		return if not DRAW_DEATHPOINTS\GetBool()
		super(map)

class PlayerDeathPointer extends DeathPointer
	new: (ply = NULL, x = 0, y = 0, z = 0) =>
		@ply = ply
		super(@ply\Nick(), x, y, z, team.GetColor(@ply\Team()))
		@SetLiveTime(SV_DEATH_POINT_DURATION\GetFloat() * 60)
		@nick = ply\Nick()
		@userid = ply\UserID()
		@steamid = ply\SteamID()
		@steamid64 = ply\SteamID64()
		@uniqueid = ply\UniqueID()
		@SteamName = ply\SteamName() if ply.SteamName
	OpenMenu: (menu = DermaMenu()) =>
		super(menu)
		with menu
			\AddSpacer()
			\AddOption('Copy Steam Name', -> SetClipboardText(tostring(@SteamName))) if @SteamName
			\AddOption('Copy UserID', -> SetClipboardText(tostring(@userid)))
			\AddOption('Copy SteamID', -> SetClipboardText(tostring(@steamid)))
			\AddOption('Copy SteamID64', -> SetClipboardText(tostring(@steamid64)))
			\AddOption('Copy UniqueID', -> SetClipboardText(tostring(@uniqueid)))
			\AddOption('Open steam profile', -> gui.OpenURL("http://steamcommunity.com/profiles/#{@steamid64}/"))
			\Open()
		return true
	Draw: (map) =>
		return if not DRAW_DEATHPOINTS_PLAYERS\GetBool()
		super(map)


DMaps.DeathPointer = DeathPointer
DMaps.PlayerDeathPointer = PlayerDeathPointer

local LAST_DEATH_POINT
REMEMBER_DEATH_POINT = DMaps.ClientsideOption('remember_death', '1', 'Remember last death point')
DEATH_POINT_COLOR = DMaps.CreateColor(255, 255, 255, 'remember_death', 'Latest death point color')

net.Receive 'DMaps.PlayerDeath', ->
	ply = net.ReadEntity()
	{:x, :y, :z} = net.ReadVector()

	if not IsValid(ply) return
	if ply == LocalPlayer()
		return if not REMEMBER_DEATH_POINT\GetBool()
		x, y, z = math.floor(x), math.floor(y), math.floor(z)
		LAST_DEATH_POINT\Remove() if IsValid(LAST_DEATH_POINT)
		LAST_DEATH_POINT = DMapWaypoint('Latest death', x, y, z, Color(DEATH_POINT_COLOR()), 'skull_old')
		hook.Run 'DMaps.PlayerDeath', ply, LAST_DEATH_POINT
		DMaps.ChatPrint('You died at X: ', x, ' Y: ', y, ' Z: ', z)
		return
	
	point = PlayerDeathPointer(ply, x, y, z)
	hook.Run 'DMaps.PlayerDeath', ply, point
