
-- Copyright (C) 2017-2019 DBotThePony

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


gui.dsit.friend = 'DSit друг'

message.dsit.sit.toofast = 'Вы двигаетесь слишком быстро!'

message.dsit.check.pitch = 'Неверный угол поверхности (питч %i, когда должен быть <> +-20 или -180)'
message.dsit.check.roll = 'Неверный угол поверхности (ролл %i, когда должен быть <> +-20)'
message.dsit.check.unreachable = 'Целевая позиция недоступна'

message.dsit.status.entities = 'Возможность сидеть на ентити отключена'
message.dsit.status.npc = 'Вы не можете сидеть на NPC'
message.dsit.status.toofast = 'Цель двигается слишком быстро!'
message.dsit.status.recursion = 'Вы не можете сидеть на том, кто сидит на вас'
message.dsit.status.nolegs = 'Возможность сидеть на ногах игроков отключена'
message.dsit.status.noplayers = 'Возможность сидеть на игроках отключена'
message.dsit.status.diasallowed = 'Цель отключила возможность сидеть на ней'
message.dsit.status.friendsonly = 'Один (или оба) игрок(а) cl_dsit_friendsonly 1 и вы не друзья'
message.dsit.status.nonowned = 'Вы можете сидеть только на ентити без владельца'
message.dsit.status.onlyowned = 'Вы можете сидеть только на ентити, владелец которых вы'
message.dsit.status.restricted = 'Цель ограничила максимальное количество игроков, которые сидят на ней'
message.dsit.status.hook = 'Сейчас вы не можете сидеть'

info.dsit.nopos = 'Не обнаружено каких либо правильных позиций, вы будете возвращены в начало...'

gui.dsit.menu.author = 'DSit был создан DBotThePony'
gui.dsit.menu.sitonme = 'Разрешить сидеть на мне'
gui.dsit.menu.friendsonly = 'Разрешить только для друзей'
gui.dsit.menu.getoff_check = 'Проверять ваш чат на фразу "get off"'
gui.dsit.menu.max = 'Максимальное кол-во игроков на вас'
gui.dsit.menu.hide = 'Прятать игроков над вами'
gui.dsit.menu.getoff = 'Скинуть игрока(-ов) над вами'
gui.dsit.menu.getoff_e = 'Скинуть определённого игрока над вами'
