
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

local math = math
local Lerp = Lerp
local WOverlord = WOverlord

local meta = DLib.FindMetaTable('WODate')

local HUMADITY_AVERAGE_CACHE = {}

local function reset()
	HUMADITY_AVERAGE_CACHE = {}
end

function meta:GetAverageHumadity()
	local day = self:GetDay()

	if not HUMADITY_AVERAGE_CACHE[day] then
		local date = WOverlord.Date(day * WOverlord.timeTypes.day)
		local total = date:GetHumadity()

		for hour = 1, 23 do
			date:SetStamp(day * WOverlord.timeTypes.day + hour * WOverlord.timeTypes.hour)
			total = total + date:GetHumadity()
		end

		HUMADITY_AVERAGE_CACHE[day] = total / 24
	end

	return HUMADITY_AVERAGE_CACHE[day]
end

function meta:GetHumadity()
	local day = self:GetDay()

end

hook.Add('WOverlord_SeedChanges', 'WeatherOverlord_ClearHumadity', reset)
