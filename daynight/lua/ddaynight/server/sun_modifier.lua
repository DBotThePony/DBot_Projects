
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


local DLib = DLib
local DDayNight = DDayNight
local hook = hook
local CurTimeL = CurTimeL
local math = math
local tostring = tostring
local Angle = Angle
local env_sun

local function initializeEntity()
	local sun = ents.FindByClass('env_sun')

	if #sun > 1 then
		error('wtf? There is ' .. #sun .. ' env_sun in total')
	elseif #sun == 0 then
		return
	end

	env_sun = sun[1]

	local self = DDayNight.GetCurrentDate()
	local progression = self:GetDayProgression()

	if progression ~= 0 and progression ~= 1 then
		env_sun:Fire('turnon')
	else
		env_sun:Fire('turnoff')
	end
end

if AreEntitiesAvaliable() then
	initializeEntity()
end

local meta = DLib.FindMetaTable('WODate')

function meta:GetSunAngles()
	local length = self.dayObject.dayMultiplier
	local progression = self:GetDayProgression()
	local finalAngle = Angle(-180 * progression, 0, 0)
	finalAngle:RotateAroundAxis(Vector(-1, 0, 0), (1 - length) * 90)
	return finalAngle
end

local function DDayNight_NewMinute()
	if not env_sun then return end

	local self = DDayNight.GetCurrentDate()
	local progression = self:GetDayProgression()

	env_sun:SetKeyValue('sun_dir', tostring(self:GetSunAngles():Forward()))
end

local function DDayNight_Sunrise()
	if not env_sun then return end

	env_sun:Fire('turnon')
end

local function DDayNight_Sunset()
	if not env_sun then return end

	env_sun:Fire('turnoff')
end

local function DDayNight_InitializeTimeStatement()
	if not env_sun then return end

	env_sun:Fire('turnon')
end

hook.Add('InitPostEntity', 'DDayNight_InitializeSun', initializeEntity)
hook.Add('PostCleanupMap', 'DDayNight_InitializeSun', initializeEntity)
hook.Add('DDayNight_NewMinute', 'DDayNight_Sun', DDayNight_NewMinute)
hook.Add('DDayNight_Sunrise', 'DDayNight_Sun', DDayNight_Sunrise)
hook.Add('DDayNight_Sunset', 'DDayNight_Sun', DDayNight_Sunset)
