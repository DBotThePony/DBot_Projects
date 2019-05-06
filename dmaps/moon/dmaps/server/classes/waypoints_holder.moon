
--
-- Copyright (C) 2017-2019 DBotThePony
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

-- I only now noticed that if i created a subclass WaypointData
-- i will receive much more profit :s
class WaypointsDataContainer
	@TABLE_NAME = 'dmap_basic_waypoints'
	@WaypointsTable = [[CREATE TABLE IF NOT EXISTS dmap_basic_waypoints (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	map VARCHAR(128) NOT NULL,
	name VARCHAR(128) NOT NULL,
	posx INTEGER NOT NULL DEFAULT 0,
	posy INTEGER NOT NULL DEFAULT 0,
	posz INTEGER NOT NULL DEFAULT 0,
	red INTEGER NOT NULL DEFAULT 255,
	green INTEGER NOT NULL DEFAULT 255,
	blue INTEGER NOT NULL DEFAULT 255,
	icon VARCHAR(64) NOT NULL DEFAULT ']] .. Icon.DefaultIconName .. [['
)]] -- Override
	-- In subclasses you must define SQL tables at least with same columns!

	@CreateTables = => print @WaypointsTable, '\n' .. sql.LastError! if sql.Query(@WaypointsTable) == false
	@CreateTables()

	new: (map = game.GetMap()) =>
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
	SetX: (id = 0, val = 0, triggerSave = true) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		data.posx = val
		@SetSaveData(id, data, triggerSave)
	SetY: (id = 0, val = 0, triggerSave = true) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		data.posy = val
		@SetSaveData(id, data, triggerSave)
	SetZ: (id = 0, val = 0, triggerSave = true) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		data.posz = val
		@SetSaveData(id, data, triggerSave)
	SetRed: (id = 0, val = 0, triggerSave = true) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		data.red = val
		@SetSaveData(id, data, triggerSave)
	SetGreen: (id = 0, val = 0, triggerSave = true) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		data.green = val
		@SetSaveData(id, data, triggerSave)
	SetBlue: (id = 0, val = 0, triggerSave = true) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		data.blue = val
		@SetSaveData(id, data, triggerSave)

	GetData: => @SaveData
	PointExists: (id = 0) => @SaveData[id] ~= nil
	GetPoint: (id = 0) => table.Copy(@SaveData[id]) if @SaveData[id] else nil
	GetWaypoint: (id = 0) => table.Copy(@SaveData[id]) if @SaveData[id] else nil
	GetTable: => @SaveData
	GetCount: => table.Count(@SaveData)
	Clear: => for k, v in pairs @SaveData do @SaveData[k] = nil
	SaveWaypoints: => @SaveWaypoint(k) for k, v in pairs @SaveData

	@WriteNetworkData: (data, writeID = true) =>
		net.WriteUInt(data.id, 32) if writeID
		net.WriteString(data.name)
		net.WriteInt(data.posx, 32)
		net.WriteInt(data.posy, 32)
		net.WriteInt(data.posz, 32)
		net.WriteUInt(data.red, 8)
		net.WriteUInt(data.green, 8)
		net.WriteUInt(data.blue, 8)
		net.WriteUInt(Icon\GetNetworkID(data.icon), 16)
	WriteNetworkData: (id = 0) =>
		data = @GetPoint(id)
		error("No such a waypoint with ID: #{id}") if not data
		@@WriteNetworkData(data)

	@ReadNetworkData: => -- Static function!
		read = {}
		read.id = net.ReadUInt(32)
		read.name = net.ReadString()
		read.posx = net.ReadInt(32)
		read.posy = net.ReadInt(32)
		read.posz = net.ReadInt(32)
		read.red = net.ReadUInt(8)
		read.green = net.ReadUInt(8)
		read.blue = net.ReadUInt(8)
		read.icon = Icon\GetIconName(net.ReadUInt(16))
		return read

	SaveWaypoint: (id = 0) =>
		waypoint = @SaveData[id]
		error("No such a waypoint with ID: #{id}") if not waypoint
		status = sql.Query("UPDATE #{@@TABLE_NAME} SET #{table.concat([k .. ' = ' .. SQLStr(v) for k, v in pairs waypoint], ', ')} WHERE id = #{id};")

		print sql.LastError! if status == false
		return status
	DeleteWaypoint: (id = 0) =>
		error("No such a waypoint with ID: #{id}") if not @SaveData[id]
		query = "DELETE FROM #{@@TABLE_NAME} WHERE id = #{SQLStr(id)};"
		status = sql.Query(query)

		print sql.LastError! if status == false
		if status == nil
			@RemoveTrigger(id, @SaveData[id])
			@SaveData[id] = nil
		return status

	-- Override
	CreateSaveData: (name = 'New Waypoint', posx = 0, posy = 0, posz = 0, red = math.random(1, 255), green = math.random(1, 255), blue = math.random(1, 255), icon = Icon.DefaultIconName) =>
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
			:icon
		}

		return newData

	CreateWaypoint: (...) =>
		newData = @CreateSaveData(...)
		map = SQLStr(@map)
		query = "INSERT INTO #{@@TABLE_NAME} (#{table.concat([k for k, v in pairs newData], ', ')}, map) VALUES (#{table.concat([SQLStr(v) for k, v in pairs newData], ', ')}, #{map});"

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
		query = "SELECT * FROM #{@@TABLE_NAME} WHERE map = #{SQLStr(@map)}"
		data = sql.Query(query)
		print query, sql.LastError! if data == false
		if data ~= nil
			@Clear!
			for row in *data
				row.map = nil
				row[k] = tonumber(row[k]) for k in *{'id', 'posx', 'posy', 'posz', 'red', 'green', 'blue'}
				@SaveData[row.id] = row if row.id
				@CreateTrigger(row.id, row) if row.id
		print sql.LastError! if data == false
		return data

DMaps.WaypointsDataContainer = WaypointsDataContainer
return WaypointsDataContainer