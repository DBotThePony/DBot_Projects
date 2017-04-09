
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

DMaps.DMap = include 'dmaps/client/class_map.lua'
DMaps.DMapPointer = include 'dmaps/client/class_map_point.lua'
DMaps.DMapEntityPointer = include 'dmaps/client/class_map_entity_point.lua'
DMaps.DMapPlayerPointer = include 'dmaps/client/class_player_point.lua'
DMaps.DMapLocalPlayerPointer = include 'dmaps/client/class_lplayer_point.lua'
DMaps.PANEL_ABSTRACT_MAP_HOLDER = include 'dmaps/client/abstract_map_holder.lua'

vgui.Register('DMapsMapHolder', DMaps.PANEL_ABSTRACT_MAP_HOLDER, 'EditablePanel')

include 'dmaps/client/default_gui.lua'