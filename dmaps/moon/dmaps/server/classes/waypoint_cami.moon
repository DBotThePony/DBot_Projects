
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

import DMaps, hook, string, player from _G
import WaypointDataContainerCAMIGroups, BasicWaypoint, Icon from DMaps

class CAMIGroupWaypoint extends BasicWaypoint
	@S_OPEN_MENU = 'dmaps_serverwaypoints_cami'
	@EDIT_PERMISSION = 'cami'
	@SNETWORK_STRING_PREFIX = 'DMaps.CAMIWaypoint'

	@CreateFromData: (data) => -- Override
		@CONTAINER\CreateWaypoint(string.Explode(',', data.ugroups), data.name, data.posx, data.posy, data.posz, data.red, data.green, data.blue, data.icon)

	WriteNetworkData: =>
		super()
		with @savedata
			net.WriteString(.ugroups)
	
	@ReadNetworkData: => -- Static function!
		read = super()
		read.ugroups = net.ReadString()
		return read

	@RegisterNetwork()

	@WAYPOINTS_SAVED = {} -- Redefine in subclasses
	@CONTAINER = WaypointDataContainerCAMIGroups()
	@PLAYER_FILTER_FUNC = (waypoint, ply) => waypoint._check[ply\GetUserGroup()]
	
	@RegisterContainerFunctions()
	@CONTAINER\LoadWaypoints()
	
	new: (savedata) =>
		@_check = {}
		@_array = {}
		super(savedata)
	
	GetGroups: =>
		data = @savedata
		groups = string.Explode(',', data.ugroups)
		groupsMap = {k, true for k in *groups}
		
		camiGroups = CAMI.GetUsergroups()
		diff = 1
		
		while diff ~= 0
			diff = 0
			for groupName, groupData in pairs camiGroups
				if groupsMap[groupData.Inherits] and not groupsMap[groupName]
					groupsMap[groupName] = true
					table.insert(groups, groupName)
					diff += 1
		
		return groups
	GetUserGroups: (...) => @GetGroups(...)
	
	RecalculateGroups: =>
		@_array = @GetGroups()
		@_check = {v, true for v in *@_array}
		if @INITIALIZE
			for {ply, group} in *[{ply, ply\GetUserGroup()} for ply in *player.GetAll()]
				if @_check[group]
					@AddPlayer(ply)
				else
					@RemovePlayer(ply)
	
	SetupSaveData: (data) =>
		super(data)
		@ugroups = data.ugroups
		@RecalculateGroups()

hook.Add 'CAMI.PlayerUsergroupChanged', 'DMaps.CAMIGroupWaypoint', (ply, old, new, source) ->
	for i, waypoint in pairs CAMIGroupWaypoint.WAYPOINTS_SAVED
		if waypoint._check[new]
			waypoint\AddPlayer(ply)
		else
			waypoint\RemovePlayer(ply)
OnUsergroupRegistered = (group) ->
	plys = [{ply, ply\GetUserGroup()} for ply in *player.GetAll()]
	for i, waypoint in pairs CAMIGroupWaypoint.WAYPOINTS_SAVED
		waypoint\RecalculateGroups()
		for ply in *plys
			if waypoint._check[ply[2]]
				waypoint\AddPlayer(ply[1])
			else
				waypoint\RemovePlayer(ply[1])
hook.Add 'CAMI.OnUsergroupRegistered', 'DMaps.CAMIGroupWaypoint', OnUsergroupRegistered
hook.Add 'CAMI.OnUsergroupUnregistered', 'DMaps.CAMIGroupWaypoint', OnUsergroupRegistered
DMaps.CAMIGroupWaypoint = CAMIGroupWaypoint
return CAMIGroupWaypoint