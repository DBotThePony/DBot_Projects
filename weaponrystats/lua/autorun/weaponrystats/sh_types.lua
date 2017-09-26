
-- Copyright (C) 2017 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

return {
	poison = {
		name = 'Poisonus',
		dmgtype = DMG_POISON,
		isAdditional = false,
		damage = 1.1,
		force = 1,
		quality = 1,
		order = 5
	},

	electric = {
		name = 'Shocking',
		dmgtype = DMG_SHOCK,
		isAdditional = false,
		damage = 1.25,
		force = 0.4,
		quality = 2,
		order = 10
	},
}
