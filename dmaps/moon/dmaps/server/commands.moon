
--
-- Copyright (C) 2017-2019 DBot
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

import concommand, Vector, MsgC, NULL, tonumber, team from _G

TeleportTo = (ply, x, y, z) ->
	if not ply\IsValid() return
	CAMI.PlayerHasAccess ply, 'dmaps_teleport', (has = false, reason = '') ->
		if not has return
		if not x return
		if not y return
		if not z return
		if not ply\Alive() return
		ply\SetPos(Vector(x, y, z))
		DMaps.AdminEcho('Admin ', ply, ' has teleported to X: ', x, ' Y: ', y, ' Z: ', z)
concommand.Add('dmaps_teleport', (ply = NULL, cmd = '', args = {}) -> TeleportTo(ply, tonumber(args[1]), tonumber(args[2]), tonumber(args[3])))

concommand.Add 'dmaps_share', (ply = NULL, cmd = '', args = {}, argStr = '') ->
	return DMaps.Message('what are you doing') if not IsValid(ply)
	ply.__DMaps_Share = ply.__DMaps_Share or 0
	return DMaps.Notify(ply, 'Please wait before sharing another waypoint!', NOTIFY_ERROR) if ply.__DMaps_Share > RealTime()
	players = for str in *string.Explode(',', args[1] or '')
		mply = Player(tonumber(str\Trim()) or -1)
		if not IsValid(mply) or mply == ply or mply\IsBot() continue
		mply
	return DMaps.Print(ply, 'No valid players found') if #players == 0
	local x, y, z
	{x, y, z} = [math.floor(math.Clamp(tonumber(args[i] or '0') or 0, -16000, 16000)) for i = 2, 4]
	ply.__DMaps_Share = RealTime() + 2
	DMaps.Message(ply, ' shares a waypoint to ', unpack(players))
	DMaps.ChatPrint(ply, 'You shared waypoint to ', unpack(players))
	net.Start('DMaps.Sharing')
	net.WriteInt(x, 16)
	net.WriteInt(y, 16)
	net.WriteInt(z, 16)
	net.WriteEntity(ply)
	net.SendOmit(ply)
