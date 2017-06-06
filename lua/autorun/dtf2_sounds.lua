DTF2 = DTF2 or { }
if DTF2.LOAD_SOUNDS then
  return 
end
DTF2.LOAD_SOUNDS = true
sound.AddSoundOverrides('scripts/dtf2_sounds.txt')
sound.AddSoundOverrides('scripts/dtf2_sounds_mvm.txt')
sound.AddSoundOverrides('scripts/dtf2_sounds_passtime.txt')
sound.AddSoundOverrides('scripts/dtf2_sounds_physics.txt')
sound.AddSoundOverrides('scripts/dtf2_sounds_player.txt')
sound.AddSoundOverrides('scripts/dtf2_sounds_taunt_workshop.txt')
return sound.AddSoundOverrides('scripts/dtf2_sounds_weapons.txt')
