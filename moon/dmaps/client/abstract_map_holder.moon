
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

import DMapLocalPlayerPointer, DMapPlayerPointer from DMaps

PANEL = {}

PANEL.Init = =>
	@SetSize(200, 200)
	@mapObject = DMaps.DMap!
	@UpdateMapSizes!
	@SetCursor('hand')
	@hold = false
	
	@compass = vgui.Create('DMapsMapCompass', @)
	@compass\SetMap(@mapObject)
	
	@arrows = vgui.Create('DMapsMapArrows', @)
	@arrows\SetMap(@mapObject)
	
	@zoom = vgui.Create('DMapsMapZoom', @)
	@zoom\SetMap(@mapObject)
	
	@mapObject\IsDrawnInPanel(true)
	@mapObject\AddObject(DMapLocalPlayerPointer!)
	
	@SetMouseInputEnabled(true)
	
	@Spectating = LocalPlayer!
	
	@cursor_lastX = 0
	@cursor_lastY = 0

PANEL.OnMousePressed = (code) =>
	if code == MOUSE_LEFT
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
	@mapObject\AddZoom(-deltaWheel * math.max(math.abs(@mapObject\GetZoom!), 100) * 0.1)
	
	mult = @mapObject\GetZoomMultiplier! * 0.019
	yawDeg = @mapObject\GetYaw!
	yaw = math.rad(yawDeg)
	sin, cos = math.sin(yaw), math.cos(yaw)
	
	x, y = gui.MousePos()
	
	deltaX = x - ScrW! / 2
	deltaY = y - ScrH! / 2
	
	bMoveX = deltaX * mult
	bMoveY = deltaY * mult
	
	--moveX = bMoveX * cos - bMoveY * sin
	--moveY = bMoveX * sin + bMoveY * cos
	
	moveX = bMoveX
	moveY = bMoveY
	
	--if @mapObject\GetRealYaw! < 0
	--	moveX = -moveX
	--	moveY = -moveY
	
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
	
	@compass\SetPos(0, h - @compass.HEIGHT)
	@arrows\SetPos(w - @arrows.WIDTH - 25, 10)
	@zoom\SetPos(w - @zoom.WIDTH - 40, @arrows.HEIGHT + 40)

PANEL.Think = =>
	if not @IsHovered!
		@Release!
	
	@mapObject\PanelScreenPos(@LocalToScreen(0, 0))
	@mapObject\Think!
	@mapObject\ThinkPlayer(@Spectating)
	
	existingPlayers = {}
	
	for k, obj in pairs @mapObject.players
		if IsValid(obj\GetEntity!)
			existingPlayers[obj\GetEntity!] = obj\GetEntity!
	
	for k, ply in pairs player.GetAll!
		if existingPlayers[ply] then continue
		@mapObject\AddObject(DMapPlayerPointer(ply))
	
	if @hold
		x, y = gui.MousePos()
		deltaX = x - @cursor_lastX
		deltaY = y - @cursor_lastY
		
		if deltaX ~= 0 or deltaY ~= 0
			yawDeg = @mapObject\GetYaw!
			yaw = math.rad(yawDeg)
			sin, cos = math.sin(yaw), math.cos(yaw)
			
			@cursor_lastX = x
			@cursor_lastY = y
			
			mult = @mapObject\GetZoomMultiplier! * 0.125
			
			bMoveX = -deltaX * mult
			bMoveY = deltaY * mult
			
			moveX = bMoveX * cos - bMoveY * sin
			moveY = bMoveX * sin + bMoveY * cos
			
			if yawDeg < -180
				moveX = -moveX
				moveY = -moveY
			
			@mapObject\AddX(moveX)
			@mapObject\AddY(moveY)
		
	
PANEL.Paint = (w, h) =>
	surface.SetDrawColor(0, 0, 0)
	surface.DrawRect(0, 0, w, h)
	
	@mapObject\SetWidth(w)
	@mapObject\SetHeight(h)
	
	@mapObject\SetDrawPos(@LocalToScreen(0, 0))
	@mapObject\DrawHook!
	
PANEL.OnRemove = =>
	@mapObject\Remove!

DMaps.PANEL_ABSTRACT_MAP_HOLDER = PANEL
return PANEL
