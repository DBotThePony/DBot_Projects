
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

import DMaps from _G
import DMapWaypoint from DMaps

DMaps.NAV_ENABLE = CreateConVar('sv_dmaps_nav_enable', '1', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable navigation support (if map has nav file)')

DMaps.IsNavigating = false
DMaps.NavigationPoints = {}
DMaps.LastNavRequestWindow = true
DMaps.NavigationStart = Vector(0, 0, 0)
DMaps.NavigationEnd = Vector(0, 0, 0)

NAV_POINT_COLOR = DMaps.CreateColor(255, 255, 255, 'nav_target', 'Navigation target point color')
NAV_ARROW_COLOR = DMaps.CreateColor(34, 209, 217, 'nav_arrow', 'Navigation arrows color')
DRAW_DIST = CreateConVar('cl_dmaps_nav_line_dist', '1000', {FCVAR_ARCHIVE}, 'How far navigation path should draw')

ARROW_DATA_1 = {
	{x: 0, y: 15}
	{x: 20, y: 0}
	{x: 20, y: 5}
	{x: 0, y: 20}
}

ARROW_DATA_2 = {
	{x: 20, y: 0}
	{x: 40, y: 15}
	{x: 40, y: 20}
	{x: 20, y: 5}
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
			deltaZ = math.abs(z - Z)
			if deltaZ > 200 continue
			yaw = math.rad(-deltaAng.y)
			sin, cos = math.sin(yaw), math.cos(yaw)
			alpha = 1
			alpha = math.Clamp(1 - (deltaZ - 50) / 150, 0.2, 1) if deltaZ > 50
			surface.SetDrawColor(colorR, colorG, colorB, 255 * alpha)

			xDraw, yDraw = @Start2D(x, y)
			newArrow1 = [{x: (xC - 10) * cos - yC * sin + xDraw, y: yC * cos + (xC - 10) * sin + yDraw} for {x: xC, y: yC} in *ARROW_DATA_1]
			newArrow2 = [{x: (xC - 10) * cos - yC * sin + xDraw, y: yC * cos + (xC - 10) * sin + yDraw} for {x: xC, y: yC} in *ARROW_DATA_2]
			surface.DrawPoly(newArrow1)
			surface.DrawPoly(newArrow2)
			cam.End3D2D()
			

hook.Add 'DrawDMapWorld', 'DMaps.Navigation', =>
	return if not DMaps.NAV_ENABLE\GetBool()
	return if not DMaps.IsNavigating
	dist = DMaps.NavigationEnd\Distance(LocalPlayer()\GetPos())
	mDist = DRAW_DIST\GetInt()
	
	cam.IgnoreZ(true)
	draw.NoTexture()
	surface.SetDrawColor(NAV_ARROW_COLOR())

	for {point, nDist, :approx} in *DMaps.NavigationPoints
		if nDist + mDist < dist continue
		if nDist - mDist > dist continue
		for {v, deltaAng} in *approx
			cam.Start3D2D(v, deltaAng, 1)
			surface.DrawPoly(ARROW_DATA_1)
			surface.DrawPoly(ARROW_DATA_2)
			cam.End3D2D()
	
	cam.IgnoreZ(false)

hook.Add 'Think', 'DMaps.Navigation', ->
	return if not DMaps.NAV_ENABLE\GetBool()
	return if not DMaps.IsNavigating
	if LocalPlayer()\GetPos()\Distance(DMaps.NavigationEnd) < 125
		DMaps.IsNavigating = false
		lastNavPoint\Remove() if IsValid(lastNavPoint)

DMaps.RequireNavigation = (target = Vector(0, 0, 0), displayWindow = true) ->
	return if not DMaps.NAV_ENABLE\GetBool()
	lastNavPoint\Remove() if IsValid(lastNavPoint)
	{:x, :y, :z} = target
	x, y, z = math.floor(x), math.floor(y), math.floor(z)
	DMaps.IsNavigating = false
	DMaps.NavigationPoints = {}
	net.Start('DMaps.Navigation.Require')
	net.WriteVector(Vector(x, y, z))
	net.SendToServer()
	DMaps.LastNavRequestWindow = displayWindow

	if displayWindow
		DMaps.NavRequestWindow\Remove() if IsValid(DMaps.NavRequestWindow)
		DMaps.NavRequestWindow = vgui.Create('DFrame')
		with DMaps.NavRequestWindow
			\SetSize(400, 200)
			\Center()
			\MakePopup()
			\SetTitle('DMaps navigation request')
		self = DMaps.NavRequestWindow
		@bar = vgui.Create('EditablePanel', @)
		@bar\Dock(BOTTOM)
		@bar.currentPos = 0
		@bar.action = true
		@bar.Paint = (pnl, w, h) ->
			if @bar.action
				@bar.currentPos += FrameTime() * 200
			else
				@bar.currentPos -= FrameTime() * 200
			if @bar.currentPos < 0 or @bar.currentPos > w - 15
				@bar.action = not @bar.action
			surface.SetDrawColor(220, 220, 220)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(146, 176, 172)
			surface.DrawRect(@bar.currentPos, 0, 15, h)
		@label = vgui.Create('DLabel', @)
		@label\Dock(FILL)
		@label\SetText('The Server is calculating path to required point...')

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

net.Receive 'DMaps.Navigation.Require', ->
	status = net.ReadBool()

	if not status
		if DMaps.LastNavRequestWindow
			DMaps.NavRequestWindow\Remove() if IsValid(DMaps.NavRequestWindow)
			Derma_Message('Server is unable to find a path to requested point\n:(', 'DMaps navigation failure', 'OK')
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
					deltaAng = (last - calcVector)\Angle()
					deltaAng\RotateAroundAxis(deltaAng\Forward(), 90)
					deltaAng\RotateAroundAxis(deltaAng\Right(), 90)
					deltaAng\RotateAroundAxis(deltaAng\Forward(), -90)
					add\Rotate(deltaAng)
					table.insert(output.approx, {calcVector + add, deltaAng})
				last = point
			output

		{:x, :y, :z} = DMaps.NavigationEnd
		lastNavPoint = DMapWaypoint('Navigation target', math.floor(x), math.floor(y), math.floor(z), Color(NAV_POINT_COLOR()), 'gear_in')
		map = DMaps.GetMainMap()
		map\AddObject(lastNavPoint) if map
		DMaps.NavRequestWindow\Remove() if DMaps.LastNavRequestWindow and IsValid(DMaps.NavRequestWindow)
		DMaps.Message('Clientside navigation processing took ', math.floor((SysTime() - sysTime) * 10000) / 10, ' milliseconds')
