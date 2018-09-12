
-- Copyright (C) 2017-2018 DBot

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
local CurTimeL = CurTimeL
local self = DDayNight
local math = math
local net = net

net.pool('ddaynight.replicatetime')
net.pool('ddaynight.forcetimechange')

local timeSinceLastTick = 0

self.TIME_CVAR = CreateConVar('sv_ddaynight_time', '0', {FCVAR_ARCHIVE}, 'Current time in seconds. 0 is first second of the first year (january 1 of 1 year)')
self.TIME = self.TIME_CVAR:GetInt()
self.DATE_OBJECT = self.Date(self.TIME)
self.DATE_OBJECT_ACCURATE = self.Date(self.TIME)

function self.GetAccurateTime()
	return self.TIME + (CurTimeL() - timeSinceLastTick) * self.TIME_MULTIPLIER:GetInt()
end

local function Think()
	self.DATE_OBJECT_ACCURATE:SetStamp(self.GetAccurateTime())
end

local sunset, sunrise = false, false

local function UpdateTime()
	local add = self.TIME_MULTIPLIER:GetInt()
	local old = self.TIME
	self.TIME = self.TIME + add
	local new = self.TIME
	self.TIME_CVAR:SetInt(self.TIME)
	self.DATE_OBJECT:SetStamp(self.TIME)
	timeSinceLastTick = CurTimeL()

	if math.floor(old) < math.floor(new) then
		hook.Run('DDayNight_NewSecond')

		for i = math.floor(old), math.floor(new) do
			hook.Run('DDayNight_RealTimeLSecond')
		end
	end

	if math.floor(old / self.timeTypes.minute) < math.floor(new / self.timeTypes.minute) then
		hook.Run('DDayNight_NewMinute')
	end

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
	net.Start('ddaynight.replicatetime')
	net.WriteBigUInt(self.TIME)
	net.WriteDouble(timeSinceLastTick)
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
	net.WriteDouble(timeSinceLastTick)
	net.Send(ply)
end)

timer.Create('DDayNight.UpdateTime', 1, 0, function() ProtectedCall(UpdateTime) end)
timer.Create('DDayNight.ReplicateTime', 10, 0, function() ProtectedCall(ReplicateTime) end)
ReplicateTime()
hook.Add('Think', 'DDayNight_UpdateTime', Think)
