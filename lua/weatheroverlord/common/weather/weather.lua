
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
local hook = hook

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

local standartMeta = {}

function standartMeta:AddFlag(flagName, default)
	if type(default) ~= 'function' then
		local d = default
		default = function() return d end
	end

	self.flags[flagName] = default
end

function standartMeta:RemoveFlag(flagName)
	if not self.flags[flagName] then return false end
	local value = self.flags[flagName]
	self.flags[flagName] = nil
	return value
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

	weatherMeta.flags = weatherMeta.flags or {}

	if hit then
		table.insert(WOverlord.METADATA_REG, weatherMeta)
	end

	for k, v in pairs(standartMeta) do
		weatherMeta[k] = v
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

	if not weatherMeta.Initialize then
		-- self -> IWeatherState
		function weatherMeta:Initialize(dryRun)

		end
	end

	weatherMeta.UPDATE_RATE = checkFrequency

	-- Update - each checkFrequency
	-- Think - each frame

	if not weatherMeta.Think then
		local hookID = 'WeatherThink' .. id:formatname()
		weatherMeta.ThinkHookID = hookID

		function weatherMeta:Think(date, lastThinkDelta)
			hook.Run(hookID, self, date, lastThinkDelta)
			return true
		end
	end

	if not weatherMeta.ThinkServer then
		local hookID = 'WeatherThinkServer' .. id:formatname()
		weatherMeta.ThinkServerHookID = hookID

		function weatherMeta:ThinkServer(date, lastThinkDelta)
			hook.Run(hookID, self, date, lastThinkDelta)
			return true
		end
	end

	if not weatherMeta.ThinkClient then
		local hookID = 'WeatherThinkClient' .. id:formatname()
		weatherMeta.ThinkClientHookID = hookID

		function weatherMeta:ThinkClient(date, lastThinkDelta)
			hook.Run(hookID, self, date, lastThinkDelta)
			return true
		end
	end

	if not weatherMeta.Update then
		local hookID = 'WeatherUpdate' .. id:formatname()
		weatherMeta.UpdateHookID = hookID

		function weatherMeta:Update(date, lastThinkDelta)
			hook.Run(hookID, self, date, lastThinkDelta)
			return true
		end
	end

	if not weatherMeta.UpdateServer then
		local hookID = 'WeatherUpdateServer' .. id:formatname()
		weatherMeta.UpdateServerHookID = hookID

		function weatherMeta:UpdateServer(date, lastThinkDelta)
			hook.Run(hookID, self, date, lastThinkDelta)
			return true
		end
	end

	if not weatherMeta.UpdateClient then
		local hookID = 'WeatherUpdateClient' .. id:formatname()
		weatherMeta.UpdateClientHookID = hookID

		function weatherMeta:UpdateClient(date, lastThinkDelta)
			hook.Run(hookID, self, date, lastThinkDelta)
			return true
		end
	end

	if not weatherMeta.DisplayName then
		local grab = transformWord(id)
		weatherMeta.DisplayName = function(self, date)
			return grab
		end
	end

	if not weatherMeta.DisplayNamePriority then
		weatherMeta.DisplayNamePriority = function(self, date)
			return 0
		end
	end

	if not weatherMeta.Stop then
		-- Stop(self -> IWeatherState)
		function weatherMeta:Stop()
			return true
		end
	end

	return weatherMeta
end

function WOverlord.GetWeather(id)
	assert(type(id) == 'string', 'ID Should be string')
	assert(id == id:lower(), 'ID Should be lowercased')
	return WOverlord.METADATA[id]
end

WOverlord.GetWeatherMeta = WOverlord.GetWeather
WOverlord.FindWeatherMeta = WOverlord.GetWeather

local include = include
local SERVER = SERVER
local AddCSLuaFile = AddCSLuaFile
local ipairs = ipairs

function WOverlord.LoadWeatherFiles()
	local _, folders = file.Find('weatheroverlord/common/weather/classes/*', 'LUA')

	for i, folder in ipairs(folders) do
		local files = file.Find('weatheroverlord/common/weather/classes/' .. folder .. '/*.lua', 'LUA')
		local sh, cl, sv = DLib.Loader.filter(files)

		-- local class = file:sub(1, #file - 4)
		-- local classFile = WOverlord.RegisterWeather(class, name, checkFrequency)

		for i, file in ipairs(sh) do
			include('weatheroverlord/common/weather/classes/' .. folder .. '/' .. file)
			if SERVER then AddCSLuaFile('weatheroverlord/common/weather/classes/' .. folder .. '/' .. file) end
		end

		if SERVER then
			for i, file in ipairs(sv) do
				include('weatheroverlord/common/weather/classes/' .. folder .. '/' .. file)
			end
		end

		if SERVER then
			for i, file in ipairs(cl) do
				AddCSLuaFile('weatheroverlord/common/weather/classes/' .. folder .. '/' .. file)
			end
		else
			for i, file in ipairs(cl) do
				include('weatheroverlord/common/weather/classes/' .. folder .. '/' .. file)
			end
		end
	end
end
