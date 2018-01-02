
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

local math = math
local Lerp = Lerp
local WOverlord = WOverlord

local meta = DLib.FindMetaTable('WODate')

local function formula(day, hour)
	if hour == 0 then hour = -1 end -- special case :^)
	if day == 0 then day = 15.52 end -- special case :^)
	return ((day % 3) ^ 4 / hour - math.cos(day * 3) * 4 + math.abs(math.sin(hour * 2)) * 5 - hour + (hour % 15) * 4 + math.cos(hour / (math.max(day % hour, 0.5))) * 5 - 1.1 ^ hour) / 10
end

function meta:GetTemperature()
	local day = self:GetDay()
	local hour = self:GetHour()
	local hourPast = self:GetHour() - 1
	local dayPast = day

	local fraction = self:GetSecondInHour() / WOverlord.timeTypes.hour

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

	local rnd = WOverlord.random(0, 400, 'day_temperature_night', self:GetAbsoluteDay()) / 400 * mult

	local current = formula(day, hour)
	local past = formula(dayPast, hourPast)
	local lerp = Lerp(fraction, past, current)
	local usualTemperature = self:CalculateMonthsFraction(WOverlord.monthsAverageTemperature)

	return usualTemperature + lerp - math.abs(usualTemperature) * rnd
end
