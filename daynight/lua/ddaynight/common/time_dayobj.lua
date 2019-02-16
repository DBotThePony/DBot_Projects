
-- Copyright (C) 2017-2019 DBot

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


-- This object is supposted to be static

local DLib = DLib
local DDayNight = DDayNight
local math = math
local ipairs = ipairs
local pairs = pairs
local table = table
local Lerp = Lerp
local string = string

local meta = DLib.CreateLuaObject('WODay', false)

DDayNight.Day = meta.Create

function meta:Initialize(stamp)
	self:SetStamp(stamp)
end

function meta:SetStamp(stamp)
	self.stamp = stamp
	self.year = math.floor(stamp / DDayNight.timeTypes.year)
	self.yearStamp = stamp % DDayNight.timeTypes.year

	self.absoluteDay = math.floor(self.stamp / DDayNight.timeTypes.day)
	self.yearDay = math.floor(self.yearStamp / DDayNight.timeTypes.day)

	for i, seconds in pairs(DDayNight.monthsTimeInYearNumeric) do
		if seconds >= self.yearStamp then
			self.month = i
			break
		end
	end

	if not self.month then
		self.month = 11
	end

	if self.month == 0 then
		self.monthTime = self.yearStamp
	else
		self.monthTime = self.yearStamp - DDayNight.MonthLengthAbsolute(DDayNight.NormalizeMonth(self.month - 1)) - DDayNight.timeTypes.day
	end

	self.monthDay = math.floor(self.monthTime / DDayNight.timeTypes.day) + 1
	self.monthProgress = math.floor((self.monthDay / DDayNight.months[self.month]) * 10) / 10

	if self.monthProgress < 0.5 then
		local old = DDayNight.NormalizeMonth(self.month - 1)
		local new = self.month
		self.dayMultiplier = Lerp(self.monthProgress + 0.5, DDayNight.monthsDaytimeMultiplier[old], DDayNight.monthsDaytimeMultiplier[new])
		self.nightMultiplier = Lerp(self.monthProgress + 0.5, DDayNight.monthsNighttimeMultiplier[old], DDayNight.monthsNighttimeMultiplier[new])
	elseif self.monthProgress == 0.5 then
		self.dayMultiplier = DDayNight.monthsDaytimeMultiplier[self.month]
		self.nightMultiplier = DDayNight.monthsNighttimeMultiplier[self.month]
	else
		local new = DDayNight.NormalizeMonth(self.month + 1)
		local old = self.month
		self.dayMultiplier = Lerp(self.monthProgress - 0.5, DDayNight.monthsDaytimeMultiplier[old], DDayNight.monthsDaytimeMultiplier[new])
		self.nightMultiplier = Lerp(self.monthProgress - 0.5, DDayNight.monthsNighttimeMultiplier[old], DDayNight.monthsNighttimeMultiplier[new])
	end

	self.dayStart = math.floor(DDayNight.middayTime - DDayNight.dayDiffPre * self.dayMultiplier) + DDayNight.frandom(-480, 480, 'sunrise', self.absoluteDay)
	self.dayStartLighting = math.floor(DDayNight.middayTime - DDayNight.dayDiffPreLighting * self.dayMultiplier) + DDayNight.frandom(-480, 480, 'sunrise_lighting', self.absoluteDay)
	self.dayEnd = math.floor(DDayNight.dayDiffPost * self.dayMultiplier + DDayNight.middayTime) + DDayNight.frandom(-480, 480, 'sunset', self.absoluteDay)
	self.dayEndLighting = math.floor(DDayNight.dayDiffPostLighting * self.dayMultiplier + DDayNight.middayTime) + DDayNight.frandom(-480, 480, 'sunset_lighting', self.absoluteDay)
	self.dayLength = self.dayEnd - self.dayStart
	self.dayLengthLighting = self.dayEndLighting - self.dayStartLighting

	self.dayLightDiffPre = self.dayStart - self.dayStartLighting
	self.dayLightDiffPost = self.dayEndLighting - self.dayEnd
end

function meta:Random(min, max, addSeed)
	return DDayNight.frandom(min, max, 'dateDay', (addSeed or 0) + self.absoluteDay)
end

function meta:CalculateMonthsFraction(tableIn)
	if self.monthProgress < 0.5 then
		local old = DDayNight.NormalizeMonth(self.month - 1)
		local new = self.month
		return Lerp(self.monthProgress + 0.5, tableIn[old], tableIn[new])
	elseif self.monthProgress == 0.5 then
		return tableIn[self.month]
	else
		local new = DDayNight.NormalizeMonth(self.month + 1)
		local old = self.month
		return Lerp(self.monthProgress - 0.5, tableIn[old], tableIn[new])
	end
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

function meta:GetDayStartLighting()
	return self.dayStartLighting
end

function meta:GetDayEndLighting()
	return self.dayEndLighting
end

function meta:GetSunriseLighting()
	return self.dayStartLighting
end

function meta:GetSunsetLighting()
	return self.dayEndLighting
end

function meta:GetNightEnd()
	return self.dayStartLighting
end

function meta:GetNightStart()
	return self.dayEndLighting
end

function meta:GetDayInYear()
	return self.yearDay
end

function meta:GetAbsoluteDay()
	return self.absoluteDay
end

function meta:FormatSunrise()
	return DDayNight.FormatHours(self.dayStart)
end

function meta:FormatSunset()
	return DDayNight.FormatHours(self.dayEnd)
end

function meta:FormatSunriseLighting()
	return DDayNight.FormatHours(self.dayStartLighting)
end

function meta:FormatSunsetLighting()
	return DDayNight.FormatHours(self.dayEndLighting)
end

function meta:FormatNightEnd()
	return DDayNight.FormatHours(self.dayStartLighting)
end

function meta:FormatNightStart()
	return DDayNight.FormatHours(self.dayEndLighting)
end

function meta:GetMonthString()
	return DLib.i18n.localize('gui.daynight.months.' .. self.month + 1)
end

function meta:Format()
	return string.format('%.2i %s', self:GetDayInMonth(), self:GetMonthString())
end
