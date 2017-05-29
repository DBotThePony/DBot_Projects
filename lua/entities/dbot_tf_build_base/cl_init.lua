include('shared.lua')
ENT.Initialize = function(self)
  self:DrawShadow(false)
  self:SetModel(self.IdleModel1)
  self:SetHP(self.HealthLevel1)
  self:SetMHP(self.HealthLevel1)
  self.buildSequence = self:LookupSequence('build')
  self.upgradeSequence = self:LookupSequence('upgrade')
  self.lastSeqModel = self.IdleModel1
  self.lastAnimTick = CurTime()
end
ENT.Think = function(self)
  if self:GetIsBuilding() then
    if self:GetBuildSpeedup() then
      return self:SetPlaybackRate(1)
    else
      return self:SetPlaybackRate(0.5)
    end
  else
    return self:SetPlaybackRate(1)
  end
end
ENT.Draw = function(self)
  local ctime = CurTime()
  self:FrameAdvance(ctime - self.lastAnimTick)
  self.lastAnimTick = ctime
  self:DrawShadow(false)
  return self:DrawModel()
end
