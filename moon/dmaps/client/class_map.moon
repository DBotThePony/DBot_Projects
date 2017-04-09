
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

_assert = assert

assert = (arg, tp) ->
	_assert(type(arg) == tp, 'must be ' .. tp)
	return arg

class DMap
	@MAP_2D_SIZE = 8000
	@MAP_2D_STEP_LIMIT = 1000
	@MAP_2D_START_MULTIPLIER = 1
	
	@MAP_2D_START_VECTOR = Vector(-@MAP_2D_SIZE, @MAP_2D_SIZE, 0)
	@MAP_2D_START_ANGLE = Angle(0, 0, 0)
	@MAP_2D_X_ADD = @MAP_2D_SIZE
	@MAP_2D_Y_ADD = @MAP_2D_SIZE
	
	@divideConstant = 400
	
	@hooksToDisable = {
		'PreDrawEffects'
		'PreDrawHalos'
		'PreDrawHUD'
		'PreDrawPlayerHands'
		'PreDrawSkyBox'
		'PreDrawViewModel'
		--'PrePlayerDraw'
		--'PreDrawOpaqueRenderables'
		'ShouldDrawLocalPlayer'
	}
	
	@uid = 0
	
	new: (x = 0, y = 0, width = ScrW(), height = ScrH(), fov = 90, angle = Angle(0, 0, 0)) =>
		@MY_ID = @@uid
		@@uid += 1
		
		@waypoints = {}
		@entities = {}
		@players = {}
		@points = {}
		
		@x = x
		@y = y
		
		@width = width
		@height = height
		@fov = fov
		@fovSin = math.sin(math.rad(@fov))
		@angle = Angle(90, 90, 0) + angle
		@angleOffset = angle
		
		@zoom = 1000
		@currX = 0
		@currY = 0
		@currZ = 0
		
		@clipLevelTop = 100
		@clipLevelBottom = -100
		@lockClip = false
		@lockView = false
		@lockZoom = false
		
		@skyHeight = 0
		
		@removed = false
		
		@outside = false
		
		@RegisterHooks!
		
		@CatchError = (err) ->
			print('[DMaps|' .. @ .. '] ERROR: ', err)
			print debug.traceback!
	
	GetDrawX: => @x
	GetDrawY: => @y
	
	IsValid: => not @removed
	
	Remove: =>
		if @removed then return
		@removed = true
		@UnregisterHooks!
	
	SetDrawPos: (x = 0, y = 0) =>
		@x = assert(x, 'number')
		@y = assert(y, 'number')
	
	GetX: => @currX
	GetY: => @curry
	GetZ: => @zoom
	
	AddX: (val = 0) => @currX += assert(val, 'number')
	AddY: (val = 0) => @currY += assert(val, 'number')
	AddZ: (val = 0) => @zoom += assert(val, 'number')
	AddZoom: (val = 0) => @zoom += assert(val, 'number')
	
	GetFOV: => @fov
	
	GetPos: => Vector(@currX, @currY, @clipLevelTop)
	GetPosTop: => Vector(@currX, @currY, @clipLevelTop)
	GetPosBottom: => Vector(@currX, @currY, @clipLevelBottom)
	GetPosCurrent: => Vector(@currX, @currY, @currZ + 300)
	
	GetDrawPos: => Vector(@currX, @currY, @zoom)
	GetAngles: => @angle
	GetAngle: => @angle
	
	LockClip: (val = false) => @lockClip = assert(val, 'boolean')
	LockView: (val = false) => @lockView = assert(val, 'boolean')
	LockZoom: (val = false) => @lockZoom = assert(val, 'boolean')
	
	GetWidth: => @width
	GetHeight: => @height
	
	SetWidth: (val = @width) => @width = assert(val, 'number')
	SetHeight: (val = @height) => @height = assert(val, 'number')
	
	GetSize: => return @x, @y
	
	SetSize: (width = 0, height = 0) =>
		@width = assert(width, 'number')
		@height = assert(height, 'number')
	
	GetZoomMultiplier: => @zoom / @fov
	GetMapZoomMultiplier: => (@zoom - @currZ) / @fov
	
	-- fucking math
	-- For now custom map angles are not supported
	GetBorderBox: =>
		distMult = @GetZoomMultiplier!
		
		halfWidth = (@width - @x) / 2
		halfHeight = (@height - @y) / 2
		
		topLeftX = @currX - halfWidth * distMult
		topLeftY = @currY + halfHeight * distMult
		
		topRightX = @currX + halfWidth * distMult
		topRightY = topLeftY
		
		bottomLeftX = topLeftX
		bottomLeftY = @currY - halfHeight * distMult
		
		bottomRightX = topRightX
		bottomRightY = bottomLeftY
		
		return {:topLeftX, :topLeftY, :topRightX, :topRightY, :bottomLeftX, :bottomLeftY, :bottomRightX, :bottomRightY}
	
	PointIsVisible: (x = 0, y = 0) =>
		border = @GetBorderBox!
		return x > border.topLeftX and x < border.topRightX and
			y < border.topLeftY and y > border.bottomLeftY
	
	AddObject: (object) =>
		if object.__type == 'waypoint' -- Waypoint object
			if not table.HasValue(@waypoints, object)
				table.insert(@waypoints, object)
		elseif object.__type == 'entity' -- Generic/Entity pointer
			if not table.HasValue(@entities, object)
				table.insert(@entities, object)
		elseif object.__type == 'player' -- Player pointer
			if not table.HasValue(@players, object)
				table.insert(@players, object)
		elseif object.__type == 'points' -- Simple pointer
			if not table.HasValue(@points, object)
				table.insert(@points, object)
	
	__tostring: =>
		return "[DMapObject:#{@MY_ID}]"
	
	RegisterHooks: =>
		hookID = tostring(@)
		
		preDrawFunc = ->
			if not @MAP_DRAW return
			
			@INSIDE_2D_DRAW = true
			
			cam.IgnoreZ(true)
			@Draw2DHook!
			cam.IgnoreZ(false)
			
			@INSIDE_2D_DRAW = false
			
			return true
		
		disableFunc = ->
			if @MAP_DRAW
				return true
		
		for k, hookName in pairs @@hooksToDisable
			hook.Add(hookName, hookID, disableFunc)
		
		hook.Add('PreDrawTranslucentRenderables', hookID, preDrawFunc)
	
	FixCoordinate: (x = 0, y = 0) =>
		return x + 16000, y + 16000
	
	UnregisterHooks: =>
		hookID = tostring(@)
		
		for k, hookName in pairs @@hooksToDisable
			hook.Remove(hookName, hookID)
		
		hook.Remove('PreDrawTranslucentRenderables', hookID)
	
	-- Call when you give the decidion about pointer draw
	-- To the map object itself
	PrefferDraw: (x = 0, y = 0, z = 0) =>
		if not @PointIsVisible(x, y)
			return false
		
		minZoom = @zoom - 500
		maxZoom = @zoom + 500
		
		if z < minZoom or z > maxZoom
			return false
		
		return true
	
	ThinkPlayer: (ply = LocalPlayer!) =>
		if not @IsValid! then return
		pos = ply\GetPos!
		
		if not @lockClip
			trData = {
				mask: MASK_BLOCKLOS
				filter: ply
				start: pos
				endpos: pos + Vector(0, 0, 1000)
			}
			
			tr = util.TraceLine(trData)
			deltaZ = tr.HitPos.z - (pos.z + 10)
			
			@clipLevelTop = Lerp(0.2, @clipLevelTop, pos.z + deltaZ * 0.8)
			@clipLevelBottom = Lerp(0.2, @clipLevelBottom, pos.z - deltaZ * 0.2)
			
			@outside = not tr.Hit or tr.HitSky
			
			if @outside
				@skyHeight = deltaZ
			
			@currZ = pos.z + 20
			
			if not @lockZoom
				@zoom = @clipLevelTop * 1.3
			
		else
			@outside = false
		
		if not @lockView
			@currX = pos.x
			@currY = pos.y
	
	Think: =>
		if not @IsValid! then return
		for k, waypoint in pairs @waypoints
			if waypoint\IsValid()
				waypoint\Think()
			else
				@waypoints[k] = nil
	
	DrawEntities: =>
		for k, pointer in pairs @entities
			if pointer\IsValid()
				if pointer\ShouldDraw(@)
					pointer\Draw()
			else
				@entities[k] = nil
		
		for k, pointer in pairs @players
			if pointer\IsValid()
				if pointer\ShouldDraw(@)
					pointer\Draw()
			else
				@players[k] = nil
	
	-- Called to draw map
	-- It calls Draw2D() inside it
	DrawMap: (x, y, w, h) =>
		aspectRatio1 = w / h
		aspectRatio2 = h / w * 2
		
		localZoom = @zoom
		
		newView = {
			:x
			:y
			:w
			:h
			origin: @GetPosCurrent!
			angles: @GetAngles!
			drawhud: false
			drawmonitors: false
			drawviewmodel: false
			viewmodelfov: @fov
			fov: @fov
			
			ortho: true
			ortholeft: -localZoom * aspectRatio1
			orthoright: localZoom * aspectRatio1
			orthotop: -localZoom * aspectRatio2
			orthobottom: localZoom * aspectRatio2
		}
		
		if @outside
			newView.origin.z += @skyHeight
			newView.zfar = 4000 + @skyHeight
		
		@MAP_DRAW = true
		xpcall(render.RenderView, @CatchError, newView)
		@MAP_DRAW = false
	
	DrawWaypoints: (x, y, w, h) =>
		for k, waypoint in pairs @waypoints
			if waypoint\IsValid()
				if waypoint\ShouldDraw(@)
					waypoint\Draw()
			else
				@waypoints[k] = nil
	
	DrawPoints: (x, y, w, h) =>
		for k, pointer in pairs @points
			if pointer\IsValid()
				if pointer\ShouldDraw(@)
					pointer\Draw()
			else
				@waypoints[k] = nil
	
	PreDraw: (x, y, w, h) =>
		-- Override
	
	-- X and Y are preffered positions where we would draw
	-- Function returns shift of X and Y for use
	Start2D: (x = 0, y = 0, size = @@MAP_2D_START_MULTIPLIER) =>
		shft = @@MAP_2D_STEP_LIMIT / 2
		newVector = Vector(x - shft * size, y + shft * size, 0)
		cam.Start3D2D(newVector, @@MAP_2D_START_ANGLE, size)
		
		return shft, shft
	
	Stop2D: =>
		cam.End3D2D()
	
	-- Called when new X, Y, Width and Height are calculated
	-- And we need to start draw of Map
	Draw: (x, y, w, h) =>
		oldClipping = render.EnableClipping(true)
		
		if not @outside
			render.PushCustomClipPlane(@@clipNormalUp, @@clipNormalUp\Dot(@GetPosTop!))
			render.PushCustomClipPlane(@@clipNormalDown, @@clipNormalDown\Dot(@GetPosBottom!))
		
		xpcall(@DrawMap, @CatchError, @, x, y, w, h)
		
		if not @outside
			render.PopCustomClipPlane()
			render.PopCustomClipPlane()
		
		render.EnableClipping(oldClipping)
		
	-- PostDraw
	-- Called after all was drawn on the screen
	PostDraw: (screenx, screeny, screenw, screenh) =>
		-- Override
	
	PreDraw2D: (screenx, screeny, screenw, screenh) =>
		surface.SetFont('Default')
		surface.SetTextColor(255, 255, 255)
		surface.SetDrawColor(255, 255, 255)
		draw.NoTexture()
	
	DrawMapCenter: (screenx, screeny, screenw, screenh) =>
		x, y = @Start2D(0, 0, 5)
		
		surface.SetTextPos(x + 40, y + 4)
		surface.SetTextColor(200, 50, 50)
		surface.SetDrawColor(200, 50, 50)
		
		surface.DrawLine(x - 40, y, x + 40, y)
		surface.DrawText('X')
		
		surface.SetTextPos(x + 4, y + 40)
		surface.SetTextColor(50, 200, 50)
		surface.SetDrawColor(50, 200, 50)
		
		surface.DrawLine(x, y - 40, x, y + 40)
		surface.DrawText('Y')
		
		cam.End3D2D()
	
	-- Still have to create 3D2D context!
	Draw2D: (screenx, screeny, screenw, screenh) =>
		@DrawWaypoints(screenx, screeny, screenw, screenh)
		@DrawEntities(screenx, screeny, screenw, screenh)
		@DrawMapCenter(screenx, screeny, screenw, screenh)
	
	PostDraw2D: (x, y, screenx, screeny, screenw, screenh) =>
		-- Override
	
	Get2DContextData: => @DRAW_X, @DRAW_Y, @DRAW_WIDTH, @DRAW_HEIGHT
	
	-- Called inside DrawMap() right after landskape was drawn
	-- Calls all 2D hooks with X and Y that are used as shift, also
	-- Called with default 2D properties
	Draw2DHook: =>
		screenx, screeny, screenw, screenh = @Get2DContextData!
		xpcall(@PreDraw2D, @CatchError, @, screenx, screeny, screenw, screenh)
		xpcall(@Draw2D, @CatchError, @, screenx, screeny, screenw, screenh)
		xpcall(@PostDraw2D, @CatchError, @, screenx, screeny, screenw, screenh)
	
	DrawHook: =>
		if not @IsValid! then return
		newX = @GetDrawX!
		newY = @GetDrawY!
		newWidth = @GetWidth!
		newHeight = @GetHeight!
		
		if newX < 0
			newWidth += newX
			newX = 0
		
		if newY < 0
			newHeight += newY
			newY = 0
		
		if newWidth + newX > ScrW!
			newWidth = ScrW! - newX
		
		if newHeight + newY > ScrH!
			newHeight = ScrH! - newY
		
		oldW, oldH = ScrW!, ScrH!
		
		@DRAW_X = newX
		@DRAW_Y = newY
		@DRAW_WIDTH = newWidth
		@DRAW_HEIGHT = newHeight
		
		render.SetViewPort(newX, newY, newWidth, newHeight)
		
		xpcall(@PreDraw, @CatchError, @, newX, newY, newWidth, newHeight)
		xpcall(@Draw, @CatchError, @, newX, newY, newWidth, newHeight)
		xpcall(@PostDraw, @CatchError, @, newX, newY, newWidth, newHeight)
		
		render.SetViewPort(0, 0, oldW, oldH)
		
return DMap
