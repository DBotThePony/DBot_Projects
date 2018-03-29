
-- Copyright (C) 2017-2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local DLib = DLib
local DDayNight = DDayNight
local timer = timer
local hook = hook
local CurTimeL = CurTimeL
local self = DDayNight
local math = math
local net = net

self.INITIALIZE = false
self.BOUND_TIME = 0
self.BOUND_TIME_TO = 0
local lastThink = 0
self.DATE_OBJECT = self.Date(0)
self.DATE_OBJECT_ACCURATE = self.Date(self.TIME)

function self.GetAccurateTime()
	return self.BOUND_TIME + (CurTimeL() - self.BOUND_TIME_TO) * self.TIME_MULTIPLIER:GetInt()
end

local sunset, sunrise = true, true

local function Think()
	if not self.INITIALIZE then return end
	self.DATE_OBJECT_ACCURATE:SetStamp(self.GetAccurateTime())

	if math.floor(lastThink) == math.floor(CurTimeL()) then return end
	lastThink = CurTimeL()

	local old = self.TIME
	self.TIME = math.floor(self.GetAccurateTime())
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
	local time = net.ReadUInt(64)
	local validAt = net.ReadDouble()

	self.BOUND_TIME = time
	self.TIME = time
	self.BOUND_TIME_TO = validAt
	lastThink = validAt
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
