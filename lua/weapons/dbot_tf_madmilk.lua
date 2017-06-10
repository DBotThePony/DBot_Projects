AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_cleaver')
SWEP.Base = 'dbot_tf_cleaver'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Mad Milk'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_madmilk/c_madmilk.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ProjectileRestoreTime = 10
SWEP.AttackAnimationDuration = 1
SWEP.ProjectileClass = 'dbot_milk_projectile'
SWEP.DrawHUD = function(self)
  return DTF2.DrawCenteredBar(self:GetProjectileReady() / self.ProjectileRestoreTime, 'Mad milk')
end
