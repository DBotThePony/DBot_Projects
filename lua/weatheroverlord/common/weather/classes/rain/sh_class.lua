
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

local meta = WOverlord.RegisterWeather('rain', 'Rain', WOverlord.CHECK_FREQUENCY_MINUTE)

function meta:CanBeTriggeredNow()

end

function meta:GetLength()

end

function meta:Initialize(dryRun)
	if dryRun then return end
	WOverlord.AddWeatherParticles('env_rain_512')
end
