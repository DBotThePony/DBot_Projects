
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
import WaypointDataContainerTeams, WaypointsController, Icon from DMaps

class TeamWaypoint extends WaypointsController
	@WAYPOINTS_SAVED = {} -- Redefine in subclasses
	@CONTAINER = WaypointDataContainerTeams()
	@PLAYER_FILTER_FUNC = (waypoint, ply) => waypoint.teamCheck[ply\Team()]
	
	@RegisterContainerFunctions()
	@CONTAINER\LoadWaypoints()
	
	new: (savedata) =>
		@teamCheck = {}
		@teamsArray = {}
		super(savedata)
	
	GetTeams: => @teamsArray
	SetupSaveData: (data) =>
		super(data)
		@teamsArray = [tonumber(v) for v in *string.Explode(',', data.teams)]
		@teamCheck = {v, true for v in *@teamsArray}
		@teams = data.teams

TeamChanges = (ply, newTeam) ->
	for i, waypoint in pairs TeamWaypoint.WAYPOINTS_SAVED
		if waypoint.teamCheck[newTeam]
			waypoint\AddPlayer(ply)
		else
			waypoint\RemovePlayer(ply)

-- what the fuck with this hook on sandbox
-- i know that wiki says i should use PlayerJoinTeam
-- but any gamemode DON'T GIVE A FUCK ABOUT PlayerJoinTeam HOOK
hook.Add 'PlayerJoinTeam', 'DMaps.TeamWaypoint', TeamChanges
hook.Add 'OnPlayerChangedTeam', 'DMaps.TeamWaypoint', (ply, old, new) -> TeamChanges(ply, new)
	
DMaps.TeamWaypoint = TeamWaypoint
return TeamWaypoint