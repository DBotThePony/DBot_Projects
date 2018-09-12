
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


local math = math
local Lerp = Lerp
local DDayNight = DDayNight

local meta = DLib.FindMetaTable('WODate')

local TEMPERATURE_CACHE = {}

local function reset()
	TEMPERATURE_CACHE = {}
end

local function formula(day, hour)
	if hour == 0 then hour = -1 end -- special case :^)
	if day == 0 then day = 15.52 end -- special case :^)
	return ((day % 3) ^ 4 / hour - math.cos(day * 3) * 4 + math.abs(math.sin(hour * 2)) * 5 - hour + (hour % 15) * 4 + math.cos(hour / (math.max(day % hour, 0.5))) * 5 - 1.1 ^ hour) / 10
end

function meta:GetAverageTemperature()
	local day = self:GetDay()

	if not TEMPERATURE_CACHE[day] then
		local date = DDayNight.Date(day * DDayNight.timeTypes.day)
		local total = date:GetTemperature()

		for hour = 1, 23 do
			date:SetStamp(day * DDayNight.timeTypes.day + hour * DDayNight.timeTypes.hour)
			total = total + date:GetTemperature()
		end

		TEMPERATURE_CACHE[day] = total / 24
	end

	return TEMPERATURE_CACHE[day]
end

function meta:GetTemperature()
	local day = self:GetDay()
	local hour = self:GetHour()
	local hourPast = self:GetHour() - 1
	local dayPast = day

	local fraction = self:GetSecondInHour() / DDayNight.timeTypes.hour

	if hourPast < 0 then
		hourPast = 23
		dayPast = math.max(dayPast - 1, 0)
	end

	local mult
	local progression = self:GetDayProgression()

	if progression > 0.15 and progression < 0.85 then
		mult = 0
	elseif progression ~= 0 and progression ~= 1 then
		if progression < 0.3 then
			mult = (0.3 - progression) * 3.3
		elseif progression > 0.7 then
			mult = (progression - 0.85) * 3.3
		else
			mult = 0
		end
	else
		mult = 1
	end

	local rnd = DDayNight.random(0, 400, 'day_temperature_night', self:GetAbsoluteDay()) / 400 * mult

	local current = formula(day, hour)
	local past = formula(dayPast, hourPast)
	local lerp = Lerp(fraction, past, current)
	local usualTemperature = self:CalculateMonthsFraction(DDayNight.monthsAverageTemperature)

	return usualTemperature + lerp - math.abs(usualTemperature) * rnd
end

hook.Add('DDayNight_SeedChanges', 'DDayNight_ClearTemperature', reset)
