
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
local WOverlord = WOverlord
local timer = timer
local hook = hook
local CurTime = CurTime
local self = WOverlord
local math = math

local timeSinceLastTick = 0

self.TIME_CVAR = CreateConVar('sv_woverlord_time', '0', {FCVAR_ARCHIVE}, 'Current time in seconds. 0 is first second of the first year (january 1 of 1 year)')
self.TIME = self.TIME_CVAR:GetInt()
self.DATE_OBJECT = self.Date(self.TIME)

function self.UpdateTime()
	local add = self.TIME_MULTIPLIER:GetInt()
	local old = self.TIME
	self.TIME = self.TIME + add
	self.TIME_CVAR:SetInt(self.TIME)
	self.DATE_OBJECT:SetStamp(self.TIME)
	timeSinceLastTick = CurTime()

	if math.floor(old) < math.floor(new) then
		hook.Run('WOverlord_NewSecond')
	end

	if math.floor(old / self.timeTypes.minute) < math.floor(new / self.timeTypes.minute) then
		hook.Run('WOverlord_NewMinute')
	end

	if math.floor(old / self.timeTypes.hour) < math.floor(new / self.timeTypes.hour) then
		hook.Run('WOverlord_NewHour')
	end

	if math.floor(old / self.timeTypes.midday) < math.floor(new / self.timeTypes.midday) then
		hook.Run('WOverlord_NewHalfofday')
	end

	if math.floor(old / self.timeTypes.day) < math.floor(new / self.timeTypes.day) then
		hook.Run('WOverlord_NewDay')
	end

	if math.floor(old / self.timeTypes.week) < math.floor(new / self.timeTypes.week) then
		hook.Run('WOverlord_NewWeek')
	end

	if math.floor(old / self.timeTypes.year) < math.floor(new / self.timeTypes.year) then
		hook.Run('WOverlord_NewYear')
	end

	if math.floor(old / self.timeTypes.age) < math.floor(new / self.timeTypes.age) then
		hook.Run('WOverlord_NewAge')
	end
end

function self.ReplicateTime()

end

timer.Create('WOverlord.UpdateTime', 1, 0, self.UpdateTime)
timer.Create('WOverlord.ReplicateTime', 10, 0, self.ReplicateTime)
