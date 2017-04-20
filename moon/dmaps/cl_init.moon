
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

import CreateConVar from _G

include 'dmaps/sh_init.lua'

Files = {
	'dmaps/common/icons.lua'
	'dmaps/common/functions.lua'
	
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
	'dmaps/client/controls/waypoint_row.server.lua'
	'dmaps/client/controls/icons_list.lua'

	'dmaps/client/default_gui.lua'
	'dmaps/client/waypoints_controller.lua'
	'dmaps/client/server_waypoints_gui.lua'
	'dmaps/client/network.lua'
	
	'dmaps/common/classes/networked_waypoint.lua'
}

DMaps.CONVARS_SETTINGS = {}

DMaps.ClientsideOption = (cvar, default, desc) ->
	object = CreateConVar(cvar, default, {FCVAR_ARCHIVE}, desc)
	table.insert(DMaps.CONVARS_SETTINGS, {cvar, desc})
	return object

include file for file in *Files
