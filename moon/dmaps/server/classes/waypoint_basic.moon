
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

import DMaps, Color from _G
import WaypointsDataContainer, Icon, NetworkedWaypoint from DMaps

class BasicWaypoint extends NetworkedWaypoint
	@STORED_WAYPOINTS = {}
	@WAYPOINTS_SAVED = {} -- Redefine in subclasses
	@CONTAINER = WaypointsDataContainer()
	
	@RegisterContainerFunctions = => -- Call in subclasses
		@CONTAINER.CreateTrigger = (container, id, data) ->
			waypoint = @(data)
			waypoint\InitPoint()
		@CONTAINER.UpdateTrigger = (container, id, data) -> @WAYPOINTS_SAVED[id]\SetupSaveData(data) if @WAYPOINTS_SAVED[id]
		@CONTAINER.RemoveTrigger = (container, id, data) -> @WAYPOINTS_SAVED[id]\Remove() if @WAYPOINTS_SAVED[id]
	
	@RegisterContainerFunctions()
	@CONTAINER\LoadWaypoints()
	
	new: (savedata) =>
		super(savedata.name, savedata.posx, savedata.posy, savedata.posz, Color(savedata.red, savedata.green, savedata.blue), savedata.icon)
		@@STORED_WAYPOINTS[@ID] = @
		@SetupSaveData(savedata)
		@SAVEID = savedata.id
		@@WAYPOINTS_SAVED[@SAVEID] = @
	
	SaveID: => @SAVEID
	GetSaveID: => @SAVEID
	
	SetupSaveData: (data) =>
		@savedata = data
		with data
			@SetName(.name)
			@SetX(.posx)
			@SetY(.posy)
			@SetZ(.posz)
			@SetColor(Color(.red, .green, .blue))
			@SetIcon(.icon)
	
	Remove: =>
		super!
		@@STORED_WAYPOINTS[@ID] = nil
		@@WAYPOINTS_SAVED[@SAVEID] = nil if @SAVEID

DMaps.BasicWaypoint = BasicWaypoint
return BasicWaypoint