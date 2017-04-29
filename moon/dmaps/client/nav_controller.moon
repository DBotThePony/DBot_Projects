
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

local lastNavPoint

hook.Add 'DrawDMap2D', 'DMaps.Navigation', (x, y, w, h) =>
	return if not DMaps.NAV_ENABLE\GetBool()
	return if not DMaps.IsNavigating
	color = Color(255, 255, 255)
	pos = LocalPlayer()\GetPos()
	dist = DMaps.NavigationEnd\Distance(pos)
	local last
	
	for {v, nDist} in *DMaps.NavigationPoints
		if nDist > dist break
		last = last or v
		render.DrawLine(last, v, color)
		last = v

hook.Add 'DrawDMapWorld', 'DMaps.Navigation', =>
	return if not DMaps.NAV_ENABLE\GetBool()
	return if not DMaps.IsNavigating
	color = Color(255, 255, 255)
	pos = LocalPlayer()\GetPos()
	dist = DMaps.NavigationEnd\Distance(pos)
	local last
	
	for {v, nDist} in *DMaps.NavigationPoints
		if nDist > dist break
		last = last or v
		render.DrawLine(last, v, color)
		last = v

hook.Add 'Think', 'DMaps.Navigation', ->
	return if not DMaps.NAV_ENABLE\GetBool()
	return if not DMaps.IsNavigating
	if LocalPlayer()\GetPos()\Distance(DMaps.NavigationEnd) < 250
		DMaps.IsNavigating = false
		lastNavPoint\Remove() if IsValid(lastNavPoint)

DMaps.RequireNavigation = (target = Vector(0, 0, 0), displayWindow = true) ->
	return if not DMaps.NAV_ENABLE\GetBool()
	lastNavPoint\Remove() if IsValid(lastNavPoint)
	DMaps.IsNavigating = false
	DMaps.NavigationPoints = {}
	net.Start('DMaps.Navigation.Require')
	net.WriteVector(target)
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
	output = for t = 0, 1, step
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
		points = [Vector(net.ReadInt(16), net.ReadInt(16), net.ReadInt(16)) for i = 1, net.ReadUInt(16)]
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
		{:x, :y, :z} = DMaps.NavigationEnd
		lastNavPoint = DMapWaypoint('Navigation target', x, y, z, Color(NAV_POINT_COLOR()), 'gear_in')
		map = DMaps.GetMainMap()
		map\AddObject(lastNavPoint) if map
		DMaps.IsNavigating = true
		DMaps.NavigationPoints = [{point, point\Distance(DMaps.NavigationEnd)} for point in *newPoints]
		DMaps.NavRequestWindow\Remove() if DMaps.LastNavRequestWindow and IsValid(DMaps.NavRequestWindow)
