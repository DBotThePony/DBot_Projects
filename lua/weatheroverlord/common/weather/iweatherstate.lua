
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
local assert = assert
local type = type
local WOverlord = WOverlord

local meta = DLib.CreateLuaObject('WOIWeatherState', false)

WOverlord.IWeatherState = meta
WOverlord.IWeatherStateCreate = meta.Create

function meta:Initialize(id, length, startFrom, dryRun)
	self.id = id
	self.length = length
	self.dateStart = WOverlord.Date(startFrom)
	self.dateEnd = WOverlord.Date(startFrom + length)
	self.meta = WOverlord.METADATA[id]

	self.meta.Initialize(self, dryRun)
end

function meta:GetLength()
	return self.length
end

function meta:GetID()
	return self.id
end

function meta:GetMeta()
	return self.meta
end

function meta:GetWeatherStatus(date)
	date = date or WOverlord.GetCurrentDate()
	return self.meta.DisplayName(date, self)
end

function meta:GetWeatherStatusPriority(date)
	date = date or WOverlord.GetCurrentDate()
	return self.meta.DisplayNamePriority(date, self)
end

function meta:GetFraction(date)
	date = date or WOverlord.GetCurrentDate()
	return math.min((date:GetStamp() - self.dateStart:GetStamp()) / self.length, 1)
end

function meta:HasEnded(date)
	date = date or WOverlord.GetCurrentDate()
	return self.dateEnd:GetStamp() > date:GetStamp()
end

function meta:HasStarted(date)
	date = date or WOverlord.GetCurrentDate()
	return self.dateStart:GetStamp() <= date:GetStamp()
end

function meta:IsActive(date)
	date = date or WOverlord.GetCurrentDate()
	return self.dateEnd:GetStamp() > date:GetStamp() and self.dateStart:GetStamp() <= date:GetStamp()
end

meta.IsValid = meta.IsActive
