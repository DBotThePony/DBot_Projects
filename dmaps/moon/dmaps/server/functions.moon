
--
-- Copyright (C) 2017 DBot

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
	net.WriteArray({...})
	net.Send(ply)
DMaps.ChatPrint = (ply, ...) ->
	net.Start('DMaps.ChatMessage')
	net.WriteArray({...})
	net.Send(ply)
DMaps.Notify = (ply = player.GetAll(), message = {}, Type = NOTIFY_GENERIC, time = 5) ->
	message = {message} if type(message) ~= 'table'
	net.Start('DMaps.ChatMessage')
	net.WriteUInt(Type, 8)
	net.WriteUInt(time, 8)
	net.WriteArray(message)
	net.Send(ply)
DMaps.AdminEcho = (...) ->
	DMaps.Message(...)
	net.Start('DMaps.AdminEcho')
	net.WriteArray({...})
	net.Send([k for k, v in pairs AVALIABLE_ADMINS_LOGS])
