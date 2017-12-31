
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

_G.WOverlord = _G.WOverlord or {}
local WOverlord = WOverlord
local DLib = DLib
local self = WOverlord
local ipairs = ipairs
local string = string
local math = math
local SharedRandom = util.SharedRandom

DLib.MessageMaker(self, 'WeatherOverlord')

self.SEED = DLib.util.CreateSharedConvar('sv_woverlord_seed', math.random(1, 100000), 'Seed of Weather Overlord. Two same seeds on different servers will produce same weather, rain, snow, wind strength, temperature on same time!')

function self.random(min, max, name, additional)
	additional = additional or 0
	name = name or 'random'
	return SharedRandom('WOverlord_' .. name, min, max, self.SEED:GetInt() + additional)
end

function self.frandom(...)
	return math.floor(self.random(...))
end

function self.Seed()
	return self.SEED:GetInt()
end

function self.GetSeed()
	return self.SEED:GetInt()
end

local function seedChanges(cvar, oldValue, newValue)
	if not tonumber(newValue) then
		local newSeed = 0

		for i, byte in ipairs({string.byte(newValue, 1, #newValue)}) do
			newSeed = newSeed + math.abs(math.floor((byte + 2) * 3 - math.pow(byte / 4, 3) + math.sqrt(byte)))
		end

		newSeed = newSeed % math.pow(2, 31)
		self.Message('String conversion to seed for ', newValue, ' is ', newSeed)
		self.SEED:SetInt(newSeed)
	end
end

cvars.AddChangeCallback('sv_woverlord_seed', seedChanges, 'WeatherOverlord')

local function sinclude(file)
	if SERVER then AddCSLuaFile(file) end
	return include(file)
end

sinclude('common/time.lua')
sinclude('common/time_funcs.lua')
sinclude('common/time_getters.lua')
sinclude('common/time_dayobj.lua')
sinclude('common/time_date.lua')

if SERVER then
	include('server/time.lua')
end
