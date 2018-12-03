
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

local months = {
	'january',
	'feburary',
	'march',
	'april',
	'may',
	'june',
	'july',
	'august',
	'september',
	'october',
	'november',
	'december',
}

for i, name in ipairs(months) do
	gui.daynight.months[tostring(i)] = name:formatname()
end

gui.daynight.time.format = 'HH:MM:SS'
gui.daynight.time.sun = 'Sunrise: %s   Sunset: %s'
gui.daynight.time.night = 'Night end: %s   Night start: %s'
gui.daynight.time.temperature = 'Temperature: %.1f°C'
gui.daynight.time.wind = 'Wind speed: %.2f m/s; Beaufort Score: %i (%s)'

gui.daynight.wind.stille = 'Stille'
gui.daynight.wind.sillent = 'Sillent'
gui.daynight.wind.light = 'Light'
gui.daynight.wind.weak = 'Weak'
gui.daynight.wind.moderate = 'Moderate'
gui.daynight.wind.fresh = 'Fresh'
gui.daynight.wind.strong = 'Strong'
gui.daynight.wind.robust = 'Robust'
gui.daynight.wind.very_robust = 'Very robust'
gui.daynight.wind.storm = 'Storm'
gui.daynight.wind.strong_storm = 'Strong storm'
gui.daynight.wind.violent_storm = 'Violent storm'
gui.daynight.wind.hurricane = 'Hurricane'
