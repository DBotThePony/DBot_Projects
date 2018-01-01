
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

-- This object is supposted to be static

local DLib = DLib
local WOverlord = WOverlord
local math = math
local ipairs = ipairs
local pairs = pairs
local table = table
local Lerp = Lerp
local string = string

local meta = DLib.CreateLuaObject('WODate', false)

WOverlord.Date = meta.Create

function meta:Initialize(stamp)
	self:SetStamp(stamp)
end

function meta:SetStamp(stamp)
	self.stamp = stamp

	if not self.dayObject or self.dayObject:GetAbsoluteDay() ~= self:GetAbsoluteDay() then
		if not self.dayObject then
			self.dayObject = WOverlord.Day(stamp)
		else
			self.dayObject:SetStamp(stamp)
		end
	end
end

function meta:GetDayObject()
	return self.dayObject
end

function meta:DateDay()
	return self.dayObject
end

function meta:GetAge()
	return math.floor(self.stamp / WOverlord.timeTypes.age)
end

function meta:GetYear()
	return math.floor(self.stamp / WOverlord.timeTypes.year)
end

function meta:GetMonth()
	local time = self.stamp % WOverlord.timeTypes.year

	for i, seconds in pairs(WOverlord.monthsTimeInYearNumeric) do
		if seconds >= time then
			return i - 1
		end
	end
end

function meta:GetMonthTime()
	local time = self.stamp % WOverlord.timeTypes.year
	local month = self:GetMonth()

	if month == 0 then
		return time
	end

	return time - WOverlord.MonthLength(month - 1)
end

function meta:GetAbsoluteMonth()
	return self.GetMonth() + 12 * self:GetYear()
end

function meta:GetWeek()
	return math.floor((self.stamp % WOverlord.timeTypes.year) / WOverlord.timeTypes.week)
end

function meta:GetLocalWeek()
	return math.floor(self:GetMonthTime() / WOverlord.timeTypes.week)
end

function meta:GetDay()
	return math.floor((self.stamp % WOverlord.timeTypes.year) / WOverlord.timeTypes.day)
end

function meta:GetLocalDay()
	return math.floor((self.stamp % WOverlord.timeTypes.week) / WOverlord.timeTypes.day)
end

function meta:GetAbsoluteDay()
	return math.floor(self.stamp / WOverlord.timeTypes.day)
end

function meta:GetAbsoluteHour()
	return math.floor(self.stamp / WOverlord.timeTypes.hour)
end

function meta:GetHour()
	return math.floor((self.stamp % WOverlord.timeTypes.day) / WOverlord.timeTypes.hour)
end

function meta:GetAbsoluteMinute()
	return math.floor(self.stamp / WOverlord.timeTypes.minute)
end

function meta:GetMinute()
	return math.floor((self.stamp % WOverlord.timeTypes.hour) / WOverlord.timeTypes.minute)
end

function meta:GetAbsoluteSecond()
	return math.floor(self.stamp)
end

function meta:GetSecond()
	return math.floor(self.stamp % WOverlord.timeTypes.minute)
end

function meta:FormatCurrentHour()
	return WOverlord.FormatHours(self.stamp)
end

function meta:FormatHour()
	return WOverlord.FormatHours(self.stamp)
end

function meta:FormatCurrentTime()
	return WOverlord.FormatTime(self.stamp)
end

function meta:FormatTime()
	return WOverlord.FormatTime(self.stamp)
end

function meta:Format()
	return string.format('%.2i %s %.4i %s', self:GetDayInMonth(), self:GetMonthString(), self:GetYear(), self:FormatTime())
end

function meta:FormatDateYear()
	return string.format('%s %.4i', self:FormatDate(), self:GetYear())
end

local function bridge(funcName, funcAs)
	meta[funcAs or funcName] = function(self, ...)
		return self.dayObject[funcName](self.dayObject, ...)
	end
end

bridge('FormatSunrise')
bridge('FormatSunset')
bridge('GetSunset')
bridge('GetSunrise')
bridge('GetDayStart')
bridge('GetDayEnd')
bridge('GetMonthString')
bridge('GetDayInMonth')
bridge('GetDayStartLighting')
bridge('GetDayEndLighting')
bridge('GetSunriseLighting')
bridge('GetSunsetLighting')
bridge('GetNightEnd')
bridge('GetNightEnd')
bridge('GetNightStart')
bridge('FormatSunriseLighting')
bridge('FormatSunsetLighting')
bridge('FormatNightEnd')
bridge('FormatNightStart')
bridge('Format', 'FormatDate')
