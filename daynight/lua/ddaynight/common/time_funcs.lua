
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
local self = DDayNight
local math = math
local ipairs = ipairs
local pairs = pairs
local table = table
local string = string

function self.MonthLength(id)
	return self.monthLength[id]
end

function self.MonthLengthAbsolute(id)
	return self.monthsTimeInYearNumeric[id]
end

function self.NormalizeMonth(index)
	local new = index % 11

	if new < 0 then
		new = new + 12
	end

	return new
end

function self.NormalizeDaytime(stamp)
	return stamp % self.timeTypes.day
end

function self.FormatTime(stamp)
	stamp = self.NormalizeDaytime(stamp)
	local hours = math.floor(stamp / self.timeTypes.hour)
	stamp = stamp - hours * self.timeTypes.hour
	local minutes = math.floor(stamp / self.timeTypes.minute)
	stamp = stamp - minutes * self.timeTypes.minute
	local seconds = math.floor(stamp)

	return string.format('%.2i:%.2i:%.2i', hours, minutes, seconds)
end

function self.FormatHours(stamp)
	stamp = self.NormalizeDaytime(stamp)
	local hours = math.floor(stamp / self.timeTypes.hour)
	stamp = stamp - hours * self.timeTypes.hour
	local minutes = math.floor(stamp / self.timeTypes.minute)

	return string.format('%.2i:%.2i', hours, minutes)
end

function self.NewDate()
	return self.Date(self.GetAccurateTime())
end
