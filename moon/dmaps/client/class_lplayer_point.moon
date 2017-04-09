
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

import DMapPlayerPointer from DMaps

class DMapLocalPlayerPointer extends DMapPlayerPointer
	@PointerColor = Color(80, 80, 210)
	
	new: =>
		super(LocalPlayer!)
	
	IsValid: =>
		if @IsRemoved! return false
		return true
	
	ShouldDraw: => true
	
	CalculatePlayerVisibility: => true
	
	Draw: (map) =>
		trig = @@generateTriangle(@DRAW_X, @DRAW_Y, @yaw, 40, 50, 200)
		
		surface.SetDrawColor(@@PointerColor)
		surface.DrawPoly(trig)
		
		surface.SetFont(@@FONT)
		
		text = "Local Player (#{@playerName})"
		w, h = surface.GetTextSize(text)
		
		surface.SetTextPos(@DRAW_X - w / 2, @DRAW_Y + 50)
		surface.SetTextColor(color_white)
		surface.DrawText(text)

DMaps.DMapLocalPlayerPointer = DMapLocalPlayerPointer
return DMapLocalPlayerPointer
