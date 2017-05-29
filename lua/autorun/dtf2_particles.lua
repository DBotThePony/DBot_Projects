if DTF2_LOAD_PARTICLES then
  return 
end
DTF2_LOAD_PARTICLES = true
local manifest = {
  'bigboom',
  'bigboom_dx80',
  'blood_impact',
  'blood_trail',
  'blood_trail_dx80',
  'bl_killtaunt',
  'bl_killtaunt_dx80',
  'bombinomicon',
  'buildingdamage',
  'bullet_tracers',
  'burningplayer',
  'burningplayer_dx80',
  'cig_smoke',
  'cig_smoke_dx80',
  'cinefx',
  'classic_rocket_trail',
  'class_fx',
  'class_fx_dx80',
  'coin_spin',
  'conc_stars',
  'crit',
  'dirty_explode',
  'disguise',
  'doomsday_fx',
  'drg_bison',
  'drg_cowmangler',
  'drg_cowmangler_dx80',
  'drg_engineer',
  'drg_pyro',
  'drg_pyro_dx80',
  'dxhr_fx',
  'explosion',
  'explosion_dx80',
  'explosion_dx90_slow',
  'explosion_high',
  'eyeboss',
  'eyeboss_dx80',
  'firstperson_weapon_fx',
  'firstperson_weapon_fx_dx80',
  'flag_particles',
  'flamethrower',
  'flamethrowertest',
  'flamethrower_dx80',
  'flamethrower_dx90_slow',
  'flamethrower_high',
  'flamethrower_mvm',
  'halloween',
  'halloween2015_unusuals',
  'halloween2016_unusuals',
  'harbor_fx',
  'harbor_fx_dx80',
  'impact_fx',
  'invasion_ray_gun_fx',
  'invasion_unusuals',
  'items_demo',
  'items_engineer',
  'killstreak',
  'level_fx',
  'medicgun_attrib',
  'medicgun_beam',
  'medicgun_beam_dx80',
  'muzzle_flash',
  'muzzle_flash_dx80',
  'mvm',
  'nailtrails',
  'nemesis',
  'npc_fx',
  'passtime',
  'passtime_beam',
  'passtime_tv_projection',
  'player_recent_teleport',
  'player_recent_teleport_dx80',
  'powerups',
  'rain_custom',
  'rankup',
  'rocketbackblast',
  'rocketjumptrail',
  'rockettrail',
  'rockettrail_dx80',
  'rps',
  'scary_ghost',
  'shellejection',
  'shellejection_dx80',
  'shellejection_high',
  'smoke_blackbillow',
  'smoke_blackbillow_dx80',
  'smoke_blackbillow_hoodoo',
  'soldierbuff',
  'soldierbuff_dx80',
  'sparks',
  'stamp_spin',
  'stickybomb',
  'stickybomb_dx80',
  'stormfront',
  'taunt_fx',
  'teleported_fx',
  'teleport_status',
  'training',
  'urban_fx',
  'vgui_menu_particles',
  'water',
  'water_dx80',
  'weapon_unusual_cool',
  'weapon_unusual_energyorb',
  'weapon_unusual_hot',
  'weapon_unusual_isotope',
  'xms'
}
for _index_0 = 1, #manifest do
  local part = manifest[_index_0]
  game.AddParticles("particles/" .. tostring(part) .. ".pcf")
end
local toPrecache = {
  'muzzle_sentry',
  'muzzle_sentry2'
}
for _index_0 = 1, #toPrecache do
  local part = toPrecache[_index_0]
  PrecacheParticleSystem(part)
end