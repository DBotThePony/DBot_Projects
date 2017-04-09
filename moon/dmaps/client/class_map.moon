
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
	@xLineStart = Vector(-30, 0, 0)
	@xLineEnd = Vector(30, 0, 0)
	
	@xLineText = Vector(20, 0, 0)
	@xLineTextAngle = Angle(0, 0, 0)
	
	@xLineColor = Color(200, 50, 50)
	
	@yLineStart = Vector(0, 30, 0)
	@yLineEnd = Vector(0, -30, 0)
	@yLineColor = Color(50, 200, 50)
	
	@yLineText = Vector(-5, 28, 0)
	@yLineTextAngle = Angle(0, 0, 0)
	
	new: (x = 0, y = 0, width = ScrW(), height = ScrH(), fov = 90, angle = Angle(0, 0, 0)) =>
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
		
		@clipLevel = 100
		@lockClip = false
		@lockView = false
		@lockZoom = false
		@clipNormal = Vector(0, 0, -1)
		
		@CatchError = (err) ->
			print('[DMaps|' .. @ .. '] ERROR: ', err)
			print debug.traceback!
	
	GetDrawX: => @x
	GetDrawY: => @y
	
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
	
	GetPos: => Vector(@currX, @currY, @clipLevel)
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
	
	GetZoomMultiplier: => @zoom / @fov * @fovSin
	
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
		pos = ply\GetPos!
		
		if not @lockClip
			trData = {
				mask: MASK_BLOCKLOS
				filter: ply
				start: pos
				endpos: pos + Vector(0, 0, 1000)
			}
			
			tr = util.TraceLine(trData)
			deltaZ = trData.HutPos.z - (pos.z + 10)
			
			@clipLevel = Lerp(0.2, @clipLevel, deltaZ * 0.8)
			
			if not @lockZoom
				@zoom = @clipLevel * 1.3
		
		if not @lockView
			@currX = pos.x
			@currY = pos.y
	
	Think: =>
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
	
	DrawMap: =>
		render.DrawLine(@@xLineStart, @@xLineEnd, @@xLineColor)
		render.DrawLine(@@yLineStart, @@yLineEnd, @@yLineColor)
		
		surface.SetTextPos(0, 0)
		surface.SetFont('Default')
		
		cam.Start3D2D(@@xLineText, @@xLineTextAngle, 1)
		surface.SetTextColor(@@xLineColor)
		surface.DrawText('X')
		cam.End3D2D()
		
		cam.Start3D2D(@@yLineText, @@yLineTextAngle, 1)
		surface.SetTextColor(@@yLineColor)
		surface.DrawText('Y')
		cam.End3D2D()
	
	DrawWaypoints: =>
		for k, waypoint in pairs @waypoints
			if waypoint\IsValid()
				if waypoint\ShouldDraw(@)
					waypoint\Draw()
			else
				@waypoints[k] = nil
	
	DrawPoints: =>
		for k, pointer in pairs @points
			if pointer\IsValid()
				if pointer\ShouldDraw(@)
					pointer\Draw()
			else
				@waypoints[k] = nil
	
	PreDraw: =>
		-- Override
	
	Draw: =>
		-- Override with call "super!"
		oldClipping = render.EnableClipping(true)
		render.PushCustomClipPlane(@clipNormal, @clipNormal\Dot(@GetPos!))
		xpcall(@DrawMap, @CatchError, @)
		render.PopCustomClipPlane()
		render.EnableClipping(oldClipping)
		
		@DrawWaypoints!
		@DrawEntities!
		
	PostDraw: =>
		-- Override
		
	DrawHook: =>
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
		
		cam.Start3D(@GetDrawPos!, @GetAngles!, @GetFOV!, newX, newY, newWidth, newHeight)
		
		xpcall(@PreDraw, @CatchError, @)
		xpcall(@Draw, @CatchError, @)
		xpcall(@PostDraw, @CatchError, @)
		
		cam.End3D()
		
return DMap
