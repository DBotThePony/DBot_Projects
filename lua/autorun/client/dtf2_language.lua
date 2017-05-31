local langPhrases = {
  {
    'dbot_tf_build_base',
    'Building base'
  },
  {
    'dbot_tf_sentry',
    'Sentry gun'
  },
  {
    'dbot_tf_dispenser',
    'Dispenser'
  },
  {
    'dbot_tf_weapon_base',
    'Base weapon'
  },
  {
    'dbot_tf_melee',
    'Melee weapon'
  },
  {
    'dbot_tf_wrench',
    'Engineer Wrench'
  },
  {
    'dbot_tf_ranged',
    'Ranged weapon'
  },
  {
    'dbot_tf_shotgun',
    'Engineer Shotgun'
  },
  {
    'dbot_tf_shotgun_heavy',
    'Heavyweapons Shotgun'
  },
  {
    'dbot_tf_shotgun_pyro',
    'Pyro Shotgun'
  },
  {
    'dbot_tf_shotgun_soldier',
    'Soldier Shotgun'
  }
}
for _index_0 = 1, #langPhrases do
  local _des_0 = langPhrases[_index_0]
  local placeholder, fullText
  placeholder, fullText = _des_0[1], _des_0[2]
  language.Add(placeholder, fullText)
end
