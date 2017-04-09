
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

generateTriangle = (x = 0, y = 0, ang = 0, hypo = 30) ->
	sin = math.sin(math.rad(ang))
	cos = math.cos(math.rad(ang))
	
	hypo *= 0.5
	
	Ax, Ay = -hypo * sin, hypo * cos
	Bx, By = hypo * cos * 2, hypo * sin * 2
	Cx, Cy = hypo * sin, -hypo * cos
	
	trigData = {
		{x: x + Cx, y: y + Cy}
		{x: x + Bx, y: y + By}
		{x: x + Ax, y: y + Ay}
	}
	
	return trigData

generateCircle = (x = 0, y = 0, radius = 0) ->
	reply = {}
	
	table.insert(reply, {:x, :y, u: 0.5, v: 0.5})
	
	for i = 0, 60 do
		rad = math.rad((i / 60) * -360)
		sin, cos = math.sin(rad), math.cos(rad)
		
		data = {
			x: x + sin * radius
			y: y + cos * radius
			u: sin / 2 + 0.5
			v: cos / 2 + 0.5
		}
		
		table.insert(reply, data)

	table.insert(reply, {:x, y: y + radius, u: 0.5, v: 1})
	return reply

PANEL = {}

PANEL.BACKGROUND_COLOR = Color(0, 0, 0, 150)

PANEL.Init = =>
	@UpdateCache!
	@yaw = 0
	@SetSize(128, 128)
	@targetyaw = 0

PANEL.SetMap = (map) =>
	@mapObject = map
	@yaw = @mapObject\GetYaw!
	@targetyaw = @yaw
	@UpdateCache!

PANEL.OnYawChanges = =>
	@mapObject\SetYaw(@yaw)
	@BuildTriangle!

PANEL.Think = =>
	if @yaw ~= @targetyaw
		@yaw = Lerp(0.2, @yaw, @targetyaw)
		@OnYawChanges!
	
	if @mapObject\GetYaw! ~= @yaw
		@mapObject\SetYaw(@yaw)

PANEL.UpdateCache = =>
	@BuildCircle!
	@BuildTriangle!

PANEL.InvalidateLayout = =>
	@UpdateCache!

PANEL.BuildTriangle = =>
	if @__cahcedTopYaw ~= @yaw then
		@__cahcedTopYaw = @yaw
		w, h = @GetSize!
		@northPart = generateTriangle(w / 2, h / 2, @yaw - 90, w / 2.5)
	
	if @__cahcedBottomYaw ~= @yaw
		@__cahcedBottomYaw = @yaw
		w, h = @GetSize!
		@southPart = generateTriangle(w / 2, h / 2, @yaw + 90, w / 2.5)
	
PANEL.BuildCircle = =>
	w, h = @GetSize!
	
	x = w / 2
	y = h / 2
	
	@circleOuter = generateCircle(x, y, 64)
	@circleInner = generateCircle(x, y, 58)

PANEL.Paint = (w, h) =>
	draw.NoTexture!
	
	surface.SetDrawColor(@BACKGROUND_COLOR)
	surface.DrawRect(0, 0, w, h)
	
	surface.SetDrawColor(40, 70, 180)
	surface.DrawPoly(@circleOuter)
	
	surface.SetDrawColor(200, 200, 200)
	surface.DrawPoly(@circleInner)
	
	surface.SetDrawColor(255, 0, 0)
	surface.DrawPoly(@northPart)
	
	surface.SetDrawColor(230, 230, 230)
	surface.DrawPoly(@southPart)

DMaps.PANEL_MAP_COMPASS = PANEL
return PANEL
