
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
local self = DDayNight
local math = math
local ipairs = ipairs
local pairs = pairs
local table = table

local function numerize(tabIn)
	for index, month in pairs(self.indexedMonths) do
		tabIn[index] = tabIn[month]
	end
end

self.monthsAverageTemperature = {
	january = -20,
	feburary = -18,
	march = -6,
	april = 4,
	may = 17,
	june = 24,
	july = 30,
	august = 27,
	september = 20,
	october = 13,
	november = -4,
	december = -23,
}

numerize(self.monthsAverageTemperature)
