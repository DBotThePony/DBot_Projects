
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

local function bridge(funcName)
	WOverlord[funcName] = function(...)
		local targetFunction = WOverlord.DATE_OBJECT[funcName]
		return targetFunction(WOverlord.DATE_OBJECT, ...)
	end

	WOverlord['Accurate' .. funcName] = function(...)
		local targetFunction = WOverlord.DATE_OBJECT_ACCURATE[funcName]
		return targetFunction(WOverlord.DATE_OBJECT_ACCURATE, ...)
	end

	WOverlord[funcName .. 'Accurate'] = function(...)
		local targetFunction = WOverlord.DATE_OBJECT_ACCURATE[funcName]
		return targetFunction(WOverlord.DATE_OBJECT_ACCURATE, ...)
	end
end

bridge('GetAge')
bridge('GetYear')
bridge('GetMonth')
bridge('GetMonthTime')
bridge('GetAbsoluteMonth')
bridge('GetWeek')
bridge('GetLocalWeek')
bridge('GetDay')
bridge('GetLocalDay')
bridge('GetAbsoluteDay')
bridge('GetAbsoluteHour')
bridge('GetHour')
bridge('GetAbsoluteMinute')
bridge('GetMinute')
bridge('GetAbsoluteSecond')
bridge('GetSecond')
bridge('FormatCurrentHour')
bridge('FormatCurrentTime')
