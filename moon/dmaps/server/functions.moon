
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

import DMaps, net, CAMI, player, hook from _G

AVALIABLE_ADMINS_LOGS = {}

UpdateLogAdminList = ->
	for ply in *player.GetAll()
		CAMI.PlayerHasAccess ply, 'dmaps_logs', (has = false, reason = '') ->
			AVALIABLE_ADMINS_LOGS[ply] = true if has
			AVALIABLE_ADMINS_LOGS[ply] = nil if not has
	for i, bool in pairs AVALIABLE_ADMINS_LOGS
		AVALIABLE_ADMINS_LOGS[i] = nil if not IsValid(i)

timer.Create 'DMaps.AdminCheckup', 10, 0, UpdateLogAdminList
hook.Add 'PlayerInitialSpawn', 'DMaps.Logs', -> timer.Simple(1, UpdateLogAdminList)
hook.Add 'PlayerDisconnected', 'DMaps.Logs', -> timer.Simple(1, UpdateLogAdminList)

DMaps.Print = (ply, ...) ->
	net.Start('DMaps.ConsoleMessage')
	DMaps.WriteArray({...})
	net.Send(ply)
DMaps.ChatPrint = (ply, ...) ->
	net.Start('DMaps.ChatMessage')
	DMaps.WriteArray({...})
	net.Send(ply)
DMaps.Notify = (ply = player.GetAll(), message = {}, Type = NOTIFY_GENERIC, time = 5) ->
	message = {message} if type(message) ~= 'table'
	net.Start('DMaps.ChatMessage')
	net.WriteUInt(Type, 8)
	net.WriteUInt(time, 8)
	DMaps.WriteArray(message)
	net.Send(ply)
DMaps.AdminEcho = (...) ->
	DMaps.Message(...)
	net.Start('DMaps.AdminEcho')
	DMaps.WriteArray({...})
	net.Send([k for k, v in pairs AVALIABLE_ADMINS_LOGS])
