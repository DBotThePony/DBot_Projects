
--[[
Copyright (C) 2016-2018 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

util.AddNetworkString('DFlashback.RecordStatusChanges')
util.AddNetworkString('DFlashback.ReplayStatusChanges')
util.AddNetworkString('DFlashback.SyncFrameAmount')
util.AddNetworkString('DFlashback.SyncServerFPS')
util.AddNetworkString('DFlashback.RestoreSpeed')
util.AddNetworkString('DFlashback.Notify')

local self = DFlashback

function self.Notify(ply, ...)
	net.Start('DFlashback.Notify')
	net.WriteTable{...}
	net.Send(ply)
end

local function SayFunc(ply, text)
	if IsValid(ply) then
		self.Notify(ply, text)
	else
		self.Message(text)
	end
end

self.Commands = {
	record = function(ply, cmd, args)
		if IsValid(ply) and not ply:IsAdmin() then
			SayFunc(ply, 'Not an admin!')
			return
		end

		if self.IsRestoring then
			SayFunc(ply, 'Unable to record: Currently we are replaying!')
			return
		end

		if self.IsRecording then
			self.End()
			SayFunc(ply, 'Recording stopped')
			return
		end

		local time = tonumber(args[1])

		if time then
			self.Begin()
			SayFunc(ply, 'Recording started for ' .. time .. ' seconds')

			timer.Create('DFlashback.Commant.RecordTimer', time, 1, self.End)
		else
			self.Begin()
			SayFunc(ply, 'Recording started')
		end
	end,

	replay = function(ply, cmd, args)
		if IsValid(ply) and not ply:IsAdmin() then
			SayFunc(ply, 'Not an admin!')
			return
		end

		if self.IsRecording then
			self.End()
		end

		if self.IsRestoring then
			self.EndRestore()
			SayFunc(ply, 'Replay stopped')
			return
		end

		self.BeginRestore()
		SayFunc(ply, 'Replay started')
	end,
}

for name, func in pairs(self.Commands) do
	concommand.Add('flashback_' .. name, func)
end
