
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
gui.daynight.time.wind = 'Wind speed: %.2f m/s;\nBeaufort Score: %i (%s)'

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

gui.daynight.menu.current = 'Currently, it is'
gui.daynight.menu.currentof = 'Of'
gui.daynight.menu.sunrise = 'SUNRISE'
gui.daynight.menu.sunset = 'SUNSET'

gui.daynight.menu.cvar.small = 'Display time at corner of screen'
gui.daynight.menu.cvar.scoreboard = 'Display time at scoreboard'
gui.daynight.menu.cvar.context = 'Display progression at context menu'

gui.daynight.menu.sv.seed = 'Time seed'
gui.daynight.menu.sv.seed_change = 'Change time seed...'
gui.daynight.menu.sv.seed_desc = 'Time seed is big integer\nand slightly affect sunset/sunrise/temperature/wind.\nYou can also type random string, it will be translated\ninto integer seed using CRC32 function.'
gui.daynight.menu.sv.forward_title = 'Fast-forward time'
gui.daynight.menu.sv.forward_button = 'Fast-forward time by %s'
gui.daynight.menu.sv.forward_button2 = 'Fast-forward time...'
gui.daynight.menu.sv.forward_desc = 'This will fast-forward time by %s'

gui.daynight.menu.sv.forward_menu = 'Fast forward menu\nYou can adjuct value in any field\nYou can use only positive integers in these fields.\nBelow you can change absolute amount of seconds\nDont try to do anything stupid!'

message.daynight.command.no_perms = 'Missing permissions!'
message.daynight.command.already_sequence = 'Already playing fast-forward sequence!'
message.daynight.command.fastforward = ' initiated time fast-forward by '
message.daynight.command.missing_time = 'Invalid time were specified.'
message.daynight.command.invalid_time = 'Invalid or too small time were specified. Minimal time is 21600 seconds'
message.daynight.command.invalid_seed = 'Invalid seed were specified.'
