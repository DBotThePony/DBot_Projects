
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

DMaps.DeltaString = (z = 0, newline = true) ->
	delta = LocalPlayer()\GetPos().z - z
	return "#{DMaps.FormatMetre(delta)} lower" if delta > 200 and not newline
	return "\n#{DMaps.FormatMetre(delta)} lower" if delta > 200 and newline
	return "#{DMaps.FormatMetre(-delta)} upper" if -delta > 200 and not newline
	return "\n#{DMaps.FormatMetre(-delta)} upper" if -delta > 200 and newline
	return ''
DMaps.ChatPrint = (...) ->
	formated = DMaps.Format(...)
	chat.AddText(DMaps.CHAT_PREFIX_COLOR, DMaps.CHAT_PREFIX, DMaps.CHAT_COLOR, unpack(formated))
DMaps.WaypointAction = (x = 0, y = 0, z = 0) ->
	data, id = DMaps.ClientsideWaypoint.DataContainer\CreateWaypoint("New Waypoint At X: #{@x}, Y: #{@y}, Z: #{@z}", @x, @y, @z)
	DMaps.OpenWaypointEditMenu(id, DMaps.ClientsideWaypoint.DataContainer, (-> DMaps.ClientsideWaypoint.DataContainer\DeleteWaypoint(id))) if id