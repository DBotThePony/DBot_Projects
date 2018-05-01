
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
gui.dsit.menu.getoff = 'Скинуть игрока(-ов) над вами'
