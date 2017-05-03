
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
import DMapPointer, DMapWaypoint, Icon from DMaps

surface.CreateFont('DMaps.EventPointText', {
	font: 'Roboto'
	size: 36
	weight: 500
})

surface.CreateFont('DMaps.EventPointTextSmaller', {
	font: 'Roboto'
	size: 28
	weight: 500
})

surface.CreateFont('DMaps.EventPointTextSmall', {
	font: 'Roboto'
	size: 24
	weight: 500
})

surface.CreateFont('DMaps.EventPointTextTiny', {
	font: 'Roboto'
	size: 18
	weight: 500
})

MAXIMAL_AMOUNT = CreateConVar('cl_dmaps_max_events', '120', {FCVAR_ARCHIVE}, 'Maximal amount of event points')

class EventPointer extends DMapPointer
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

	@Font = 'DMaps.EventPointText'
	@FontSmaller = 'DMaps.EventPointTextSmaller'
	@FontSmall = 'DMaps.EventPointTextSmall'
	@FontTiny = 'DMaps.EventPointTextTiny'
	@TextColor = Color(200, 200, 200)
	@BackgroundColor = Color(0, 0, 0, 150)
	@DefaultColor = Color(14, 201, 174)
	@GetDefaultTime = => @DefaultLiveTime

	@EVENT_POINTS = {}
	@EVENT_POINTS_AMOUNT = 0

	new: (name = 'Perfectly generic event', x = 0, y = 0, z = 0, color = @@DefaultColor, yaw = 0, size = 1) =>
		super(x, y, z)
		@eName = name
		@start = CurTime()
		@size = size
		@yaw = yaw
		@color = color
		@SetLiveTime(@@DefaultLiveTime)
		@eTabId = table.insert(@@EVENT_POINTS, @)
		@@EVENT_POINTS_AMOUNT += 1
		maximal = MAXIMAL_AMOUNT\GetInt()
		return if maximal <= 0
		return if @@EVENT_POINTS_AMOUNT <= maximal
		timer.Create 'DMaps.ClearEventPoints', 0, 1, ->
			objects = [obj for index, obj in pairs @@EVENT_POINTS]
			table.sort(objects, (a, b) -> a\GetStamp() < b\GetStamp())
			objects[i]\Remove() for i = 1, @@EVENT_POINTS_AMOUNT - maximal

	GetName: => @eName
	GetYaw: => @yaw
	GetSize: => @size
	GetColor: => @color
	SetColor: (color = @@DefaultColor) => @color = color
	SetYaw: (val = 0) => @yaw = val
	SetSize: (val = 0) => @size = val
	SetName: (val = '') => @eName = val
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
	GetText: => "#{@eName} happened #{@NiceTime()} ago#{DMaps.DeltaString(@z)}" -- Override

	PreDraw: (map) =>
		super(map)
		@DRAW_X, @DRAW_Y = map\Start2D(@x, @y)
	PostDraw: (map) =>
		super(map)
		map\Stop2D()

	DrawText: (map) =>
		if not @IsNearMouse() return
		x, y = @DRAW_X, @DRAW_Y
		selectfont = @@Font if @size >= 1
		selectfont = @@FontSmaller if @size < 1 and @size > 0.5
		selectfont = @@FontSmall if @size <= 0.5 and @size > 0.25
		selectfont = @@FontTiny if @size <= 0.25
		surface.SetDrawColor(@@BackgroundColor)
		surface.SetFont(selectfont)
		text = @GetText()
		w, h = surface.GetTextSize(text)
		y -= h / 2
		surface.DrawRect(x - 4 - w / 2, y - 4, w + 8, h + 8)
		draw.DrawText(text, selectfont, x, y, @@TextColor, TEXT_ALIGN_CENTER)
	DrawCross: (map) =>
		x, y = @DRAW_X, @DRAW_Y
		surface.SetDrawColor(@color)
		draw.NoTexture()
		p1, p2 = @@GenerateCross(x, y, @size, @yaw)
		surface.DrawPoly(p1)
		surface.DrawPoly(p2)
	Draw: (map) =>
		@DrawCross(map)
		@DrawText(map)
	OpenMenu: (menu = DermaMenu()) =>
		with menu
			\AddOption('Teleport to', -> RunConsoleCommand('dmaps_teleport', @x, @y, @z))\SetIcon('icon16/arrow_in.png') if DMaps.HasPermission('teleport')
			\AddOption('Create waypoint...', ->
				data, id = DMaps.ClientsideWaypoint.DataContainer\CreateWaypoint("New Waypoint At X: #{@x}, Y: #{@y}, Z: #{@z}", @x, @y, @z)
				DMaps.OpenWaypointEditMenu(id, DMaps.ClientsideWaypoint.DataContainer, (-> DMaps.ClientsideWaypoint.DataContainer\DeleteWaypoint(id))) if id
			)\SetIcon(table.Random(DMaps.FLAGS))
			\AddOption('Navigate to...', -> DMaps.RequireNavigation(@GetPos()))\SetIcon('icon16/map_go.png') if DMaps.NAV_ENABLE\GetBool()
			DMaps.CopyMenus(menu, @x, @y, @z)
			\AddOption('Copy name', -> SetClipboardText(@dName))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Copy stamp', -> SetClipboardText(@start))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Copy date', ->
				time = os.time()
				delta = math.floor(CurTime() - @start)
				timeStamp = time - delta
				SetClipboardText(os.date('%H:%M:%S - %d/%m/%Y', timeStamp))
			)\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Copy point data string', -> SetClipboardText("Name: #{@dName}, X: #{@x}, Y: #{@y}, Z: #{@z}"))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Look At', -> LocalPlayer()\SetEyeAngles((@GetPos() - LocalPlayer()\EyePos())\Angle()))\SetIcon('icon16/arrow_in.png')
			\Open()
		return true
	Remove: =>
		super()
		@@EVENT_POINTS[@eTabId] = nil
		@@EVENT_POINTS_AMOUNT -= 1

DMaps.EventPointer = EventPointer