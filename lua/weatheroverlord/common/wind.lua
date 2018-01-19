
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
local math = math
local Vector = Vector
local pairs = pairs
local ipairs = ipairs

WOverlord.beaufort = {
	stille = 		{0, 0.3},
	sillent = 		{1, 1.5},
	light = 		{2, 3.3},
	weak = 			{3, 5.4},
	moderate = 		{4, 7.9},
	fresh = 		{5, 10.7},
	strong = 		{6, 13.8},
	robust = 		{7, 17.1},
	very_robust = 	{8, 20.7},
	storm = 		{9, 24.4},
	strong_storm = 	{10, 28.4},
	violent_storm = {11, 32.6},
	hurricane = 	{12, 999},
}

WOverlord.beaufortLocalized = {}
WOverlord.beaufortNumered = {}

for id, data in pairs(WOverlord.beaufort) do
	WOverlord.beaufortLocalized[data[1]] = id
	data[3] = id
	data[4] = id:sub(1, 1):upper() .. id:sub(2)
	WOverlord.beaufortNumered[data[1] + 1] = data
end

local meta = DLib.FindMetaTable('WODate')

local function bezier(lerp, one, two, three)
	local minus = 1 - lerp
	return minus * minus * one + 2 * lerp * minus * two + lerp * lerp * three
end

local function bezierVector(lerp, one, two, three)
	return Vector(bezier(lerp, one.x, two.x, three.x), bezier(lerp, one.y, two.y, three.y), 0)
end

local CACHE = {}

local function reset()
	CACHE = {}
end

local hourAmount = 4
local hourPiece = 24 / hourAmount

local upsaleChance = 75

local function upscale(str, seed)
	local currentChance = upsaleChance
	local currentStep = 0
	local concat = 'wind_direction_upscale_' .. str

	for i = 1, 100 do
		if WOverlord.random(0, 100, concat, seed % 600 - 15 * i + seed / 100) <= currentChance then
			currentChance = currentChance * 0.75
			currentStep = currentStep + math.pow(3, i)
		else
			break
		end
	end

	return currentStep
end

local function calculate(self)
	local day = self:GetAbsoluteDay()
	CACHE[day] = {}
	CACHE[day].perHour = {}

	local average = Vector(0, 0, 0)

	for hour = 1, 23 do
		local date = WOverlord.Date(day * WOverlord.timeTypes.day + hour * WOverlord.timeTypes.hour)
		local wind = date:GetWindDirection()
		average = average + wind
		CACHE[day].perHour[hour] = wind
	end

	CACHE[day].average = average / 24
end

function meta:GetWindTable()
	local day = self:GetAbsoluteDay()

	if CACHE[day] then
		return CACHE[day].perHour
	end

	calculate(self)

	return CACHE[day].perHour
end

function meta:GetAverageWindDirection()
	local day = self:GetAbsoluteDay()

	if CACHE[day] then
		return CACHE[day].average
	end

	calculate(self)

	return CACHE[day].average
end

function meta:GetWindDirection()
	local day = self:GetAbsoluteDay()
	local hour = self:GetHour()
	local part = math.floor(hour / hourPiece)
	local part2 = WOverlord.timeTypes.hour * hourAmount
	local t = (self:GetSecondInDay() % part2) / part2

	local vec1 = Vector(0, 0, 0)

	local post = WOverlord.Date(self:GetStamp() + hourAmount * WOverlord.timeTypes.hour)

	local dayPost = post:GetAbsoluteDay()
	local hourPost = post:GetHour()
	local partPost = math.floor(hourPost / 4)
	local seed = day * hourAmount + part

	local windSelfX = WOverlord.random(-upscale('x_minus', seed), upscale('x_plus', seed), 'wind_direction_x', seed)
	local windSelfY = WOverlord.random(-upscale('y_minus', seed), upscale('y_plus', seed), 'wind_direction_y', seed)

	seed = dayPost * hourAmount + partPost
	local windPostX = WOverlord.random(-upscale('x_minus', seed), upscale('x_plus', seed), 'wind_direction_x', seed)
	local windPostY = WOverlord.random(-upscale('y_minus', seed), upscale('y_plus', seed), 'wind_direction_y', seed)

	if self:GetStamp() - hourAmount * WOverlord.timeTypes.hour >= 0 then
		local pre = WOverlord.Date(self:GetStamp() - hourAmount * WOverlord.timeTypes.hour)
		local dayPre = pre:GetAbsoluteDay()
		local hourPre = pre:GetHour()
		local partPre = math.floor(hourPre / 4)

		seed = dayPre * hourAmount + partPre
		local windPreX = WOverlord.random(-upscale('x_minus', seed), upscale('x_plus', seed), 'wind_direction_x', seed)
		local windPreY = WOverlord.random(-upscale('y_minus', seed), upscale('y_plus', seed), 'wind_direction_y', seed)

		vec1 = Vector(windPreX, windPreY, 0)
	end

	local vec2 = Vector(windSelfX, windSelfY, 0)
	local vec3 = Vector(windPostX, windPostY, 0)

	return bezierVector(t, vec1, vec2, vec3)
end

function meta:GetWindSpeed()
	return self:GetWindDirection():Length()
end

function meta:GetWindSpeedSI()
	return DLib.MeasurmentNoCache(self:GetWindSpeed())
end

function meta:GetBeaufortScore()
	local metresPerSecond = self:GetWindSpeedSI():GetMetres()

	for i, data in ipairs(WOverlord.beaufortNumered) do
		if data[2] >= metresPerSecond then
			return data[1]
		end
	end
end

function meta:GetBeaufortName()
	return WOverlord.beaufortNumered[self:GetBeaufortScore() + 1][4]
end

function meta:GetBeaufortID()
	return WOverlord.beaufortNumered[self:GetBeaufortScore() + 1][3]
end

hook.Add('WOverlord_SeedChanges', 'WeatherOverlord_ClearWind', reset)
