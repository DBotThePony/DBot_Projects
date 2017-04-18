
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

import util from _G

util.AddNetworkString 'DMaps.AdminEcho'
util.AddNetworkString 'DMaps.NetworkedWaypoint'
util.AddNetworkString 'DMaps.NetworkedWaypointChanges'
util.AddNetworkString 'DMaps.NetworkedWaypointRemoved'

ClientsideFiles = {
	'dmaps/client/classes/class_map.lua'
	'dmaps/client/classes/class_map_point.lua'
	'dmaps/client/classes/class_map_entity_point.lua'
	'dmaps/client/classes/class_player_point.lua'
	'dmaps/client/classes/class_lplayer_point.lua'
	'dmaps/client/classes/class_map_waypoint.lua'
	'dmaps/client/classes/waypoints_holder.lua'
	'dmaps/client/classes/class_clientside_waypoint.lua'

	'dmaps/client/controls/control_compass.lua'
	'dmaps/client/controls/control_arrows.lua'
	'dmaps/client/controls/control_zoom.lua'
	'dmaps/client/controls/control_buttons.lua'
	'dmaps/client/controls/abstract_map_holder.lua'
	'dmaps/client/controls/waypoint_row.lua'
	'dmaps/client/controls/icons_list.lua'

	'dmaps/client/default_gui.lua'
	'dmaps/client/waypoints_controller.lua'
	'dmaps/client/network.lua'
	
	'dmaps/common/functions.lua'
	'dmaps/common/icons.lua'
	'dmaps/common/classes/networked_waypoint.lua'
	
	'dmaps/cl_init.lua'
	'dmaps/sh_init.lua'
}

AddCSLuaFile v for v in *ClientsideFiles

ServersideFiles = {
	'dmaps/sh_init.lua'
	
	'dmaps/common/icons.lua'
	'dmaps/common/functions.lua'
	'dmaps/common/classes/networked_waypoint.lua'
	
	'dmaps/server/classes/waypoints_holder.lua'
	'dmaps/server/classes/waypoints_controller.lua'
	
	'dmaps/server/classes/waypoints_holder_team.lua'
	'dmaps/server/classes/waypoint_team.lua'
	
	'dmaps/server/functions.lua'
	'dmaps/server/commands.lua'
}

include v for v in *ServersideFiles