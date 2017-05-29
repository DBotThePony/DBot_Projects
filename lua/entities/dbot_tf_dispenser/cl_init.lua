include('shared.lua')
ENT.Initialize = function(self)
  self.BaseClass.Initialize(self)
  self.idleSound = CreateSound(self, 'weapons/dispenser_idle.wav')
  self.idleSound:ChangeVolume(0.75)
  self.idleSound:SetSoundLevel(75)
  return self.idleSound:Play()
end
ENT.OnRemove = function(self)
  if self.idleSound then
    return self.idleSound:Stop()
  end
end
ENT.Think = function(self)
  return self.BaseClass.Think(self)
end
ENT.Draw = function(self)
  local screenMat
  if self:GetTeamType() then
    screenMat = ''
  end
  if not self:GetTeamType() then
    screenMat = ''
  end
  return self.BaseClass.Draw(self)
end
