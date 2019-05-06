
-- Copyright (C) 2017-2019 DBotThePony

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.


_G.DDayNight = _G.DDayNight or {}
local DDayNight = DDayNight
local DLib = DLib
local self = DDayNight
local ipairs = ipairs
local string = string
local math = math
local hook = hook
local SharedRandom = util.SharedRandom

DLib.CMessageChat(self, 'DDayNight')

self.SEED = DLib.util.CreateSharedConvar('sv_daynight_seed', math.random(1, 100000), 'Seed of Weather Overlord. Two same seeds on different servers will produce same weather, rain, snow, wind strength, temperature on same time!')

self.TIME_FAST_FORWARD_SEQ = false
self.TIME_FAST_FORWARD = false
self.TIME_FAST_FORWARD_SPEED = 0
self.TIME_FAST_FORWARD_START = 0
self.TIME_FAST_FORWARD_END = 0
self.TIME_FAST_FORWARD_LAST = 0

local CurTime = CurTimeL

function self.CalcFastForward()
	if not self.TIME_FAST_FORWARD then return 0 end
	local delta = CurTime():min(self.TIME_FAST_FORWARD_END) - self.TIME_FAST_FORWARD_LAST
	self.TIME_FAST_FORWARD_LAST = CurTime()

	if CurTime() >= self.TIME_FAST_FORWARD_END then
		self.TIME_FAST_FORWARD = false
		hook.Run('DDayNight_FastForwardEnd')
	end

	return delta * self.TIME_FAST_FORWARD_SPEED
end

if SERVER or not self.SEED_VALID then
	self.SEED_VALID = self.SEED:GetInt()
end

function self.random(min, max, name, additional)
	additional = additional or 0
	name = name or 'random'
	return SharedRandom('DDayNight_' .. name, min, max, self.SEED_VALID + additional)
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
		hook.Run('DDayNight_SeedChanges', oldValue, newSeed)

		self.SEED_VALID = newSeed
		return
	end

	self.SEED_VALID = self.SEED:GetInt()
	hook.Run('DDayNight_SeedChanges', oldValue, newValue)
end

cvars.AddChangeCallback('sv_daynight_seed', seedChanges, 'DDayNightCycle')

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

CAMI.RegisterPrivilege({
	Name = 'ddaynight_setseed',
	Description = 'Set seed of DDayNight',
	MinAccess = 'superadmin',
})

CAMI.RegisterPrivilege({
	Name = 'ddaynight_fastforward',
	Description = 'Fast-forward random amount of time',
	MinAccess = 'superadmin',
})

CAMI.RegisterPrivilege({
	Name = 'ddaynight_fastforward12h',
	Description = 'Fast-forward 12 hours',
	MinAccess = 'superadmin',
})

CAMI.RegisterPrivilege({
	Name = 'ddaynight_fastforward1',
	Description = 'Fast-forward 1 day',
	MinAccess = 'superadmin',
})

CAMI.RegisterPrivilege({
	Name = 'ddaynight_fastforward7',
	Description = 'Fast-forward 7 days',
	MinAccess = 'superadmin',
})

CAMI.RegisterPrivilege({
	Name = 'ddaynight_fastforward30',
	Description = 'Fast-forward 30 days',
	MinAccess = 'superadmin',
})

CAMI.RegisterPrivilege({
	Name = 'ddaynight_fastforward90',
	Description = 'Fast-forward 90 days',
	MinAccess = 'superadmin',
})

CAMI.RegisterPrivilege({
	Name = 'ddaynight_fastforward180',
	Description = 'Fast-forward 180 days',
	MinAccess = 'superadmin',
})

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
svinclude('server/commands.lua')
clinclude('client/lightstyle.lua')

sinclude('common/temperature.lua')
sinclude('common/temperature_date.lua')
sinclude('common/wind.lua')

clinclude('client/fog.lua')
clinclude('client/hud.lua')
clinclude('client/menu.lua')

hook.Run('DDayNight_SeedChanges', self.SEED_VALID, self.SEED_VALID)
