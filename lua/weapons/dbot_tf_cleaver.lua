AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_weapon_base')
SWEP.Base = 'dbot_tf_weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Flying Guillotine'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_sd_cleaver/v_sd_cleaver.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ProjectileRestoreTime = 10
SWEP.IdleAnimation = 'ed_idle'
SWEP.DrawAnimation = 'ed_draw'
SWEP.AttackAnimation = 'ed_throw'
SWEP.AttackAnimationCrit = 'ed_throw'
SWEP.AttackAnimationDuration = 1
SWEP.ProjectileClass = 'dbot_cleaver_projectile'
SWEP.ProjectileIsReady = function(self)
  return self:GetProjectileReady() >= self.ProjectileRestoreTime
end
SWEP.PreDrawViewModel = function(self, vm)
  self.vmModel = vm
end
SWEP.Primary = {
  ['Ammo'] = 'none',
  ['ClipSize'] = -1,
  ['DefaultClip'] = 0,
  ['Automatic'] = true
}
SWEP.Secondary = {
  ['Ammo'] = 'none',
  ['ClipSize'] = -1,
  ['DefaultClip'] = 0,
  ['Automatic'] = false
}
SWEP.SetupDataTables = function(self)
  BaseClass.SetupDataTables(self)
  self:NetworkVar('Float', 16, 'ProjectileReady')
  return self:NetworkVar('Float', 17, 'HideProjectile')
end
SWEP.Initialize = function(self)
  BaseClass.Initialize(self)
  self:SetProjectileReady(self.ProjectileRestoreTime)
  self.lastProjectileThink = CurTime()
  self.lastProjectileStatus = true
  return self:SetHideProjectile(0)
end
SWEP.Think = function(self)
  BaseClass.Think(self)
  if SERVER then
    local delta = CurTime() - self.lastProjectileThink
    self.lastProjectileThink = CurTime()
    if self:GetProjectileReady() < self.ProjectileRestoreTime then
      self:SetProjectileReady(math.Clamp(self:GetProjectileReady() + delta, 0, self.ProjectileRestoreTime))
    end
  end
  local old = self.lastProjectileStatus
  local newStatus = self:ProjectileIsReady()
  if IsValid(self.vmModel) then
    self.vmModel:SetNoDraw(not newStatus and self:GetHideProjectile() < CurTime())
  end
  if old ~= newStatus then
    self.lastProjectileStatus = newStatus
    if newStatus then
      self:SendWeaponSequence(self.DrawAnimation)
      if self.OnProjectileRestored then
        self:OnProjectileRestored()
      end
      return self:WaitForSequence(self.IdleAnimation, self.AttackAnimationDuration)
    end
  end
end
SWEP.DrawHUD = function(self)
  return DTF2.DrawCenteredBar(self:GetProjectileReady() / self.ProjectileRestoreTime, 'Cleaver')
end
SWEP.PrimaryAttack = function(self)
  if not self:ProjectileIsReady() then
    return false
  end
  local incomingCrit = self:CheckNextCrit()
  self:SetProjectileReady(0)
  self.lastProjectileStatus = false
  self:SendWeaponSequence(self.AttackAnimation)
  self:WaitForSequence(self.IdleAnimation, self.AttackAnimationDuration)
  self:SetHideProjectile(CurTime() + self.AttackAnimationDuration)
  if CLIENT then
    return 
  end
  return timer.Simple(0, function()
    if not IsValid(self) or not IsValid(self:GetOwner()) then
      return 
    end
    do
      local _with_0 = ents.Create(self.ProjectileClass)
      _with_0:SetPos(self:GetOwner():EyePos())
      _with_0:Spawn()
      _with_0:Activate()
      _with_0:SetIsCritical(incomingCrit)
      _with_0:SetOwner(self:GetOwner())
      _with_0:SetAttacker(self:GetOwner())
      _with_0:SetInflictor(self)
      _with_0:SetDirection(self:GetOwner():GetAimVector())
      return _with_0
    end
  end)
end
