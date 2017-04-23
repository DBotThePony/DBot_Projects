
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

-- Yeah, waypoints

import DMaps, surface, Color, math, draw, TEXT_ALIGN_CENTER from _G
import math, Vector, Angle, render, cam, CreateConVar, table from _G
import DMapPointer, HU_IN_METRE, Icon from DMaps

DMaps.WatchPermission('teleport')

DRAW_DISTANCE = DMaps.ClientsideOption('cl_dmap_draw_dist', '1', 'Draw distance under waypoint name')
DRAW_BEAM = DMaps.ClientsideOption('cl_dmap_draw_beam', '1', 'Draw waypoint beam')
DRAW_IN_WORLD = DMaps.ClientsideOption('cl_dmap_draw_waypoints', '1', 'Draw waypoints in world')

surface.CreateFont('DMaps.WaypointName', {
	font: 'Roboto',
	size: 48
	weight: 500
})

surface.CreateFont('DMaps.WaypointNameSmaller', {
	font: 'Roboto',
	size: 36
	weight: 500
})

surface.CreateFont('DMaps.WaypointNameSmall', {
	font: 'Roboto',
	size: 24
	weight: 500
})

surface.CreateFont('DMaps.WaypointNameSmall2', {
	font: 'Roboto',
	size: 18
	weight: 500
})

surface.CreateFont('DMaps.WaypointNameSmall3', {
	font: 'Roboto',
	size: 14
	weight: 500
})

