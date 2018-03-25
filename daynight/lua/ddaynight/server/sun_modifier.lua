
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
local DDayNight = DDayNight
local hook = hook
local CurTime = CurTime
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
hook.Add('DDayNight_InitializeTimeStatement', 'DDayNight_Sun', WOverlDDayNight_InitializeTimeStatementord_Sunset)
