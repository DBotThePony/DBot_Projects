
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
local assert = assert
local type = type
local WOverlord = WOverlord
local SERVER = SERVER
local CurTime = CurTime
local ipairs = ipairs

local lastThink

local function Think()
	local curr = CurTime()
	lastThink = lastThink or curr
	local delta = curr - lastThink
	lastThink = curr
	if delta == 0 then return end

	for i, value in ipairs(WOverlord.WEATHER_STATUS_ARRAY) do
		if value:IsValid() then
			local weather = value:GetMeta()
			weather.Update(WOverlord.DATE_OBJECT, value, delta)

			if SERVER then
				weather.UpdateServer(WOverlord.DATE_OBJECT, value, delta)
			else
				weather.UpdateClient(WOverlord.DATE_OBJECT, value, delta)
			end
		else
			WOverlord.RemoveWeather(value)
			break
		end
	end
end

local function generate(updaterate)
	local lastThink

	return function()
		local curr = CurTime()
		lastThink = lastThink or curr
		local delta = curr - lastThink
		lastThink = curr
		if delta == 0 then return end

		for i, value in ipairs(WOverlord.WEATHER_STATUS_ARRAY) do
			-- do not remove if weather state is invalid, let think hook remove it
			if value:IsValid() then
				local weather = value:GetMeta()

				if weather.UPDATE_RATE == updaterate then
					weather.Think(WOverlord.DATE_OBJECT, value, delta)

					if SERVER then
						weather.ThinkServer(WOverlord.DATE_OBJECT, value, delta)
					else
						weather.ThinkClient(WOverlord.DATE_OBJECT, value, delta)
					end
				end
			end
		end
	end
end

local HOOK_ID = 'WeatherOverlord_ThinkWeather'

hook.Add('Think', 'WeatherOverlord_UpdateWeather', Think)
hook.Add('WOverlord_NewHour', HOOK_ID, generate(WOverlord.CHECK_FREQUENCY_HOUR))
hook.Add('WOverlord_NewSecond', HOOK_ID, generate(WOverlord.CHECK_FREQUENCY_SECOND))
hook.Add('WOverlord_NewDay', HOOK_ID, generate(WOverlord.CHECK_FREQUENCY_DAY))
hook.Add('WOverlord_NewHalfofday', HOOK_ID, generate(WOverlord.CHECK_FREQUENCY_HALF))
hook.Add('WOverlord_NewTwoHours', HOOK_ID, generate(WOverlord.CHECK_FREQUENCY_TWO_HOURS))
hook.Add('WOverlord_NewQuater', HOOK_ID, generate(WOverlord.CHECK_FREQUENCY_QUATER))
hook.Add('WOverlord_NewMinute', HOOK_ID, generate(WOverlord.CHECK_FREQUENCY_MINUTE))
hook.Add('WOverlord_RealTimeSecond', HOOK_ID, generate(WOverlord.CHECK_FREQUENCY_REALTIME))
