
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
local ipairs = ipairs
local table = table

WOverlord.WEATHER_STATUS = WOverlord.WEATHER_STATUS or {}
WOverlord.WEATHER_STATUS_ARRAY = WOverlord.WEATHER_STATUS_ARRAY or {}

function WOverlord.GetWeatherStatus()
	return WOverlord.WEATHER_STATUS
end

function WOverlord.GetWeatherStatusArray()
	return WOverlord.WEATHER_STATUS_ARRAY
end

function WOverlord.WeatherIsRunning(id)
	assert(type(id) == 'string', 'ID must be a string')
	id = id:lower()
	return WOverlord.WEATHER_STATUS[id] ~= nil and WOverlord.WEATHER_STATUS[id]
end

function WOverlord.ClearInvalidWeather()
	local toremove = {}

	for i, value in ipairs(WOverlord.WEATHER_STATUS_ARRAY) do
		if not value:IsActive() then
			WOverlord.WEATHER_STATUS[value:GetID()] = nil
			table.remove(toremove, i)
		end
	end

	table.removeValues(WOverlord.WEATHER_STATUS_ARRAY, toremove)
end

-- This actually adds and starts weather specified with it
-- must be called both clientside and serverside
function WOverlord.AddWeather(iWeatherState)
	for i, value in ipairs(WOverlord.WEATHER_STATUS_ARRAY) do
		if value:GetID() == iWeatherState:GetID() then
			return false
		end
	end

	table.insert(WOverlord.WEATHER_STATUS_ARRAY, iWeatherState)
	WOverlord.WEATHER_STATUS[iWeatherState:GetID()] = iWeatherState
	return true
end

function WOverlord.IsWeatherActive(id)
	return WOverlord.WEATHER_STATUS[id] ~= nil
end

local function generate(updaterate)
	local date = WOverlord.DATE_OBJECT

	return function()
		for i, meta in ipairs(WOverlord.METADATA_REG) do
			local id = meta.ID

			if not WOverlord.IsWeatherActive(id) and meta.UPDATE_RATE == updaterate then
				local trigger = meta.CanBeTriggeredNow(date)

				if trigger then
					local length = assert(meta.GetLength(date) > 0, 'Weather::GetLength(date) <= 0!!! ' .. id .. ' has invalid implentation of length calculation')
					local state = WOverlord.IWeatherState(id, length, date:GetStamp())
					WOverlord.AddWeather(state)
				end
			end
		end
	end
end

local HOOK_ID = 'WeatherOverlord_StartWeather'

hook.Add('WOverlord_NewHour', HOOK_ID, generate(WOverlord.CHECK_FREQUENCY_HOUR))
hook.Add('WOverlord_NewSecond', HOOK_ID, generate(WOverlord.CHECK_FREQUENCY_SECOND))
hook.Add('WOverlord_NewDay', HOOK_ID, generate(WOverlord.CHECK_FREQUENCY_DAY))
hook.Add('WOverlord_NewHalfofday', HOOK_ID, generate(WOverlord.CHECK_FREQUENCY_HALF))
hook.Add('WOverlord_NewTwoHours', HOOK_ID, generate(WOverlord.CHECK_FREQUENCY_TWO_HOURS))
hook.Add('WOverlord_NewQuater', HOOK_ID, generate(WOverlord.CHECK_FREQUENCY_QUATER))
hook.Add('WOverlord_NewMinute', HOOK_ID, generate(WOverlord.CHECK_FREQUENCY_MINUTE))
hook.Add('WOverlord_RealTimeSecond', HOOK_ID, generate(WOverlord.CHECK_FREQUENCY_REALTIME))
