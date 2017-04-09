
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

import DMapEntityPointer from DMaps

class DMapPlayerPointer extends DMapEntityPointer
	new: (ply = NULL) =>
		super(ply)
		@playerName = '%PLAYERNAME%'
		@color = Color(50, 50, 50)
		@teamID = 0
	
	ShouldDraw: => true
	
	Think: (map) =>
		super(map)
		
		if IsValid(@entity)
			ply = @entity
			@playerName = ply\Nick()
			@teamID = ply\Team!
			@color = team.GetColor(@teamID)
	
	Draw: (map) =>
		trig = @@generateTriangle(@DRAW_X - 25, @DRAW_Y - 25, @yaw)
		
		surface.SetDrawColor(color_white)
		surface.DrawRect(0, 0, 100, 100)
		
		surface.SetDrawColor(@color)
		surface.DrawPoly(trig)

return DMapPlayerPointer
