
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
	'Январь',
	'Февраль',
	'Март',
	'Апрель',
	'Май',
	'Июнь',
	'Июль',
	'Август',
	'Сентябрь',
	'Октябрь',
	'Ноябрь',
	'Декабрь',
}

for i, name in ipairs(months) do
	gui.daynight.months[tostring(i)] = name:formatname()
end

gui.daynight.time.format = 'ЧЧ:ММ:СС'
gui.daynight.time.sun = 'Рассвет: %s   Закат: %s'
gui.daynight.time.night = 'Конец ночи: %s   Начало ночи: %s'
gui.daynight.time.temperature = 'Температура: %.1f°C'
gui.daynight.time.wind = 'Скорость ветра: %.2f m/s; по Бофорту: %i (%s)'

gui.daynight.wind.stille = 'Штиль'
gui.daynight.wind.sillent = 'Тихий'
gui.daynight.wind.light = 'Легкий'
gui.daynight.wind.weak = 'Слабый'
gui.daynight.wind.moderate = 'Умеренный'
gui.daynight.wind.fresh = 'Свежий'
gui.daynight.wind.strong = 'Сильный'
gui.daynight.wind.robust = 'Крепкий'
gui.daynight.wind.very_robust = 'Очень крепкий'
gui.daynight.wind.storm = 'Шторм'
gui.daynight.wind.strong_storm = 'Сильный шторм'
gui.daynight.wind.violent_storm = 'Жестокий шторм'
gui.daynight.wind.hurricane = 'Ураган'
