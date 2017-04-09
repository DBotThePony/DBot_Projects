
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

import DMapPointer from DMaps

class DMapEntityPointer extends DMapPointer
	@TRIANGLE_COLOR = Color(200, 200, 200)
	
	new: (entity = NULL) =>
		super!
		
		@__type = 'entity'
		@drawScale = 1
		
		@pitch = 0
		@yaw = 0
		@roll = 0
		@pos = Vector(0, 0, 0)
		@ang = Angle(0, 0, 0)
		
		@SetEntity(entity)
	
	UpdatePos: =>
		@pos = @entity\GetPos!
		
		@x = @pos.x
		@y = @pos.y
		@z = @pos.z
	
	UpdateAngles: =>
		@ang = @entity\GetAngles!
		
		@pitch = @ang.p
		@yaw = -@ang.y
		@roll = @ang.r
	
	GetEntity: => @entity
	
	PreDraw: (map) =>
		@DRAW_X, @DRAW_Y = map\Start2D(@x, @y)
	
	PostDraw: (map) =>
		map\Stop2D()
	
	Think: =>
		if IsValid(@entity)
			@UpdatePos!
			@UpdateAngles!
	
	SetEntity: (entity = NULL) =>
		@entity = entity
		
		if IsValid(@entity)
			@UpdatePos!
			@UpdateAngles!
			@entClass = @entity\GetClass!
		else
			@entClass = 'NULL'
	
	Draw: (map) =>
		trig = @@generateTriangle(@DRAW_X - 25, @DRAW_Y - 25, @yaw)
		
		surface.SetDrawColor(@@TRIANGLE_COLOR)
		surface.DrawPoly(trig)
	
	DrawHook: (map) =>
		if IsValid(@entity)
			@PreDraw(map)
			@Draw(map)
			@PostDraw(map)
	
	__eq: (other) =>
		if type(other) == 'table' and other.__type == 'entity'
			return @entity == other.entity
		else
			return @ == other
	
	IsValid: =>
		if not super! then return false
		return IsValid(@entity)

return DMapEntityPointer
