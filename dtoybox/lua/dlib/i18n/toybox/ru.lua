
-- Copyright (C) 2018-2019 DBot

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

gui.toybox.tab = 'DToyBox'
gui.toybox.tab_tip = 'Используется для горячей догрузки аддонов с Steam Workshop'

gui.toybox.frame = 'Браузеров аддонов DToyBox'
gui.toybox.controls.open_full = 'Открыть в новом окне (более удобно)'
gui.toybox.controls.button.not_avaliable = 'Нет доступа!'
gui.toybox.controls.button.ready = 'Загрузить!'
gui.toybox.controls.button.ready_collection = 'Загрузить коллекцию!'
gui.toybox.controls.button.browse = 'Откройте страницу аддона...'
gui.toybox.controls.button.busy = '< ... >'
gui.toybox.controls.button.error = 'ОШИБКА'
gui.toybox.controls.button.enabled = 'Аддон уже подгружен!'
gui.toybox.controls.button.ready_tooltip = 'Нажмите тут что бы подгрузить этот аддон!\nЕсли вы откроете страницу с аддоном под баном, вы ВСЕ РАВНО МОЖЕТЕ подгрузить его!\nПример: Neurotec Base Part 1: он получил бан но все ещё может быть подгружен, открыв страницу с ним\nТем не менее Steam скажет "тут ничего нет"\n\nУчтите - что подгрузка аддонов под баном несет весь риск связанный с тем, что именно указано в причине бана (к примеру, бэкдор)'
gui.toybox.controls.button.browse_tooltip = 'Открой страницу с аддоном! Коллекции так же поддерживаются!'
gui.toybox.controls.button.shared_parts = 'УСТОНОВИ ОБЩИЕ АССЕТЫ'
gui.toybox.notify.text = 'Помните, что не все (но близко ко всем) аддоны могут быть подгружены!\n(из-за того, как они работают)\n\nТак же, если вы подгрузили оружие/ентити/машину, не забудьте прописать spawnmenu_reload в своей консоли!\nАвтоматическая перезагрузка меню не происходит из-за проблем с производительностью\n(только если установлено >200 аддонов, что вы очень любите делать, нелюди по отношению к нам, компьютерам >:())\n\n--- ВНИМАНИЕ ---\nЕСЛИ АДДОНУ НУЖНА КАКАЯ ЛИБО БАЗА, СНАЧАЛА УСТАНОВИТЕ ЕЁ, А ПОСЛЕ УЖЕ АДДОН, ИНАЧЕ ДРЕВНЕЕ ЗЛО ПРОБУДИТСЯ. ВАС ПРЕДУПРЕДИЛИ.'
gui.toybox.notify.header = 'О горячей подгрузке аддонов'
gui.toybox.notify.button = 'Понял!'

message.toybox.missing_access = 'Нет доступа!'
