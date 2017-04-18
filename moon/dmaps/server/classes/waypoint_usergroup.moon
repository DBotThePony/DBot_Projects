
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

import DMaps, net, player, math, Color, hook, table from _G
import SERVER, CLIENT, Vector from _G
import WaypointDataContainerUsergroup, BasicWaypoint, Icon from DMaps

class UsergroupWaypoint extends BasicWaypoint
	@WAYPOINTS_SAVED = {} -- Redefine in subclasses
	@CONTAINER = WaypointDataContainerUsergroup()
	@PLAYER_FILTER_FUNC = (waypoint, ply) => waypoint._check[ply\GetUserGroup()]
	
	@RegisterContainerFunctions()
	@CONTAINER\LoadWaypoints()
	
	new: (savedata) =>
		@_check = {}
		@_array = {}
		super(savedata)
	
	CheckTeam: (ply) => @teamCheck[ply\Team()] or false
	CheckTeamNum: (num) => @teamCheck[num] or false
	GetTeams: => @teamsArray
	SetupSaveData: (data) =>
		super(data)
		@_array = string.Explode(',', data.ugroups)
		@_check = {v, true for v in *@_array}
		@ugroups = data.ugroups

	
DMaps.UsergroupWaypoint = UsergroupWaypoint
return UsergroupWaypoint