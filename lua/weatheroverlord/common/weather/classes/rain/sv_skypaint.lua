
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
local WOverlord = WOverlord
local meta = WOverlord.GetWeatherMeta('rain')

function meta:StarSpeed(speedIn, date)
	if self:GetFlag('storm') then
		return speedIn * 4
	end

	return speedIn * 2
end

function meta:StarFade(valueIn, date)
	local fadeMult = 4 - date:GetNightMultiplier():progression(0, 1, 0.5) * 3

	if self:GetFlag('storm') then
		return 0.1 * fadeMult
	end

	return 0.05 * fadeMult
end

function meta:SunSize(valueIn, date)
	if self:GetFlag('storm') then
		return 0
	end

	return math.min(0.4, valueIn * 0.6)
end

function meta:DuskIntensity(valueIn, date)
	if self:GetFlag('storm') then
		return 0
	end

	return math.min(0.6, valueIn * 0.5)
end

function meta:DuskScale(valueIn, date)
	if self:GetFlag('storm') then
		return 0
	end

	return math.min(1, valueIn * 0.5)
end

function meta:FadeBias(valueIn, date)
	if self:GetFlag('storm') then
		return 0
	end

	return math.min(2, valueIn * 0.5)
end

function meta:TopColor(valueIn, date)
	if self:GetFlag('storm') then
		return valueIn * 0.25
	end

	return valueIn * 0.4
end

function meta:BottomColor(valueIn, date)
	if self:GetFlag('storm') then
		return valueIn * 0.35
	end

	return valueIn * 0.6
end

function meta:StarScale(valueIn, date)
	if self:GetFlag('storm') then
		return valueIn * 0.4
	end

	return valueIn * 0.79
end

function meta:StarTexture(textureIn, date)
	return 'skybox/clouds'
end
