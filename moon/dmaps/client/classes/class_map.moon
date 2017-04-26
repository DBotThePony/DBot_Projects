
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
import xpcall, DMaps from _G
import cam, surface, draw, util, Vector, Angle, hook from _G
import debug, print, MsgC, Msg, table, render, math from _G

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
	
	@clipNormalDown = Vector(0, 0, 1)
	@clipNormalUp = Vector(0, 0, -1)
	
	@MAP_MOUSE_POINTER_SIZE = 3
	@MAP_MOUSE_POINTER_DRAW_SIZE = 10
	
	@divideConstant = 400
	
	@MINIMAL_ZOOM = 300
	
	@hooksToDisable = {
		'PreDrawEffects'
		'PreDrawHalos'
		'PreDrawHUD'
		'PreDrawPlayerHands'
		'PreDrawSkyBox'
		'PreDrawViewModel'
		'PrePlayerDraw'
		'PreDrawOpaqueRenderables'
		'ShouldDrawLocalPlayer'
	}
	
	@uid = 0
	
	@CatchError = (err) ->
		print('ERROR: ' .. err)
		print debug.traceback!
	
	new: (x = 0, y = 0, width = ScrW(), height = ScrH(), fov = 90, angle = Angle(0, 0, 0)) =>
		@MY_ID = @@uid
		@@uid += 1
		
		@xHUPerPixel = 1
		@yHUPerPixel = 1
		@xHUPerPixelOriginal = 1
		@yHUPerPixelOriginal = 1
		@REAL_SCRW = 0
		@REAL_SCRH = 0
		
		@waypoints = {}
		@entities = {}
		@players = {}
		@points = {}
		
		@objectTables = {@waypoints, @entities, @players, @points}
		
		@x = x
		@y = y
		
		@panelx = 0
		@panely = 0
		
		@SetSize(width, height)
		
		@fov = fov
		@fovSin = math.sin(math.rad(@fov))
		@angle = Angle(90, 90, 0) + angle
		@angleOffset = angle
		@mapYaw = 0
		@mapYawLerp = 0
		
		@MINIMAL_AUTO_ZOOM = @@MINIMAL_ZOOM
		@zoomAdd = 0
		@autoZoomMult = 1
		@zoom = 1000
		@lerpzoom = 1000
		@currX = 0
		@abstractX = 0
		@currY = 0
		@abstractY = 0
		@currZ = 0
		@abstractZ = 0
		@abstractSetup = false
		@isDrawinInPanel = false
		
		@mouseX = 0
		@mouseY = 0
		@mouseHit = false
		
		@clipLevelTop = 100
		@clipLevelBottom = -100
		@lockClip = false
		@lockView = false
		@lockZoom = false
		
		@skyHeight = 0
		
		@removed = false
		
		@outside = false
		
		@RegisterHooks!
	
	IsMouseActive: => @mouseHit
	MouseActive: => @mouseHit
	SetMouseActive: (val = false) => @mouseHit = val
	GetMouseX: => @mouseX
	GetMouseY: => @mouseY
	
	GetDrawX: => @x
	GetDrawY: => @y
	
	GetYaw: => @mapYaw
	GetRealYaw: => @mapYaw + 90
	SetYaw: (val = 0) =>
		@mapYaw = assert(val, 'number')
		@mapYawLerp = @mapYaw
		@angle = Angle(90, 90 + @mapYaw, 0) + @angleOffset
	
	LerpYaw: (val = 0) => @mapYawLerp = assert(val, 'number')
	
	IsValid: => not @removed
	
	Remove: =>
		if @removed then return
		@removed = true
		@UnregisterHooks!
		hook.Remove 'DMaps.EntityPointCreated', tostring(@)
	
	SetDrawPos: (x = 0, y = 0) =>
		@x = assert(x, 'number')
		@y = assert(y, 'number')
	
	GetX: => @currX
	GetY: => @curry
	GetZ: => @currZ
	GetZoom: => @zoom
	GetAutoZoomMult: => @autoZoomMult
	GetMinimalAutoZoom: => @MINIMAL_AUTO_ZOOM
	GetZoomAdd: => @zoomAdd
	
	GetZoomLock: => @lockZoom
	GetClipLock: => @lockClip
	GetViewLock: => @lockView
	GetLockZoom: => @lockZoom
	GetLockClip: => @lockClip
	GetLockView: => @lockView
	
	SetMousePos: (x = 0, y = 0) =>
		@mouseX = assert(x, 'number')
		@mouseY = assert(y, 'number')
		@mouseHit = true
		
	IsDrawnInPanel: (val = false) => @isDrawinInPanel = assert(val, 'boolean')
	PanelScreenPos: (x = 0, y = 0) =>
		@panelx = assert(x, 'number')
		@panely = assert(y, 'number')
	
	AddX: (val = 0) => @currX += assert(val, 'number')
	AddY: (val = 0) => @currY += assert(val, 'number')
	AddZ: (val = 0) => @zoom += assert(val, 'number')
	DeltaZoomMultiplier: => @zoom / @@MINIMAL_ZOOM
	AddZoom: (val = 0) => @zoom = math.max(@zoom + assert(val, 'number'), @@MINIMAL_ZOOM)
	SetZoom: (val = @@MINIMAL_ZOOM) =>
		@zoom = math.max(assert(val, 'number'), @@MINIMAL_ZOOM)
		@lerpzoom = @zoom
	
	SetLerpZoom: (val = @@MINIMAL_ZOOM) => @lerpzoom = math.max(assert(val, 'number'), @@MINIMAL_ZOOM)
	SetAutoZoomMult: (val = 1) => @autoZoomMult = val
	SetZoomAdd: (val = 0) => @zoomAdd = val
	SetMinimalAutoZoom: (val = @@MINIMAL_ZOOM) => @MINIMAL_AUTO_ZOOM = val
	
	GetFOV: => @fov
	
	GetPos: => Vector(@currX, @currY, @clipLevelTop)
	GetAbstractPos: => Vector(@abstractX, @abstractY, @abstractZ)
	GetPosTop: => Vector(@currX, @currY, @clipLevelTop)
	GetPosBottom: => Vector(@currX, @currY, @clipLevelBottom)
	GetPosCurrent: => Vector(@currX, @currY, @currZ + 100)
	
	GetDrawPos: => Vector(@currX, @currY, @zoom)
	GetAngles: => @angle
	GetAngle: => @angle
	
	LockClip: (val = false) => @lockClip = assert(val, 'boolean')
	LockView: (val = false) => @lockView = assert(val, 'boolean')
	LockZoom: (val = false) => @lockZoom = assert(val, 'boolean')
	
	GetWidth: => @width
	GetHeight: => @height
	
	SetWidth: (val = @width) =>
		@width = assert(val, 'number')
	
	SetHeight: (val = @height) =>
		@height = assert(val, 'number')
	
	GetSize: => return @x, @y
	
	SetSize: (width = @width, height = @height) =>
		@SetWidth(width)
		@SetHeight(height)
	
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

	WatchMapEntities: =>
		hook.Add 'DMaps.EntityPointCreated', tostring(@), (obj) -> @AddObject(obj)
		for i, point in pairs DMaps.DisplayedEntityBase.INSTANCES
			if point\IsValid()
				@AddObject(point)

	AddObject: (object) =>
		switch object.__class.__type
			when 'waypoint' -- Waypoint object
				if not table.HasValue(@waypoints, object)
					table.insert(@waypoints, object)
					object.map = @
			when 'entity' -- Generic/Entity pointer
				if not table.HasValue(@entities, object)
					table.insert(@entities, object)
					object.map = @
			when 'player' -- Player pointer
				if not table.HasValue(@players, object)
					table.insert(@players, object)
					object.map = @
			when 'point' -- Simple pointer
				if not table.HasValue(@points, object)
					table.insert(@points, object)
					object.map = @
	
	Add: (...) => @AddObject(...)
	
	__tostring: =>
		return "[DMapObject:#{@MY_ID}]"
	
	RegisterHooks: =>
		hookID = tostring(@)

		hook.Add 'DMaps.PlayerDeath', hookID, (ply, point) ->
			for i, p in pairs @players
				if p\GetEntity() == ply
					@AddObject(point)
					return
		
		preDrawFunc = (a, b) ->
			if a or b return
			if not @MAP_DRAW
				@INSIDE_3D_DRAW = true
				@DrawWorldHook!
				@INSIDE_3D_DRAW = false
				return
			
			@INSIDE_2D_DRAW = true
			
			@Draw2DLight!
			
			cam.IgnoreZ(true)
			
			if not @outside
				render.PopCustomClipPlane()
				render.PopCustomClipPlane()
			
			@Draw2DHook!
			
			if not @outside
				render.PushCustomClipPlane(@GetClipDataUp!)
				render.PushCustomClipPlane(@GetClipDataDown!)
			
			cam.IgnoreZ(false)
			
			@INSIDE_2D_DRAW = false
			
			return true
		
		disableFunc = ->
			if @MAP_DRAW
				return true
		
		for k, hookName in pairs @@hooksToDisable
			hook.Add(hookName, hookID, disableFunc)
		
		hook.Add('PreDrawTranslucentRenderables', hookID, preDrawFunc)
	
	CloneNetworkWaypoints: =>
		@AddObject(point\CloneWaypoint()) for point in *DMaps.NetworkedWaypoint\GetWaypoints()
	ListenNetworkWaypoints: =>
		hookID = tostring(@)
		created = (waypoint) ->
			if not @IsValid()
				hook.Remove('NetworkedWaypointCreated', hookID)
				return
			@AddObject(waypoint\CloneWaypoint())
		hook.Add('NetworkedWaypointCreated', hookID, created)
	
	FixCoordinate: (x = 0, y = 0) =>
		return x + 16000, y + 16000
	
	UnregisterHooks: =>
		hookID = tostring(@)
		
		for k, hookName in pairs @@hooksToDisable
			hook.Remove(hookName, hookID)
		
		hook.Remove('PreDrawTranslucentRenderables', hookID)
		hook.Remove('DMaps.PlayerDeath', hookID)
	
	-- Call when you give the decidion about pointer draw
	-- To the map object itself
	PrefferDraw: (x = 0, y = 0, z = 0) =>
		--if not @PointIsVisible(x, y)
		--	return false
		
		if z < @clipLevelBottom or z > @clipLevelTop
			return false
		
		if @zoom > z + 1400
			return false
		
		return true
	
	ThinkPlayer: (ply = LocalPlayer!) =>
		if not @IsValid! then return
		@abstractSetup = true
		pos = ply\GetPos!
		
		@abstractX = Lerp(0.1, @abstractX, pos.x)
		@abstractY = Lerp(0.1, @abstractY, pos.y)
		@abstractZ = Lerp(0.1, @abstractZ, pos.z)
		
		if not @lockClip
			trData = {
				mask: MASK_BLOCKLOS
				filter: ply
				start: pos
				endpos: pos + Vector(0, 0, 1000)
			}
			
			tr = util.TraceLine(trData)
			deltaZ = tr.HitPos.z - (pos.z + 10)
			
			@clipLevelTop = Lerp(0.2, @clipLevelTop, pos.z + deltaZ * 0.9)
			@clipLevelBottom = Lerp(0.2, @clipLevelBottom, pos.z - deltaZ * 0.9)
			
			@outside = not tr.Hit or tr.HitSky
			
			if @outside
				@skyHeight = deltaZ
			
			@currZ = Lerp(0.1, @currZ, pos.z + 20)
			
			if not @lockZoom
				@zoom = Lerp(0.1, @zoom, math.max(math.abs(@clipLevelTop * 1.3) * @autoZoomMult + @zoomAdd, @@MINIMAL_ZOOM * @autoZoomMult, @MINIMAL_AUTO_ZOOM))
			
		else
			@outside = false
		
		if not @lockView
			@currX = Lerp(0.1, @currX, pos.x)
			@currY = Lerp(0.1, @currY, pos.y)
	
	@WaypointsFilter = (obj, radius) -> obj.__class.__type == 'waypoint'
	@EntityFilter = (obj, radius) -> obj.__class.__type == 'entity'
	@PlayerFilter = (obj, radius) -> obj.__class.__type == 'player'
	@PointFilter = (obj, radius) -> obj.__class.__type == 'points'
	FindInRadius: (x = 0, y = 0, radius = 130, filter = ((obj, radius) -> true)) =>
		output = {}
		for objectTab in *@objectTables
			for k, object in pairs objectTab
				if object\IsValid()
					x1 = object\GetX()
					y1 = object\GetY()
					dist = ((x - x1) ^ 2 + (y - y1) ^ 2) ^ 0.5
					if dist < radius
						if filter(object, radius)
							table.insert(output, object)
				else
					objectTab[k] = nil
		return output
	
	StandartThink: =>
		existingPlayers = {ply, ply for ply in *[obj\GetEntity() for i, obj in pairs @players]}
		for ply in *player.GetAll()
			if not existingPlayers[ply]
				@AddObject(DMaps.DMapPlayerPointer(ply))

	Think: =>
		if not @IsValid! then return
		
		if @mapYawLerp ~= @mapYaw
			@mapYaw = Lerp(0.2, @mapYaw, @mapYawLerp)
			@angle = Angle(90, 90 + @mapYaw, 0) + @angleOffset
		
		for k, objectTab in pairs @objectTables
			for k, object in pairs objectTab
				if object\IsValid()
					object.map = @
					object\Think(@)
				else
					objectTab[k] = nil
	
	-- Called to draw map
	-- It calls Draw2D() inside it
	
	@BOX_DRAW_CONSTANT = 800
	
	DrawMap: (x, y, w, h) =>
		localZoom = @zoom / @@MINIMAL_ZOOM
		
		hw, hh = w / 2, h / 2
		
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
			ortholeft: -hw * localZoom
			orthoright: hw * localZoom
			orthotop: -hh * localZoom
			orthobottom: hh * localZoom
		}
		
		if @outside
			newView.origin.z += @skyHeight
			newView.zfar = 4000 + @skyHeight
		
		@MAP_DRAW = true
		xpcall(render.RenderView, @@CatchError, newView)
		@MAP_DRAW = false
	
	PreDraw: (x, y, w, h) =>
		-- Override
	
	-- X and Y are preffered positions where we would draw
	-- Function returns shift of X and Y for use
	Start2D: (x = 0, y = 0, size = @@MAP_2D_START_MULTIPLIER) =>
		shft = @@MAP_2D_STEP_LIMIT / 2
		newVector = Vector(x - shft * size, y + shft * size, @currZ)
		
		if @isDrawinInPanel
			newVector.x -= @panelx * size
			newVector.y += @panely * size
		
		cam.Start3D2D(newVector, @@MAP_2D_START_ANGLE, size)
		
		return shft, shft
	
	Stop2D: => cam.End3D2D()
	End2D: => cam.End3D2D()
	
	GetClipDataUp: => @@clipNormalUp, @@clipNormalUp\Dot(@GetPosTop!)
	GetClipDataDown: => @@clipNormalDown, @@clipNormalDown\Dot(@GetPosBottom!)
	
	-- Called when new X, Y, Width and Height are calculated
	-- And we need to start draw of Map
	Draw: (x, y, w, h) =>
		oldClipping = render.EnableClipping(true)
		
		if not @outside
			render.PushCustomClipPlane(@GetClipDataUp!)
			render.PushCustomClipPlane(@GetClipDataDown!)
		
		xpcall(@DrawMap, @@CatchError, @, x, y, w, h)
		
		if not @outside
			render.PopCustomClipPlane()
			render.PopCustomClipPlane()
		
		render.EnableClipping(oldClipping)
		
	PostDraw: (screenx = 0, screeny = 0, screenw = 0, screenh = 0) =>
		-- @DrawMapDirections(screenx, screeny, screenw, screenh)
	
	PreDraw2D: (screenx = 0, screeny = 0, screenw = 0, screenh = 0) =>
		surface.SetFont('Default')
		surface.SetTextColor(255, 255, 255)
		surface.SetDrawColor(255, 255, 255)
		draw.NoTexture()
	
	DrawMapCenter: (screenx = 0, screeny = 0, screenw = 0, screenh = 0) =>
		x, y = @Start2D(0, 0, 5)
		
		with surface
			.SetFont('Default')
			.SetTextPos(x + 40, y + 4)
			.SetTextColor(200, 50, 50)
			.SetDrawColor(200, 50, 50)
			
			.DrawLine(x - 40, y, x + 40, y)
			.DrawText('X')
			
			.SetTextPos(x + 4, y - 40)
			.SetTextColor(50, 200, 50)
			.SetDrawColor(50, 200, 50)
			
			.DrawLine(x, y - 40, x, y + 40)
			.DrawText('Y')
		
		cam.End3D2D()
	
	
	@ROTATED_TRIANGLE = (x = 0, y = 0, ang = 0, hypo = 20, myShift = 0) =>
		sin = math.sin(math.rad(ang))
		cos = math.cos(math.rad(ang))
		
		x -= myShift * cos
		y -= myShift * sin
		
		Ax, Ay = -hypo * sin, hypo * cos
		Bx, By = hypo * cos * 3, hypo * sin * 3
		Cx, Cy = hypo * sin, -hypo * cos
		
		trigData = {
			{x: x + Cx, y: y + Cy}
			{x: x + Bx, y: y + By}
			{x: x + Ax, y: y + Ay}
		}
		
		return trigData

	@DIRECTION_FONT = 'DMaps.SideFont'
	surface.CreateFont(@DIRECTION_FONT, {
		font: 'Roboto'
		size: 24
		weight: 600
	})

	@DIR_SIZE_MULT_X = .3
	@DIR_SIZE_MULT_Y = .3
	@DIR_SIZE_LEN = .7

	-- just a test
	DrawMapDirections: (screenx = 0, screeny = 0, screenw = 0, screenh = 0) =>
		yawDeg = @GetYaw! - 125
		yawNorthDeg = yawDeg
		yawSouthDeg = yawDeg - 180
		yawWestDeg = yawDeg - 90
		yawEastDeg = yawDeg + 90

		yawNorthDegRaw = yawNorthDeg + 125
		yawSouthDegRaw = yawSouthDeg + 125
		yawWestDegRaw = yawWestDeg + 125
		yawEastDegRaw = yawEastDeg + 125

		yawNorth = math.rad(yawNorthDeg)
		yawSouth = math.rad(yawSouthDeg)
		yawWest = math.rad(yawWestDeg)
		yawEast = math.rad(yawEastDeg)

		sin, cos = math.sin(math.rad(yawDeg - 22)), math.cos(math.rad(yawDeg - 22))
		sinN, cosN = math.sin(yawNorth), math.cos(yawNorth)
		sinS, cosS = math.sin(yawSouth), math.cos(yawSouth)
		sinW, cosW = math.sin(yawWest), math.cos(yawWest)
		sinE, cosE = math.sin(yawEast), math.cos(yawEast)

		centerX, centerY = screenw / 2, screenh / 2

		sizeX = screenw * @@DIR_SIZE_MULT_X
		sizeY = screenh * @@DIR_SIZE_MULT_Y

		northX = sizeX * cosN - sizeY * sinN + centerX
		northY = sizeY * cosN + sizeX * sinN + centerY

		southX = sizeX * cosS - sizeY * sinS + centerX
		southY = sizeY * cosS + sizeX * sinS + centerY

		westX = sizeX * cosW - sizeY * sinW + centerX
		westY = sizeY * cosW + sizeX * sinW + centerY

		eastX = sizeX * cosE - sizeY * sinE + centerX
		eastY = sizeY * cosE + sizeX * sinE + centerY

		draw.NoTexture()

		with surface
			.SetFont(@@DIRECTION_FONT)
			.SetTextColor(200, 50, 50)
			.SetDrawColor(255, 255, 255)
			
			w, h = .GetTextSize('N')
			.SetTextPos(northX - w * cos * @@DIR_SIZE_LEN + h * sin * @@DIR_SIZE_LEN - w / 2, northY - h * cos * @@DIR_SIZE_LEN - w * sin * @@DIR_SIZE_LEN - h / 2)
			.DrawPoly(@@ROTATED_TRIANGLE(northX, northY, yawNorthDegRaw - 90, 15))
			.DrawText('N')
			
			w, h = .GetTextSize('S')
			.SetTextPos(southX + w * cos * @@DIR_SIZE_LEN - h * sin * @@DIR_SIZE_LEN - w / 2, southY + h * cos * @@DIR_SIZE_LEN + w * sin * @@DIR_SIZE_LEN - h / 2)
			.DrawPoly(@@ROTATED_TRIANGLE(southX, southY, yawSouthDegRaw - 90, 15))
			.DrawText('S')
			
			w, h = .GetTextSize('W')
			.SetTextPos(westX - w * cos * @@DIR_SIZE_LEN * 2 - h * sin * @@DIR_SIZE_LEN - w / 2, westY + h * cos * @@DIR_SIZE_LEN - w * sin * @@DIR_SIZE_LEN * 2 - h / 2)
			.DrawPoly(@@ROTATED_TRIANGLE(westX, westY, yawWestDegRaw - 90, 15))
			.DrawText('W')
			
			w, h = .GetTextSize('E')
			.SetTextPos(eastX + w * cos * @@DIR_SIZE_LEN * 2 + h * sin * @@DIR_SIZE_LEN - w / 2, eastY - h * cos * @@DIR_SIZE_LEN + w * sin * @@DIR_SIZE_LEN * 2 - h / 2)
			.DrawPoly(@@ROTATED_TRIANGLE(eastX, eastY, yawEastDegRaw - 90, 15))
			.DrawText('E')
	
	-- When 1113 830
	@CONSTANT_MULTIPLY = 1.6
	@CONSTANT_ZOOM_MOVE = 0.43
	
	-- wtf
	ScreenToMap: (x = 0, y = 0) =>
		newX, newY = x, y
		
		newX /= @xHUPerPixel
		newY /= @yHUPerPixel
		
		newX *= @@CONSTANT_MULTIPLY
		newY *= @@CONSTANT_MULTIPLY
		
		yawDeg = @GetYaw!
		yaw = math.rad(yawDeg)
		sin, cos = math.sin(yaw), math.cos(yaw)
		
		newX2 = newX * cos - newY * sin
		newY2 = newY * cos + newX * sin
		
		newX2 += @currX
		newY2 += @currY
		
		return newX2, newY2
	
	-- wtf
	MapToScreen: (x = 0, y = 0) =>
		deltaZoom = @@MINIMAL_ZOOM / @zoom
		
		yawDeg = @GetYaw!
		yaw = math.rad(yawDeg)
		sin1, cos1 = math.sin(-yaw), math.cos(-yaw)
		sin2, cos2 = math.sin(yaw), math.cos(yaw)
		
		newX = x * cos2 - y * sin2
		newY = y * cos2 + x * sin2
		
		newX *= @xHUPerPixelOriginal
		newY *= @yHUPerPixelOriginal
		
		newX -= (@currX * cos1 - @currY * sin1) * deltaZoom
		newY += (@currY * cos1 + @currX * sin1) * deltaZoom
		
		newX += @width / 2
		newY += @height / 2
		
		return newX, newY
	
	-- wtf
	Trace2DPoint: (x = 0, y = 0) =>
		trData = {
			mask: MASK_BLOCKLOS
			start: Vector(x, y, @clipLevelTop)
			endpos: Vector(x, y, @clipLevelBottom)
		}
		
		return util.TraceLine(trData)
	Trace2D: (...) => @Trace2DPoint(...)
	DrawMousePointer: (screenx = 0, screeny = 0, screenw = 0, screenh = 0) =>
		if not @mouseHit return
		
		x, y = @Start2D(@mouseX, @mouseY, @@MAP_MOUSE_POINTER_DRAW_SIZE)
		size = @@MAP_MOUSE_POINTER_SIZE
		
		with surface
			.SetDrawColor(230, 230, 230)
			.DrawLine(x - size, y - size, x + size, y - size)
			.DrawLine(x - size, y + size, x + size, y + size)
			.DrawLine(x - size, y + size, x - size, y - size)
			.DrawLine(x + size, y + size, x + size, y - size)
		
		cam.End3D2D()
	
	@MAP_2D_LIGHT_SIZE = 1000
	@MAP_2D_LIGHT_SIZING = 16000
	@MAP_2D_LIGHT_START_X = -@MAP_2D_LIGHT_SIZING
	@MAP_2D_LIGHT_END_X = @MAP_2D_LIGHT_SIZING
	@MAP_2D_LIGHT_START_Y = -@MAP_2D_LIGHT_SIZING
	@MAP_2D_LIGHT_END_Y = @MAP_2D_LIGHT_SIZING
	@MAP_2D_LIGHT_Z = -1600
	@MAP_2D_LIGHT_ANGLE_CONST = Angle(0, 0, 0)
	
	-- Better not override that
	Draw2DLight: =>
		if true then return -- just a test
		draw.NoTexture!
		surface.SetDrawColor(255, 255, 255)
		for x = @@MAP_2D_LIGHT_START_X, @@MAP_2D_LIGHT_END_X, @@MAP_2D_LIGHT_SIZE
			for y = @@MAP_2D_LIGHT_START_Y, @@MAP_2D_LIGHT_END_Y, @@MAP_2D_LIGHT_SIZE
				vec = Vector(x, y, @@MAP_2D_LIGHT_Z)
				cam.Start3D2D(vec, @@MAP_2D_LIGHT_ANGLE_CONST, 10)
				surface.DrawRect(x, y, @@MAP_2D_LIGHT_SIZE, @@MAP_2D_LIGHT_SIZE)
				cam.End3D2D()
	
	BuildRenderList: =>
		pre = {}
		for objectTab in *@objectTables
			for k, object in pairs objectTab
				if object\IsValid()
					if object\ShouldDraw(@)
						table.insert(pre, {object, object\GetRenderPriority()})
				else
					objectTab[k] = nil
		
		table.sort pre, (a, b) -> b[2] > a[2]
		return [o[1] for o in *pre]

	-- Still have to create 3D2D context!
	Draw2D: (screenx = 0, screeny = 0, screenw = 0, screenh = 0) =>
		object\DrawHook(@) for object in *@BuildRenderList()
		
		@DrawMapCenter(screenx, screeny, screenw, screenh)
		@DrawMousePointer(screenx, screeny, screenw, screenh)
	
	PostDraw2D: (screenx = 0, screeny = 0, screenw = 0, screenh = 0) =>
		-- Override
	
	Get2DContextData: => @DRAW_X_2D, @DRAW_Y_2D, @DRAW_WIDTH, @DRAW_HEIGHT
	
	-- Called inside DrawMap() right after landskape was drawn
	-- Calls all 2D hooks with X and Y that are used as shift, also
	-- Called with default 2D properties
	Draw2DHook: =>
		screenx, screeny, screenw, screenh = @Get2DContextData!
		
		render.SetViewPort(unpack(@PREVIOUS_RENDER_PORT))
		
		vec1Check = Vector(-40, -40, 0)
		vec2Check = Vector(40, 40, 0)
		
		ang = Angle(0, @GetYaw!, 0)
		vec1Check\Rotate(ang)
		vec2Check\Rotate(ang)
		
		pos1 = vec1Check\ToScreen!
		pos2 = vec2Check\ToScreen!
		
		render.SetViewPort(unpack(@CURENT_RENDER_PORT))
		
		@xHUPerPixel = (pos2.x - pos1.x) / 50
		@xHUPerPixelOriginal = (pos2.x - pos1.x) / 40
		@yHUPerPixel = (pos1.y - pos2.y) / 50
		@yHUPerPixelOriginal = (pos1.y - pos2.y) / 40
		
		oldClipping = render.EnableClipping(false)
		xpcall(@PreDraw2D, @@CatchError, @, screenx, screeny, screenw, screenh)
		xpcall(@Draw2D, @@CatchError, @, screenx, screeny, screenw, screenh)
		xpcall(@PostDraw2D, @@CatchError, @, screenx, screeny, screenw, screenh)
		render.EnableClipping(oldClipping)
	
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
		
		surface.DisableClipping(true)
		
		if @isDrawinInPanel
			@DRAW_X_2D = newX - @panelx
			@DRAW_Y_2D = newY - @panely
		else
			@DRAW_X_2D = newX
			@DRAW_Y_2D = newY
			
		@DRAW_X = newX
		@DRAW_Y = newY
		@DRAW_WIDTH = newWidth
		@DRAW_HEIGHT = newHeight
		
		render.SuppressEngineLighting(true)
		@PREVIOUS_RENDER_PORT = {0, 0, oldW, oldH}
		@CURENT_RENDER_PORT = {newX, newY, newWidth, newHeight}
		
		@REAL_SCRW = oldW
		@REAL_SCRH = oldH
		
		render.SetViewPort(unpack(@CURENT_RENDER_PORT))
		
		xpcall(@PreDraw, @@CatchError, @, @DRAW_X, newY, newWidth, newHeight)
		xpcall(@Draw, @@CatchError, @, @DRAW_X, newY, newWidth, newHeight)
		xpcall(@PostDraw, @@CatchError, @, @DRAW_X, newY, newWidth, newHeight)
		
		render.SetViewPort(unpack(@PREVIOUS_RENDER_PORT))
		render.SuppressEngineLighting(false)
		
		surface.DisableClipping(false)
		
		
	PreDrawWorld: => -- Override
	PostDrawWorld: => -- Override
	
	DrawWorld: =>
		object\DrawWorldHook(@) for object in *@BuildRenderList()
	
	DrawWorldHook: =>
		xpcall(@PreDrawWorld, @@CatchError, @)
		xpcall(@DrawWorld, @@CatchError, @)
		xpcall(@PostDrawWorld, @@CatchError, @)
		
DMaps.DMap = DMap
return DMap
