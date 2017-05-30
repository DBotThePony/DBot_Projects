ENT.Type = 'nextbot'
ENT.Base = 'base_nextbot'
ENT.IsTF2Building = true
ENT.BuildModel1 = 'models/buildables/dispenser.mdl'
ENT.BuildModel2 = 'models/buildables/dispenser_lvl2.mdl'
ENT.BuildModel3 = 'models/buildables/dispenser_lvl3.mdl'
ENT.IdleModel1 = 'models/buildables/dispenser_light.mdl'
ENT.IdleModel2 = 'models/buildables/dispenser_lvl2_light.mdl'
ENT.IdleModel3 = 'models/buildables/dispenser_lvl3_light.mdl'
ENT.HealthLevel1 = 150
ENT.HealthLevel2 = 180
ENT.HealthLevel3 = 216
ENT.BuildTime = 2
ENT.BuildingMins = Vector(-16, -16, 0)
ENT.BuildingMaxs = Vector(16, 16, 48)
ENT.Author = 'DBot'
ENT.PrintName = 'TF2 Buildable base'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.IDLE_ANIM = 'ref'
ENT.UPGRADE_TIME_2 = 1.16
ENT.UPGRADE_TIME_3 = 1.16
ENT.REPAIR_HEALTH = 40
ENT.UPGRADE_HIT = 25
ENT.MAX_UPGRADE = 200
ENT.MAX_DISTANCE = 512 ^ 2
ENT.GetLevel = function(self)
  return self:GetnwLevel()
end
ENT.SetupDataTables = function(self)
  self:NetworkVar('Bool', 0, 'IsBuilding')
  self:NetworkVar('Bool', 2, 'IsUpgrading')
  self:NetworkVar('Bool', 1, 'BuildSpeedup')
  self:NetworkVar('Bool', 16, 'TeamType')
  self:NetworkVar('Int', 1, 'nwLevel')
  self:NetworkVar('Int', 16, 'UpgradeAmount')
  return self:NetworkVar('Entity', 0, 'Player')
end
ENT.UpdateSequenceList = function(self)
  self.buildSequence = self:LookupSequence('build')
  self.upgradeSequence = self:LookupSequence('upgrade')
  self.idleSequence = self:LookupSequence(self.IDLE_ANIM)
end
ENT.IsAvaliable = function(self)
  return not self:GetIsBuilding() and not self:GetIsUpgrading()
end
ENT.CustomRepair = function(self, thersold, simulate)
  if thersold == nil then
    thersold = 200
  end
  if simulate == nil then
    simulate = CLIENT
  end
  if thersold == 0 then
    return 0
  end
  local weight = 0
  return weight
end
ENT.SimulateRepair = function(self, thersold, simulate)
  if thersold == nil then
    thersold = 200
  end
  if simulate == nil then
    simulate = CLIENT
  end
  if thersold == 0 then
    return 0
  end
  local weight = 0
  local repairHP = 0
  if self:IsAvaliable() then
    repairHP = math.Clamp(math.min(self:GetMaxHealth() - self:Health(), self.REPAIR_HEALTH), 0, thersold - weight)
  end
  if repairHP ~= 0 then
    weight = weight + repairHP
  end
  if repairHP ~= 0 and not simulate then
    self:SetHealth(self:Health() + repairHP)
  end
  weight = weight + self:CustomRepair(thersold - weight, simulate)
  if self:GetLevel() < 3 and weight ~= thersold and self:IsAvaliable() then
    local upgradeAmount = math.Clamp(math.min(self.MAX_UPGRADE - self:GetUpgradeAmount(), self.UPGRADE_HIT), 0, thersold - weight)
    if upgradeAmount ~= 0 then
      weight = weight + upgradeAmount
    end
    if upgradeAmount ~= 0 and not simulate then
      self:SetUpgradeAmount(self:GetUpgradeAmount() + upgradeAmount)
    end
    if self:GetUpgradeAmount() >= self.MAX_UPGRADE then
      self:SetLevel(self:GetLevel() + 1)
    end
  end
  return weight
end
