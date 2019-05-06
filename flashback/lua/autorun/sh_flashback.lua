
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

DFlashback = DFlashback or {}
local self = DFlashback

self.RESTORE_SPEED = CreateConVar('sv_flashback_speed', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Multiplier of restore speed. Must be 0.1 - 1.0')

self.Frames = {}
self.IsRecording = false
self.IsRestoring = false
self.LastFrame = 0
self.LastGC = 0
self.CurrentFrame = {}
self.DISABLED = false

self.RestoreSpeed = 1

self.RestoreLastFrameCurTimeL = 0
self.RestoreLastFrameRealTimeL = 0
self.RestoreLastFrameSysTime = 0

function self.SetRestoreSpeed(speed)
	self.RestoreSpeed = math.Clamp(speed, 0.1, 1)

	if CLIENT then return end
	net.Start('DFlashback.RestoreSpeed')
	net.WriteFloat(speed)
	net.Broadcast()
end

local function SpeedChanges()
	self.SetRestoreSpeed(self.RESTORE_SPEED:GetFloat())
end

cvars.AddChangeCallback('sv_flashback_speed', SpeedChanges, 'Flashback')
timer.Simple(0, SpeedChanges)

local GREY = Color(200, 200, 200)
local GREEN = Color(0, 200, 0)

function self.Message(...)
	MsgC(GREEN, '[DFlashback] ', GREY, ...)
	MsgC('\n')
end

if not CPPI then
	self.Message('/------------------------------------------------------\\')
	self.Message('Warning: No CPPI Found. Without CPPI some features would not work.')
	self.Message('To use all features install prop proection with CPPI support!')
	self.Message('Try DPP (Mine PP), or FPP (loved by all PP)!')
	self.Message('/------------------------------------------------------\\')
end

function self.rungc()
	for i = 1, #self.Frames - 3000 do
		self.Frames[i] = nil
	end

	table.remove(self.Frames, 0) -- Remove gaps

	for id, frame in ipairs(self.Frames) do
		frame.index = id
		frame.ID = id

		for key, data in pairs(frame.Data) do
			data.ID = id
			data.index = id
		end
	end
end

function self.Begin()
	if self.IsRecording then return end
	if self.IsRestoring then self.EndRestore() end
	self.Frames = {}
	self.IsRecording = true
	self.Message('Record Started')

	if SERVER then
		net.Start('DFlashback.RecordStatusChanges')
		net.WriteBool(true)
		net.Broadcast()

		timer.Stop('DFlashback.Commant.RecordTimer')
	end

	hook.Run('FlashbackStartsRecord')
end

function self.End()
	if not self.IsRecording then return end
	self.IsRecording = false
	self.Message('Record Stopped')

	if SERVER then
		net.Start('DFlashback.RecordStatusChanges')
		net.WriteBool(false)
		net.Broadcast()

		timer.Stop('DFlashback.Commant.RecordTimer')
	end

	hook.Run('FlashbackEndRecord')
end

function self.BeginRestore()
	if self.IsRestoring then return end
	if self.IsRecording then self.End() end
	self.IsRestoring = true
	self.Message('Replay Started')

	if SERVER then
		net.Start('DFlashback.ReplayStatusChanges')
		net.WriteBool(true)
		net.Broadcast()

		timer.Stop('DFlashback.Commant.RecordTimer')
	end

	hook.Run('FlashbackStartsRestore')
end

function self.EndRestore()
	if not self.IsRestoring then return end
	if self.IsRecording then self.End() end
	self.IsRestoring = false
	self.Frames = {}
	self.Message('Replay Ended')

	if SERVER then
		net.Start('DFlashback.ReplayStatusChanges')
		net.WriteBool(false)
		net.Broadcast()

		timer.Stop('DFlashback.Commant.RecordTimer')
	else
		RunConsoleCommand('stopsound')
	end

	hook.Run('FlashbackEndsRestore')
end

self.Start = self.Begin
self.Play = self.Begin
self.Stop = self.End

self.StartReplay = self.BeginRestore
self.StartRestore = self.BeginRestore
self.StarFlashback = self.BeginRestore
self.StopReplay = self.EndRestore
self.StopRestore = self.EndRestore
self.StopFlashback = self.EndRestore

local function Err(err)
	self.Message(err)
	self.Message(debug.traceback())
end

function self.RecordFrame()
	local time = SysTime()
	local frame = self.GetCurrentFrame()

	self.RestoreLastFrameCurTimeL = frame.CurTimeL
	self.RestoreLastFrameRealTimeL = frame.RealTimeL
	self.RestoreLastFrameSysTime = frame.SysTime

	local tab = hook.GetTable().FlashbackRecordFrame
	if not tab then return end

	for k, func in pairs(tab) do
		xpcall(func, Err, self.GetCurrentData(k), k)
	end
	local delta = (SysTime() - time) * 1000

	if delta > 30 then
		self.Message('Recording this frame took ' .. math.floor(delta * 100) / 100 .. 'ms!')
	end
end

function self.RestoreFrame()
	local time = SysTime()
	local frame = table.remove(self.Frames)
	if not frame then self.EndRestore() return end

	self.CurrentFrame = frame
	self.LastFrame = frame.CurTimeL

	local tab = hook.GetTable().FlashbackRestoreFrame

	if not tab then
		self.RestoreLastFrameCurTimeL = frame.CurTimeL
		self.RestoreLastFrameRealTimeL = frame.RealTimeL
		self.RestoreLastFrameSysTime = frame.SysTime
		return
	end

	for k, func in pairs(tab) do
		xpcall(func, Err, self.GetCurrentData(k) or {}, k)
	end

	self.RestoreLastFrameCurTimeL = frame.CurTimeL
	self.RestoreLastFrameRealTimeL = frame.RealTimeL
	self.RestoreLastFrameSysTime = frame.SysTime

	local delta = (SysTime() - time) * 1000

	if delta > 30 then
		self.Message('Restoring this frame took ' .. math.floor(delta * 100) / 100 .. 'ms!')
	end
end

function self.CurTimeL()
	if not self.IsRestoring then return CurTimeL() end
	return self.GetCurrentFrame().CurTimeL
end

function self.RealTimeL()
	if not self.IsRestoring then return RealTimeL() end
	return self.GetCurrentFrame().RealTimeL
end

function self.SysTime()
	if not self.IsRestoring then return SysTime() end
	return self.GetCurrentFrame().SysTime
end

function self.CurTimeLDelta()
	if not self.IsRestoring then return 0 end
	return - self.RestoreLastFrameCurTimeL + self.GetCurrentFrame().CurTimeL
end

function self.RealTimeLDelta()
	if not self.IsRestoring then return 0 end
	return - self.RestoreLastFrameRealTimeL + self.GetCurrentFrame().RealTimeL
end

function self.SysTimeDelta()
	if not self.IsRestoring then return 0 end
	return - self.RestoreLastFrameSysTime + self.GetCurrentFrame().SysTime
end

self.NextThink = 0
self.IgnoreNextThink = false

function self.OnThink()
	if self.DISABLED then return end

	if not self.IgnoreNextThink and self.NextThink > RealTimeL() then return end

	if CLIENT then
		if self.IsRestoring then
			self.NextThink = RealTimeL() + self.ServerFPSTime * (1 / self.RestoreSpeed)
		else
			self.NextThink = RealTimeL() + self.ServerFPSTime
		end
	else
		if self.IsRestoring then
			self.NextThink = RealTimeL() + FrameTime() * (1 / self.RestoreSpeed)
		else
			self.NextThink = RealTimeL()
		end
	end

	if self.SkipCurrentFrame then
		self.GetCurrentFrame()
		self.SkipCurrentFrame = false
	end

	if self.LastGC < RealTimeL() then
		self.rungc()
		self.LastGC = RealTimeL() + 20
	end

	if #self.Frames > 10000 then
		self.Message('FLASHBACK PANIC! Disabling DFlashBack')
		self.Message(debug.traceback())
		self.Frames = {}
		self.DISABLED = true
		return
	end

	if #self.Frames > 6000 then
		self.rungc()
	end

	if self.IsRecording then
		self.RecordFrame()
	elseif self.IsRestoring then
		self.RestoreFrame()
	end

	if SERVER then
		net.Start('DFlashback.SyncFrameAmount')
		net.WriteUInt(#self.Frames, 16)
		net.Broadcast()

		net.Start('DFlashback.SyncServerFPS')
		net.WriteUInt(math.floor(1 / FrameTime()), 16)
		net.Broadcast()
	end
end

function self.WriteDelta(str, key, val)
	local get = self.FindDelta(str, key, 'DFLASBACK_NO_DELTA_RESULT')

	if get == val then return end

	self.GetCurrentData(str)[key] = val
end

function self.FindDelta(str, key, ifNothing)
	local lookingAt = #self.Frames

	for i = lookingAt, lookingAt - 400, -1 do -- Limit to 400 frames
		local frame = self.Frames[i]
		if not frame then break end

		local data = frame.Data[str]
		if not data then break end

		local get = data[key]

		if get ~= nil then
			return get
		end
	end

	return ifNothing
end

function self.GetPreviousFrame()
	return self.Frames[self.GetCurrentFrame().ID - 1]
end

function self.GetCurrentFrame()
	if (self.IsRestoring or self.LastFrame == CurTimeL()) and not self.SkipCurrentFrame then
		return self.CurrentFrame
	end

	if (self.CurrentFrame and self.CurrentFrame.CurTimeL == CurTimeL()) and not self.SkipCurrentFrame then
		return self.CurrentFrame
	end

	local newFrame = {}
	local index = table.insert(self.Frames, newFrame)

	newFrame.ID = index
	newFrame.index = index
	newFrame.CurTimeL = CurTimeL()
	newFrame.RealTimeL = RealTimeL()
	newFrame.SysTime = SysTime()

	newFrame.Data = {}
	newFrame.Data.default = {}
	newFrame.Data.default.index = index
	newFrame.Data.default.ID = index

	self.LastFrame = CurTimeL()

	self.CurrentFrame = newFrame

	return newFrame
end

function self.GetCurrentData(str)
	if str then
		local frame = self.GetCurrentFrame()
		frame.Data[str] = frame.Data[str] or {}
		frame.Data[str].ID = frame.ID
		frame.Data[str].index = frame.ID
		return frame.Data[str]
	else
		return self.GetCurrentFrame().Data.default
	end
end

hook.Add('Think', 'DFlashback.OnThink', self.OnThink)
