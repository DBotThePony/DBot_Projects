
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
import DMapPointer, ClientsideWaypoint, DMapWaypoint, Icon from DMaps

SV_DEATH_POINT_DURATION = CreateConVar('sv_dmaps_deathpoints_duration', '15', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Player death point live time in minutes')
DRAW_DEATHPOINTS = DMaps.ClientsideOption('draw_deathpoints', '1', 'Draw deathpoints on map')
DRAW_DEATHPOINTS_PLAYERS = DMaps.ClientsideOption('draw_deathpoints_player', '1', 'Draw player deathpoints on map')

surface.CreateFont('DMaps.DeathPointText', {
	font: 'Roboto'
	size: 36
	weight: 500
})

surface.CreateFont('DMaps.DeathPointTextSmaller', {
	font: 'Roboto'
	size: 28
	weight: 500
})

surface.CreateFont('DMaps.DeathPointTextSmall', {
	font: 'Roboto'
	size: 24
	weight: 500
})

surface.CreateFont('DMaps.DeathPointTextTiny', {
	font: 'Roboto'
	size: 18
	weight: 500
})

class DeathPointer extends DMapPointer
	@NiceTime: (time = 0) =>
		time = math.floor(time)
		seconds = time % 60
		time = time - seconds
		
		minutes = time % (60 * 60)
		time = time - minutes
		
		hours = time
		
		str = ''
		
		str ..= ' ' .. math.floor(hours / 3600) .. ' hours' if hours ~= 0
		str ..= ' ' .. minutes / 60 .. ' minutes' if minutes ~= 0
		str ..= ' ' .. seconds .. ' seconds' if seconds ~= 0
		return str\Trim()
	NiceTime: => @@NiceTime(CurTime() - @start)
	GetRenderPriority: => -10
	@DefaultLiveTime = 60 -- Override

	@GenerateCross = (X = 0, Y = 0, size = 1, yaw = 0) =>
		-- yeeeee gmod
		--pattern = {
		--	{x: -50, y: -50}
		--	{x: -45, y: -50}
		--	{x: 0, y: -5}
		--	{x: 45, y: -50}
		--	{x: 50, y: -50}
		--	{x: 50, y: -45}
		--	{x: 5, y: 0}
		--	{x: 50, y: 45}
		--	{x: 50, y: 50}
		--	{x: 45, y: 50}
		--	{x: 0, y: 5}
		--	{x: -45, y: 50}
		--	{x: -50, y: 50}
		--	{x: -50, y: 45}
		--	{x: -5, y: 0}
		--	{x: -50, y: -45}
		--}

		pattern1 = {
			{x: -50, y: -50}
			{x: -45, y: -50}
			{x: 50, y: 45}
			{x: 50, y: 50}
			{x: 45, y: 50}
			{x: -50, y: -45}
		}

		pattern2 = {
			{x: 45, y: -50}
			{x: 50, y: -50}
			{x: 50, y: -45}
			{x: -45, y: 50}
			{x: -50, y: 50}
			{x: -50, y: 45}
		}

		rad = math.rad(yaw)
		sin = math.sin(rad)
		cos = math.cos(rad)

		for data in *pattern1
			{:x, :y} = data
			x *= size
			y *= size
			data.x = x * cos - y * sin + X
			data.y = y * cos + x * sin + Y
		
		for data in *pattern2
			{:x, :y} = data
			x *= size
			y *= size
			data.x = x * cos - y * sin + X
			data.y = y * cos + x * sin + Y
		
		return pattern1, pattern2

	@Font = 'DMaps.DeathPointText'
	@FontSmaller = 'DMaps.DeathPointTextSmaller'
	@FontSmall = 'DMaps.DeathPointTextSmall'
	@FontTiny = 'DMaps.DeathPointTextTiny'
	@TextColor = Color(200, 200, 200)
	@BackgroundColor = Color(0, 0, 0, 150)
	@DefaultColor = Color(233, 89, 89)
	@GetDefaultTime = => @DefaultLiveTime

	@DEATH_POINTS = {}

	new: (name = 'Perfectly generic death', x = 0, y = 0, z = 0, color = @@DefaultColor) =>
		super(x, y, z)
		@dName = name
		@start = CurTime()
		@size = 1
		@yaw = 0
		@color = color
		@SetLiveTime(@@DefaultLiveTime)
		@_dPointID = table.insert(@@DEATH_POINTS, @)
	GetYaw: => @yaw
	GetSize: => @size
	GetColor: => @color
	SetColor: (color = @@DefaultColor) => @color = color
	SetYaw: (val = 0) => @yaw = val
	SetSize: (val = 0) => @size = val
	ResetTimer: =>
		@start = CurTime()
		@finish = @start + @toLive
	SetLiveTime: (val = @@DefaultLiveTime, resetTimer = true) =>
		@toLive = val
		@finish = @start + val
		@ResetTimer() if resetTimer
	Think: (map) =>
		super(map)
		@Remove() if @finish < CurTime()
	GetText: => "#{@dName} died #{@NiceTime()} ago#{DMaps.DeltaString(@z)}"

	PreDraw: (map) =>
		super(map)
		@DRAW_X, @DRAW_Y = map\Start2D(@x, @y)
	PostDraw: (map) =>
		super(map)
		map\Stop2D()
	Remove: =>
		super()
		@@DEATH_POINTS[@_dPointID] = nil

	Draw: (map) =>
		return if not DRAW_DEATHPOINTS\GetBool()
		x, y = @DRAW_X, @DRAW_Y
		selectfont = @@Font if @size >= 1
		selectfont = @@FontSmaller if @size < 1 and @size > 0.5
		selectfont = @@FontSmall if @size <= 0.5 and @size > 0.25
		selectfont = @@FontTiny if @size <= 0.25
		surface.SetDrawColor(@color)
		draw.NoTexture()
		p1, p2 = @@GenerateCross(x, y, @size, @yaw)
		surface.DrawPoly(p1)
		surface.DrawPoly(p2)
		if not @IsNearMouse() return

		surface.SetDrawColor(@@BackgroundColor)
		surface.SetFont(selectfont)
		text = @GetText()
		w, h = surface.GetTextSize(text)
		y -= h / 2
		surface.DrawRect(x - 4 - w / 2, y - 4, w + 8, h + 8)
		draw.DrawText(text, selectfont, x, y, @@TextColor, TEXT_ALIGN_CENTER)
	OpenMenu: (menu = DermaMenu()) =>
		with menu
			\AddOption('Teleport to', -> RunConsoleCommand('dmaps_teleport', @x, @y, @z)) if DMaps.HasPermission('teleport')
			\AddOption 'Create waypoint...', ->
				data, id = ClientsideWaypoint.DataContainer\CreateWaypoint("New Waypoint At X: #{@x}, Y: #{@y}, Z: #{@z}", @x, @y, @z)
				DMaps.OpenWaypointEditMenu(id, ClientsideWaypoint.DataContainer, (-> ClientsideWaypoint.DataContainer\DeleteWaypoint(id))) if id
			\AddOption('Copy XYZ position', -> SetClipboardText("X: #{@x}, Y: #{@y}, Z: #{@z}"))
			\AddOption('Copy name', -> SetClipboardText(@dName))
			\AddOption('Copy death stamp', -> SetClipboardText(@start))
			\AddOption 'Copy death date', ->
				time = os.time()
				delta = math.floor(CurTime() - @start)
				timeStamp = time - delta
				SetClipboardText(os.date('%H:%M:%S - %d/%m/%Y', timeStamp))
			\AddOption('Copy point data string', -> SetClipboardText("Name: #{@dName}, X: #{@x}, Y: #{@y}, Z: #{@z}"))
			\Open()
		return true

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
	OpenMenu: (menu = DermaMenu()) =>
		super(menu)
		with menu
			\AddSpacer()
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
