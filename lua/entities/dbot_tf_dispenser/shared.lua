ENT.Base = 'dbot_tf_build_base'
ENT.Type = 'nextbot'
ENT.PrintName = 'Dispenser'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = false
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.HEAL_SPEED_MULT = 10
ENT.BuildModel1 = 'models/buildables/dispenser.mdl'
ENT.BuildModel2 = 'models/buildables/dispenser_lvl2.mdl'
ENT.BuildModel3 = 'models/buildables/dispenser_lvl3.mdl'
ENT.IdleModel1 = 'models/buildables/dispenser_light.mdl'
ENT.IdleModel2 = 'models/buildables/dispenser_lvl2_light.mdl'
ENT.IdleModel3 = 'models/buildables/dispenser_lvl3_light.mdl'
ENT.BuildingMins = Vector(-18, -16, 0)
ENT.BuildingMaxs = Vector(18, 16, 64)
ENT.BuildTime = 20
ENT.IDLE_ANIM = 'ref'
ENT.MAX_DISTANCE = 128 ^ 2
ENT.RESSUPLY_MULTIPLIER_1 = 1
ENT.RESSUPLY_MULTIPLIER_2 = 1.2
ENT.RESSUPLY_MULTIPLIER_3 = 1.4
ENT.MAS_RESSUPLY_1 = 300
ENT.MAS_RESSUPLY_2 = 400
ENT.MAS_RESSUPLY_3 = 500
ENT.AMMO_RESSUPLY_MAX_1 = 40
ENT.AMMO_RESSUPLY_MAX_2 = 50
ENT.AMMO_RESSUPLY_MAX_3 = 60
ENT.CHARGE_TIME_1 = 5
ENT.CHARGE_TIME_2 = 5
ENT.CHARGE_TIME_3 = 5
ENT.CHARGE_AMOUNT_1 = 40
ENT.CHARGE_AMOUNT_2 = 50
ENT.CHARGE_AMOUNT_3 = 60
ENT.AMMO_AMOUNT_1 = 40
ENT.AMMO_AMOUNT_2 = 50
ENT.AMMO_AMOUNT_3 = 60
ENT.GetRessuplyMultiplier = function(self, level)
  if level == nil then
    level = self:GetLevel()
  end
  local _exp_0 = level
  if 1 == _exp_0 then
    return self.RESSUPLY_MULTIPLIER_1
  elseif 2 == _exp_0 then
    return self.RESSUPLY_MULTIPLIER_2
  elseif 3 == _exp_0 then
    return self.RESSUPLY_MULTIPLIER_3
  end
end
ENT.GetMaxRessuply = function(self, level)
  if level == nil then
    level = self:GetLevel()
  end
  local _exp_0 = level
  if 1 == _exp_0 then
    return self.MAS_RESSUPLY_1
  elseif 2 == _exp_0 then
    return self.MAS_RESSUPLY_2
  elseif 3 == _exp_0 then
    return self.MAS_RESSUPLY_3
  end
end
ENT.GetAmmoRessuply = function(self, level)
  if level == nil then
    level = self:GetLevel()
  end
  local _exp_0 = level
  if 1 == _exp_0 then
    return self.AMMO_RESSUPLY_MAX_1
  elseif 2 == _exp_0 then
    return self.AMMO_RESSUPLY_MAX_2
  elseif 3 == _exp_0 then
    return self.AMMO_RESSUPLY_MAX_3
  end
end
ENT.GetChargeTime = function(self, level)
  if level == nil then
    level = self:GetLevel()
  end
  local _exp_0 = level
  if 1 == _exp_0 then
    return self.CHARGE_TIME_1
  elseif 2 == _exp_0 then
    return self.CHARGE_TIME_2
  elseif 3 == _exp_0 then
    return self.CHARGE_TIME_3
  end
end
ENT.GetChargeAmount = function(self, level)
  if level == nil then
    level = self:GetLevel()
  end
  local _exp_0 = level
  if 1 == _exp_0 then
    return self.CHARGE_AMOUNT_1
  elseif 2 == _exp_0 then
    return self.CHARGE_AMOUNT_2
  elseif 3 == _exp_0 then
    return self.CHARGE_AMOUNT_3
  end
end
ENT.GetAmmoToAmount = function(self, level)
  if level == nil then
    level = self:GetLevel()
  end
  local _exp_0 = level
  if 1 == _exp_0 then
    return self.AMMO_AMOUNT_1
  elseif 2 == _exp_0 then
    return self.AMMO_AMOUNT_2
  elseif 3 == _exp_0 then
    return self.AMMO_AMOUNT_3
  end
end
ENT.GetAvaliableForAmmo = function(self, level)
  if level == nil then
    level = self:GetLevel()
  end
  return math.Clamp(self:GetAmmoRessuply(), 0, math.min(self:GetRessuplyAmount(), self:GetAmmoToAmount(level)))
end
ENT.GetAvaliablePercent = function(self, level)
  if level == nil then
    level = self:GetLevel()
  end
  return self:GetRessuplyAmount() / self:GetMaxRessuply()
end
ENT.SetupDataTables = function(self)
  self.BaseClass.SetupDataTables(self)
  return self:NetworkVar('Int', 2, 'RessuplyAmount')
end
