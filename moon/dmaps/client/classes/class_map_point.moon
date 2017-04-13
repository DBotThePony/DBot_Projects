
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

class DMapPointer
	@TEXT_COLOR = Color(255, 255, 255)
	@UID = 0
	
	@generateTriangle = (x = 0, y = 0, ang = 0, hypo = 20, myShift = 30, height = 70) =>
		sin = math.sin(math.rad(ang))
		cos = math.cos(math.rad(ang))
		
		x -= myShift * cos
		y -= myShift * sin
		
		Ax, Ay = -hypo * sin, hypo * cos
		Bx, By = height * cos, height * sin
		Cx, Cy = hypo * sin, -hypo * cos
		
		trigData = {
			{x: x + Cx, y: y + Cy}
			{x: x + Bx, y: y + By}
			{x: x + Ax, y: y + Ay}
		}
		
		return trigData
	
	@__type = 'point'
	
	new: (x = 0, y = 0, z = 0) =>
		@ID = @@UID
		@@UID += 1
		@x = x
		@y = y
		@z = z
		@removed = false
	
	-- Called internally
	PositionChanged: => -- Override
	OnDataChanged: => -- Override
	
	GetID: => @ID
	ShouldDraw: (map) => map\PrefferDraw(@x, @y, @z)
	
	@MOUSE_CONSTANT = 70
	
	IsNearMouse: =>
		if not @map.mouseHit return false
		deltaX = @map.mouseX - @x
		deltaY = @map.mouseY - @y
		return deltaX > -@@MOUSE_CONSTANT and deltaX < @@MOUSE_CONSTANT and deltaY > -@@MOUSE_CONSTANT and deltaY < @@MOUSE_CONSTANT
	
	DrawWorld: (map) =>
		-- Do nothing
		-- Override
	
	SetX: (val = 0) =>
		@x = assert(val, 'number')
		@PositionChanged!
		@OnDataChanged!
	SetY: (val = 0) =>
		@y = assert(val, 'number')
		@PositionChanged!
		@OnDataChanged!
	SetZ: (val = 0) =>
		@z = assert(val, 'number')
		@PositionChanged!
		@OnDataChanged!
	SetPos: (val = Vector(0, 0, 0)) =>
		@x = val.x
		@y = val.y
		@z = val.z
		@PositionChanged!
		@OnDataChanged!
	
	GetX: => @x
	GetY: => @y
	GetZ: => @z
	GetPos: => Vector(@x, @y, @z)
	Remove: => @removed = true
	
	Draw: (map) => -- Override
	PreDraw: (map) => -- Override
	PostDraw: (map) => -- Override
	
	DrawHook: (map) =>
		@PreDraw(map)
		@Draw(map)
		@PostDraw(map)
	
	-- Simple check
	__eq: (other) =>
		return @ == other
	
	Think: (map) =>
		-- Override
	
	IsValid: => not @removed
	IsRemoved: => @removed

DMaps.DMapPointer = DMapPointer
return DMapPointer