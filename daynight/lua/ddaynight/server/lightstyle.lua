
-- Copyright (C) 2017-2018 DBot

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


local DLib = DLib
local DDayNight = DDayNight
local hook = hook
local math = math
local string = string
local type = type
local engine = engine
local net = net
local light_environment

net.pool('ddaynight.lightstyle')

local lastStyleOverall, lastStyleOutside

local function initializeEntity()
	local find = ents.FindByClass('light_environment')

	if #find > 1 then
		-- it is allowed on engine level, but... why?
		error('wtf? There are ' .. #find .. ' light_environment in total')
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

local MINIMAL = string.byte('a')
local MAXIMAL = string.byte('z')
local NORMAL = string.byte('m')
local DARKER = NORMAL - 5
local LIGHTEN = NORMAL + 5
local VERY_LIGHTEN = NORMAL + 10

local DIFF_MIN_NORMAL = NORMAL - MINIMAL
local DIFF_DARKER_NORMAL = NORMAL - DARKER
local DIFF_NORMAL_MAX = MAXIMAL - NORMAL
local DIFF_NORMAL_DARKER = DARKER - NORMAL

local dirty = false

local function modifyAll(pattern)
	if type(pattern) == 'number' then pattern = string.char(pattern) end
	if lastStyleOverall == pattern then return end
	if not light_environment then return end
	lastStyleOverall = pattern
	dirty = true
	engine.LightStyle(STYLE_OVERALL, pattern)
end

local function modifyOutside(pattern)
	if type(pattern) == 'number' then pattern = string.char(pattern) end
	if lastStyleOutside == pattern then return end
	lastStyleOutside = pattern
	dirty = true

	if not light_environment then
		engine.LightStyle(STYLE_OVERALL, string.char(math.max(MINIMAL + 1, string.byte(pattern))))
	else
		light_environment:Fire('fadetopattern', pattern)
	end
end

local function DDayNight_NewMinute()
	local self = DDayNight.GetCurrentDateAccurate()
	local progression = self:GetDayProgression()
	local progressionLight = self:GetLightProgression()
	local fullNight = progressionLight == 0 or progressionLight == 1
	local semiNight = progression == 0 or progression == 1 and not fullNight
	local noNight = progression ~= 0 and progression ~= 1
	local nightProgression = self:GetNightMultiplier()
	local almostNightStart = progression > 0.9
	local sunny = progression > 0.2 and progression < 0.8
	local verysunny = progression > 0.35 and progression < 0.65
	local isSunrise = self:IsBeforeMidday()
	local darken = math.Clamp(1 - (0.15 - progression) * 6.6, 0, 1)
	local darkenNight = math.Clamp((progression - 0.85) * 6.6, 0, 1)

	-- these nights are usually really dark, so let's try to make even indoor light darker
	local isDarkNight = self:GetDayLengthMultiplier() < 0.7
	local isBrightDay = self:GetDayLengthMultiplier() > 0.8 and sunny
	local isVeryBrightDay = self:GetDayLengthMultiplier() > 0.85 and verysunny

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
		elseif isVeryBrightDay then
			modifyOutside(VERY_LIGHTEN)
			modifyAll(VERY_LIGHTEN)
		elseif isBrightDay then
			modifyOutside(LIGHTEN)
			modifyAll(LIGHTEN)
		else
			modifyOutside('m')
			modifyAll('m')
		end
	else
		if fullNight then
			modifyOutside('a')
		elseif semiNight then
			local mult = nightProgression * 0.5 + 0.5
			modifyOutside(string.char(NORMAL - math.floor(DIFF_MIN_NORMAL * mult)))

			if isDarkNight then
				modifyAll(string.char(NORMAL - math.floor(DIFF_DARKER_NORMAL * mult)))
			end
		elseif darkenNight < 1 then
			local mult = darkenNight * 0.5
			modifyOutside(string.char(NORMAL - math.floor(DIFF_MIN_NORMAL * mult)))

			if isDarkNight then
				modifyAll(string.char(NORMAL - math.floor(DIFF_DARKER_NORMAL * mult)))
			end
		elseif isVeryBrightDay then
			modifyOutside(VERY_LIGHTEN)
			modifyAll(VERY_LIGHTEN)
		elseif isBrightDay then
			modifyOutside(LIGHTEN)
			modifyAll(LIGHTEN)
		else
			modifyOutside('m')
			modifyAll('m')
		end
	end

	if dirty then
		dirty = false

		timer.Create('ddaynight.lightstyle', 0.5, 1, function()
			net.Start('ddaynight.lightstyle')
			net.Broadcast()
		end)
	end
end

hook.Add('DDayNight_NewMinute', 'DDayNight_LightstyleModifier', DDayNight_NewMinute)
hook.Add('InitPostEntity', 'DDayNight_Lightstyle', initializeEntity)
hook.Add('PostCleanupMap', 'DDayNight_Lightstyle', initializeEntity)
