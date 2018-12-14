
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
local CurTime = CurTimeL
local self = DDayNight
local math = math
local net = net

self.INITIALIZE = false

local lastThink = 0
local _delta
self.DATE_OBJECT = self.Date(0)

function self.GetAccurateTime()
	return self.TIME
end

local sunset, sunrise = true, true

local function Think()
	if not self.INITIALIZE then return end
	_delta = _delta or CurTime()
	local delta = CurTime() - _delta
	_delta = CurTime()

	local old = self.TIME
	self.TIME = self.TIME + self.CalcFastForward() + delta * self.TIME_MULTIPLIER:GetFloat()
	local new = self.TIME
	self.DATE_OBJECT:SetStamp(self.TIME)

	if math.floor(old) < math.floor(new) then
		hook.Run('DDayNight_NewSecond')

		for i = math.floor(old), math.floor(new) do
			hook.Run('DDayNight_RealTimeLSecond')
		end
	end

	if math.floor(old / self.timeTypes.minute) < math.floor(new / self.timeTypes.minute) then
		hook.Run('DDayNight_NewMinute')
	end

	if math.floor(lastThink) == math.floor(CurTime()) then return end
	lastThink = CurTime()

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
	elseif progression > 0 then
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

net.receive('ddaynight.replicatetime', function()
	self.INITIALIZE = true
	local time = net.ReadBigUInt()
	local validAt = net.ReadDouble()
	local delta = CurTime() - validAt
	self.TIME = time + delta * self.TIME_MULTIPLIER:GetFloat()
	lastThink = CurTime()
	_delta = CurTime()
end)

net.receive('ddaynight.forcetimechange', function()
	sunset = false
	sunrise = false
	hook.Run('DDayNight_ForceRecalculateTime')
end)

if IsValid(LocalPlayer()) then
	net.Start('ddaynight.replicatetime')
	net.SendToServer()
else
	local frame = 0
	hook.Add('Think', 'DDayNight_RequestTime', function()
		if not IsValid(LocalPlayer()) then return end

		frame = frame + 1
		if frame < 200 then return end

		hook.Remove('Think', 'DDayNight_RequestTime')
		net.Start('ddaynight.replicatetime')
		net.SendToServer()
	end)
end

hook.Add('Think', 'DDayNight_UpdateTime', Think)
