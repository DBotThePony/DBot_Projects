
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
gui.daynight.time.wind = 'Скорость ветра: %.2f m/s;\nпо Бофорту: %i (%s)'

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

gui.daynight.menu.sv.seed = 'Зерно времени'
gui.daynight.menu.sv.seed_change = 'Изменить зерно времени...'
gui.daynight.menu.sv.seed_desc = 'Зерно времени это большое целочисленное значение\nи оно незначительно влияет на закат/восход/ветер/температуру.\nВы так же можете ввести любое строковое значение,\nоно будет преобразовано в целочисленное.'
gui.daynight.menu.sv.forward_title = 'Промотать время вперед'
gui.daynight.menu.sv.forward_button = 'Промотать время вперед на %s'
gui.daynight.menu.sv.forward_button2 = 'Промотать время вперед...'
gui.daynight.menu.sv.forward_desc = 'Данное действие промотает время вперед на %s'

gui.daynight.menu.sv.forward_menu = 'Меню перемотки времени\nВы можете менять значения в любом из этих полей\nВы можете вводить только положительные целочисленные значения.\nНиже вы можете изменить абсолютное количество секунд\nНе делайте глупостей!'

message.daynight.command.no_perms = 'Нет прав!'
message.daynight.command.already_sequence = 'Уже работаю над перемоткой времени!'
message.daynight.command.fastforward = ' запустил перемотку времени на '
message.daynight.command.missing_time = 'Дано неверное время.'
message.daynight.command.invalid_time = 'Время неверно либо слишком мало. Минимум - 21600 секунд'
message.daynight.command.invalid_seed = 'Дано неверное зерно.'
