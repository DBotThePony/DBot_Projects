
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

import CreateConVar, math from _G
import Clamp from math

include 'dmaps/sh_init.lua'

Files = {
	'dmaps/client/cami_wrapper.lua'
	
	'dmaps/client/classes/class_map.lua'
	'dmaps/client/classes/class_map_point.lua'
	'dmaps/client/classes/class_map_entity_point.lua'
	'dmaps/client/classes/player_filter.lua'
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

	'dmaps/client/options.lua'
	'dmaps/client/default_gui.lua'
	'dmaps/client/waypoints_controller.lua'
	'dmaps/client/server_waypoints_gui.lua'
	'dmaps/client/network.lua'
	
	'dmaps/common/classes/networked_waypoint.lua'
}

DMaps.CONVARS_SETTINGS = {}

DMaps.ClientsideOption = (cvar, default, desc) ->
	object = CreateConVar("cl_dmaps_#{cvar}", default, {FCVAR_ARCHIVE}, desc)
	table.insert(DMaps.CONVARS_SETTINGS, {cvar, desc})
	return object

DMaps.CONVARS_COLORS = {}
DMaps.CONVARS_COLORS_GROUP = {}
DMaps.CONVARS_COLORS_ARRAY = {}

DMaps.CreateColor = (r = 220, g = 220, b = 220, name = 'generic', desc = 'ERROR_COLOR_NAME', group = 'generic') ->
	RED = CreateConVar("cl_dmaps_color_#{name}_r", tostring(r), {FCVAR_ARCHIVE}, "#{desc} 'Red' channel color")
	GREEN = CreateConVar("cl_dmaps_color_#{name}_g", tostring(g), {FCVAR_ARCHIVE}, "#{desc} 'Green' channel color")
	BLUE = CreateConVar("cl_dmaps_color_#{name}_b", tostring(b), {FCVAR_ARCHIVE}, "#{desc} 'Blue' channel color")
	DMaps.CONVARS_COLORS[name] = {
		:name, :desc, :group
		:r, :g, :b
		:RED, :GREEN, :BLUE
	}
	DMaps.CONVARS_COLORS_GROUP[group] = DMaps.CONVARS_COLORS_GROUP[group] or {}
	DMaps.CONVARS_COLORS_GROUP[group][name] = DMaps.CONVARS_COLORS[name]
	table.insert(DMaps.CONVARS_COLORS_ARRAY, DMaps.CONVARS_COLORS[name])
	return -> DMaps.GetColor(name)
DMaps.GetColor = (name, r = 0, g = 0, b = 0) ->
	return r, g, b if not DMaps.CONVARS_COLORS[name]
	{:RED, :GREEN, :BLUE} = DMaps.CONVARS_COLORS[name]
	return Clamp(RED\GetInt(), 0, 255), Clamp(GREEN\GetInt(), 0, 255), Clamp(BLUE\GetInt(), 0, 255)

DMapsIconData =
	title: 'DMaps',
	icon: 'dmaps/map.png',
	width: 960,
	height: 700,
	onewindow: true,
	init: (icon, window) ->
		window\Remove()
		RunConsoleCommand('dmaps_open')

list.Set('DesktopWindows', 'DMaps', DMapsIconData)
CreateContextMenu() if IsValid(g_ContextMenu)

include file for file in *Files
