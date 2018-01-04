
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

local meta = DLib.FindMetaTable('WODate')

local function bezier(lerp, one, two, three)
	local minus = 1 - lerp
	return minus * minus * one + 2 * lerp * minus * two + lerp * lerp * three
end

local function bezierVector(lerp, one, two, three)
	return Vector(bezier(lerp, one.x, two.x, three.x), bezier(lerp, one.y, two.y, three.y), 0)
end

local hourAmount = 4
local hourPiece = 24 / hourAmount

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

	local windSelfX = WOverlord.random(-18, 18, 'wind_direction_x', day * hourAmount + part)
	local windSelfY = WOverlord.random(-18, 18, 'wind_direction_y', day * hourAmount + part)

	local windPostX = WOverlord.random(-18, 18, 'wind_direction_x', dayPost * hourAmount + partPost)
	local windPostY = WOverlord.random(-18, 18, 'wind_direction_y', dayPost * hourAmount + partPost)

	if self:GetStamp() - hourAmount * WOverlord.timeTypes.hour >= 0 then
		local pre = WOverlord.Date(self:GetStamp() - hourAmount * WOverlord.timeTypes.hour)
		local dayPre = pre:GetAbsoluteDay()
		local hourPre = pre:GetHour()
		local partPre = math.floor(hourPre / 4)

		local windPreX = WOverlord.random(-18, 18, 'wind_direction_x', dayPre * hourAmount + partPre)
		local windPreY = WOverlord.random(-18, 18, 'wind_direction_y', dayPre * hourAmount + partPre)

		vec1 = Vector(windPreX, windPreY, 0)
	end

	local vec2 = Vector(windSelfX, windSelfY, 0)
	local vec3 = Vector(windPostX, windPostY, 0)

	return bezierVector(t, vec1, vec2, vec3)
end

hook.Add('WOverlord_SeedChanges', 'WeatherOverlord_ClearWind', reset)
