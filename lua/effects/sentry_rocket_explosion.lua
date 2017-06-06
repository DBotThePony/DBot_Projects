EFFECT.Init = function(self, effData)
  local pos = effData:GetOrigin()
  local ang = effData:GetNormal():Angle()
  ParticleEffect('Explosion_CoreFlash', pos, ang)
  ParticleEffect('Explosion_Dustup', pos, ang)
  ParticleEffect('Explosion_Dustup_2', pos, ang)
  ParticleEffect('Explosion_Smoke_1', pos, ang)
  return ParticleEffect('Explosion_Flashup', pos, ang)
end
EFFECT.Think = function(self)
  return false
end
