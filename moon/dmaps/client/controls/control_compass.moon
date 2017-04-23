
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

import draw, surface, LocalPlayer, gui, CreateConVar, DMaps from _G

COLOR_OUTER = DMaps.CreateColor(40, 70, 180, 'compass_outer', 'Compass outer')
COLOR_INNER = DMaps.CreateColor(200, 200, 200, 'compass_inner', 'Compass inner')
COLOR_NORTH = DMaps.CreateColor(255, 0, 0, 'color_north', 'Compass north part')
COLOR_SOUTH = DMaps.CreateColor(230, 230, 230, 'color_south', 'Compass south part')

generateTriangle = (x = 0, y = 0, ang = 0, hypo = 30) ->
	sin = math.sin(math.rad(ang))
	cos = math.cos(math.rad(ang))
	
	hypo *= 0.5
	
	Ax, Ay = -hypo * sin, hypo * cos
	Bx, By = hypo * cos * 2, hypo * sin * 2
	Cx, Cy = hypo * sin, -hypo * cos
	
	trigData = {
		{x: x + Cx, y: y + Cy}
		{x: x + Bx, y: y + By}
		{x: x + Ax, y: y + Ay}
	}
	
	return trigData

generateCircle = (x = 0, y = 0, radius = 0) ->
	reply = {}
	
	table.insert(reply, {:x, :y, u: 0.5, v: 0.5})
	
	for i = 0, 60 do
		rad = math.rad((i / 60) * -360)
		sin, cos = math.sin(rad), math.cos(rad)
		
		data = {
			x: x + sin * radius
			y: y + cos * radius
			u: sin / 2 + 0.5
			v: cos / 2 + 0.5
		}
		
		table.insert(reply, data)

	table.insert(reply, {:x, y: y + radius, u: 0.5, v: 1})
	return reply

PANEL = {}

PANEL.BACKGROUND_COLOR = Color(0, 0, 0, 150)
PANEL.WIDTH = 96
PANEL.HEIGHT = 96
PANEL.DIV = 64

PANEL.SetSizeMult = (mult = 1) =>
	@sizeMult = mult
	@WIDTH = 96 * mult
	@HEIGHT = 96 * mult
	@SetSize(@WIDTH, @HEIGHT)
	@UpdateCache(true)

PANEL.CreateControlButtons = =>
	buttonFollowAngles = vgui.Create('DButton')
	buttonFollowAngles\SetText('Follow player direction')
	buttonFollowAngles\SetTooltip('Follow player direction')
	
	lastStatus = @followingPlayer
	
	buttonFollowAngles.compass = @
	buttonFollowAngles.DoClick = =>
		@compass.followingPlayer = not @compass.followingPlayer
		@Think!
	
	buttonFollowAngles.Think = =>
		if lastStatus ~= @compass.followingPlayer
			lastStatus = @compass.followingPlayer
			if lastStatus
				@SetText('Stop following player direction')
				@SetTooltip('Stop following player direction')
			else
				@SetText('Follow player direction')
				@SetTooltip('Follow player direction')
	
	return buttonFollowAngles

PANEL.Init = =>
	@UpdateCache!
	@yaw = 0
	@SetSize(96, 96)
	@targetyaw = 0
	
	@followingPlayer = false
	@hold = false
	@holdstart = 0

PANEL.OnMousePressed = (code) =>
	if code == MOUSE_RIGHT or code == MOUSE_MIDDLE
		@targetyaw = 0
		@followingPlayer = false
	elseif code == MOUSE_LEFT
		@hold = true
		@followingPlayer = false
		@holdstart = RealTime!

PANEL.OnMouseReleased = (code) =>
	if code == MOUSE_LEFT
		@hold = false
		if @holdstart + 0.1 > RealTime!
			@targetyaw = 0
			@followingPlayer = false
	
PANEL.SetMap = (map) =>
	@mapObject = map
	@yaw = @mapObject\GetYaw!
	@targetyaw = @yaw
	@UpdateCache!

PANEL.OnYawChanges = =>
	@mapObject\SetYaw(@yaw)
	@BuildTriangle!

PANEL.Think = =>
	if @followingPlayer
		@targetyaw = LocalPlayer!\GetAngles!.y - 90
	
	if @hold
		if @holdstart + 0.1 < RealTime!
			w, h = @GetSize!
			
			centerX, centerY = @LocalToScreen(w / 2, h / 2)
			x, y = gui.MousePos()
			
			deltaX = x - centerX
			deltaY = centerY - y
			
			if deltaX < 64 and deltaX > -64 and deltaY < 64 and deltaY > -64
				forward = deltaX / ((deltaX ^ 2 + deltaY ^ 2) ^ 0.5)
				if forward == forward -- Divide by zero
					ang = math.deg(math.acos(-forward))
					
					if deltaY < 0 then ang = -ang
					@targetyaw = ang - 90
	
	if @yaw ~= @targetyaw
		@yaw += math.AngleDifference(@targetyaw, @yaw) * 0.2
		
		if @yaw < -180
			@yaw = 180
		elseif @yaw > 180
			@yaw = -180
		
		@OnYawChanges!
	
	if @mapObject\GetYaw! ~= @yaw
		@mapObject\SetYaw(@yaw)

PANEL.UpdateCache = (force = false) =>
	@BuildCircle(force)
	@BuildTriangle(force)

PANEL.InvalidateLayout = =>
	@UpdateCache!

PANEL.BuildTriangle = (force = false) =>
	if @__cahcedTopYaw ~= @yaw or force
		@__cahcedTopYaw = @yaw
		w, h = @WIDTH, @HEIGHT
		@northPart = generateTriangle(w / 2, h / 2, @yaw - 90, w / 2.5)
	
	if @__cahcedBottomYaw ~= @yaw or force
		@__cahcedBottomYaw = @yaw
		w, h = @WIDTH, @HEIGHT
		@southPart = generateTriangle(w / 2, h / 2, @yaw + 90, w / 2.5)
	
PANEL.BuildCircle = =>
	w, h = @WIDTH, @HEIGHT
	
	x = w / 2
	y = h / 2
	
	@circleOuter = generateCircle(x, y, @WIDTH / 2)
	@circleInner = generateCircle(x, y, @WIDTH / 2 - @WIDTH * 0.05)

PANEL.Paint = (w, h) =>
	draw.NoTexture!

	surface.SetDrawColor(COLOR_OUTER())
	surface.DrawPoly(@circleOuter)
	
	surface.SetDrawColor(COLOR_INNER())
	surface.DrawPoly(@circleInner)
	
	surface.SetDrawColor(COLOR_NORTH())
	surface.DrawPoly(@northPart)
	
	surface.SetDrawColor(COLOR_SOUTH())
	surface.DrawPoly(@southPart)

DMaps.PANEL_MAP_COMPASS = PANEL
vgui.Register('DMapsMapCompass', DMaps.PANEL_MAP_COMPASS, 'EditablePanel')
return PANEL
