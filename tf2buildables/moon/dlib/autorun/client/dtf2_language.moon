
--
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
