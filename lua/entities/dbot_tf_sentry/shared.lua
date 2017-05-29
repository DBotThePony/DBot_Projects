ENT.Base = 'dbot_tf_build_base'
ENT.Type = 'nextbot'
ENT.PrintName = 'Sentry gun'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = false
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.BuildModel1 = 'models/buildables/sentry1_heavy.mdl'
ENT.IdleModel1 = 'models/buildables/sentry1.mdl'
ENT.BuildModel2 = 'models/buildables/sentry2_heavy.mdl'
ENT.IdleModel2 = 'models/buildables/sentry2.mdl'
ENT.BuildModel3 = 'models/buildables/sentry3_heavy.mdl'
ENT.IdleModel3 = 'models/buildables/sentry3.mdl'
ENT.BuildTime = 10
ENT.SENTRY_ANGLE_CHANGE_MULT = 50
ENT.SENTRY_SCAN_YAW_MULT = 30
ENT.SENTRY_SCAN_YAW_CONST = 30
ENT.IDLE_ANIM = 'idle_off'
ENT.MAX_DISTANCE = 1024 ^ 2
ENT.MAX_AMMO_1 = 150
ENT.MAX_AMMO_2 = 250
ENT.MAX_AMMO_3 = 250
ENT.MAX_ROCKETS_1 = 0
ENT.MAX_ROCKETS_2 = 0
ENT.MAX_ROCKETS_3 = 30
ENT.BULLET_DAMAGE = 12
ENT.BULLET_RELOAD_1 = 0.3
ENT.BULLET_RELOAD_2 = 0.1
ENT.BULLET_RELOAD_3 = 0.1
ENT.GetMaxAmmo = function(self, level)
  if level == nil then
    level = self:GetLevel()
  end
  local _exp_0 = level
  if 1 == _exp_0 then
    return self.MAX_AMMO_1
  elseif 2 == _exp_0 then
    return self.MAX_AMMO_2
  elseif 3 == _exp_0 then
    return self.MAX_AMMO_3
  end
end
ENT.SetupDataTables = function(self)
  self.BaseClass.SetupDataTables(self)
  self:NetworkVar('Int', 2, 'AimPitch')
  self:NetworkVar('Int', 3, 'AimYaw')
  self:NetworkVar('Int', 4, 'AmmoAmount')
  return self:NetworkVar('Int', 5, 'Rockets')
end
ENT.UpdateSequenceList = function(self)
  self.BaseClass.UpdateSequenceList(self)
  self.fireSequence = self:LookupSequence('fire')
  self.muzzle = self:LookupAttachment('muzzle')
  self.muzzle_l = self:LookupAttachment('muzzle_l')
  self.muzzle_r = self:LookupAttachment('muzzle_r')
end