class DMapWaypoint extends DMapPointer
	@__type = 'waypoint'
	
	@TEXT_BACKGROUND_COLOR = Color(0, 0, 0, 150)
	@TEXT_FONT = 'DMaps.WaypointName'
	@TEXT_FONT_SMALL = 'DMaps.WaypointNameSmall'
	@TEXT_FONT_SMALLER = 'DMaps.WaypointNameSmaller'
	@TEXT_FONT_SMALL2 = 'DMaps.WaypointNameSmall2'
	@TEXT_FONT_SMALL3 = 'DMaps.WaypointNameSmall3'
	@TEXT_COLOR = Color(255, 255, 255)
	@TEXT_BACKGROUND_SHIFT = 4
	
	@HU_IN_METR = 40
	@HuToMemtr = (val = 0) =>
	
	@generateSquare = (x = 0, y = 0, size = 30) =>
		output = {
			{x: x, y: y - size / 2}
			{x: x + size / 2, y: y}
			{x: x, y: y + size / 2}
			{x: x - size / 2, y: y}
		}
		
		return output
	
	new: (name = "%WAYPOINT_#{@@UID}%", x = 0, y = 0, z = 0, color = DMaps.RandomColor(), icon = Icon\GetDefaultIcon()) =>
		super(x, y, z)
		@drawInWorld = true
		@pointName = name
		@icon = icon if type(icon) == 'table'
		@icon = Icon(icon) if type(icon) == 'string'
		@name = name
		@color = color
		@zoom = 60
		@visible = true
	
	@WORLD_BOXES = {}
	for i = 30, 5, -10
		mins = Vector(-i, -i, -2000)
		maxs = Vector(i, i, 4000)
		table.insert(@WORLD_BOXES, {:mins, :maxs})

	SetIcon: (val = Icon.DefaultIconName) => @icon = Icon(val)
	SetIconObject: (val) => @icon = val
	GetIcon: => @icon
	GetIconName: => @icon\GetName()
	
	PreDraw: (map) => @DRAW_X, @DRAW_Y = map\Start2D(@x, @y)
	PostDraw: (map) => map\Stop2D()
	ShouldDraw: (map) => true
	SetSize: (val = 1) => @zoom = 60 * val
	
	SetDrawInWorld: (val = true) => @drawInWorld = val
	GetDrawInWorld: => @drawInWorld
	ShouldDrawInWorld: => @drawInWorld and @visible
	
	@MAX_DRAW_DIST = 1000
	
	OnDataChanged: =>
		super!
		@BuildBoxes!
	
	@BOX_MATERIAL = Material('models/debug/debugwhite')
	@BLEND = 0.1
	@BOX_ANGLES = Angle(0, 0, 0)
	@NORMAL_LEFT = Vector(0, 1, 0)
	@BOX_MATERIAL\SetFloat('$alpha', @@BLEND)
	
	OpenMenu: (menu = DermaMenu()) =>
		with menu
			\AddOption('Teleport to', -> RunConsoleCommand('dmaps_teleport', @x, @y, @z)) if DMaps.HasPermission('teleport')
			\AddOption('Copy XYZ position', -> SetClipboardText("X: #{@x}, Y: #{@y}, Z: #{@z}"))
			\AddOption('Copy name', -> SetClipboardText(@name))
			\AddOption('Copy Data string', -> SetClipboardText("Name: #{@name}, X: #{@x}, Y: #{@y}, Z: #{@z}"))
			\Open()
		return true
	
	DrawWorld: (map) =>
		return if not DRAW_IN_WORLD\GetBool()
		return if not @ShouldDrawInWorld()
		pos = @GetPos()
		scr = pos\ToScreen()
		w, h = ScrW!, ScrH!
		if scr.x > w + 100 or scr.x < -100 return
		-- if scr.y > h + 100 or scr.y < -100 return
		
		if DRAW_BEAM\GetBool()
			@@BOX_MATERIAL\SetVector('$color', Vector(@color.r / 255, @color.g / 255, @color.b / 255))
			render.SuppressEngineLighting(true)
			render.SetMaterial(@@BOX_MATERIAL)
			
			for box in *@@WORLD_BOXES
				render.DrawBox(pos, @@BOX_ANGLES, box.mins, box.maxs, Color(@color.r, @color.b, @color.g, 255 * @@BLEND), true)
			
			render.SuppressEngineLighting(false)
		
		x, y = w / 2, h / 2
		dist = ((x - scr.x) ^ 2 + (y - scr.y) ^ 2) ^ 0.5
		alpha = math.Clamp((200 - dist) / 180, 0.1, 1)
		
		epos = LocalPlayer()\EyePos()
		pdist = epos\Distance(pos)
		
		cam.Start2D()
		@DrawInternal(scr.x, scr.y, math.Clamp((@@MAX_DRAW_DIST - pdist) / @@MAX_DRAW_DIST, 0.1, 1), alpha)
		cam.End2D()
	
	GetColor: => @color
	SetColor: (color = DMaps.RandomColor()) =>
		@color = color
		@OnDataChanged!
	GetIsVisible: => @visible
	SetIsVisible: (val = true) =>
		@visible = val
		@OnDataChanged!
	SetName: (val = "%WAYPOINT_#{@ID}%") =>
		@pointName = val
		@name = val
		@OnDataChanged!
	
	GetText: =>
		text = @name
		text ..= "\nDistance: #{math.floor(LocalPlayer()\EyePos()\Distance(@GetPos()) / HU_IN_METRE * 10) / 10} metres" if DRAW_DISTANCE\GetBool()
		if @IsNearMouse!
			text ..= "\nX: #{@x}; Y: #{@y}; Z: #{@z}"
		return text
	DrawInternal: (x = 0, y = 0, size = 1, alpha = 1) =>
		draw.NoTexture!
		
		with surface
			.SetDrawColor(@color.r, @color.g, @color.b, @color.a * alpha)
			--.DrawPoly(@@generateSquare(x, y, @zoom * math.max(size, 0.3)))
			@icon\Draw(x, y, @zoom * math.max(size, 0.3) / 30, true)
			pickFont = @@TEXT_FONT if size >= 1
			pickFont = @@TEXT_FONT_SMALLER if size < 1 and size > 0.5
			pickFont = @@TEXT_FONT_SMALL if size < 0.5
			pickFont = @@TEXT_FONT_SMALL2 if size < 0.3
			pickFont = @@TEXT_FONT_SMALL3 if size <= 0.1
			.SetFont(pickFont)
			.SetDrawColor(@@TEXT_BACKGROUND_COLOR.r, @@TEXT_BACKGROUND_COLOR.g, @@TEXT_BACKGROUND_COLOR.b, @@TEXT_BACKGROUND_COLOR.a * alpha)
			
			text = @GetText!
			w, h = .GetTextSize(text)
			.DrawRect(x - @@TEXT_BACKGROUND_SHIFT - w / 2, y - @@TEXT_BACKGROUND_SHIFT + 10 + @zoom * size, w + @@TEXT_BACKGROUND_SHIFT * 2, h + @@TEXT_BACKGROUND_SHIFT * 2)
			draw.DrawText(text, pickFont, x, y + @zoom * size + 10, Color(@@TEXT_COLOR.r, @@TEXT_COLOR.g, @@TEXT_COLOR.b, @@TEXT_COLOR.a * alpha), TEXT_ALIGN_CENTER)
	Draw: (map) =>
		x, y = @DRAW_X, @DRAW_Y
		@DrawInternal(x, y)

DMaps.DMapWaypoint = DMapWaypoint
return DMapWaypoint
