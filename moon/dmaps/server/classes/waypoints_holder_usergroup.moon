
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

import DMaps, pairs, table, string from _G
import Icon, WaypointsDataContainer from DMaps

class WaypointDataContainerUsergroup extends WaypointsDataContainer
	@TABLE_NAME = 'dmap_ugroup_waypoints'
	@WaypointsTable = [[CREATE TABLE IF NOT EXISTS dmap_ugroup_waypoints (
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
	
	GetGroups: (id = 0) =>
		data = @SaveData[id]
		error("No such a waypoint with ID: #{id}") if not data
		return string.Explode(data.ugroups,  ',')
	GetUserGroups: (...) => @GetGroups(...)
	SetGroups: (id = 0, val = {}, triggerSave = true) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		val = {val} if type(val) ~= 'table'
		data.ugroups = table.concat(val,  ',')
		@SetSaveData(id, data, triggerSave)
	SetUserGroups: (...) => @SetGroups(...)
	
	AddGroup: (id = 0, val = 'user', triggerSave = true) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		ugroupVals = string.Explode(',', data.ugroups)
		table.insert(ugroupVals, val) if not table.HasValue(ugroupVals, val)
		data.ugroups = table.concat(ugroupVals,  ',')
		@SetSaveData(id, data, triggerSave)
	RemoveGroup: (id = 0, val = 'user', triggerSave = true) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		ugroupVals = string.Explode(',', data.ugroups)
		
		for i, v in pairs ugroupVals
			if v == val
				table.remove(ugroupVals, i)
				break
		
		data.ugroups = table.concat(ugroupVals,  ',')
		@SetSaveData(id, data, triggerSave)
	CreateSaveData: (ugroups = {}, ...) =>
		newData = super(...)
		ugroups = {ugroups} if type(ugroups) ~= 'table'
		newData.ugroups = table.concat(ugroups, ',')
		return newData
		
DMaps.WaypointDataContainerUsergroup = WaypointDataContainerUsergroup
return WaypointDataContainerUsergroup