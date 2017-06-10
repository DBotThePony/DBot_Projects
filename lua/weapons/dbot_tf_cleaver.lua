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
SWEP.CleaverRestoreTime = 10
SWEP.IdleAnimation = 'ed_idle'
SWEP.DrawAnimation = 'ed_draw'
SWEP.AttackAnimation = 'ed_throw'
SWEP.AttackAnimationCrit = 'ed_throw'
SWEP.AttackAnimationDuration = 1
SWEP.CleaverIsReady = function(self)
  return self:GetCleaverReady() >= self.CleaverRestoreTime
end
SWEP.PreDrawViewModel = function(self, vm)
  self.vmModel = vm
end
SWEP.SetupDataTables = function(self)
  self.BaseClass.SetupDataTables(self)
  self:NetworkVar('Float', 16, 'CleaverReady')
  self:NetworkVar('Float', 17, 'HideCleaver')
  return self:NetworkVar('Entity', 16, 'TF2BallModel')
end
SWEP.Initialize = function(self)
  self.BaseClass.Initialize(self)
  self:SetCleaverReady(self.CleaverRestoreTime)
  self.lastCleaverThink = CurTime()
  self.lastCleaverStatus = true
  return self:SetHideCleaver(0)
end
SWEP.Think = function(self)
  self.BaseClass.Think(self)
  if SERVER then
    local delta = CurTime() - self.lastCleaverThink
    self.lastCleaverThink = CurTime()
    if self:GetCleaverReady() < self.CleaverRestoreTime then
      self:SetCleaverReady(math.Clamp(self:GetCleaverReady() + delta, 0, self.CleaverRestoreTime))
    end
  end
  local old = self.lastCleaverStatus
  local newStatus = self:CleaverIsReady()
  if IsValid(self.vmModel) then
    self.vmModel:SetNoDraw(not newStatus and self:GetHideCleaver() < CurTime())
  end
  if old ~= newStatus then
    self.lastCleaverStatus = newStatus
    if newStatus then
      self:SendWeaponSequence(self.DrawAnimation)
      return self:WaitForSequence(self.IdleAnimation, self.AttackAnimationDuration)
    end
  end
end
SWEP.DrawHUD = function(self)
  return DTF2.DrawCenteredBar(self:GetCleaverReady() / self.CleaverRestoreTime, 'Cleaver')
end
SWEP.PrimaryAttack = function(self)
  if not self:CleaverIsReady() then
    return false
  end
  local incomingCrit = self:CheckNextCrit()
  self:SetCleaverReady(0)
  self.lastCleaverStatus = false
  self:SendWeaponSequence(self.AttackAnimation)
  self:WaitForSequence(self.IdleAnimation, self.AttackAnimationDuration)
  self:SetHideCleaver(CurTime() + self.AttackAnimationDuration)
  if CLIENT then
    return 
  end
  return timer.Simple(0, function()
    if not IsValid(self) or not IsValid(self:GetOwner()) then
      return 
    end
    do
      local _with_0 = ents.Create('dbot_cleaver_projectile')
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
