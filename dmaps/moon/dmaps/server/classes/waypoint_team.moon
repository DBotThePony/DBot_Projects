
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

import DMaps, hook, string from _G
import WaypointDataContainerTeams, BasicWaypoint, Icon from DMaps

class TeamWaypoint extends BasicWaypoint
	@EDIT_PERMISSION = 'team'
	@S_OPEN_MENU = 'dmaps_serverwaypoints_teams'
	@SNETWORK_STRING_PREFIX = 'DMaps.TeamWaypoint'

	@CreateFromData: (data) => -- Override
		@CONTAINER\CreateWaypoint(string.Explode(',', data.teams), data.name, data.posx, data.posy, data.posz, data.red, data.green, data.blue, data.icon)

	WriteNetworkData: =>
		super()
		with @savedata
			net.WriteString(.teams)
	
	@ReadNetworkData: => -- Static function!
		read = super()
		read.teams = net.ReadString()
		return read

	@RegisterNetwork()

	@WAYPOINTS_SAVED = {} -- Redefine in subclasses
	@CONTAINER = WaypointDataContainerTeams()
	@PLAYER_FILTER_FUNC = (waypoint, ply) => waypoint._check[ply\Team()]
	
	@RegisterContainerFunctions()
	@CONTAINER\LoadWaypoints()
	
	new: (savedata) =>
		@_check = {}
		@_array = {}
		super(savedata)
	
	CheckTeam: (ply) => @_check[ply\Team()] or false
	CheckTeamNum: (num) => @_check[num] or false
	GetTeams: => @_array
	SetupSaveData: (data) =>
		super(data)
		@_array = [tonumber(v) for v in *string.Explode(',', data.teams)]
		@_check = {v, true for v in *@_array}
		@teams = data.teams
		if @INITIALIZE
			for {ply, tm} in *[{ply, ply\Team()} for ply in *player.GetAll()]
				if @_check[tm]
					@AddPlayer(ply)
				else
					@RemovePlayer(ply)

TeamChanges = (ply, newTeam) ->
	for i, waypoint in pairs TeamWaypoint.WAYPOINTS_SAVED
		if waypoint._check[newTeam]
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