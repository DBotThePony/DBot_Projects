
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

-- A panel that holds the map
-- And user controls

import DMaps, surface, gui, draw, table, unpack, vgui, math, DermaMenu from _G
import DMapLocalPlayerPointer, DMapPlayerPointer, ClientsideWaypoint from DMaps
import \RegisterWaypoints from ClientsideWaypoint

ENABLE_SMOOTH = DMaps.ClientsideOption('smooth_animations', '1', 'Use smooth map animations')
ENABLE_SMOOTH_MOVE = DMaps.ClientsideOption('smooth_animations_mv', '1', 'Use smooth map moving animation')
ENABLE_SMOOTH_ZOOM = DMaps.ClientsideOption('smooth_animations_zoom', '1', 'Use smooth map zoom animation')

MOVE_MULT = CreateConVar('cl_dmaps_wasd_speed', '850', {FCVAR_ARCHIVE}, 'Sensivity of WASD buttons on map')
ZOOM_BIND_MULT = CreateConVar('cl_dmaps_zoom_bind', '25', {FCVAR_ARCHIVE}, 'Sensivity of zoom in/out buttons on map')
SHIFT_MULT = CreateConVar('cl_dmaps_wasd_shift', '2', {FCVAR_ARCHIVE}, 'Sensivity of shift button on map')
CTRL_MULT = CreateConVar('cl_dmaps_wasd_ctrl', '0.5', {FCVAR_ARCHIVE}, 'Sensivity of ctrl button on map')

DMaps.ENABLE_SMOOTH = ENABLE_SMOOTH
DMaps.ENABLE_SMOOTH_MOVE = ENABLE_SMOOTH_MOVE
DMaps.ENABLE_SMOOTH_ZOOM = ENABLE_SMOOTH_ZOOM

DMaps.WatchPermission('teleport')
PANEL = {}

PANEL.GetButtons = =>
	buttons = {}
	for button in *{@compass\CreateControlButtons!} do table.insert(buttons, button)
	return unpack(buttons)

PANEL.Init = =>
	@SetSize(200, 200)
	@mapObject = DMaps.DMap!
	RegisterWaypoints(@mapObject)
	@UpdateMapSizes!
	@SetCursor('hand')
	@hold = false
	
	@mapX = 0
	@mapY = 0
	
	@compass = vgui.Create('DMapsMapCompass', @)
	@compass\SetMap(@mapObject)
	
	@arrows = vgui.Create('DMapsMapArrows', @)
	@arrows\SetMap(@mapObject)
	
	@zoom = vgui.Create('DMapsMapZoom', @)
	@zoom\SetMap(@mapObject)
	
	@bottomClip = vgui.Create('DMapsMapClipBottom', @)
	@bottomClip\SetMap(@mapObject)
	
	@topClip = vgui.Create('DMapsMapClipTop', @)
	@topClip\SetMap(@mapObject)
	
	@mapObject\AddObject(DMapLocalPlayerPointer!)
	@mapObject\CloneNetworkWaypoints()
	@mapObject\ListenNetworkWaypoints()
	@mapObject\WatchMapEntities()
	@mapObject\SetMinimalAutoZoom()

	@caveModeButton = vgui.Create('DButton', @)
	@caveModeButton\SetText('Enable cave mode')
	@caveModeButton\SetTooltip('Enable cave mode')
	@caveModeButton\SetSize(120, 17)
	@caveModeButton.lastStatus = false
	@caveModeButton.DoClick = ->
		@mapObject\SetIsCaveModeEnabled(not @mapObject\IsCaveModeEnabled())
		@Think()
	@caveModeButton.Think = ->
		status = @mapObject\IsCaveModeEnabled()
		if status == @caveModeButton.lastStatus return
		@caveModeButton.lastStatus = status
		text = if status
			'Disable cave mode'
		else
			'Enable cave mode'
		@caveModeButton\SetText(text)
		@caveModeButton\SetTooltip(text)

	@showHelp = true
	@helpAlpha = 1
	@pressedButtons = {}

	@notifications = {}
	
	@SetMouseInputEnabled(true)
	@SetKeyboardInputEnabled(true)
	
	@Spectating = LocalPlayer!
	
	@cursor_lastX = 0
	@cursor_lastY = 0
PANEL.GetMap = => @mapObject

