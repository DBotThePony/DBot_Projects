
--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

langPhrases = {
	{'dbot_tf_build_base', 'Building base'}
	{'dbot_tf_sentry', 'Sentry gun'}
	{'dbot_sentry_rocket', 'Sentry rockets'}
	{'dbot_tf_dispenser', 'Dispenser'}
	{'dbot_tf_weapon_base', 'Base weapon'}
	{'dbot_tf_melee', 'Melee weapon'}
	{'dbot_tf_wrench', 'Engineer Wrench'}
	{'dbot_tf_ranged', 'Ranged weapon'}
	{'dbot_tf_shotgun', 'Engineer Shotgun'}
	{'dbot_tf_shotgun_heavy', 'Heavyweapons Shotgun'}
	{'dbot_tf_shotgun_pyro', 'Pyro Shotgun'}
	{'dbot_tf_shotgun_soldier', 'Soldier Shotgun'}

	{'ammo_tf_syringe_Ammo', 'Syringes'}
	{'ammo_tf_flame_Ammo', 'Flamethrower Ammo'}
}

language.Add(placeholder, fullText) for {placeholder, fullText} in *langPhrases
