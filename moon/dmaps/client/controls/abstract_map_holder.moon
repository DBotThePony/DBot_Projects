
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
	
	@SetMouseInputEnabled(true)
	
	@Spectating = LocalPlayer!
	
	@cursor_lastX = 0
	@cursor_lastY = 0
	@svWaypoints = {
		DMaps.ServerWaypointsContainer
		DMaps.ServerWaypointsContainerCAMI
		DMaps.ServerWaypointsContainerTeam
		DMaps.ServerWaypointsContainerUsergroups
	}
PANEL.GetMap = => @mapObject

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
				\AddOption('Create waypoint...', createWaypoint)
				\AddOption('Navigate to...', -> DMaps.RequireNavigation(Vector(x, y, z))) if DMaps.NAV_ENABLE\GetBool()
				if DMaps.HasPermission('teleport')
					\AddOption('Teleport to', -> RunConsoleCommand('dmaps_teleport', x, y, z))
				hit = false
				sub = \AddSubMenu('Serverside waypoints')

				for container in *@svWaypoints
					if DMaps.HasPermission(container.__PERM_EDIT) and DMaps.HasPermission(container.__PERM_VIEW)
						hit = true
						sub\AddOption "Create #{container._NAME_ON_PANEL} waypoint", ->
							containerObject = container\GetContainer()
							if not container\IsValid()
								containerObject = container(false, false)
								net.Start(container.NETWORK_STRING)
								net.SendToServer()
							containerObject\OpenEditMenu(container\GenerateData(x, y, z))
				sub\Remove() if not hit
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
	
PANEL.OnRemove = =>
	@mapObject\Remove!

DMaps.PANEL_ABSTRACT_MAP_HOLDER = PANEL
vgui.Register('DMapsMapHolder', DMaps.PANEL_ABSTRACT_MAP_HOLDER, 'EditablePanel')
return PANEL
