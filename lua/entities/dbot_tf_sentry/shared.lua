ENT.Base = 'dbot_tf_build_base'
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
ENT.BuildTime = 5
ENT.SENTRY_ANGLE_CHANGE_MULT = 30
ENT.SENTRY_SCAN_YAW_MULT = 30
ENT.SENTRY_SCAN_YAW_CONST = 30
ENT.SetupDataTables = function(self)
  self.BaseClass.SetupDataTables(self)
  self:NetworkVar('Int', 2, 'AimPitch')
  return self:NetworkVar('Int', 3, 'AimYaw')
end
