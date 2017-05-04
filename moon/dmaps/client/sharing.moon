
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

import DMaps, net, IsValid from _G
import DMapWaypoint, ENABLE_SMOOTH, ENABLE_SMOOTH_MOVE from DMaps

local LAST_SHARE_WAYPOINT
SHARING_DATABASE = {}
SHARE_COLOR = DMaps.CreateColor(123, 204, 204, 'share', 'Shared waypoint color')
SHARE_NOTIFY = DMaps.ClientsideOption('share_notify', '1', 'Notify in chat when player shares a waypoint to you')

class SharedWaypoint extends DMapWaypoint
	new: (id = 0, data) =>
		@hightlightID = id
		{:x, :y, :z, sharer: @sharer, nick: @nick, steamid: @steamid, steamid64: @steamid64, uniqueid: @uniqueid, steamname: @steamname} = data
		super("#{@nick}'s waypoint\nX: #{x}, Y: #{y}, Z: #{z}", x, y, z, Color(SHARE_COLOR()), 'magnet')
	
	OpenMenu: (menu = DermaMenu()) =>
		super(menu)
		with menu
			\AddSpacer()
			\AddOption('Remove highlight', -> @Remove())\SetIcon('icon16/cross.png')
			\AddOption('Copy share point ID', -> SetClipboardText("#{@hightlightID}"))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			createWaypoint = ->
				data, id = ClientsideWaypoint.DataContainer\CreateWaypoint("#{@nickname}'s waypoint", @x, @y, @z)
				reject = -> ClientsideWaypoint.DataContainer\DeleteWaypoint(id)
				accept = -> @Remove()
				DMaps.OpenWaypointEditMenu(id, ClientsideWaypoint.DataContainer, reject, accept) if id
			\AddOption('Create waypoint', createWaypoint)\SetIcon(table.Random(DMaps.FLAGS))
			hit = false
			sub = \AddSubMenu('Create serverside waypoint...')
			for container in *DMaps.ServerWaypointsContainers
				if DMaps.HasPermission(container.__PERM_EDIT) and DMaps.HasPermission(container.__PERM_VIEW)
					hit = true
					sub\AddOption("Create #{container._NAME_ON_PANEL} waypoint", ->
						containerObject = container\GetContainer()
						if not container\IsValid()
							containerObject = container(false, false)
							net.Start(container.NETWORK_STRING)
							net.SendToServer()
						containerObject\OpenEditMenu(container\GenerateData(x, y, z))
					)\SetIcon(table.Random(DMaps.FLAGS))
			sub\Remove() if not hit
			\AddSpacer()
			\AddOption('Copy sharer\'s Steam Name', -> SetClipboardText(tostring(@SteamName)))\SetIcon(table.Random(DMaps.TAGS_ICONS)) if @SteamName
			\AddOption('Copy sharer\'s nickname', -> SetClipboardText(tostring(@nick)))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Copy sharer\'s UserID', -> SetClipboardText(tostring(@userid)))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Copy sharer\'s SteamID', -> SetClipboardText(tostring(@steamid)))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Copy sharer\'s SteamID64', -> SetClipboardText(tostring(@steamid64)))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Copy sharer\'s UniqueID', -> SetClipboardText(tostring(@uniqueid)))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Open sharer\'s steam profile', -> gui.OpenURL("http://steamcommunity.com/profiles/#{@steamid64}/"))\SetIcon('icon16/link.png')
			\Open()
		return true

concommand.Add 'dmaps_s', (ply, cmd = '', args = {}, argStr = '') ->
	num = tonumber(args[1] or '')
	return DMaps.Message('Invalid number!') if not num
	data = SHARING_DATABASE[num]
	return DMaps.Message('No such data with ', num, ' ID!') if not data

	{:x, :y, :z, :sharer, :vec} = data
	vec = Vector(x, y, z)
	map = DMaps.GetMainMap()
	ply = LocalPlayer()
	pos = ply\EyePos()
	ang = (vec - pos)\Angle()

	ply\SetEyeAngles(ang)
	DMaps.ChatPrint('Targeting X: ', x, ' Y: ', y, ' Z: ', z)

	if IsValid(map)
		LAST_SHARE_WAYPOINT\Remove() if IsValid(LAST_SHARE_WAYPOINT)
		LAST_SHARE_WAYPOINT = SharedWaypoint(num, data)
		map\AddObject(LAST_SHARE_WAYPOINT)
		vec.z += 600
		map\LockZoom(true)
		map\LockView(true)
		if ENABLE_SMOOTH\GetBool() and ENABLE_SMOOTH_MOVE\GetBool()
			map\SetLerpPos(vec)
		else
			map\SetPos(vec)

