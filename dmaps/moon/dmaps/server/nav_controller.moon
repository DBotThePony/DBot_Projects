
--
-- Copyright (C) 2017-2019 DBot

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.


import DMaps, navmesh, net from _G
import AStarTracer from DLib

NAV_ENABLE = CreateConVar('sv_dmaps_nav_enable', '1', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable navigation support (if map has nav file)')

net.Receive 'DMaps.Navigation.Stop', (len, ply) ->
	return if not ply.__DMaps_AStarTracer or ply.__DMaps_AStarTracer\HasFinished()
	ply.__DMaps_AStarTracer\Stop()

net.Receive 'DMaps.Navigation.Require', (len, ply) ->
	return if not NAV_ENABLE\GetBool()
	if not navmesh.IsLoaded()
		net.Start('DMaps.Navigation.NotInstalled')
		net.Send(ply)
		return

	hookID = "DMaps.NavigationCheck.#{ply\SteamID()}"

	return if ply.__DMaps_AStarTracer and not ply.__DMaps_AStarTracer\HasFinished()

	pos = ply\GetPos()
	endPos = Vector(net.ReadInt(32), net.ReadInt(32), net.ReadInt(32))
	sendInfos = net.ReadBool()
	tracer = AStarTracer(pos, endPos)
	ply.__DMaps_AStarTracer = tracer
	ply.__DMaps_SendTracingInfos = sendInfos

	hook.Add 'Think', hookID, ->
		if tracer\HasFinished()
			hook.Remove 'Think', hookID
			return
		if not IsValid(ply)
			tracer\Stop()
			hook.Remove 'Think', hookID
			return
		net.Start('DMaps.Navigation.Info', true)
		net.WriteInt(tracer\GetIterations(), 16)
		net.WriteInt(tracer\GetOpenNodesCount(), 16)
		net.WriteInt(tracer\GetClosedNodesCount(), 16)
		net.WriteInt(tracer\GetTotalNodesCount(), 16)
		net.WriteInt(math.floor(tracer\GetCalculationTime()), 16)
		net.WriteInt(math.floor(tracer\GetLeftDistance()), 16)
		net.Send(ply)

	tracer\SetFailureCallback((code) =>
		if not IsValid(ply) return
		net.Start('DMaps.Navigation.Require')
		net.WriteBool(false)
		net.WriteUInt(code, 8)
		net.Send(ply)
	)

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