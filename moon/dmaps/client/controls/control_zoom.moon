
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

CONTROL_LOCKED = DMaps.CreateColor(230, 230, 230, 'zoom_locked', 'Zoom control "Locked"')
CONTROL_UNLOCKED = DMaps.CreateColor(170, 170, 170, 'zoom_unlocked', 'Zoom control "Unlocked"')
CONTROL_TOOBIG = DMaps.CreateColor(80, 80, 170, 'zoom_big', 'Zoom control "Too big"')
CONTROL_BACKGROUND = DMaps.CreateColor(40, 40, 40, 'zoom_background', 'Zoom control background')

ENABLE_SMOOTH = DMaps.ClientsideOption('smooth_animations', '1', 'Use smooth map animations')
ENABLE_SMOOTH_ZOOM = DMaps.ClientsideOption('smooth_animations_zoom', '1', 'Use smooth map zoom animation')
ENABLE_SMOOTH_ZOOM_BAR = DMaps.ClientsideOption('smooth_animations_bzoom', '1', 'Use smooth map ZOOM BAR animation')

IsSmooth = -> ENABLE_SMOOTH\GetBool() and ENABLE_SMOOTH_ZOOM\GetBool() and ENABLE_SMOOTH_ZOOM_BAR\GetBool()

PANEL = {}

PANEL.WIDTH = 48
PANEL.HEIGHT = 256
PANEL.MIN_ZOOM = 300
PANEL.MAX_ZOOM = 3000
PANEL.DELTA_ZOOM = PANEL.MAX_ZOOM - PANEL.MIN_ZOOM
PANEL.MULT_ADD = PANEL.MIN_ZOOM / PANEL.DELTA_ZOOM

PANEL.Init = =>
	@zoom = 0
	@displayZoom = 0
	@hold = false
	@lock = false
	@holdstart = 0
	@SetSize(@WIDTH, @HEIGHT)

PANEL.SetSizeMult = (mult = 1) =>
	@sizeMult = mult
	@WIDTH = 48 * mult
	@HEIGHT = 256 * mult
	@SetSize(@WIDTH, @HEIGHT)

PANEL.OnMousePressed = (code) =>
	if code == MOUSE_RIGHT or code == MOUSE_MIDDLE
		@lock = false
		@mapObject\LockZoom(false)
	elseif code == MOUSE_LEFT
		@hold = true
		@lock = true
		@holdstart = RealTime!

PANEL.OnMouseReleased = (code) =>
	if code == MOUSE_LEFT
		@hold = false
		if @holdstart + 0.1 > RealTime!
			@lock = false
			@mapObject\LockZoom(false)
	
PANEL.SetMap = (map) =>
	@mapObject = map
	@zoom = @mapObject\GetZoom!
	@displayZoom = @zoom
	@lock = @mapObject\GetLockZoom!

PANEL.OnYawChanges = =>
	@mapObject\SetYaw(@yaw)

PANEL.Think = =>
	@lock = @mapObject\GetLockZoom!
	
	holdingEnough = @hold and @holdstart + 0.1 < RealTime!
		
	if not @IsHovered!
		@hold = false
		holdingEnough = false
	
	if holdingEnough
		@lock = true
		@mapObject\LockZoom(true)
	
	if @lock
		if holdingEnough
			w, h = @GetSize!
			hw, hh = w / 2, h / 2
			
			centerX, centerY = @LocalToScreen(hw, h)
			x, y = gui.MousePos()
			
			deltaX = x - centerX
			deltaY = centerY - y
			
			if deltaX < hw and deltaX > -hw and deltaY > 0 and deltaY < h
				@zoom = @DELTA_ZOOM * deltaY / h + @MIN_ZOOM
				if IsSmooth()
					@mapObject\SetZoom(Lerp(0.1, @mapObject\GetZoom!, @zoom))
				else
					@mapObject\SetZoom(@zoom)
		else
			@zoom = @mapObject\GetZoom!
	else
		@zoom = @mapObject\GetZoom!
	
	if IsSmooth()
		@displayZoom = Lerp(0.1, @displayZoom, @zoom)
	else
		@displayZoom = @zoom

PANEL.Paint = (w, h) =>
	draw.NoTexture!
	
	-- Background
	surface.SetDrawColor(CONTROL_BACKGROUND())
	surface.DrawRect(3, 0, w - 6, h)
	
	step = h / 14
	
	surface.SetDrawColor(0, 0, 0)
	
	-- Visual step markers
	for i = step, h, step
		surface.DrawRect(5, i, w - 10, 4 * @sizeMult)
	
	if @lock
		surface.SetDrawColor(CONTROL_LOCKED())
	else
		surface.SetDrawColor(CONTROL_UNLOCKED())
	
	mult = (1 - @displayZoom / @DELTA_ZOOM)
	
	if mult >= -0.1
		surface.DrawRect(0, math.min(mult * h + 30, h - @sizeMult * 10), w, 10 * @sizeMult)
	else
		surface.SetDrawColor(CONTROL_TOOBIG())
		surface.DrawRect(0, 0, w, 10 * @sizeMult)

DMaps.PANEL_MAP_ZOOM = PANEL
vgui.Register('DMapsMapZoom', DMaps.PANEL_MAP_ZOOM, 'EditablePanel')
return PANEL
