
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

import DMaps, sql from _G
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
	
	@RegisterWaypoints = (map) =>
		error('Data was not loaded!') if not @DataContainer
		for k, data in pairs @DataContainer\GetData!
			waypoint = ClientsideWaypoint(data)
			map\AddObject(waypoint)
	
	@SaveWaypoints = =>
		error('Data was not loaded!') if not @DataContainer
		@DataContainer\SaveWaypoints!
	@SaveWaypoint = (id = 0) =>
		error('Data was not loaded!') if not @DataContainer
		@DataContainer\SaveWaypoint(id)
	
	@OnWaypointUpdates = (waypoint) =>
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
		@DataContainer\SetSaveData(newData.id, newData)
		waypoint.savedata = newData
	
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
		@DataContainer = newData if not dryrun
		return newData
	
	-- Static methods end
	new: (savedata) =>
		if not savedata then error('No savedata was passed to the constructor of DMapClientsideWaypoint!')
		super(savedata.name, savedata.posx, savedata.posy, savedata.posz)
		@savedata = savedata
		@SAVEID = savedata.id
		@@WAYPOINTS[@SAVEID] = @
		@tableID = table.insert(@@WAYPOINTS_ALL, @)
	
	OnDataChanged: => timer.Create("DMaps.SaveClientsideWaypointData.#{@SAVEID}", 0.5, 1, -> @@OnWaypointUpdates(@))
	GetSaveID: => @SAVEID
	Remove: =>
		super!
		@@WAYPOINTS[@SAVEID] = nil
		@@WAYPOINTS_ALL[@tableID] = nil

DMaps.ClientsideWaypoint = ClientsideWaypoint
DMaps.DMapClientsideWaypoint = ClientsideWaypoint
return ClientsideWaypoint
