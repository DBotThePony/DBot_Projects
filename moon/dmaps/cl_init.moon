
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

include 'dmaps/client/classes/class_map.lua'
include 'dmaps/client/classes/class_map_point.lua'
include 'dmaps/client/classes/class_map_entity_point.lua'
include 'dmaps/client/classes/class_player_point.lua'
include 'dmaps/client/classes/class_lplayer_point.lua'
include 'dmaps/client/classes/class_map_waypoint.lua'

include 'dmaps/client/controls/control_compass.lua'
include 'dmaps/client/controls/control_arrows.lua'
include 'dmaps/client/controls/control_zoom.lua'
include 'dmaps/client/controls/control_buttons.lua'
include 'dmaps/client/controls/abstract_map_holder.lua'

vgui.Register('DMapsMapHolder', DMaps.PANEL_ABSTRACT_MAP_HOLDER, 'EditablePanel')
vgui.Register('DMapsMapCompass', DMaps.PANEL_MAP_COMPASS, 'EditablePanel')
vgui.Register('DMapsMapArrows', DMaps.PANEL_MAP_ARROWS, 'EditablePanel')
vgui.Register('DMapsMapZoom', DMaps.PANEL_MAP_ZOOM, 'EditablePanel')
vgui.Register('DMapButtons', DMaps.PANEL_CONTROL_BUTTONS, 'EditablePanel')

include 'dmaps/client/default_gui.lua'