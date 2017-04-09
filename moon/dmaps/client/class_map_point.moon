
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
	@generateTriangle = (x = 0, y = 0, ang = 0) ->
		sin = math.sin(math.rad(ang))
		cos = math.cos(math.rad(ang))
		
		newData = {
			{x: x + 7.5 * sin, y: y - 7.5 * cos}
			{x: x + 50 * cos, y: y - 50 * sin}
			{x: x - 7.5 * sin, y: y + 7.5 * cos}
		}
		
		return newData
	
	new: =>
		@__type = 'point'
		
		@x = 0
		@y = 0
		@z = 0
		@removed = false
		
	ShouldDraw: (map) => map\PrefferDraw(@x, @y, @z)
	
	SetX: (val = 0) => @x = assert(val, 'number')
	SetY: (val = 0) => @y = assert(val, 'number')
	SetZ: (val = 0) => @z = assert(val, 'number')
	
	GetX: => @x
	GetY: => @y
	GetZ: => @z
	
	SetPos: (val = Vector(0, 0, 0)) =>
		@x = val.x
		@y = val.y
		@z = val.z
	
	GetPos: => Vector(@x, @y, @z)
	
	Remove: =>
		@removed = true
	
	Draw: =>
		-- Override
	
	Think: =>
		-- Override
	
	IsValid: => not @removed
	
return DMapPointer