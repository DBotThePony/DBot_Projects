
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

import DMaps, surface, color, Vector, render, draw, CreateConVar, CreateMaterial from _G
import DMapWaypoint from DMaps

NAV_STATUS_IDLE = -1
NAV_STATUS_SUCCESS = 0
NAV_STATUS_GENERIC_FAILURE = 1
NAV_STATUS_WORKING = 2
NAV_STATUS_FAILURE_TIME_LIMIT = 3
NAV_STATUS_FAILURE_OPEN_NODES_LIMIT = 4
NAV_STATUS_FAILURE_LOOPS_LIMIT = 5
NAV_STATUS_FAILURE_NO_OPEN_NODES = 6
NAV_STATUS_INTERRUPT = 7

DMaps.NAV_ENABLE = CreateConVar('sv_dmaps_nav_enable', '1', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable navigation support (if map has nav file)')

DMaps.IsNavigating = false
DMaps.NavigationPoints = {}
DMaps.LastNavRequestWindow = true
DMaps.LastDisplayNavPoint = true
DMaps.NavigationStart = Vector(0, 0, 0)
DMaps.NavigationEnd = Vector(0, 0, 0)

NAV_POINT_COLOR = DMaps.CreateColor(255, 255, 255, 'nav_target', 'Navigation target point color')
NAV_ARROW_COLOR = DMaps.CreateColor(34, 209, 217, 'nav_arrow', 'Navigation arrows color')
DRAW_DIST = CreateConVar('cl_dmaps_nav_line_dist', '1000', {FCVAR_ARCHIVE}, 'How far navigation path should draw')

ARROW_DATA_1 = {
	{x: 0, y: 20}
	{x: 20, y: 0}
	{x: 20, y: 10}
	{x: 0, y: 25}
}

ARROW_DATA_2 = {
	{x: 20, y: 0}
	{x: 40, y: 20}
	{x: 40, y: 25}
	{x: 20, y: 10}
}

local lastNavPoint

hook.Add 'DrawDMap2D', 'DMaps.Navigation', =>
	return if not DMaps.NAV_ENABLE\GetBool()
	return if not DMaps.IsNavigating
	colorR, colorG, colorB = NAV_ARROW_COLOR()
	dist = DMaps.NavigationEnd\Distance(LocalPlayer()\GetPos())
	Z = @GetZ()
	
	for {point, nDist, :approx} in *DMaps.NavigationPoints
		for {node, deltaAng} in *approx
			{:x, :y, :z} = node
			deltaZRaw = z - Z
			deltaZ = math.abs(deltaZRaw)
			if deltaZ > 200 continue
			yaw = math.rad(-deltaAng.y)
			sin, cos = math.sin(yaw), math.cos(yaw)
			alpha = 1
			sizeMult = 1
			alpha = math.Clamp(1 - (deltaZ - 50) / 150, 0.2, 1) if deltaZ > 50
			sizeMult = math.Clamp(1.2 + (deltaZRaw) / 300, 0.2, 2) if deltaZ > 70
			surface.SetDrawColor(colorR, colorG, colorB, 255 * alpha)

			xDraw, yDraw = @Start2D(x, y, @@MAP_2D_START_MULTIPLIER * sizeMult)
			newArrow1 = [{x: (xC - 10) * cos - yC * sin + xDraw, y: yC * cos + (xC - 10) * sin + yDraw} for {x: xC, y: yC} in *ARROW_DATA_1]
			newArrow2 = [{x: (xC - 10) * cos - yC * sin + xDraw, y: yC * cos + (xC - 10) * sin + yDraw} for {x: xC, y: yC} in *ARROW_DATA_2]
			surface.DrawPoly(newArrow1)
			surface.DrawPoly(newArrow2)
			cam.End3D2D()

hook.Add 'DrawDMapWorld', 'DMaps.Navigation', =>
	return if not DMaps.NAV_ENABLE\GetBool()
	return if not DMaps.IsNavigating
	eyePos = LocalPlayer()\EyePos()
	dist = DMaps.NavigationEnd\Distance(LocalPlayer()\GetPos())
	mDist = DRAW_DIST\GetInt()
	posZ = eyePos.z
	colorR, colorG, colorB = NAV_ARROW_COLOR()
	colorRInv, colorGInv, colorBInv = 255 - colorR, 255 - colorG, 255 - colorB
	draw.NoTexture()

	oldBlend = render.GetBlend()
	prevClip = render.EnableClipping(false)
	render.SetBlend(1)
	cam.IgnoreZ(true)

	for {point, nDist, :approx} in *DMaps.NavigationPoints
		if nDist + mDist < dist continue
		if nDist - mDist > dist continue
		if point.z - 40 < posZ
			for {v, deltaAng, v2, deltaAngRotate} in *approx
				surface.SetDrawColor(colorR, colorG, colorB)
				cam.Start3D2D(v, deltaAng, 1)
				surface.DrawPoly(ARROW_DATA_1)
				surface.DrawPoly(ARROW_DATA_2)
				cam.End3D2D()
		if point.z + 40 > posZ
			for {v, deltaAng, v2, deltaAngRotate} in *approx
				surface.SetDrawColor(colorRInv, colorGInv, colorBInv)
				cam.Start3D2D(v2, deltaAngRotate, 1)
				surface.DrawPoly(ARROW_DATA_1)
				surface.DrawPoly(ARROW_DATA_2)
				cam.End3D2D()
	
	cam.IgnoreZ(false)
	render.EnableClipping(prevClip)
	render.SetBlend(oldBlend)

hook.Add 'Think', 'DMaps.Navigation', ->
	return if not DMaps.NAV_ENABLE\GetBool()
	return if not DMaps.IsNavigating
	if LocalPlayer()\GetPos()\Distance(DMaps.NavigationEnd) < 125
		DMaps.IsNavigating = false
		lastNavPoint\Remove() if IsValid(lastNavPoint)

DMaps.StopNavigation = ->
	lastNavPoint\Remove() if IsValid(lastNavPoint)
	DMaps.IsNavigating = false
	DMaps.NavigationPoints = {}

ENABLE_SMOOTH = DMaps.ClientsideOption('smooth_animations', '1', 'Use smooth map animations')
ENABLE_SMOOTH_MOVE = DMaps.ClientsideOption('smooth_animations_mv', '1', 'Use smooth map moving animation')
SCREEN_COLOR = CreateMaterial('DMaps.ScreenColorEffect', 'g_colourmodify', {
	'$fbtexture': '_rt_FullFrameFB'
	'$ignorez': '1'
	'$pp_colour_addr': 0,
	'$pp_colour_addg': 0,
	'$pp_colour_addb': 0,
	'$pp_colour_brightness': 0,
	'$pp_colour_contrast': 1,
	'$pp_colour_colour': 0.3,
	'$pp_colour_mulr': 0,
	'$pp_colour_mulg': 0,
	'$pp_colour_mulb': 0
})

hook.Add 'RenderScreenspaceEffects', 'DMaps.RequireNavigationEffect', ->
	return if not IsValid(DMaps.NavRequestWindow)
	render.UpdateScreenEffectTexture()
	SCREEN_COLOR\SetFloat('$pp_colour_colour', 1 - DMaps.NavRequestWindow.alpha / 160)
	SCREEN_COLOR\SetFloat('$pp_colour_contrast', 1 - DMaps.NavRequestWindow.alpha / 160 * .3)
	render.SetMaterial(SCREEN_COLOR)
	render.DrawScreenQuad()

DMaps.RequireNavigation = (target = Vector(0, 0, 0), displayWindow = true, dontDisplayPoint = false) ->
	return if not DMaps.NAV_ENABLE\GetBool()
	lastNavPoint\Remove() if IsValid(lastNavPoint)
	{:x, :y, :z} = target
	x, y, z = math.floor(x), math.floor(y), math.floor(z)
	DMaps.IsNavigating = false
	DMaps.NavigationPoints = {}
	net.Start('DMaps.Navigation.Require')
	net.WriteInt(x, 32)
	net.WriteInt(y, 32)
	net.WriteInt(z, 32)
	net.WriteBool(displayWindow)
	net.SendToServer()
	DMaps.LastNavRequestWindow = displayWindow
	DMaps.LastDisplayNavPoint = not dontDisplayPoint

	if displayWindow
		map = DMaps.GetMainMap()
		if IsValid(map)
			tpos = Vector(x, y, z + 600)
			map\LockZoom(true)
			map\LockView(true)
			if ENABLE_SMOOTH\GetBool() and ENABLE_SMOOTH_MOVE\GetBool()
				map\SetLerpPos(tpos)
			else
				map\SetPos(tpos)
		DMaps.NavRequestWindow\Remove() if IsValid(DMaps.NavRequestWindow)
		DMaps.NavRequestWindow = vgui.Create('DFrame')
		with DMaps.NavRequestWindow
			\SetSize(400, 300)
			\Center()
			\MakePopup()
			\SetTitle('DMaps navigation request')
		self = DMaps.NavRequestWindow
		@bar = vgui.Create('DMapProgressBar', @)
		@bar\Dock(BOTTOM)
		@bar\SetSize(0, 40)

		@OnClose = ->
			net.Start('DMaps.Navigation.Stop')
			net.SendToServer()
		
		@oldPaint = @Paint
		@alpha = 0
		@Paint = (pnl, w, h) ->
			@alpha = math.min(@alpha + FrameTime() * 100, 160)
			surface.SetDrawColor(70, 70, 70, @alpha * .7)
			surface.DisableClipping(true)
			x, y = @LocalToScreen(0, 0)
			sw, sh = ScrW(), ScrH()
			surface.DrawRect(-x, -y, sw, sh)
			surface.DisableClipping(false)
			@oldPaint(w, h) if @oldPaint
		
		@label = vgui.Create('DLabel', @)
		@label\SetText('The Server is calculating')
		@label\SetFont('Trebuchet24')
		@label\SizeToContents()
		@label\Center()
		labX, labY = @label\GetPos()

		@label\SetPos(labX, 25)
		@label2 = vgui.Create('DLabel', @)
		@label2\SetText('path to required point...')
		@label2\SetFont('Trebuchet24')
		@label2\SizeToContents()
		@label2\Center()
		labX, labY = @label2\GetPos()
		@label2\SetPos(labX, 45)

		yShift = 80

		@totalIterations = vgui.Create('DLabel', @)
		with @totalIterations
			\SetPos(10, yShift)
			\SetText('Total iterations: ???')
			\SetSize(180, 20)
		@totalIterationsBar = vgui.Create('DMapProgressBar', @)
		with @totalIterationsBar
			\SetPos(200, yShift + 2)
			\SetSize(180, 15)
			\InvertColors()
		yShift += 20

		@openNodes = vgui.Create('DLabel', @)
		with @openNodes
			\SetPos(10, yShift)
			\SetText('Open nodes: ???')
			\SetSize(180, 20)
		@openNodesBar = vgui.Create('DMapProgressBar', @)
		with @openNodesBar
			\SetPos(200, yShift + 2)
			\SetSize(180, 15)
			\InvertColors()
		yShift += 20

		@closedNodes = vgui.Create('DLabel', @)
		with @closedNodes
			\SetPos(10, yShift)
			\SetText('Closed nodes: ???')
			\SetSize(180, 20)
		@closedNodesBar = vgui.Create('DMapProgressBar', @)
		with @closedNodesBar
			\SetPos(200, yShift + 2)
			\SetSize(180, 15)
			\InvertColors()
		yShift += 20

		@totalNodes = vgui.Create('DLabel', @)
		with @totalNodes
			\SetPos(10, yShift)
			\SetText('Total nodes: ???')
			\SetSize(180, 20)
		@totalNodesBar = vgui.Create('DMapProgressBar', @)
		with @totalNodesBar
			\SetPos(200, yShift + 2)
			\SetSize(180, 15)
			\InvertColors()
		yShift += 20

		@totalTime = vgui.Create('DLabel', @)
		with @totalTime
			\SetPos(10, yShift)
			\SetText('Total calculation time: ???ms')
			\SetSize(180, 20)
		@totalTimeBar = vgui.Create('DMapProgressBar', @)
		with @totalTimeBar
			\SetPos(200, yShift + 2)
			\SetSize(180, 15)
			\InvertColors()
		yShift += 35

		@requiredPointDistance = target\Distance(LocalPlayer()\GetPos())
		@requiredPointDistanceFormat = DMaps.FormatMetre(@requiredPointDistance)
		@distanceLeft = vgui.Create('DLabel', @)
		with @distanceLeft
			\SetPos(10, yShift)
			\SetText('Distance left: ???')
			\SetSize(180, 20)
		@distanceLeftBar = vgui.Create('DMapProgressBar', @)
		with @distanceLeftBar
			\SetPos(200, yShift + 2)
			\SetSize(180, 15)
		yShift += 25

		timer.Simple 1, ->
			if not IsValid(@) return
			@cancelButton = vgui.Create('DButton', @)
			@cancelButton\SetText('Cancel')
			@cancelButton\SetSize(380, 30)
			@cancelButton\SetPos(10, yShift)
			@cancelButton.DoClick = -> @Close()

NAV_OPEN_LIMIT = CreateConVar('sv_dmaps_nav_open_limit', '700', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'A* Searcher "open" nodes limit (at same time)')
NAV_LIMIT = CreateConVar('sv_dmaps_nav_limit', '4000', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'A* Searcher total iterations limit')
TIME_LIMIT = CreateConVar('sv_dmaps_nav_time_limit', '2500', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'A* Searcher total time limit (in milliseconds) per one search')

net.Receive 'DMaps.Navigation.Info', ->
	return if not IsValid(DMaps.NavRequestWindow)
	self = DMaps.NavRequestWindow

	iterations = net.ReadInt(16)
	onodes = net.ReadInt(16)
	cnodes = net.ReadInt(16)
	tnodes = net.ReadInt(16)
	calctime = net.ReadInt(16)
	distLeft = net.ReadInt(16)
	iterationsPercent = iterations / NAV_LIMIT\GetInt()
	onodesPercent = onodes / NAV_OPEN_LIMIT\GetInt()
	cnodesPercent = cnodes / (NAV_OPEN_LIMIT\GetInt() * 3)
	tnodesPercent = tnodes / (NAV_OPEN_LIMIT\GetInt() * 4)
	calctimePercent = calctime / TIME_LIMIT\GetInt()
	distanceLeftPercent = 1 - distLeft / @requiredPointDistance

	@totalIterations\SetText("Total iterations: #{iterations}/#{NAV_LIMIT\GetInt()}")
	@totalIterationsBar\SetPercent(iterationsPercent)
	@openNodes\SetText("Open nodes: #{onodes}/#{NAV_OPEN_LIMIT\GetInt()}")
	@openNodesBar\SetPercent(onodesPercent)
	@closedNodes\SetText("Closed nodes: #{cnodes}")
	@closedNodesBar\SetPercent(cnodesPercent)
	@totalNodes\SetText("Total nodes: #{tnodes}")
	@totalNodesBar\SetPercent(tnodesPercent)
	@totalTime\SetText("Total calculation time: #{calctime}/#{TIME_LIMIT\GetInt()}ms")
	@totalTimeBar\SetPercent(calctimePercent)
	@distanceLeft\SetText("Distance left: #{DMaps.FormatMetre(distLeft)}/#{@requiredPointDistanceFormat}")
	@distanceLeftBar\SetPercent(distanceLeftPercent)


Bezier = (vec1 = Vector(0, 0, 0), vec2 = Vector(0, 0, 0), vec3 = Vector(0, 0, 0), step = 0.1) ->
	{x: x1, y: y1, z: z1} = vec1
	{x: x2, y: y2, z: z2} = vec2
	{x: x3, y: y3, z: z3} = vec3
	output = for t = step, 1 - step, step
		x = (1 - t) ^ 2 * x1 + 2 * t * (1 - t) * x2 + t ^ 2 * x3
		y = (1 - t) ^ 2 * y1 + 2 * t * (1 - t) * y2 + t ^ 2 * y3
		z = (1 - t) ^ 2 * z1 + 2 * t * (1 - t) * z2 + t ^ 2 * z3
		Vector(x, y, z)
	return output


class DMapsNavigationTarget extends DMapWaypoint
	new: (x = 0, y = 0, z = 0) =>
		x, y, z = math.floor(x), math.floor(y), math.floor(z)
		super('Navigation target', x, y, z, Color(NAV_POINT_COLOR()), 'gear_in')
	
	OpenMenu: (menu = DermaMenu()) =>
		super(menu)
		with menu
			\AddOption('Stop navigation', DMaps.StopNavigation)\SetIcon('icon16/map_delete.png')
			\AddOption('Remove target point', -> @Remove())\SetIcon('icon16/cross.png')
			\Open()
		return true

net.Receive 'DMaps.Navigation.Require', ->
	status = net.ReadBool()

	if not status
		if DMaps.LastNavRequestWindow
			DMaps.NavRequestWindow\Remove() if IsValid(DMaps.NavRequestWindow)
			err = '%ERRORNAME%'
			errCode = net.ReadUInt(8)
			switch errCode
				when NAV_STATUS_GENERIC_FAILURE
					err = 'Generic error'
				when NAV_STATUS_FAILURE_TIME_LIMIT
					err = 'Calculation time limit exceeded'
				when NAV_STATUS_FAILURE_OPEN_NODES_LIMIT
					err = 'Too many open nodes'
				when NAV_STATUS_FAILURE_LOOPS_LIMIT
					err = 'Total iterations limit hit'
				when NAV_STATUS_FAILURE_NO_OPEN_NODES
					err = 'No open nodes (dead end)'
			Derma_Message("Server is unable to find a path to requested point\n:(\nError: '#{err}' (#{errCode})", 'DMaps navigation failure', 'OK')
		return
	else
		sysTime = SysTime()
		points = [Vector(net.ReadInt(16), net.ReadInt(16), net.ReadInt(16)) for i = 1, net.ReadUInt(16)]
		if points[1]\Distance(points[2]) < 300
			table.remove(points, 2)
		newPoints = {}

		for i = 2, #points, 2
			point1 = points[i - 1]
			point2 = points[i]
			point3 = points[i + 1]
			if not point1 or not point2 or not point3
				table.insert(newPoints, point1) if point1
				table.insert(newPoints, point2) if point2
				table.insert(newPoints, point3) if point3
				break
			for point in *Bezier(point1, point2, point3)
				table.insert(newPoints, point)

		DMaps.NavigationStart = newPoints[#newPoints]
		DMaps.NavigationEnd = newPoints[1]
		DMaps.IsNavigating = true

		local last
		DMaps.NavigationPoints = for point in *newPoints
			last = last or point
			output = {point, point\Distance(DMaps.NavigationEnd), approx: {}}
			distBetween = last\Distance(point)
			if distBetween >= 50
				for i = 50, distBetween, 50
					calcVector = LerpVector(i / distBetween, last, point)
					add = Vector(-20, 0, 0)
					add2 = Vector(-20, 0, 0)
					deltaAng = (last - calcVector)\Angle()
					deltaAng\RotateAroundAxis(deltaAng\Forward(), 90)
					deltaAng\RotateAroundAxis(deltaAng\Right(), 90)
					deltaAng\RotateAroundAxis(deltaAng\Forward(), -90)
					add\Rotate(deltaAng)
					{:p, :y, :r} = deltaAng
					deltaAngRotate = Angle(p, y, r)
					deltaAngRotate\RotateAroundAxis(deltaAngRotate\Forward(), 180)
					deltaAngRotate\RotateAroundAxis(deltaAngRotate\Up(), 180)
					add2\Rotate(deltaAngRotate)
					table.insert(output.approx, {calcVector + add, deltaAng, calcVector + add2, deltaAngRotate})
				last = point
			output

		{:x, :y, :z} = DMaps.NavigationEnd
		if DMaps.LastDisplayNavPoint
			lastNavPoint = DMapsNavigationTarget(x, y, z)
			map = DMaps.GetMainMap()
			map\AddObject(lastNavPoint) if map
		DMaps.NavRequestWindow\Remove() if DMaps.LastNavRequestWindow and IsValid(DMaps.NavRequestWindow)
		DMaps.Message('Clientside navigation processing took ', math.floor((SysTime() - sysTime) * 10000) / 10, ' milliseconds')
