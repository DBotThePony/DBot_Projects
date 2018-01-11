
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
local pairs = pairs

WOverlord.METADATA = WOverlord.METADATA or {}
WOverlord.METADATA_REG = WOverlord.METADATA_REG or {}

WOverlord.CHECK_FREQUENCY_HOUR = 0
WOverlord.CHECK_FREQUENCY_SECOND = 1
WOverlord.CHECK_FREQUENCY_REALTIME = 2
WOverlord.CHECK_FREQUENCY_TWO_HOURS = 3
WOverlord.CHECK_FREQUENCY_QUATER = 4
WOverlord.CHECK_FREQUENCY_HALF = 5
WOverlord.CHECK_FREQUENCY_DAY = 6
WOverlord.CHECK_FREQUENCY_MINUTE = 7

local function transformWord(wordIn)
	if wordIn:sub(#wordIn) == 'g' then
		return wordIn .. 'gy'
	end

	if wordIn:sub(#wordIn) == 'm' then
		return wordIn .. 'ing'
	end

	return wordIn .. 'y'
end

function WOverlord.RegisterWeather(id, name, checkFrequency)
	assert(type(id) == 'string', 'At least ID should be specified!')
	assert(id == id:lower(), 'ID Should be lowercased')
	checkFrequency = checkFrequency or WOverlord.CHECK_FREQUENCY_MINUTE

	if not name then
		name = id:formatname()
	end

	local hit = WOverlord.METADATA[id] == nil
	local weatherMeta = WOverlord.METADATA[id] or {}
	WOverlord.METADATA[id] = weatherMeta
	weatherMeta.ID = id

	if hit then
		table.insert(WOverlord.METADATA_REG, weatherMeta)
	end

	-- self argument is always current date

	if not weatherMeta.CanBeTriggeredNow then
		-- return true if weather should trigger
		function weatherMeta:CanBeTriggeredNow()
			return false
		end
	end

	if not weatherMeta.GetLength then
		-- in seconds
		function weatherMeta:GetLength()
			return 0
		end
	end

	weatherMeta.UPDATE_RATE = checkFrequency

	-- Think - each checkFrequency
	-- Update - each frame

	if not weatherMeta.Think then
		function weatherMeta:Think(iWeatherState, lastThinkDelta)
			return true
		end
	end

	if not weatherMeta.ThinkServer then
		function weatherMeta:ThinkServer(iWeatherState, lastThinkDelta)
			return true
		end
	end

	if not weatherMeta.ThinkClient then
		function weatherMeta:ThinkClient(iWeatherState, lastThinkDelta)
			return true
		end
	end

	if not weatherMeta.Update then
		function weatherMeta:Update(iWeatherState, lastThinkDelta)
			return true
		end
	end

	if not weatherMeta.UpdateServer then
		function weatherMeta:UpdateServer(iWeatherState, lastThinkDelta)
			return true
		end
	end

	if not weatherMeta.UpdateClient then
		function weatherMeta:UpdateClient(iWeatherState, lastThinkDelta)
			return true
		end
	end

	if not weatherMeta.DisplayName then
		local grab = transformWord(id)
		weatherMeta.DisplayName = function(self, iWeatherState)
			return grab
		end
	end

	if not weatherMeta.DisplayNamePriority then
		weatherMeta.DisplayNamePriority = function(self, iWeatherState)
			return 0
		end
	end

	return weatherMeta
end

function WOverlord.GetWeather(id)
	assert(type(id) == 'string', 'ID Should be string')
	assert(id == id:lower(), 'ID Should be lowercased')
	return WOverlord.METADATA[id]
end
