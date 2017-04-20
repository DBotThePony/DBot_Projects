
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

import DMaps, pairs, table, string, CAMI from _G
import Icon, WaypointDataContainerUsergroup from DMaps

class WaypointDataContainerCAMIGroups extends WaypointDataContainerUsergroup
	@TABLE_NAME = 'dmap_cami_waypoints'
	@WaypointsTable = [[CREATE TABLE IF NOT EXISTS dmap_cami_waypoints (
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
	ugroups VARCHAR(256) NOT NULL DEFAULT ''
)]]

	@CreateTables()

	new: (map) =>
		super(map)

	@WriteNetworkData: (data, writeID = true) =>
		super(data, writeID)
		net.WriteString(data.ugroups)
	@ReadNetworkData: => -- Static function!
		read = super()
		read.ugroups = net.ReadString()
		return read
	
	GetGroups: (id = 0) =>
		data = @SaveData[id]
		error("No such a waypoint with ID: #{id}") if not data
		groups = string.Explode(data.ugroups,  ',')
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
DMaps.WaypointDataContainerCAMIGroups = WaypointDataContainerCAMIGroups
return WaypointDataContainerCAMIGroups