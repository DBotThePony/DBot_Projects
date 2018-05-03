
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

NetworkedValues = {
	{'jump', 'Серия прыжков: %s'}
	{'speed', 'Дистанция бегом: %sm'}
	{'duck', 'Дистанция вприсядку: %sm'}
	{'walk', 'Дистанция шагом: %sm'}
	{'water', 'Дистанция вплавь: %sm'}
	{'uwater', 'Дистанция под водой: %sm'}
	{'fall', 'Падение: %sm'}
	{'climb', 'Подъём: %sm'}
	{'height', 'Максимальная потенциальная высота: %sm'}
}

for value in *NetworkedValues
	gui.actioncounter[value[1]] = value[2]
