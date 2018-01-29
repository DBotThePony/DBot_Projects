
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

CONTROL_LOCKED = DMaps.CreateColor(230, 230, 230, 'clip_locked', 'Clip control "Locked"')
CONTROL_UNLOCKED = DMaps.CreateColor(170, 170, 170, 'clip_unlocked', 'Clip control "Unlocked"')
CONTROL_TOOBIG = DMaps.CreateColor(80, 80, 170, 'clip_big', 'Clip control "Too big"')
CONTROL_BACKGROUND = DMaps.CreateColor(40, 40, 40, 'clip_background', 'Clip control background')

ENABLE_SMOOTH = DMaps.ClientsideOption('smooth_animations', '1', 'Use smooth map animations')
ENABLE_SMOOTH_CLIP_BAR = DMaps.ClientsideOption('smooth_animations_bclip', '1', 'Use smooth map Clip BAR animation')

IsSmooth = -> ENABLE_SMOOTH\GetBool() and ENABLE_SMOOTH_CLIP_BAR\GetBool()

PANEL =
	WIDTH: 24
	HEIGHT: 128
	MAXIMAL: -1200

	Init: =>
		@level = 0
		@displayLevel = 0
		@hold = false
		@lock = false
		@holdstart = 0
		@DELTA = 0
		@START = 0
		@END = 0
		@SetSize(@WIDTH, @HEIGHT)
		@SetTooltip('Single click to reset map bottom clip level')

	SetSizeMult: (mult = 1) =>
		@sizeMult = mult
		@WIDTH = 24 * mult
		@HEIGHT = 128 * mult
		@SetSize(@WIDTH, @HEIGHT)

	OnMousePressed: (code) =>
		if code == MOUSE_RIGHT or code == MOUSE_MIDDLE
			@lock = false
			@mapObject\LockClip(false)
		elseif code == MOUSE_LEFT
			@hold = true
			@lock = true
			@holdstart = RealTime!

	OnMouseReleased: (code) =>
		if code == MOUSE_LEFT
			@hold = false
			if @holdstart + 0.1 > RealTime()
				@lock = false
				@mapObject\LockClip(false)
		
	SetMap: (map) =>
		@mapObject = map
		@level = @mapObject\GetClipLevelBottom()
		@displayLevel = @level
		@lock = @mapObject\GetLockClip()

	Think: =>
		@lock = @mapObject\GetLockClip()
		@LIMIT = @mapObject\GetClipLevelTop() - 5
		@START = @MAXIMAL - @LIMIT
		@END = @LIMIT
		@DELTA = @END - @START
		
		holdingEnough = @hold and @holdstart + 0.1 < RealTime!
			
		if not @IsHovered()
			@hold = false
			holdingEnough = false
		
		if holdingEnough
			@lock = true
			@mapObject\LockClip(true)
		
		if @lock
			if holdingEnough
				w, h = @GetSize()
				hw, hh = w / 2, h / 2
				
				centerX, centerY = @LocalToScreen(hw, h)
				x, y = gui.MousePos()
				
				deltaX = x - centerX
				deltaY = centerY - y
				
				if deltaX < hw and deltaX > -hw and deltaY > 0 and deltaY < h
					@level = math.Clamp(@START + @DELTA * deltaY / h, @START, @END)
					if IsSmooth()
						@mapObject\SetClipLevelBottom(Lerp(0.1, @mapObject\GetClipLevelBottom(), @level))
					else
						@mapObject\SetClipLevelBottom(@level)
			else
				@level = @mapObject\GetClipLevelBottom()
		else
			@level = @mapObject\GetClipLevelBottom()
		
		if IsSmooth()
			@displayLevel = Lerp(0.1, @displayLevel, @level)
		else
			@displayLevel = @level

	Paint: (w, h) =>
		draw.NoTexture()
		
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
		
		mult = (1 - (@displayLevel - @START) / @DELTA) - .2
		
		if mult >= -0.2
			surface.DrawRect(0, math.min(mult * h + 30, h - @sizeMult * 10), w, 4 * @sizeMult)
		else
			surface.SetDrawColor(CONTROL_TOOBIG())
			surface.DrawRect(0, 0, w, 4 * @sizeMult)

