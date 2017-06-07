local CriticalHitLabel = CreateMaterial('effects/minicrit_unlit', 'UnlitGeneric', {
  ['$basetexture'] = 'effects/minicrit',
  ['$ignorez'] = 1,
  ['$vertexcolor'] = 1,
  ['$vertexalpha'] = 1,
  ['$nolod'] = 1
})
EFFECT.Init = function(self, effData)
  self.realpos = Vector(effData:GetOrigin())
  self.pos = Vector(effData:GetOrigin())
  self.size = 2
  self.r = 255
  self.g = 255
  self.b = 255
  self.a = 255
  self.shift = 0
end
EFFECT.Think = function(self)
  if self.size > 1 then
    self.size = self.size - (FrameTime() * 2)
  end
  if self.size <= 1 then
    self.shift = self.shift + (FrameTime() * 60)
  end
  local delta = math.max(self.size - 1, 0)
  self.r = 237 + 18 * delta
  self.g = 233 + 22 * delta
  self.b = 70 + 185 * delta
  self.pos.z = self.realpos.z + self.shift
  return self.shift < 200
end
EFFECT.Render = function(self)
  render.SetMaterial(CriticalHitLabel)
  return render.DrawSprite(self.pos, 24 * self.size, 24 * self.size, Color(self.r, self.g, self.b, self.a))
end
