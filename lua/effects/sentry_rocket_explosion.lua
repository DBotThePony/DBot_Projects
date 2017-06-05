EFFECT.Init = function(self, effData)
  local pos = effData:GetOrigin()
  local ang = effData:GetNormal():Angle()
  ParticleEffect('explosion_trailFire', pos, ang)
  return false
end
EFFECT.Think = function(self)
  return false
end
