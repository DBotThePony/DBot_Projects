
-- Copyright (C) 2017-2019 DBotThePony

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


local DLib = DLib
local DDayNight = DDayNight
local timer = timer
local hook = hook
local CurTime = CurTime
local self = DDayNight
local math = math
local net = net

net.pool('ddaynight.replicatetime')
net.pool('ddaynight.forcetimechange')

local timeSinceLastTick = 0
local _delta

self.TIME_CVAR = CreateConVar('sv_ddaynight_time', '0', {FCVAR_ARCHIVE}, 'Current time in seconds. 0 is first second of the first year (january 1 of 1 year)')
self.TIME = self.TIME_CVAR:GetInt()
self.DATE_OBJECT = self.Date(self.TIME)

function self.GetAccurateTime()
	return self.TIME
end

local sunset, sunrise = false, false

local function UpdateTime()
	_delta = _delta or CurTime()
	local delta = CurTime() - _delta
	_delta = CurTime()

	local old = self.TIME
	self.TIME = self.TIME + self.CalcFastForward() + delta * self.TIME_MULTIPLIER:GetFloat()
	local new = self.TIME

	self.DATE_OBJECT:SetStamp(self.TIME)
	self.TIME_CVAR:SetInt(self.TIME)

	if math.floor(old) < math.floor(new) then
		hook.Run('DDayNight_NewSecond')

		for i = math.floor(old), math.floor(new) do
			hook.Run('DDayNight_RealTimeLSecond')
		end
	end

	if math.floor(old / self.timeTypes.minute) < math.floor(new / self.timeTypes.minute) then
		hook.Run('DDayNight_NewMinute')
	end

	if math.floor(timeSinceLastTick) == math.floor(CurTime()) then return end
	timeSinceLastTick = CurTime()

	if math.floor(old / self.timeTypes.hour) < math.floor(new / self.timeTypes.hour) then
		hook.Run('DDayNight_NewHour')
	end

	if math.floor(old / self.timeTypes.hour / 2) < math.floor(new / self.timeTypes.hour / 2) then
		hook.Run('DDayNight_NewTwoHours')
	end

	if math.floor(old / self.timeTypes.hour / 4) < math.floor(new / self.timeTypes.hour / 4) then
		hook.Run('DDayNight_NewQuater')
	end

	if math.floor(old / self.timeTypes.midday) < math.floor(new / self.timeTypes.midday) then
		hook.Run('DDayNight_NewHalfofday')
	end

	if math.floor(old / self.timeTypes.day) < math.floor(new / self.timeTypes.day) then
		hook.Run('DDayNight_NewDay')
	end

	if math.floor(old / self.timeTypes.week) < math.floor(new / self.timeTypes.week) then
		hook.Run('DDayNight_NewWeek')
	end

	if math.floor(old / self.timeTypes.year) < math.floor(new / self.timeTypes.year) then
		hook.Run('DDayNight_NewYear')
	end

	if math.floor(old / self.timeTypes.age) < math.floor(new / self.timeTypes.age) then
		hook.Run('DDayNight_NewAge')
	end

	local progression = self.DATE_OBJECT:GetDayProgression()

	if progression == 0 then
		if sunrise then
			hook.Run('DDayNight_InitializeTimeStatement')
		end

		sunrise = false
		sunset = false
	elseif progression > 0 and progression ~= 1 then
		if not sunrise then
			sunset = false
			sunrise = true
			hook.Run('DDayNight_Sunrise')
		end
	elseif progression == 1 then
		if not sunset then
			sunset = true
			sunrise = false
			hook.Run('DDayNight_Sunset')
		end
	end
end

local function ReplicateTime()
	if not _delta then
		timer.Simple(0, ReplicateTime)
		return
	end

	net.Start('ddaynight.replicatetime')
	net.WriteBigUInt(self.TIME)
	net.WriteDouble(_delta)
	net.Broadcast()
end

function self.SetTime(stampnew)
	local add = self.TIME_MULTIPLIER:GetInt()
	stampnew = math.max(stampnew, add * 2)
	self.TIME = stampnew - add * 2
	UpdateTime()
	ReplicateTime()
	net.Start('ddaynight.forcetimechange')
	net.Broadcast()
	hook.Run('DDayNight_ForceRecalculateTime')

	sunrise = false
	sunset = false
end

net.Receive('ddaynight.replicatetime', function(len, ply)
	if not IsValid(ply) then return end
	net.Start('ddaynight.replicatetime')
	net.WriteBigUInt(self.TIME)
	net.WriteDouble(_delta)
	net.Send(ply)
end)

timer.Remove('DDayNight.UpdateTime', 0.25, 0, function() ProtectedCall(UpdateTime) end)
hook.Add('Think', 'DDayNight_UpdateTime', UpdateTime)
timer.Create('DDayNight.ReplicateTime', 10, 0, function() ProtectedCall(ReplicateTime) end)
ReplicateTime()