DMaps.PANEL_MAP_CLIP_BOTTOM = PANEL
vgui.Register('DMapsMapClipBottom', DMaps.PANEL_MAP_CLIP_BOTTOM, 'EditablePanel')

PANEL =
	WIDTH: 24
	HEIGHT: 128
	MAXIMAL: 2500

	Init: =>
		@level = 0
		@displayLevel = 0
		@hold = false
		@lock = false
		@holdstart = 0
		@DELTA = 0
		@START = 0
		@END = 0
		@SetSize(@WIDTH, @HEIGHT)
		@SetTooltip('Single click to reset map top clip level')

	SetSizeMult: (mult = 1) =>
		@sizeMult = mult
		@WIDTH = 24 * mult
		@HEIGHT = 128 * mult
		@SetSize(@WIDTH, @HEIGHT)

	OnMousePressed: (code) =>
		if code == MOUSE_RIGHT or code == MOUSE_MIDDLE
			@lock = false
			@mapObject\LockClip(false)
		elseif code == MOUSE_LEFT
			@hold = true
			@lock = true
			@holdstart = RealTime!

	OnMouseReleased: (code) =>
		if code == MOUSE_LEFT
			@hold = false
			if @holdstart + 0.1 > RealTime()
				@lock = false
				@mapObject\LockClip(false)
		
	SetMap: (map) =>
		@mapObject = map
		@level = @mapObject\GetClipLevelTop()
		@displayLevel = @level
		@lock = @mapObject\GetLockClip()

	Think: =>
		@lock = @mapObject\GetLockClip()
		@LIMIT = @mapObject\GetClipLevelBottom() + 5
		@START = @LIMIT
		@END = @LIMIT + @MAXIMAL
		@DELTA = @END - @START
		
		holdingEnough = @hold and @holdstart + 0.1 < RealTime!
			
		if not @IsHovered()
			@hold = false
			holdingEnough = false
		
		if holdingEnough
			@lock = true
			@mapObject\LockClip(true)
		
		if @lock
			if holdingEnough
				w, h = @GetSize()
				hw, hh = w / 2, h / 2
				
				centerX, centerY = @LocalToScreen(hw, h)
				x, y = gui.MousePos()
				
				deltaX = x - centerX
				deltaY = centerY - y
				
				if deltaX < hw and deltaX > -hw and deltaY > 0 and deltaY < h
					@level = math.Clamp(@START + @DELTA * deltaY / h, @START, @END)
					if IsSmooth()
						@mapObject\SetClipLevelTop(Lerp(0.1, @mapObject\GetClipLevelTop(), @level))
					else
						@mapObject\SetClipLevelTop(@level)
			else
				@level = @mapObject\GetClipLevelTop()
		else
			@level = @mapObject\GetClipLevelTop()
		
		if IsSmooth()
			@displayLevel = Lerp(0.1, @displayLevel, @level)
		else
			@displayLevel = @level

	Paint: (w, h) =>
		draw.NoTexture()
		
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
		
		mult = (1 - (@displayLevel - @START) / @DELTA) - .2
		
		if mult >= -0.2
			surface.DrawRect(0, math.min(mult * h + 30, h - @sizeMult * 10), w, 4 * @sizeMult)
		else
			surface.SetDrawColor(CONTROL_TOOBIG())
			surface.DrawRect(0, 0, w, 4 * @sizeMult)

DMaps.PANEL_MAP_CLIP_TOP = PANEL
vgui.Register('DMapsMapClipTop', DMaps.PANEL_MAP_CLIP_TOP, 'EditablePanel')

return DMaps.PANEL_MAP_CLIP_BOTTOM, DMaps.PANEL_MAP_CLIP_TOP
