
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

import DMaps, Color, LocalPlayer, surface from _G
import DMapPlayerPointer from DMaps

POINTER_COLOR = DMaps.CreateColor(80, 80, 200, 'local_player', 'Local player arrow')

class DMapLocalPlayerPointer extends DMapPlayerPointer
	new: =>
		super(LocalPlayer!)
	
	IsValid: =>
		if @IsRemoved! return false
		return true
	
	ShouldDraw: => true
	
	CalculatePlayerVisibility: => true

	OpenMenu: => false
	GetRenderPriority: => 1000
	
	Draw: (map) =>
		trig = @@generateTriangle(@DRAW_X, @DRAW_Y, @yaw, 50, 50, 170)
		
		surface.SetDrawColor(POINTER_COLOR())
		surface.DrawPoly(trig)
		
		surface.SetFont(@@FONT)
		
		text = @playerName
		w, h = surface.GetTextSize(text)

		surface.SetDrawColor(@@BACKGROUND_COLOR)
		surface.DrawRect(@DRAW_X - w / 2 - 6, @DRAW_Y + 46, w + 12, h + 8)
		
		surface.SetTextPos(@DRAW_X - w / 2, @DRAW_Y + 50)
		surface.SetTextColor(color_white)
		surface.DrawText(text)

DMaps.DMapLocalPlayerPointer = DMapLocalPlayerPointer
return DMapLocalPlayerPointer
