include('shared.lua')
ENT.Initialize = function(self)
  self:DrawShadow(false)
  self:SetModel(self.IdleModel1)
  self:SetHP(self.HealthLevel1)
  self:SetMHP(self.HealthLevel1)
  self:UpdateSequenceList()
  self.lastSeqModel = self.IdleModel1
  self.lastAnimTick = CurTime()
end
ENT.Think = function(self) end
ENT.Draw = function(self)
  self:DrawShadow(false)
  return self:DrawModel()
end
