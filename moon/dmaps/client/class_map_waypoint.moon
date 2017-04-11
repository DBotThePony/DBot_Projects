
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

import DMapPointer from DMaps

surface.CreateFont('DMaps.WaypointName', {
	font: 'Roboto',
	size: 48
	weight: 500
})

class DMapWaypoint extends DMapPointer
	@__type = 'waypoint'
	
	@TEXT_BACKGROUND_COLOR = Color(0, 0, 0, 150)
	@TEXT_FONT = 'DMaps.WaypointName'
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
	
	new: (name = "%WAYPOINT_#{@@UID}%", x = 0, y = 0, z = 0) =>
		super(x, y, z)
		@drawInWorld = true
		@pointName = name
		@name = name
		@color = Color(math.random(1, 255), math.random(1, 255), math.random(1, 255))
		@zoom = 60
	
	PreDraw: (map) => @DRAW_X, @DRAW_Y = map\Start2D(@x, @y)
	PostDraw: (map) => map\Stop2D()
	ShouldDraw: (map) => true
	SetSize: (val = 1) => @zoom = 60 * val
	
	GetText: =>
		text = @name
		if @IsNearMouse!
			text ..= "\nX: #{@x}; Y: #{@y}; Z: #{@z}"
		return text
	
	Draw: (map) =>
		x, y = @DRAW_X, @DRAW_Y
		draw.NoTexture!
		
		with surface
			.SetDrawColor(@color)
			.DrawPoly(@@generateSquare(x, y, @zoom))
			.SetFont(@@TEXT_FONT)
			.SetDrawColor(@@TEXT_BACKGROUND_COLOR)
			
			text = @GetText!
			w, h = .GetTextSize(text)
			.DrawRect(x - @@TEXT_BACKGROUND_SHIFT - w / 2, y - @@TEXT_BACKGROUND_SHIFT + 10 + @zoom, w + @@TEXT_BACKGROUND_SHIFT * 2, h + @@TEXT_BACKGROUND_SHIFT * 2)
			draw.DrawText(text, @@TEXT_FONT, x, y + @zoom + 10, @@TEXT_COLOR, TEXT_ALIGN_CENTER)

DMaps.DMapWaypoint = DMapWaypoint
return DMapWaypoint
