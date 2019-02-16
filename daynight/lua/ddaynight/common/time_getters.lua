
-- Copyright (C) 2017-2019 DBot

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

local function bridge(funcName, bridgeName)
	DDayNight[bridgeName or funcName] = function(...)
		local targetFunction = DDayNight.DATE_OBJECT[funcName]
		return targetFunction(DDayNight.DATE_OBJECT, ...)
	end

	DDayNight['Accurate' .. (bridgeName or funcName)] = function(...)
		local targetFunction = DDayNight.DATE_OBJECT[funcName]
		return targetFunction(DDayNight.DATE_OBJECT, ...)
	end

	DDayNight[(bridgeName or funcName) .. 'Accurate'] = function(...)
		local targetFunction = DDayNight.DATE_OBJECT[funcName]
		return targetFunction(DDayNight.DATE_OBJECT, ...)
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
bridge('Format', 'FormatDate')