PANEL.AddNotification = (text = '', time = #text / 10) =>
	time = math.Clamp(time, 3, 6)
	rTime = RealTime()
	table.insert(@notifications, {
		:text
		:time
		start: rTime
		startTime: rTime + .5
		endTime: rTime + time
		fadeStart: rTime + time - .5
	})

PANEL.OnKeyCodePressed = (code = KEY_NONE) =>
	return if code == KEY_NONE
	DMaps.UpdateKeysMap()
	x, y = math.floor(@mapObject.mouseX), math.floor(@mapObject.mouseY)
	points = @mapObject\FindInRadius(x, y, 90)
	for point in *points
		return if point\KeyPress(code)

	tr = @mapObject\Trace2DPoint(x, y)
	z = math.floor(tr.HitPos.z + 10)
	
	if DMaps.IsBindDown('help')
		@showHelp = not @showHelp
		return
	if DMaps.IsBindDown('new_point')
		data, id = ClientsideWaypoint.DataContainer\CreateWaypoint("New Waypoint At X: #{x}, Y: #{y}, Z: #{z}", x, y, z)
		DMaps.OpenWaypointEditMenu(id, ClientsideWaypoint.DataContainer, -> ClientsideWaypoint.DataContainer\DeleteWaypoint(id)) if id
		return
	if DMaps.IsBindDown('teleport') and DMaps.HasPermission('teleport')
		tpos = Vector(x, y, z)
		tpos.z += 600
		@mapObject\LockZoom(true)
		@mapObject\LockView(true)
		if ENABLE_SMOOTH\GetBool() and ENABLE_SMOOTH_MOVE\GetBool()
			@mapObject\SetLerpPos(tpos)
		else
			@mapObject\SetPos(tpos)
		RunConsoleCommand('dmaps_teleport', x, y, z)
		return
	if DMaps.IsBindDown('reset')
		@mapObject\LockClip(false)
		@mapObject\LockZoom(false)
		@mapObject\LockView(false)
		return
	if DMaps.IsBindDown('quick_navigation')
		x, y = @mapObject.mouseX, @mapObject.mouseY
		tr = @mapObject\Trace2DPoint(x, y)
		z = math.floor(tr.HitPos.z + 10)
		DMaps.RequireNavigation(Vector(x, y, z))
		return
	if DMaps.IsBindDown('copy_vector')
		x, y = @mapObject.mouseX, @mapObject.mouseY
		tr = @mapObject\Trace2DPoint(x, y)
		z = math.floor(tr.HitPos.z + 10)
		SetClipboardText("Vector(#{x}, #{y}, #{z})")
		@AddNotification("Copied Vector(#{x}, #{y}, #{z})")
		return
	

PANEL.OnMousePressed = (code) =>
	if code == MOUSE_RIGHT
		x, y = math.floor(@mapObject.mouseX), math.floor(@mapObject.mouseY)
		points = @mapObject\FindInRadius(x, y, 90)
		hit = false
		for point in *points
			status = point\OpenMenu()
			if status
				hit = true
				break
		if not hit
			tr = @mapObject\Trace2DPoint(x, y)
			z = math.floor(tr.HitPos.z + 10)
			menu = DermaMenu()
			with menu
				createWaypoint = ->
					data, id = ClientsideWaypoint.DataContainer\CreateWaypoint("New Waypoint At X: #{x}, Y: #{y}, Z: #{z}", x, y, z)
					DMaps.OpenWaypointEditMenu(id, ClientsideWaypoint.DataContainer, -> ClientsideWaypoint.DataContainer\DeleteWaypoint(id)) if id
				\AddOption('Create waypoint...', createWaypoint)\SetIcon(table.Random(DMaps.FLAGS))
				\AddOption('Share position...', -> DMaps.OpenShareMenu(x, y, z))\SetIcon(table.Random(DMaps.FLAGS))
				\AddOption('Navigate to...', -> DMaps.RequireNavigation(Vector(x, y, z)))\SetIcon('icon16/map_go.png') if DMaps.NAV_ENABLE\GetBool()
				\AddOption('Hightlight this postion', ->
					tpos = Vector(x, y, z)
					@mapObject\TargetPosition(tpos)
					tpos.z += 600
					@mapObject\LockZoom(true)
					@mapObject\LockView(true)
					if ENABLE_SMOOTH\GetBool() and ENABLE_SMOOTH_MOVE\GetBool()
						@mapObject\SetLerpPos(tpos)
					else
						@mapObject\SetPos(tpos)
				)\SetIcon(table.Random(DMaps.FLAGS))
				\AddOption('Hightlight...', ->
					final = (text = '') ->
						X, Y, Z = DMaps.ParseCoordinates(text)
						if not X
							Derma_Message('Failed to parse inputted coordinates', 'Hightlight failed', 'Okay')
						else
							tpos = Vector(X, Y, Z)
							@mapObject\TargetPosition(tpos)
							tpos.z += 600
							@mapObject\LockZoom(true)
							@mapObject\LockView(true)
							if ENABLE_SMOOTH\GetBool() and ENABLE_SMOOTH_MOVE\GetBool()
								@mapObject\SetLerpPos(tpos)
							else
								@mapObject\SetPos(tpos)
					Derma_StringRequest('Hightlight...', 'Put coordinates string', '0, 0, 0', final)
				)\SetIcon(table.Random(DMaps.FLAGS))
				\AddOption('Remove highlight', -> @mapObject\StopHighlight())\SetIcon('icon16/cross.png') if @mapObject\HasHighlightPoint()
				\AddOption('Stop navigation', DMaps.StopNavigation)\SetIcon('icon16/map_delete.png') if DMaps.IsNavigating
				\AddOption('Look At', -> LocalPlayer()\SetEyeAngles((Vector(x, y, z) - LocalPlayer()\EyePos())\Angle()))\SetIcon('icon16/arrow_in.png')
				if DMaps.HasPermission('teleport')
					\AddOption('Teleport to', ->
						tpos = Vector(x, y, z)
						tpos.z += 600
						@mapObject\LockZoom(true)
						@mapObject\LockView(true)
						if ENABLE_SMOOTH\GetBool() and ENABLE_SMOOTH_MOVE\GetBool()
							@mapObject\SetLerpPos(tpos)
						else
							@mapObject\SetPos(tpos)
						RunConsoleCommand('dmaps_teleport', x, y, z)
					)\SetIcon('icon16/arrow_in.png')
				hit = false
				sub = \AddSubMenu('Serverside waypoints')

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
				DMaps.CopyMenus(menu, x, y, z)
				\Open()
	elseif code == MOUSE_LEFT
		@hold = true
		x, y = gui.MousePos()
		@SetCursor('sizeall')
		
		@cursor_lastX = x
		@cursor_lastY = y
		
		@mapObject\LockView(true)

PANEL.Release = =>
	@hold = false
	@SetCursor('hand')
	
	@cursor_lastX = 0
	@cursor_lastY = 0

PANEL.OnMouseReleased = (code) =>
	if code == MOUSE_LEFT
		@Release!

PANEL.OnMouseWheeled = (deltaWheel) =>
	@mapObject\LockZoom(true)
	@mapObject\LockView(true)
	addZoom = -deltaWheel * math.max(math.abs(@mapObject\GetZoom()), 100) * 0.1
	if ENABLE_SMOOTH\GetBool() and ENABLE_SMOOTH_ZOOM\GetBool()
		@mapObject\AddLerpZoom(addZoom)
	else
		@mapObject\AddZoom(addZoom) 
	
	mult = @mapObject\GetZoomMultiplier! * 0.05
	yawDeg = @mapObject\GetYaw!
	w, h = @GetSize!
	centerX, centerY = @LocalToScreen(w / 2, h / 2)
	
	yaw = math.rad(-yawDeg)
	sin, cos = math.sin(yaw), math.cos(yaw)
	x, y = gui.MousePos()
	
	deltaX = x - centerX
	deltaY = y - centerY
	
	bMoveX = deltaX * mult
	bMoveY = deltaY * mult
	
	moveX = bMoveX * cos - bMoveY * sin
	moveY = bMoveY * cos + bMoveX * sin
	
	if yawDeg < -180
		moveX = -moveX
		moveY = -moveY
	
	if ENABLE_SMOOTH\GetBool() and ENABLE_SMOOTH_MOVE\GetBool()
		if deltaWheel < 0
			@mapObject\AddLerpX(-moveX)
			@mapObject\AddLerpY(moveY)
		else
			@mapObject\AddLerpX(moveX)
			@mapObject\AddLerpY(-moveY)
	else
		if deltaWheel < 0
			@mapObject\AddX(-moveX)
			@mapObject\AddY(moveY)
		else
			@mapObject\AddX(moveX)
			@mapObject\AddY(-moveY)

PANEL.UpdateMapSizes = =>
	@mapObject\SetSize(@GetSize!)

PANEL.PerformLayout = (w, h) =>
	@mapObject\SetSize(w, h)
	@mapObject\SetDrawPos(@LocalToScreen(0, 0))
	
	min = math.min(w, h)
	guiMult = min / 800
	@arrows\SetSizeMult(guiMult)
	@compass\SetSizeMult(guiMult)
	@zoom\SetSizeMult(guiMult)
	@bottomClip\SetSizeMult(guiMult)
	@topClip\SetSizeMult(guiMult)

	@compass\SetPos(20, h - @compass.HEIGHT - 20)
	@arrows\SetPos(w - @arrows.WIDTH - 25, 10)
	@zoom\SetPos(w - @arrows.WIDTH / 2 - @zoom.WIDTH, @arrows.HEIGHT + 40)
	@bottomClip\SetPos(w - @arrows.WIDTH / 2 - @zoom.WIDTH - 10, @arrows.HEIGHT + 60 + @zoom.HEIGHT)
	@topClip\SetPos(w - @arrows.WIDTH / 2 - @zoom.WIDTH + @bottomClip.WIDTH + 10, @arrows.HEIGHT + 60 + @zoom.HEIGHT)
	@caveModeButton\SetPos(w - @arrows.WIDTH / 2 - @zoom.WIDTH - 40, @arrows.HEIGHT + 80 + @zoom.HEIGHT + @topClip.HEIGHT)

PANEL.Think = =>
	if not @IsHovered!
		@Release!
	
	mouseX, mouseY = gui.MousePos()
	w, h = @GetSize!
	cX, cY = @LocalToScreen(w / 2, h / 2)
	
	sw, sh = ScrW!, ScrH!
	
	with @mapObject
		getX, getY = \ScreenToMap((mouseX - cX) / w * sw, (cY - mouseY) / h * sh)
		\SetMousePos(getX, getY)
		\PanelScreenPos(@LocalToScreen(0, 0))
		\Think!
		\StandartThink!
		\ThinkPlayer(@Spectating)
		
		@mapX, @mapY = math.floor(getX), math.floor(getY)
	
	if @hold
		x, y = mouseX, mouseY
		deltaX = x - @cursor_lastX
		deltaY = y - @cursor_lastY
		
		if deltaX ~= 0 or deltaY ~= 0
			yawDeg = @mapObject\GetYaw!
			yaw = math.rad(yawDeg)
			sin, cos = math.sin(yaw), math.cos(yaw)
			
			@cursor_lastX = x
			@cursor_lastY = y
			
			bMoveX = -deltaX * @mapObject.xHUPerPixel * (@mapObject\DeltaZoomMultiplier! ^ 2) * @mapObject.__class.CONSTANT_ZOOM_MOVE
			bMoveY = deltaY * @mapObject.yHUPerPixel * (@mapObject\DeltaZoomMultiplier! ^ 2) * @mapObject.__class.CONSTANT_ZOOM_MOVE
			
			moveX = bMoveX * cos - bMoveY * sin
			moveY = bMoveX * sin + bMoveY * cos
			
			if yawDeg < -180
				moveX = -moveX
				moveY = -moveY
			
			if ENABLE_SMOOTH\GetBool() and ENABLE_SMOOTH_MOVE\GetBool()
				@mapObject\AddLerpX(moveX)
				@mapObject\AddLerpY(moveY)
			else
				@mapObject\AddX(moveX)
				@mapObject\AddY(moveY)
	do
		bMoveX = 0
		bMoveY = 0

		mult = 1
		multY = 1

		deltaZoom = 0

		if DMaps.IsBindDown('speed')
			mult *= SHIFT_MULT\GetFloat()

		if DMaps.IsBindDown('duck')
			mult *= CTRL_MULT\GetFloat()
		
		if DMaps.IsBindDown('zoomin')
			deltaZoom = -FrameTime() * ZOOM_BIND_MULT\GetInt()
		
		if DMaps.IsBindDown('zoomout')
			deltaZoom = FrameTime() * ZOOM_BIND_MULT\GetInt()
		
		if DMaps.IsBindDown('left')
			bMoveX -= FrameTime() * MOVE_MULT\GetInt()
		if DMaps.IsBindDown('right')
			bMoveX += FrameTime() * MOVE_MULT\GetInt()
		if DMaps.IsBindDown('up')
			bMoveY += FrameTime() * MOVE_MULT\GetInt()
		if DMaps.IsBindDown('down')
			bMoveY -= FrameTime() * MOVE_MULT\GetInt()
		
		bMoveX *= mult
		bMoveY *= mult
		deltaZoom *= mult

		if bMoveX ~= 0 or bMoveY ~= 0
			@mapObject\LockView(true)
			yawDeg = @mapObject\GetYaw!
			yaw = math.rad(yawDeg)
			sin, cos = math.sin(yaw), math.cos(yaw)
			
			bMoveX *= @mapObject.xHUPerPixel * (@mapObject\DeltaZoomMultiplier! ^ 2) * @mapObject.__class.CONSTANT_ZOOM_MOVE
			bMoveY *= @mapObject.yHUPerPixel * (@mapObject\DeltaZoomMultiplier! ^ 2) * @mapObject.__class.CONSTANT_ZOOM_MOVE

			moveX = bMoveX * cos - bMoveY * sin
			moveY = bMoveX * sin + bMoveY * cos
			
			if yawDeg < -180
				moveX = -moveX
				moveY = -moveY
			
			if ENABLE_SMOOTH\GetBool() and ENABLE_SMOOTH_MOVE\GetBool()
				@mapObject\AddLerpX(moveX)
				@mapObject\AddLerpY(moveY)
			else
				@mapObject\AddX(moveX)
				@mapObject\AddY(moveY)
		if deltaZoom ~= 0
			@mapObject\LockZoom(true)
			@mapObject\LockView(true)
			addZoom = deltaZoom * math.max(math.abs(@mapObject\GetZoom()), 100) * 0.1
			if ENABLE_SMOOTH\GetBool() and ENABLE_SMOOTH_ZOOM\GetBool()
				@mapObject\AddLerpZoom(addZoom)
			else
				@mapObject\AddZoom(addZoom) 
	
PANEL.Paint = (w, h) =>
	with surface
		.SetDrawColor(0, 0, 0)
		.DrawRect(0, 0, w, h)
	
	@mapObject\IsDrawnInPanel(true)
	@mapObject\SetWidth(w)
	@mapObject\SetHeight(h)
	
	@mapObject\SetDrawPos(@LocalToScreen(0, 0))
	@mapObject\DrawHook!
	
	with surface
		.SetDrawColor(0, 0, 0, 100)
		.SetTextColor(255, 255, 255)
		.SetFont('Default')
		text = "X: #{@mapX}; Y: #{@mapY}"
		tw, th = .GetTextSize(text)
		.DrawRect(w - tw - 8, h - th - 8, tw + 8, th + 8)
		.SetTextPos(w - tw - 4, h - th - 4)
		.DrawText(text)
		@helpAlpha = math.min(@helpAlpha + FrameTime() * 3, 1) if @showHelp and @helpAlpha ~= 1
		@helpAlpha = math.max(@helpAlpha - FrameTime() * 3, 0) if not @showHelp and @helpAlpha ~= 0
		if @helpAlpha > 0
			text = "Drag map using your mouse or #{DMaps.GetBindString('up')}, #{DMaps.GetBindString('down')}, #{DMaps.GetBindString('left')}, #{DMaps.GetBindString('down')}\nSingle click on controler to reset it's value; or press #{DMaps.GetBindString('reset')}\nJoystick resets map position\nCompass resets map angles\nBars at right resets map zoom/clip levels\nPress #{DMaps.GetBindString('help')} to hide/show this help"
			tw, th = .GetTextSize(text)
			.SetDrawColor(0, 0, 0, 100 * @helpAlpha)
			.DrawRect(w / 2 - tw / 2 - 4, 0, tw + 8, th + 8)
			draw.DrawText(text, 'Default', w / 2, 4, Color(255, 255, 255, 255 * @helpAlpha), TEXT_ALIGN_CENTER)
	
	rTime = RealTime()
	shiftY = 0
	for i, {:text, :time, :start, :endTime, :fadeStart, :startTime} in pairs @notifications
		if endTime < rTime
			@notifications[i] = nil
			continue
		alpha = 1
		alpha = math.Clamp((0.5 - (startTime - rTime))  * 2, 0, 1) if startTime > rTime
		alpha = math.Clamp((endTime - rTime) * 2, 0, 1) if fadeStart < rTime
		tw, th = surface.GetTextSize(text)
		surface.SetDrawColor(0, 0, 0, 100 * alpha)
		surface.DrawRect(6, 0, tw + 8, th + 8 + shiftY)
		draw.DrawText(text, 'Default', 10, 4 + shiftY, Color(255, 255, 255, 255 * alpha))
		shiftY += th + 8
	
PANEL.OnRemove = =>
	@mapObject\Remove!

DMaps.PANEL_ABSTRACT_MAP_HOLDER = PANEL
vgui.Register('DMapsMapHolder', DMaps.PANEL_ABSTRACT_MAP_HOLDER, 'EditablePanel')
return PANEL
