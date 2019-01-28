
--
-- Copyright (C) 2017-2019 DBot

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.


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

	'client/controls/progress_bar.lua'
	'client/controls/control_compass.lua'
	'client/controls/control_arrows.lua'
	'client/controls/control_zoom.lua'
	'client/controls/control_clip.lua'
	'client/controls/control_buttons.lua'
	'client/controls/abstract_map_holder.lua'
	'client/controls/waypoint_row.lua'
	'client/controls/waypoint_row.server.lua'
	'client/controls/icons_list.lua'

	'client/key_controls.lua'
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
	'client/sharing.lua'

	'common/functions.lua'
	'common/icons.lua'
	'common/classes/networked_waypoint.lua'

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
