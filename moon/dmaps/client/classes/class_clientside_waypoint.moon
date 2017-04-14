
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

import DMaps, sql, Color, DermaMenu from _G
import DMapWaypoint, WaypointsDataContainer from DMaps

-- Structure of loaded clientside waypoint
-- {
-- 		:red
-- 		:green
-- 		:blue
-- 		:posx
-- 		:posy
-- 		:posz
-- 		:id
-- 		:visible
-- }

class ClientsideWaypoint extends DMapWaypoint
	@WAYPOINTS = {}
	@WAYPOINTS_ALL = {}
	@nosave = false
	
	@RegisterWaypoints = (map) =>
		error('ClientsideWaypoint Data is not loaded!') if not @DataContainer
		map\AddObject(ClientsideWaypoint(data)) for k, data in pairs @DataContainer\GetData!
		@map = map
	@SaveWaypoints = =>
		error('Data was not loaded!') if not @DataContainer
		@DataContainer\SaveWaypoints!
	@SaveWaypoint = (id = 0) =>
		error('Data was not loaded!') if not @DataContainer
		@DataContainer\SaveWaypoint(id)
	@OnWaypointUpdates = (waypoint) =>
		if @nosave return
		newData = {}
		with waypoint
			newData.posx = .GetX!
			newData.posy = .GetY!
			newData.posz = .GetZ!
			newData.name = .GetName!
			newData.visible = .GetIsVisible!
		with waypoint.color
			newData.red = .r
			newData.green = .g
			newData.blue = .b
		with waypoint.savedata
			newData.map = .map
			newData.serverip = .serverip
			newData.id = .id
		@nosave = true
		@DataContainer\SetSaveData(newData.id, newData)
		@nosave = false
		waypoint.savedata = newData
	@OnDataContainerChanges = (id, data) =>
		if @nosave return
		if not @WAYPOINTS[id] return
		waypoint = @WAYPOINTS[id]
		waypoint.nosave = true
		waypoint\SetupSaveData(data)
		waypoint.nosave = false
	@OnDataAdded = (id, data) =>
		if @nosave return
		if not @map return
		@map\AddObject(ClientsideWaypoint(data))
	@OnDataRemoved = (id, data) =>
		if @nosave return
		@WAYPOINTS[id]\Remove() if @WAYPOINTS[id]
	@Clear = =>
		error('Data was not loaded!') if not @DataContainer
		@DataContainer\Clear!
	@RemoveAll = =>
		error('Data was not loaded!') if not @DataContainer
		v\Remove! for _, v in pairs @WAYPOINTS_ALL
		@WAYPOINTS = {}
		@WAYPOINTS_ALL = {}
		@Clear!
	@LoadWaypoints = (dryrun = true, serverip = game.GetIPAddress(), map = game.GetMap()) =>
		newData = WaypointsDataContainer(serverip, map)
		newData\LoadWaypoints!
		if not dryrun
			@DataContainer = newData
			newData\SetUpdateTrigger((container, id, data) -> @OnDataContainerChanges(id, data))
			newData\SetCreateTrigger((container, id, data) -> @OnDataAdded(id, data))
			newData\SetDeleteTrigger((container, id, data) -> @OnDataRemoved(id, data))
		return newData
	
	-- Static methods end
	new: (savedata) =>
		if not savedata then error('No savedata was passed to the constructor of DMapClientsideWaypoint!')
		super(savedata.name, savedata.posx, savedata.posy, savedata.posz)
		@savedata = savedata
		@SAVEID = tonumber(savedata.id)
		@@WAYPOINTS[@SAVEID] = @
		@tableID = table.insert(@@WAYPOINTS_ALL, @)
		@nosave = false
		@SetupSaveData(savedata)
	
	SetupSaveData: (savedata) =>
		@nosave = true
		@savedata = savedata
		with savedata
			@color = Color(.red, .green, .blue)
			@x = .posx
			@y = .posy
			@z = .posz
			@name = .name
			@pointName = .name
			@visible = .visible
		@nosave = false
	
	OnDataChanged: =>
		if not @nosave then timer.Create("DMaps.SaveClientsideWaypointData.#{@SAVEID}", 0.5, 1, -> @@OnWaypointUpdates(@))
		super!
	GetSaveID: => @SAVEID
	OpenMenu: =>
		menu = DermaMenu()
		with menu
			\AddOption('Edit...', -> DMaps.OpenWaypointEditMenu(@SAVEID, @@DataContainer))
			\AddSubMenu('Delete')\AddOption('Confirm?', -> @@DataContainer\DeleteWaypoint(@SAVEID))
			\AddOption('Close', ->)
			\Open()
		return true
	Remove: =>
		super!
		@@WAYPOINTS[@SAVEID] = nil
		@@WAYPOINTS_ALL[@tableID] = nil

DMaps.ClientsideWaypoint = ClientsideWaypoint
DMaps.DMapClientsideWaypoint = ClientsideWaypoint
return ClientsideWaypoint
