
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
import Icon from DMaps

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
	visible BOOLEAN NOT NULL DEFAULT true,
	icon VARCHAR(64) NOT NULL DEFAULT ']] .. Icon.DefaultIconName .. [['
)]]

	@CreateTables = => print sql.LastError! if sql.Query(@WaypointsTable) == false

	new: (serverip = game.GetIPAddress(), map = game.GetMap()) =>
		@serverip = serverip
		@map = map
		@SaveData = {}
		@UpdateTrigger = (id, data) =>
		@CreateTrigger = (id, data) =>
		@RemoveTrigger = (id, data) =>
	
	SetUpdateTrigger: (val = ((id, data) =>)) => @UpdateTrigger = val
	SetCreateTrigger: (val = ((id, data) =>)) => @CreateTrigger = val
	SetDeleteTrigger: (val = ((id, data) =>)) => @RemoveTrigger = val
	SetRemoveTrigger: (val = ((id, data) =>)) => @RemoveTrigger = val
	SetSaveData: (id = 0, data = {}, triggerSave = true) =>
		@SaveData[id] = data
		@SaveWaypoint(id) if triggerSave
		@UpdateTrigger(id, data)
	SetVisible: (id = 0, visible = true) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		data.visible = visible
		@SetSaveData(id, data)
	SetX: (id = 0, val = 0) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		data.posx = val
		@SetSaveData(id, data)
	SetY: (id = 0, val = 0) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		data.posy = val
		@SetSaveData(id, data)
	SetZ: (id = 0, val = 0) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		data.posz = val
		@SetSaveData(id, data)
	SetRed: (id = 0, val = 0) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		data.red = val
		@SetSaveData(id, data)
	SetGreen: (id = 0, val = 0) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		data.green = val
		@SetSaveData(id, data)
	SetBlue: (id = 0, val = 0) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		data.blue = val
		@SetSaveData(id, data)
	
	GetData: => @SaveData
	GetPoint: (id = 0) => table.Copy(@SaveData[id]) if @SaveData[id] else nil
	GetWaypoint: (id = 0) => table.Copy(@SaveData[id]) if @SaveData[id] else nil
	GetTable: => @SaveData
	GetCount: => table.Count(@SaveData)
	Clear: => for k, v in pairs @SaveData do @SaveData[k] = nil
	SaveWaypoints: => @SaveWaypoint(k) for k, v in pairs @SaveData
	SaveWaypoint: (id = 0) =>
		waypoint = @SaveData[id]
		error("No such a waypoint with ID: #{id}") if not waypoint
		sqlData = {k, SQLStr(v) for k, v in pairs waypoint}
		query = "UPDATE dmap_clientwaypoints SET name = #{sqlData.name}, posx = #{sqlData.posx}, posy = #{sqlData.posy}, posz = #{sqlData.posz}, red = #{sqlData.red}, green = #{sqlData.green}, blue = #{sqlData.blue}, visible = #{sqlData.visible}, icon = #{sqlData.icon} WHERE id = #{id};"
		status = sql.Query(query)
		
		print sql.LastError! if status == false
		return status
	DeleteWaypoint: (id = 0) =>
		error("No such a waypoint with ID: #{id}") if not @SaveData[id]
		query = "DELETE FROM dmap_clientwaypoints WHERE id = #{SQLStr(id)};"
		status = sql.Query(query)
		
		print sql.LastError! if status == false
		if status == nil
			@RemoveTrigger(id, @SaveData[id])
			@SaveData[id] = nil
		return status
	CreateWaypoint: (name = 'New Waypoint', posx = LocalPlayer()\GetPos().x, posy = LocalPlayer()\GetPos().y, posz = LocalPlayer()\GetPos().z, red = math.random(1, 255), green = math.random(1, 255), blue = math.random(1, 255), visible = true, icon = Icon.DefaultIconName) =>
		posx = math.floor(posx)
		posy = math.floor(posy)
		posz = math.floor(posz)
		red = math.Clamp(math.floor(red), 0, 255)
		green = math.Clamp(math.floor(green), 0, 255)
		blue = math.Clamp(math.floor(blue), 0, 255)
		icon = Icon\FixIcon(icon)
		
		newData = {
			:name
			:posx
			:posy
			:posz
			:red
			:green
			:blue
			:visible
			:icon
		}
		
		serverip = SQLStr(@serverip)
		map = SQLStr(@map)
		sqlData = {k, SQLStr(v) for k, v in pairs newData}
		query = "INSERT INTO dmap_clientwaypoints (serverip, map, name, posx, posy, posz, red, green, blue, visible, icon) VALUES (#{serverip}, #{map}, #{sqlData.name}, #{sqlData.posx}, #{sqlData.posy}, #{sqlData.posz}, #{sqlData.red}, #{sqlData.green}, #{sqlData.blue}, #{sqlData.visible}, #{sqlData.icon});"
		status = sql.Query(query)
		if status ~= false
			id = tonumber(sql.Query('SELECT last_insert_rowid() AS "ID"')[1].ID)
			newData.id = id
			@SaveData[id] = newData
			@CreateTrigger(id, newData)
			return newData, id
		else
			print '[DMaps] ERROR WHEN EXECUTING QUERY: ', query
			print sql.LastError!
			return false, false
	LoadWaypoints: =>
		query = "SELECT * FROM dmap_clientwaypoints WHERE map = #{SQLStr(@map)} AND serverip = #{SQLStr(@serverip)}"
		data = sql.Query(query)
		if data ~= nil
			@Clear!
			for row in *data
				row[k] = tonumber(row[k]) for k in *{'id', 'posx', 'posy', 'posz', 'red', 'green', 'blue'}
				@SaveData[row.id] = row if row.id
		print sql.LastError! if data == false
		return data
		
DMaps.WaypointsDataContainer = WaypointsDataContainer
return WaypointsDataContainer