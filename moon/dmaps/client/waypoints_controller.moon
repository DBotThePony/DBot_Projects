
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

import DMaps, vgui, ScrW, ScrH from _G
import WaypointsDataContainer, ClientsideWaypoint from DMaps

WaypointsDataContainer\CreateTables!

DMaps.LoadWaypoints = ->
	status = ClientsideWaypoint.LoadWaypoints(false)
	if status == false
		chat.AddText('[DMaps] ERROR LOADING CLIENTSIDE WAYPOINTS:')
		chat.AddText(sql.LastError!)
	elseif status == nil
		chat.AddText('[DMaps] No waypoints found for this server/map')
		
timer.Simple(0, DMaps.LoadWaypoints)

DMaps.OpenWaypointsMenu = ->
	frame = vgui.Create('DFrame')
	self = frame
	
	w, h = ScrW! - 200, ScrH! - 200
	@SetSize(w, h)
	@SetTitle('DMap Clientside waypoints menu')
	@Center!
	@MakePopup!
	
	
	
	return frame