net.Receive 'DMaps.Sharing', ->
	x, y, z = net.ReadInt(16), net.ReadInt(16), net.ReadInt(16)
	sharer = net.ReadEntity()
	return if not IsValid(sharer)
	nick = sharer\Nick()
	steamid = sharer\SteamID()
	steamid64 = sharer\SteamID64()
	uniqueid = sharer\UniqueID()
	steamname = sharer\SteamName() if sharer.SteamName
	data = {:x, :y, :z, :sharer, :nick, :steamid, :steamid64, :uniqueid, :steamname}
	id = table.insert(SHARING_DATABASE, data)
	if SHARE_NOTIFY\GetBool()
		DMaps.ChatPrint(sharer, ' has just shared a world position with you! X: ', x, ' Y: ', y, ' Z: ', z, '\nTo highlight (activate) it, type "dmaps_s ', id, '" in your console!')
	else
		DMaps.Message(sharer, ' has just shared a world position with you! X: ', x, ' Y: ', y, ' Z: ', z, '\nTo highlight (activate) it, type "dmaps_s ', id, '" in your console!')

PANEL =
	textCol: Color(255, 255, 255)
	Init: =>
		@DockPadding(5, 0, 0, 0)
		@DockMargin(5, 5, 5, 5)
		@checkbox = vgui.Create('DCheckBox', @)
		@checkbox\Dock(LEFT)
		@checkbox\SetChecked(false)
		@checkbox\DockMargin(0, 8, 0, 8)
		@avatar = vgui.Create('DMaps_Avatar', @)
		@avatar\Dock(LEFT)
		@avatar\DockMargin(5, 0, 0, 0)
		@nick = vgui.Create('DLabel', @)
		@nick\Dock(LEFT)
		@nick\DockMargin(5, 0, 0, 0)
		@nick\SetText('%PLAYERNAME%')
		@nick\SetTextColor(@textCol)
		@SteamProfile = vgui.Create('DButton', @)
		@SteamProfile\Dock(RIGHT)
		@SteamProfile\DockMargin(5, 5, 5, 5)
		@SteamProfile\SetText('Open Steam profile')
		@SteamProfile\SetSize(120, 32)
		@SteamProfile.DoClick = -> gui.OpenURL("http://steamcommunity.com/profiles/#{@steamid64}/")
		@checkbox.OnChange = (c, bool) -> @OnChange(bool)
		@SetSize(200, 32)
	SetPlayer: (ply) =>
		@ply = ply
		@avatar\SetPlayer(ply, 32)
		@avatar\SetSize(32, 32)
		@steamid64 = ply\SteamID64()
		@nick\SetText(ply\Nick())
		@nick\SizeToContents()
	GetChecked: => @checkbox\GetChecked()
	OnChange: (bool) =>
	Think: => @Remove() if not IsValid(@ply)
	Paint: (w, h) =>
		surface.SetDrawColor(170, 170, 170)
		surface.DrawRect(0, 0, w, h)
vgui.Register('DMapsSharingPlayerRow', PANEL, 'EditablePanel')

DMaps.OpenShareMenu = (x = 0, y = 0, z = 0) ->
	x, y, z = math.floor(x), math.floor(y), math.floor(z)
	players = for ply in *player.GetAll()
		if ply\IsBot() continue
		if ply == LocalPlayer() continue
		ply
	if #players == 0
		Derma_Message('No other players online!\nforever alone', 'No players online', 'Okai ;w;')
		return
	table.sort players, (a, b) ->
		status1, status2, nick1, nick2 = a\GetFriendStatus(), b\GetFriendStatus(), a\Nick(), b\Nick()
		status1 = status1 == 'friend' or status1 == 'requested'
		status2 = status2 == 'friend' or status2 == 'requested'
		if status1 and status2
			return nick1 < nick2
		elseif status1
			return true
		elseif status2
			return false
		else
			return nick1 < nick2
		return true
	self = vgui.Create('DFrame')
	@SetTitle('Waypoint share menu')
	@SetSize(ScrW() - 100, ScrH() - 100)
	@Center()
	@MakePopup()
	scroll = vgui.Create('DScrollPanel', @)
	scroll\Dock(FILL)

	selected = {}
	local accept

	panels = for ply in *players
		pnl = vgui.Create('DMapsSharingPlayerRow', scroll)
		pnl\Dock(TOP)
		pnl\SetPlayer(ply)
		pnl.OnChange = (pnl, bool) ->
			if bool
				table.insert(selected, ply)
			else
				for i = 1, #selected
					if selected[i] == ply
						table.remove(selected, i)
						break
			accept\SetEnabled(#selected ~= 0)
		pnl

	decline = vgui.Create('DButton', @)
	decline\Dock(BOTTOM)
	decline\SetText('Cancel')
	decline.DoClick = -> @Close()
	accept = vgui.Create('DButton', @)
	accept\Dock(BOTTOM)
	accept\SetText('Share')
	accept\SetEnabled(false)
	accept\SetSize(200, 28)
	accept.DoClick = ->
		return if #selected == 0
		buildStr = table.concat(["#{ply\UserID()}" for ply in *selected], ',')
		RunConsoleCommand('dmaps_share', buildStr, "#{x}", "#{y}", "#{z}")
		@Close()