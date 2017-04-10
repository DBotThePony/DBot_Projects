
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

-- Nope, its a joystick! Haha!

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
PANEL.INNER_COLOR = Color(170, 170, 170)
PANEL.OUTER_COLOR = Color(190, 190, 190)
PANEL.WIDTH = 96
PANEL.HEIGHT = 96
PANEL.DIV = 96 / 2
PANEL.DIV2 = 96 / 2.5

PANEL.Init = =>
	@SetSize(96, 96)
	
	@joystickPosX = 0
	@joystickPosY = 0
	
	@hold = false
	@move = false
	@holdstart = 0
	@UpdateCache!

PANEL.OnMousePressed = (code) =>
	if code == MOUSE_RIGHT or code == MOUSE_MIDDLE
		@hold = false
		@holdstart = 0
		@mapObject\LockView(false)
	elseif code == MOUSE_LEFT
		@hold = true
		@holdstart = RealTime!

PANEL.OnMouseReleased = (code) =>
	if code == MOUSE_LEFT
		@hold = false
		
		if @holdstart + 0.1 > RealTime!
			@mapObject\LockView(false)
	
PANEL.SetMap = (map) =>
	@mapObject = map

PANEL.Think = =>
	if not @mapObject return
	
	if @hold
		@move = @holdstart + 0.1 < RealTime!
		w, h = @GetSize!
		
		centerX, centerY = @LocalToScreen(w / 2, h / 2)
		x, y = gui.MousePos()
		
		deltaX = x - centerX
		deltaY = y - centerY
		
		dist = ((deltaX ^ 2) + (deltaY ^ 2)) ^ 0.5
		
		lineX = deltaX
		lineY = deltaY
		
		if dist > @DIV2
			lineX = deltaX / ((deltaX ^ 2 + deltaY ^ 2) ^ 0.5) * @DIV2
			lineY = deltaY / ((deltaX ^ 2 + deltaY ^ 2) ^ 0.5) * @DIV2
		
		if deltaX < @DIV and deltaX > -@DIV and deltaY < @DIV and deltaY > -@DIV
			@joystickPosX = Lerp(0.1, @joystickPosX, lineX)
			@joystickPosY = Lerp(0.1, @joystickPosY, lineY)
		else
			@joystickPosX = Lerp(0.1, @joystickPosX, 0)
			@joystickPosY = Lerp(0.1, @joystickPosY, 0)
	else
		@joystickPosX = Lerp(0.1, @joystickPosX, 0)
		@joystickPosY = Lerp(0.1, @joystickPosY, 0)
	
	if @joystickPosX ~= 0 or @joystickPosY ~= 0
		@UpdateCache!
		
		if @move
			yawDeg = @mapObject\GetYaw!
			yaw = math.rad(yawDeg)
			sin, cos = math.sin(yaw), math.cos(yaw)
			mult = @mapObject\GetZoomMultiplier! * 0.1
			
			bMoveX = @joystickPosX * mult
			bMoveY = -@joystickPosY * mult
			
			moveX = bMoveX * cos - bMoveY * sin
			moveY = bMoveX * sin + bMoveY * cos
			
			if yawDeg < -180
				moveX = -moveX
				moveY = -moveY
			
			@mapObject\AddX(moveX)
			@mapObject\AddY(moveY)
			@mapObject\LockView(true)

PANEL.UpdateCache = =>
	w, h = @WIDTH, @HEIGHT
	
	if not @circleInner
		@circleInner = generateCircle(w / 2, h / 2, w / 2.5)
		
	if not @circleOuter
		@circleOuter = generateCircle(w / 2, h / 2, w / 2)
	
	@joysticks = {}
	
	for i = 0, 6, 1
		table.insert(@joysticks, {generateCircle(w / 2 + @joystickPosX, h / 2 + @joystickPosY, 16 - i), Color(230 - i * 2, 230 - i * 2, 230 - i * 2)})

PANEL.InvalidateLayout = =>
	@UpdateCache!

PANEL.Paint = (w, h) =>
	draw.NoTexture!
	
	--surface.SetDrawColor(@BACKGROUND_COLOR)
	--surface.DrawRect(0, 0, w, h)
	
	surface.SetDrawColor(@OUTER_COLOR)
	surface.DrawPoly(@circleOuter)
	
	surface.SetDrawColor(@INNER_COLOR)
	surface.DrawPoly(@circleInner)
	
	for i, joystickPart in pairs @joysticks
		surface.SetDrawColor(joystickPart[2])
		surface.DrawPoly(joystickPart[1])
	

DMaps.PANEL_MAP_ARROWS = PANEL
return PANEL
