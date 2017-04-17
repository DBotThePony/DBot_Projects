
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

import DMaps, pairs, table, sql, game, math, SQLStr, LocalPlayer from _G
import Icon, WaypointsDataContainer from DMaps

class WaypointDataContainerTeams extends WaypointsDataContainer
	@TABLE_NAME = 'dmap_team_waypoints'
	@WaypointsTable = [[CREATE TABLE IF NOT EXISTS dmap_team_waypoints (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	map VARCHAR(128) NOT NULL,
	name VARCHAR(128) NOT NULL,
	posx INTEGER NOT NULL DEFAULT 0,
	posy INTEGER NOT NULL DEFAULT 0,
	posz INTEGER NOT NULL DEFAULT 0,
	red INTEGER NOT NULL DEFAULT 255,
	green INTEGER NOT NULL DEFAULT 255,
	blue INTEGER NOT NULL DEFAULT 255,
	icon VARCHAR(64) NOT NULL DEFAULT ']] .. Icon.DefaultIconName .. [[',
	teams VARCHAR(256) NOT NULL DEFAULT ''
)]]

	@CreateTables()

	new: (map) =>
		super(map)
	
	GetTeams: (id = 0) =>
		data = @SaveData[id]
		error("No such a waypoint with ID: #{id}") if not data
		return [tonumber(v) for v in *string.Explode(data.teams,  ',')]
	CreateSaveData: (teams = {}, ...) =>
		newData = super(...)
		teams = {teams} if type(teams) ~= 'table'
		newData.teams = table.concat([tostring(v) for v in *teams], ',')
		return newData
		
DMaps.WaypointDataContainerTeams = WaypointDataContainerTeams
return WaypointDataContainerTeams