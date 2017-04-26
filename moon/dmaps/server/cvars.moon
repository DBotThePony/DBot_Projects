
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

import CreateConVar, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY from _G
_CreateConVar = CreateConVar

CreateConVar = (name = '', df = '', desc = '') -> _CreateConVar("sv_dmaps_#{name}", df, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, desc)

CreateConVar('players', '1', 'Enable player map arrows')
CreateConVar('entities', '1', 'Enable map entities display')
CreateConVar('npcs', '1', 'Enable map NPCs display')

CreateConVar('draw_players_info', '1', 'Draw players infos on map')
CreateConVar('draw_players_health', '1', 'Draw players health on map')
CreateConVar('draw_players_armor', '1', 'Draw players armor on map')
CreateConVar('draw_players_team', '1', 'Draw players teams on map')

CreateConVar('deathpoints_duration', '15', 'Player death point live time in minutes')
