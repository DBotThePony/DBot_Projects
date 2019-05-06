
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
