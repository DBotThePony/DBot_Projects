
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

local meta = DLib.CreateLuaObject('WODay', false)

WOverlord.Day = meta.Create

function meta:Initialize(stamp)
	self:SetStamp(stamp)
end

function meta:SetStamp(stamp)
	self.stamp = stamp
	self.year = math.floor(stamp / WOverlord.timeTypes.year)
	self.yearStamp = stamp % WOverlord.timeTypes.year

	self.absoluteDay = math.floor(self.stamp / WOverlord.timeTypes.day)
	self.yearDay = math.floor(self.yearStamp / WOverlord.timeTypes.day)

	for i, seconds in pairs(WOverlord.monthsTimeInYearNumeric) do
		if seconds >= self.yearStamp then
			self.month = i
			break
		end
	end

	if self.month == 0 then
		self.monthTime = self.yearStamp
	else
		self.monthTime = self.yearStamp - WOverlord.MonthLengthAbsolute(WOverlord.NormalizeMonth(self.month - 1))
	end

	self.monthDay = math.floor(self.monthTime / WOverlord.timeTypes.day)
	self.monthProgress = math.floor((self.monthDay / WOverlord.months[self.month]) * 10) / 10

	if self.monthProgress < 0.5 then
		local old = WOverlord.NormalizeMonth(self.month - 1)
		local new = self.month
		self.dayMultiplier = Lerp(self.monthProgress + 0.5, WOverlord.monthsDaytimeMultiplier[old], WOverlord.monthsDaytimeMultiplier[new])
		self.nightMultiplier = Lerp(self.monthProgress + 0.5, WOverlord.monthsNighttimeMultiplier[old], WOverlord.monthsNighttimeMultiplier[new])
	elseif self.monthProgress == 0.5 then
		self.dayMultiplier = WOverlord.monthsDaytimeMultiplier[self.month]
		self.nightMultiplier = WOverlord.monthsNighttimeMultiplier[self.month]
	else
		local new = WOverlord.NormalizeMonth(self.month + 1)
		local old = self.month
		self.dayMultiplier = Lerp(self.monthProgress - 0.5, WOverlord.monthsDaytimeMultiplier[old], WOverlord.monthsDaytimeMultiplier[new])
		self.nightMultiplier = Lerp(self.monthProgress - 0.5, WOverlord.monthsNighttimeMultiplier[old], WOverlord.monthsNighttimeMultiplier[new])
	end

	self.dayStart = math.floor(WOverlord.middayTime - WOverlord.dayDiffPre * self.dayMultiplier)
	self.dayEnd = math.floor(WOverlord.dayDiffPost * self.dayMultiplier + WOverlord.middayTime)
	self.dayLength = self.dayEnd - self.dayStart
end

function meta:GetYear()
	return self.year
end

function meta:GetMonth()
	return self.month
end

function meta:GetDayInMonth()
	return self.monthDay
end

function meta:GetDayLengthMultiplier()
	return self.dayMultiplier
end

function meta:GetDayLength()
	return self.dayLength
end

function meta:GetDayStart()
	return self.dayStart
end

function meta:GetDayEnd()
	return self.dayEnd
end

function meta:GetSunrise()
	return self.dayStart
end

function meta:GetSunset()
	return self.dayEnd
end

function meta:GetDayInYear()
	return self.yearDay
end

function meta:GetAbsoluteDay()
	return self.absoluteDay
end

function meta:FormatSunrise()
	return WOverlord.FormatHours(self.dayStart)
end

function meta:FormatSunset()
	return WOverlord.FormatHours(self.dayEnd)
end

function meta:GetMonthString()
	return WOverlord.monthNames[self.month]
end

function meta:Format()
	return string.format('%.2i %s', self:GetDayInMonth(), self:GetMonthString())
end
