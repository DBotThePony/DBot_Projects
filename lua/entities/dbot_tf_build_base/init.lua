include('shared.lua')
AddCSLuaFile('shared.lua')
ENT.Initialize = function(self)
  self:SetModel(self.IdleModel1)
  self:SetHP(self.HealthLevel1)
  self:SetMHP(self.HealthLevel1)
  self.mLevel = 1
  self:PhysicsInitBox(self.BuildingMins, self.BuildingMaxs)
  self:SetMoveType(MOVETYPE_NONE)
  self:GetPhysicsObject():EnableMotion(false)
  self.obbcenter = self:OBBCenter()
  self:SetIsBuilding(false)
  self:SetnwLevel(1)
  self:SetBuildSpeedup(false)
  self.lastThink = CurTime()
  self.buildSpeedupUntil = 0
  self.buildFinishAt = 0
  self.upgradeFinishAt = 0
  return self:UpdateSequenceList()
end
ENT.UpdateSequenceList = function(self)
  self.buildSequence = self:LookupSequence('build')
  self.upgradeSequence = self:LookupSequence('upgrade')
  self.idleSequence = self:LookupSequence(self.IDLE_ANIM)
end
ENT.GetLevel = function(self)
  return self:GetnwLevel()
end
ENT.SetLevel = function(self, val, playAnimation)
  if val == nil then
    val = 1
  end
  if playAnimation == nil then
    playAnimation = true
  end
  val = math.Clamp(math.floor(val), 1, 3)
  self:SetnwLevel(val)
  self.mLevel = val
  local _exp_0 = val
  if 1 == _exp_0 then
    self:SetModel(self.IdleModel1)
    self:SetHP(self.HealthLevel1)
    self:SetMHP(self.HealthLevel1)
    return self:UpdateSequenceList()
  elseif 2 == _exp_0 then
    self:SetModel(self.IdleModel2)
    if self:GetHP() == self:GetMHP() then
      self:SetHP(self.HealthLevel2)
    end
    self:SetMHP(self.HealthLevel2)
    self:UpdateSequenceList()
    if playAnimation then
      return self:PlayUpgradeAnimation()
    end
  elseif 3 == _exp_0 then
    self:SetModel(self.IdleModel3)
    self:SetHP(self.HealthLevel3)
    self:SetMHP(self.HealthLevel3)
    self:UpdateSequenceList()
    if playAnimation then
      return self:PlayUpgradeAnimation()
    end
  end
end
ENT.PlayUpgradeAnimation = function(self)
  if self:GetLevel() == 1 then
    return false
  end
  self:SetIsUpgrading(true)
  local _exp_0 = self:GetLevel()
  if 2 == _exp_0 then
    self.upgradeFinishAt = CurTime() + self.UPGRADE_TIME_2
    self:SetModel(self.BuildModel2)
  elseif 3 == _exp_0 then
    self.upgradeFinishAt = CurTime() + self.UPGRADE_TIME_3
    self:SetModel(self.BuildModel3)
  end
  self:UpdateSequenceList()
  self:ResetSequence(self.upgradeSequence)
  return true
end
ENT.SetBuildStatus = function(self, status)
  if status == nil then
    status = false
  end
  if self:GetLevel() > 1 then
    return false
  end
  if self:GetIsBuilding() == status then
    return false
  end
  self:SetIsBuilding(status)
  if status then
    self:SetModel(self.BuildModel1)
    self:UpdateSequenceList()
    self:SetBuildSpeedup(false)
    self.buildSpeedupUntil = 0
    self:ResetSequence(self.buildSequence)
    self.buildFinishAt = CurTime() + self.BuildTime
    self:OnBuildStart()
  else
    self:SetModel(self.IdleModel1)
    self:UpdateSequenceList()
    self:ResetSequence(self.idleSequence)
    self:OnBuildFinish()
  end
  return true
end
ENT.OnBuildStart = function(self) end
ENT.OnBuildFinish = function(self) end
ENT.OnUpgradeFinish = function(self) end
ENT.BuildThink = function(self) end
ENT.IsAvaliable = function(self)
  return not self:GetIsBuilding() and not self:GetIsUpgrading()
end
ENT.Think = function(self)
  local cTime = CurTime()
  local delta = cTime - self.lastThink
  self.lastThink = cTime
  if self:GetIsBuilding() then
    if self.buildSpeedupUntil > cTime then
      self.buildFinishAt = self.buildFinishAt - delta
    end
    if self.buildFinishAt < cTime then
      self:SetBuildSpeedup(false)
      self:SetIsBuilding(false)
      self:SetModel(self.IdleModel1)
      self:UpdateSequenceList()
      self:ResetSequence(self.idleSequence)
      return self:OnBuildFinish()
    end
  elseif self:GetIsUpgrading() then
    if self.upgradeFinishAt < cTime then
      self:SetBuildSpeedup(false)
      self:SetIsUpgrading(false)
      local _exp_0 = self:GetLevel()
      if 2 == _exp_0 then
        self:SetModel(self.IdleModel2)
      elseif 3 == _exp_0 then
        self:SetModel(self.IdleModel3)
      end
      self:UpdateSequenceList()
      self:ResetSequence(self.idleSequence)
      return self:OnUpgradeFinish()
    end
  end
end
