
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

resource.AddWorkshop('916067750')

ClientsideFiles = {
	'client/classes/class_map.lua'
	'client/classes/class_map_point.lua'
	'client/classes/event_point.lua'
	'client/classes/deathpoint.lua'
	'client/classes/class_map_entity_point.lua'
	'client/classes/player_filter.lua'
	'client/classes/class_player_point.lua'
	'client/classes/class_lplayer_point.lua'
	'client/classes/class_map_waypoint.lua'
	'client/classes/waypoints_holder.lua'
	'client/classes/class_clientside_waypoint.lua'
	'client/classes/minimap_entities.lua'
	'client/classes/minimap_npcs.lua'
	'client/classes/minimap_vehicles.lua'

	'client/controls/control_compass.lua'
	'client/controls/control_arrows.lua'
	'client/controls/control_zoom.lua'
	'client/controls/control_clip.lua'
	'client/controls/control_buttons.lua'
	'client/controls/abstract_map_holder.lua'
	'client/controls/waypoint_row.lua'
	'client/controls/waypoint_row.server.lua'
	'client/controls/icons_list.lua'

	'client/darkrp_event_points.lua'
	'client/cami_wrapper.lua'
	'client/functions.lua'
	'client/options.lua'
	'client/default_gui.lua'
	'client/waypoints_controller.lua'
	'client/server_waypoints_gui.lua'
	'client/network.lua'
	'client/misc.lua'
	'client/nav_controller.lua'
	
	'common/functions.lua'
	'common/icons.lua'
	'common/classes/networked_waypoint.lua'
	
	'common/sh_cami.lua'
	'common/access.lua'
	
	'cl_init.lua'
	'sh_init.lua'
}

AddCSLuaFile "dmaps/#{File}" for File in *ClientsideFiles

ServersideFiles = {
	'sh_init.lua'

	'server/network.lua'
	'server/cvars.lua'
	
	'common/classes/networked_waypoint.lua'
	
	'server/classes/a_star_searcher.lua'
	'server/classes/waypoints_holder.lua'
	'server/classes/waypoints_holder_team.lua'
	'server/classes/waypoints_holder_usergroup.lua'
	'server/classes/waypoints_holder_cami.lua'
	
	'server/classes/waypoint_basic.lua'
	'server/classes/waypoint_team.lua'
	'server/classes/waypoint_usergroup.lua'
	'server/classes/waypoint_cami.lua'
	
	'server/functions.lua'
	'server/commands.lua'
	'server/hooks.lua'
	'server/nav_controller.lua'
}

PostFiles = {
	'server/darkrp_event_points.lua'
}

include "dmaps/#{File}" for File in *ServersideFiles
timer.Simple 0, -> include "dmaps/#{File}" for File in *PostFiles
