
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
local WOverlord = WOverlord
local hook = hook
local math = math
local string = string
local engine = engine
local net = net
local light_environment

net.pool('weatheroverlord.lightstyle')

local lastStyleOverall, lastStyleOutside

local function initializeEntity()
	local find = ents.FindByClass('light_environment')

	if #find > 1 then
		-- it is allowed on engine level, but... why?
		error('wtf? There is ' .. #find .. ' light_environment in total')
	elseif #find == 0 then
		-- maybe inside?
		return
	end

	light_environment = find[1]
	lastStyleOverall = nil
	lastStyleOutside = nil
end

if AreEntitiesAvaliable() then
	initializeEntity()
end

local STYLE_OVERALL = 0
local STYLE_OUTSIDE = 33

local defaultLighting = string.byte('m')
local MINIMAL = string.byte('a')
local MAXIMAL = string.byte('z')
local NORMAL = string.byte('m')
local DARKER = string.byte('h')
local DIFF_MIN_NORMAL = NORMAL - MINIMAL
local DIFF_DARKER_NORMAL = NORMAL - DARKER
local DIFF_NORMAL_MAX = MAXIMAL - NORMAL
local DIFF_NORMAL_DARKER = DARKER - NORMAL

local dirty = false

local function modifyAll(pattern)
	if lastStyleOverall == pattern then return end
	if not light_environment then return end
	lastStyleOverall = pattern
	dirty = true
	engine.LightStyle(STYLE_OVERALL, pattern)
end

local function modifyOutside(pattern)
	if lastStyleOutside == pattern then return end
	lastStyleOutside = pattern
	dirty = true

	if not light_environment then
		engine.LightStyle(STYLE_OVERALL, string.char(math.max(MINIMAL + 1, string.byte(pattern))))
	else
		light_environment:Fire('fadetopattern', pattern)
	end
end

local function WOverlord_NewMinute()
	local self = WOverlord.GetCurrentDateAccurate()
	local progression = self:GetDayProgression()
	local progressionLight = self:GetLightProgression()
	local fullNight = progressionLight == 0 or progressionLight == 1
	local semiNight = progression == 0 or progression == 1 and not fullNight
	local noNight = progression ~= 0 and progression ~= 1
	local nightProgression = self:GetNightMultiplier()
	local almostNightStart = progression > 0.9
	local isSunrise = self:IsBeforeMidday()
	local darken = math.Clamp(1 - (0.15 - progression) * 6.6, 0, 1)
	local darkenNight = math.Clamp((progression - 0.85) * 6.6, 0, 1)

	-- these nights are usually really dark, so let's try to make even indoor light darker
	local isDarkNight = self:GetDayLengthMultiplier() < 0.75

	if isSunrise then
		if fullNight then
			modifyOutside('a')

			if isDarkNight then
				modifyAll('h')
			end
		elseif semiNight then
			local mult = 0.5 - nightProgression * 0.5
			modifyOutside(string.char(MINIMAL + math.floor(DIFF_MIN_NORMAL * mult)))

			if isDarkNight then
				modifyAll(string.char(DARKER + math.floor(DIFF_DARKER_NORMAL * mult)))
			end
		elseif darken < 1 then
			local mult = darken * 0.5 + 0.5
			modifyOutside(string.char(MINIMAL + math.floor(DIFF_MIN_NORMAL * mult)))

			if isDarkNight then
				modifyAll(string.char(DARKER + math.floor(DIFF_DARKER_NORMAL * mult)))
			end
		else
			modifyOutside('m')
			modifyAll('m')
		end
	else
		if fullNight then
			modifyOutside('a')
		elseif darkenNight < 1 then
			local mult = darkenNight * 0.5
			modifyOutside(string.char(NORMAL - math.floor(DIFF_MIN_NORMAL * mult)))

			if isDarkNight then
				modifyAll(string.char(NORMAL - math.floor(DIFF_DARKER_NORMAL * mult)))
			end
		elseif semiNight then
			local mult = nightProgression * 0.5 + 0.5
			modifyOutside(string.char(NORMAL - math.floor(DIFF_MIN_NORMAL * mult)))

			if isDarkNight then
				modifyAll(string.char(NORMAL - math.floor(DIFF_DARKER_NORMAL * mult)))
			end
		else
			modifyOutside('m')
			modifyAll('m')
		end
	end

	if dirty then
		dirty = false
		net.Start('weatheroverlord.lightstyle')
		net.Broadcast()
	end
end

hook.Add('WOverlord_NewMinute', 'WeatherOverlord_LightstyleModifier', WOverlord_NewMinute)
hook.Add('InitPostEntity', 'WeatherOverlord_Lightstyle', initializeEntity)
hook.Add('PostCleanupMap', 'WeatherOverlord_Lightstyle', initializeEntity)
