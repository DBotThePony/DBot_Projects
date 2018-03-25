
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

if SERVER or not self.SEED_VALID then
	self.SEED_VALID = self.SEED:GetInt()
end

function self.random(min, max, name, additional)
	additional = additional or 0
	name = name or 'random'
	return SharedRandom('WOverlord_' .. name, min, max, self.SEED_VALID + additional)
end

function self.frandom(...)
	return math.floor(self.random(...))
end

function self.Seed()
	return self.SEED_VALID
end

function self.GetSeed()
	return self.SEED_VALID
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
		hook.Run('WOverlord_SeedChanges', oldValue, newSeed)

		self.SEED_VALID = newSeed
		return
	end

	self.SEED_VALID = self.SEED:GetInt()
	hook.Run('WOverlord_SeedChanges', oldValue, newValue)
end

cvars.AddChangeCallback('sv_woverlord_seed', seedChanges, 'WeatherOverlord')

self.indexedMonths = {
	[0] = 'january',
	[1] = 'feburary',
	[2] = 'march',
	[3] = 'april',
	[4] = 'may',
	[5] = 'june',
	[6] = 'july',
	[7] = 'august',
	[8] = 'september',
	[9] = 'october',
	[10] = 'november',
	[11] = 'december',
}

local function sinclude(file)
	if SERVER then AddCSLuaFile(file) end
	return include(file)
end

local function svinclude(file)
	if CLIENT then return end
	return include(file)
end

local function clinclude(file)
	if SERVER then return AddCSLuaFile(file) end
	return include(file)
end

sinclude('common/functions.lua')
sinclude('common/time.lua')
sinclude('common/time_funcs.lua')
sinclude('common/time_getters.lua')
sinclude('common/time_dayobj.lua')
sinclude('common/time_date.lua')

svinclude('server/time.lua')
clinclude('client/time.lua')

svinclude('server/sun_modifier.lua')
svinclude('server/skypaint.lua')
svinclude('server/lightstyle.lua')
clinclude('client/lightstyle.lua')

sinclude('common/temperature.lua')
sinclude('common/temperature_date.lua')
sinclude('common/wind.lua')

clinclude('client/hud.lua')

WOverlord.LoadWeatherFiles()

hook.Run('WOverlord_SeedChanges', self.SEED_VALID, self.SEED_VALID)
