
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

import DMaps from _G

class WaypointsDataContainer
	@WaypointsTable = [[CREATE TABLE IF NOT EXISTS dmap_clientwaypoints (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	serverip VARCHAR(64) NOT NULL,
	map VARCHAR(128) NOT NULL,
	name VARCHAR(128) NOT NULL,
	posx INTEGER NOT NULL DEFAULT 0,
	posy INTEGER NOT NULL DEFAULT 0,
	posz INTEGER NOT NULL DEFAULT 0,
	red INTEGER NOT NULL DEFAULT 255,
	green INTEGER NOT NULL DEFAULT 255,
	blue INTEGER NOT NULL DEFAULT 255,
	visible BOOLEAN NOT NULL DEFAULT true
)]]

	@CreateTables = => print sql.LastError! if sql.Query(@WaypointsTable) == false

	new: (serverip = game.GetIPAddress(), map = game.GetMap()) =>
		@serverip = serverip
		@map = map
		@SaveData = {}
	
	SetSaveData: (id = 0, data = {}, triggerSave = true) =>
		@SaveData[id] = data
		@SaveWaypoint(id) if triggerSave
	GetData: => @SaveData
	GetTable: => @SaveData
	Clear: => for k, v in pairs @SaveData do @SaveData[k] = nil
	SaveWaypoints: => @SaveWaypoint(k) for k, v in pairs @SaveData
	SaveWaypoint: (id = 0) =>
		waypoint = @SaveData[id]
		if not id then error('No such a waypoint with ID: ' .. id)
		sqlData = {k, SQLStr(v) for k, v in pairs waypoint}
		query = "UPDATE dmap_clientwaypoints SET name = #{sqlData.name}, posx = #{sqlData.posx}, posy = #{sqlData.posy}, posz = #{sqlData.posz}, red = #{sqlData.red}, green = #{sqlData.green}, blue = #{sqlData.blue}, visible = #{sqlData.visible};"
		print sql.LastError! if sql.Query(query) == false
	LoadWaypoints: (serverip = game.GetIPAddress(), map = game.GetMap()) =>
		query = "SELECT * FROM dmap_clientwaypoints WHERE map = #{SQLStr(map)} AND serverip = #{SQLStr(serverip)}"
		data = sql.Query(query)
		if data ~= nil and not dryrun
			@Clear!
			for k, v in pairs data
				@SaveData[data.id] = data
		print sql.LastError! if data == false
		return data
		
DMaps.WaypointsDataContainer = WaypointsDataContainer
return WaypointsDataContainer