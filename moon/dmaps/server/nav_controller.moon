
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

import DMaps, navmesh, net from _G
import AStarTracer from DMaps

NAV_ENABLE = CreateConVar('sv_dmaps_nav_enable', '1', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable navigation support (if map has nav file)')

net.Receive 'DMaps.Navigation.Require', (len, ply) ->
	return if not NAV_ENABLE\GetBool()
	if not navmesh.IsLoaded()
		net.Start('DMaps.Navigation.NotInstalled')
		net.Send(ply)
		return
	
	hookID = "DMaps.NavigationCheck.#{ply\SteamID()}"

	return if ply.__DMaps_AStarTracer and not ply.__DMaps_AStarTracer\HasFinished()
	
	pos = ply\GetPos()
	endPos = net.ReadVector()
	tracer = AStarTracer(pos, endPos)
	ply.__DMaps_AStarTracer = tracer

	hook.Add 'Think', hookID, ->
		if tracer\HasFinished()
			hook.Remove 'Think', hookID
			return
		if IsValid(ply) return
		tracer\Stop()
		hook.Remove 'Think', hookID

	tracer\SetFailureCallback ->
		if not IsValid(ply) return
		net.Start('DMaps.Navigation.Require')
		net.WriteBool(false)
		net.Send(ply)
	
	tracer\SetSuccessCallback ->
		if not IsValid(ply) return
		net.Start('DMaps.Navigation.Require')
		net.WriteBool(true)

		points = tracer\GetPoints()
		net.WriteUInt(#points, 16)
		for {:x, :y, :z} in *points -- Less traffic when there are many points
			net.WriteInt(math.floor(x), 16)
			net.WriteInt(math.floor(y), 16)
			net.WriteInt(math.floor(z), 16)
		net.Send(ply)
	
	tracer\Start()