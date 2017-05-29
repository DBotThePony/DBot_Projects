ENT.Type = 'nextbot'
ENT.Base = 'base_nextbot'
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
ENT.SetupDataTables = function(self)
  self:NetworkVar('Float', 0, 'HP')
  self:NetworkVar('Float', 1, 'MHP')
  self:NetworkVar('Bool', 0, 'IsBuilding')
  self:NetworkVar('Bool', 2, 'IsUpgrading')
  self:NetworkVar('Bool', 1, 'BuildSpeedup')
  self:NetworkVar('Int', 1, 'nwLevel')
  return self:NetworkVar('Entity', 0, 'Player')
end
