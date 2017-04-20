
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
	-- Edit network strings
	@S_OPEN_MENU = 'dmaps_serverwaypoints'
	@SNETWORK_STRING_PREFIX = 'DMaps.BasicWaypoint'

	@NetworkOnLoad = (len, ply) =>
		return if not IsValid(ply) or not ply\IsSuperAdmin()
		net.Start(@SNETWORK_STRING_LOAD)
		net.WriteUInt(table.Count(@WAYPOINTS_SAVED), 16)
		point\WriteNetworkData() for i, point in pairs @WAYPOINTS_SAVED
		net.Send(ply)
	@CreateFromData: (data) => -- Override
		@CONTAINER\CreateWaypoint(data.name, data.posx, data.posy, data.posz, data.red, data.green, data.blue, data.icon)
	@NetworkOnCreate = (len, ply) =>
		return if not IsValid(ply) or not ply\IsSuperAdmin()
		newData = @ReadNetworkData()
		data, id = @CreateFromData(newData)
		if id
			net.Start(@@SNETWORK_STRING_CREATE)
			net.WriteUInt(id, 32)
			@CONTAINER.__class\WriteNetworkData(data)
			net.Send(ply)
	@NetworkOnRemove = (len, ply) =>
		return if not IsValid(ply) or not ply\IsSuperAdmin()
		netID = net.ReadUInt(32)
		if @CONTAINER\PointExists(netID)
			@CONTAINER\DeleteWaypoint(netID)
			net.Start(@SNETWORK_STRING_DELETE)
			net.WriteUInt(netID, 32)
			net.Send(ply)
	@NetworkOnModify = (len, ply) =>
		return if not IsValid(ply) or not ply\IsSuperAdmin()
		netID = net.ReadUInt(32)
		readData = @ReadNetworkData()
		readData.id = netID
		if @CONTAINER\PointExists(netID)
			@CONTAINER\SetSaveData(netID, readData)
			net.Start(@SNETWORK_STRING_MODIFY)
			@CONTAINER.__class\WriteNetworkData(readData)
			net.Send(ply)

	@RegisterNetwork = =>
		@SNETWORK_STRING_LOAD = "#{@SNETWORK_STRING_PREFIX}Load"
		@SNETWORK_STRING_MODIFY = "#{@SNETWORK_STRING_PREFIX}Modify"
		@SNETWORK_STRING_CREATE = "#{@SNETWORK_STRING_PREFIX}Create"
		@SNETWORK_STRING_DELETE = "#{@SNETWORK_STRING_PREFIX}Delete"
		net.Receive(@SNETWORK_STRING_LOAD, (...) ->   @NetworkOnLoad  (...))
		concommand.Add(@S_OPEN_MENU, (ply) -> @NetworkOnLoad(nil, ply))
		net.Receive(@SNETWORK_STRING_CREATE, (...) -> @NetworkOnCreate(...))
		net.Receive(@SNETWORK_STRING_DELETE, (...) -> @NetworkOnRemove(...))
		net.Receive(@SNETWORK_STRING_MODIFY, (...) -> @NetworkOnModify(...))
	
	@RegisterNetwork()

	WriteNetworkData: =>
		with @savedata
			net.WriteUInt(.id, 32)
			net.WriteString(.name, 32)
			net.WriteInt(.posx, 32)
			net.WriteInt(.posy, 32)
			net.WriteInt(.posz, 32)
			net.WriteUInt(.red, 8)
			net.WriteUInt(.green, 8)
			net.WriteUInt(.blue, 8)
			net.WriteUInt(Icon\GetNetworkID(.icon), 16)
	
	@ReadNetworkData: => -- Static function!
		read = {}
		-- read.id = net.ReadUInt(32)
		read.name = net.ReadString()
		read.posx = net.ReadInt(32)
		read.posy = net.ReadInt(32)
		read.posz = net.ReadInt(32)
		read.red = net.ReadUInt(8)
		read.green = net.ReadUInt(8)
		read.blue = net.ReadUInt(8)
		read.icon = Icon\GetIconName(net.ReadUInt(16))
		return read

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