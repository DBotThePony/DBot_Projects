
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
local self = WOverlord
local math = math
local ipairs = ipairs
local pairs = pairs
local table = table

function self.GetAge()
	return math.floor(self.TIME / self.timeTypes.age)
end

function self.GetYear()
	return math.floor(self.TIME / self.timeTypes.year)
end

function self.GetMonth()
	local time = self.TIME % self.timeTypes.year

	for i, seconds in pairs(self.monthsTimeInYearNumeric) do
		if seconds >= time then
			return i - 1
		end
	end
end

function self.GetMonthTime()
	local time = self.TIME % self.timeTypes.year
	local month = self.GetMonth()

	if month == 0 then
		return time
	end

	return time - self.MonthLength(month - 1)
end

function self.GetAbsoluteMonth()
	return self.GetMonth() + 12 * self.GetYear()
end

function self.GetWeek()
	return math.floor((self.TIME % self.timeTypes.year) / self.timeTypes.week)
end

function self.GetLocalWeek()
	return math.floor(self.GetMonthTime() / self.timeTypes.week)
end

function self.GetDay()
	return math.floor((self.TIME % self.timeTypes.year) / self.timeTypes.day)
end

function self.GetLocalDay()
	return math.floor((self.TIME % self.timeTypes.week) / self.timeTypes.day)
end

function self.GetAbsoluteDay()
	return math.floor(self.TIME / self.timeTypes.day)
end

function self.GetAbsoluteHour()
	return math.floor(self.TIME / self.timeTypes.hour)
end

function self.GetHour()
	return math.floor((self.TIME % self.timeTypes.day) / self.timeTypes.hour)
end

function self.GetAbsoluteMinute()
	return math.floor(self.TIME / self.timeTypes.minute)
end

function self.GetMinute()
	return math.floor((self.TIME % self.timeTypes.hour) / self.timeTypes.minute)
end

function self.GetAbsoluteSecond()
	return self.TIME
end

function self.GetSecond()
	return self.TIME % self.timeTypes.minute
end
