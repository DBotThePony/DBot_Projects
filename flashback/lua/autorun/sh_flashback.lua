
--[[
Copyright (C) 2016 DBot

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

DFlashback = DFlashback or {}
local self = DFlashback

self.Frames = {}
self.IsRecording = false
self.IsRestoring = false
self.LastFrame = 0
self.LastGC = 0
self.CurrentFrame = {}
self.DISABLED = false

self.RestoreLastFrameCurTime = 0
self.RestoreLastFrameRealTime = 0
self.RestoreLastFrameSysTime = 0

if SERVER then
	util.AddNetworkString('DFlashback.RecordStatusChanges')
	util.AddNetworkString('DFlashback.ReplayStatusChanges')
	util.AddNetworkString('DFlashback.SyncFrameAmount')
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
	self.IsRecording = true
	print('Record Started')
	
	if SERVER then
		net.Start('DFlashback.RecordStatusChanges')
		net.WriteBool(true)
		net.Broadcast()
	end
	
	hook.Run('FlashbackStartsRecord')
end

function self.End()
	if not self.IsRecording then return end
	self.IsRecording = false
	print('Record Stopped')
	
	if SERVER then
		net.Start('DFlashback.RecordStatusChanges')
		net.WriteBool(false)
		net.Broadcast()
	end
	
	hook.Run('FlashbackEndRecord')
end

function self.BeginRestore()
	if self.IsRestoring then return end
	if self.IsRecording then self.End() end
	self.IsRestoring = true
	print('Restoring Started')
	
	if SERVER then
		net.Start('DFlashback.ReplayStatusChanges')
		net.WriteBool(true)
		net.Broadcast()
	end
	
	hook.Run('FlashbackStartsRestore')
end

function self.EndRestore()
	if not self.IsRestoring then return end
	if self.IsRecording then self.End() end
	self.IsRestoring = false
	print('Restoring Ended')
	
	if SERVER then
		net.Start('DFlashback.ReplayStatusChanges')
		net.WriteBool(false)
		net.Broadcast()
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
	print(err)
	print(debug.traceback())
end

function self.RecordFrame()
	local time = SysTime()
	local frame = self.GetCurrentFrame()
	
	self.RestoreLastFrameCurTime = frame.CurTime
	self.RestoreLastFrameRealTime = frame.RealTime
	self.RestoreLastFrameSysTime = frame.SysTime
	
	local tab = hook.GetTable().FlashbackRecordFrame
	if not tab then return end
	
	for k, func in pairs(tab) do
		xpcall(func, Err, self.GetCurrentData(k), k)
	end
	local delta = (SysTime() - time) * 1000
	
	if delta > 30 then
		print('Recording this frame took ' .. math.floor(delta * 100) / 100 .. 'ms!')
	end
end

function self.RestoreFrame()
	local time = SysTime()
	local frame = table.remove(self.Frames)
	if not frame then self.EndRestore() return end
	
	self.CurrentFrame = frame
	self.LastFrame = frame.CurTime
	
	local tab = hook.GetTable().FlashbackRestoreFrame
	
	if not tab then
		self.RestoreLastFrameCurTime = frame.CurTime
		self.RestoreLastFrameRealTime = frame.RealTime
		self.RestoreLastFrameSysTime = frame.SysTime
		return
	end
	
	for k, func in pairs(tab) do
		xpcall(func, Err, self.GetCurrentData(k) or {}, k)
	end
	
	self.RestoreLastFrameCurTime = frame.CurTime
	self.RestoreLastFrameRealTime = frame.RealTime
	self.RestoreLastFrameSysTime = frame.SysTime
	
	local delta = (SysTime() - time) * 1000
	
	if delta > 30 then
		print('Restoring this frame took ' .. math.floor(delta * 100) / 100 .. 'ms!')
	end
end

function self.CurTime()
	if not self.IsRestoring then return CurTime() end
	return self.GetCurrentFrame().CurTime
end

function self.RealTime()
	if not self.IsRestoring then return RealTime() end
	return self.GetCurrentFrame().RealTime
end

function self.SysTime()
	if not self.IsRestoring then return SysTime() end
	return self.GetCurrentFrame().SysTime
end

function self.CurTimeDelta()
	if not self.IsRestoring then return 0 end
	return - self.RestoreLastFrameCurTime + self.GetCurrentFrame().CurTime
end

function self.RealTimeDelta()
	if not self.IsRestoring then return 0 end
	return - self.RestoreLastFrameRealTime + self.GetCurrentFrame().RealTime
end

function self.SysTimeDelta()
	if not self.IsRestoring then return 0 end
	return - self.RestoreLastFrameSysTime + self.GetCurrentFrame().SysTime
end

function self.OnThink()
	if self.DISABLED then return end
	
	if self.SkipCurrentFrame then
		self.GetCurrentFrame()
		self.SkipCurrentFrame = false
	end
	
	if self.LastGC < RealTime() then
		self.rungc()
		self.LastGC = RealTime() + 20
	end
	
	if #self.Frames > 10000 then
		print('FLASHBACK PANIC! Disabling DFlashBack')
		print(debug.traceback())
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
	if (self.IsRestoring or self.LastFrame == CurTime()) and not self.SkipCurrentFrame then
		return self.CurrentFrame
	end
	
	if (self.CurrentFrame and self.CurrentFrame.CurTime == CurTime()) and not self.SkipCurrentFrame then
		return self.CurrentFrame
	end
	
	local newFrame = {}
	local index = table.insert(self.Frames, newFrame)
	
	newFrame.ID = index
	newFrame.index = index
	newFrame.CurTime = CurTime()
	newFrame.RealTime = RealTime()
	newFrame.SysTime = SysTime()
	
	newFrame.Data = {}
	newFrame.Data.default = {}
	newFrame.Data.default.index = index
	newFrame.Data.default.ID = index
	
	self.LastFrame = CurTime()
	
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

hook.Add('Tick', 'DFlashback.Main', self.OnThink)
