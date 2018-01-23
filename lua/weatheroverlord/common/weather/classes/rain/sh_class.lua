
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
local math = math
local WOverlord = WOverlord

local meta = WOverlord.RegisterWeather('rain', 'Rain', WOverlord.CHECK_FREQUENCY_MINUTE)

meta:AddFlag('storm', false)

function meta:CanBeTriggeredNow()
	local wind = self:GetWindDirection()
	local progression = self:GetDayProgression()
	local temperature = self:GetTemperature()

	local hotPoint1 = progression:progression(0.3, 0.6, 0.5)
	local hotPoint2 = progression:progression(0.8, 1, 0.95)
	local tempMult = temperature:progression(-30, 40, 30)
	local windMultiply1 = (wind:Length() / 53):progression(0, 9)
	local windMultiply2 = (wind:Length() / 53):progression(9, 12)

	local chance = 1 + hotPoint1 * 0.8 + hotPoint2 * 1.2 + tempMult * 3 + windMultiply1 - windMultiply2 * 2
	--chance = chance * 0.2
	--return WOverlord.random(1, 100, 'weather_rain', self:GetAbsoluteDay()) <= chance
	return true
end

function meta:GetLength()
	local wind = self:GetWindDirection()
	local progression = self:GetDayProgression()
	local temperature = self:GetTemperature()

	local hotPoint1 = progression:progression(0.3, 0.6, 0.5)
	local hotPoint2 = progression:progression(0.8, 1, 0.95)
	local tempMult = temperature:progression(-30, 40, 30)
	local windMultiply1 = (wind:Length() / 53):progression(0, 9)
	local windMultiply2 = (wind:Length() / 53):progression(9, 12)

	return 24000 + hotPoint1 * 4000 + hotPoint2 * 10000 + tempMult * 12000 + windMultiply1 * 5000 - windMultiply2 * 13000
end

function meta:Initialize(dryRun)
	if dryRun then return end
end
