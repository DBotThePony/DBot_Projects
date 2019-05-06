
--[[
Copyright (C) 2016-2019 DBotThePony


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
