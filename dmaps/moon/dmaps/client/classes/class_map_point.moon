
--
-- Copyright (C) 2017-2019 DBotThePony
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

	@Filter = (obj) => obj.__class.__type == @__type

	@generateTriangle = (x = 0, y = 0, ang = 0, hypo = 20, myShift = 30, height = 70) =>
		sin = math.sin(math.rad(ang))
		cos = math.cos(math.rad(ang))

		hH = height * .2

		x -= myShift * cos
		y -= myShift * sin

		Ax, Ay = -hypo * sin, hypo * cos
		Bx, By = height * cos, height * sin
		Cx, Cy = hypo * sin, -hypo * cos
		Dx, Dy = hH * cos, hH * sin

		trigData = {
			{x: x + Dx, y: y + Dy}
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
		@creationstamp = RealTime()
		@creationstampSync = CurTime()

	CurTime: => CurTime() - @creationstampSync
	RealTime: => RealTime() - @creationstamp
	GetStamp: => @creationstamp
	GetSyncStamp: => @creationstampSync
	-- Called internally
	PositionChanged: => -- Override
	OnDataChanged: => -- Override

	GetID: => @ID
	ShouldDraw: (map) => map\PrefferDraw(@x, @y, @z)

	@MOUSE_CONSTANT = 70

	-- True - menu is opened
	-- False - Point has no menu
	OpenMenu: => -- Override
		return false
	KeyPress: (code = KEY_NONE) => -- Override
		return false

	IsNearMouse: =>
		if not @CURRENT_MAP.mouseHit return false
		deltaX = @CURRENT_MAP.mouseX - @x
		deltaY = @CURRENT_MAP.mouseY - @y
		return deltaX > -@@MOUSE_CONSTANT and deltaX < @@MOUSE_CONSTANT and deltaY > -@@MOUSE_CONSTANT and deltaY < @@MOUSE_CONSTANT

	DrawWorldHook: (map) =>
		@CURRENT_MAP = map
		@PreDrawWorld(map)
		@DrawWorld(map)
		@PostDrawWorld(map)

	PreDrawWorld: (map) => -- Override
	PostDrawWorld: (map) => -- Override
	DrawWorld: (map) => -- Override

	GetRenderPriority: => 0

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
		@CURRENT_MAP = map
	PreDraw: (map) => -- Override
		@CURRENT_MAP = map
	PostDraw: (map) => -- Override
		@CURRENT_MAP = map

	DrawHook: (map) =>
		@CURRENT_MAP = map
		@PreDraw(map)
		@Draw(map)
		@PostDraw(map)

	-- Simple check
	__eq: (other) =>
		return @ == other

	Think: (map) => -- Override
		@CURRENT_MAP = map

	IsValid: => not @removed
	IsRemoved: => @removed

DMaps.DMapPointer = DMapPointer
return DMapPointer