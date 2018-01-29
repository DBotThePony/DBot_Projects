
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
CreateConVar('vehicles', '1', 'Enable map vehicles display')
CreateConVar('allow_minimap', '1', 'Allow minimap mode')

CreateConVar('draw_players_info', '1', 'Draw players infos on map')
CreateConVar('draw_players_health', '1', 'Draw players health on map')
CreateConVar('draw_players_armor', '1', 'Draw players armor on map')
CreateConVar('draw_players_team', '1', 'Draw players teams on map')

CreateConVar('deathpoints_duration', '15', 'Player death point live time in minutes')
CreateConVar('arrest_duration', '5', 'Player arrest event pointer live time in minutes')
CreateConVar('npc_death_duration', '1', 'NPC death point live time in minutes')

CreateConVar('vehicles_undriven', '512', 'Undriven vehicle map track range')
CreateConVar('vehicles_driven', '3000', 'Driven vehicle map track range')

CreateConVar('npcs_range', '1024', 'Range of NPCs display')
CreateConVar('enpcs_range', '512', 'Range of enemy NPCs display')
CreateConVar('fnpcs_range', '2048', 'Range of friendly NPCs display')

CreateConVar('players_street', '1', 'Sandbox Player Filter: Enable player "is on street" check')
CreateConVar('players_street_dist', '9999', 'Sandbox Player Filter: "is on street" check max draw distance (Hammer units)')
CreateConVar('players_max_delta', '600', 'Sandbox Player Filter: Max distance (Hammer units) in Z "height", before hiding player')
CreateConVar('players_start_fade', '200', 'Sandbox Player Filter: Distance (Hammer units) in Z "height", before starting player fade')
CreateConVar('players_start_hide', '800', 'Sandbox Player Filter: Distance (Hammer units)')
