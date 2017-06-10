AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_bat')
SWEP.Base = 'dbot_tf_bat'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Wrap Assasin'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_xms_giftwrap/c_xms_giftwrap.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.BulletDamage = 35 * .35
SWEP.BallRestoreTime = 15 * .75
SWEP.BallModel = 'models/weapons/c_models/c_xms_festive_ornament.mdl'
SWEP.Unavaliable_DrawAnimation = 'b_draw'
SWEP.Unavaliable_IdleAnimation = 'b_idle'
SWEP.Unavaliable_AttackAnimation = 'b_swing_a'
SWEP.Unavaliable_AttackAnimationTable = {
  'b_swing_a',
  'b_swing_b'
}
SWEP.Unavaliable_AttackAnimationCrit = 'b_swing_c'
SWEP.Avaliable_DrawAnimation = 'wb_draw'
SWEP.Avaliable_IdleAnimation = 'wb_idle'
SWEP.Avaliable_AttackAnimation = 'wb_swing_a'
SWEP.Avaliable_AttackAnimationTable = {
  'wb_swing_a',
  'wb_swing_b'
}
SWEP.Avaliable_AttackAnimationCrit = 'wb_swing_c'
SWEP.BallThrowAnimation = 'wb_fire'
SWEP.BallThrowAnimationTime = 1.2
SWEP.BallThrowSound = 'DTF2_BallBuster.HitBall'
SWEP.BallThrowSoundTime = 0.1
SWEP.HitSoundsScript = 'BallBuster.HitWorld'
SWEP.HitSoundsFleshScript = 'BallBuster.HitFlesh'
SWEP.BallIsReady = function(self)
  return self:GetBallReady() >= self.BallRestoreTime
end
SWEP.CheckAnimations = function(self)
  if self:BallIsReady() then
    self.DrawAnimation = self.Avaliable_DrawAnimation
    self.IdleAnimation = self.Avaliable_IdleAnimation
    self.AttackAnimation = self.Avaliable_AttackAnimation
    self.AttackAnimationTable = self.Avaliable_AttackAnimationTable
    self.AttackAnimationCrit = self.Avaliable_AttackAnimationCrit
  else
    self.DrawAnimation = self.Unavaliable_DrawAnimation
    self.IdleAnimation = self.Unavaliable_IdleAnimation
    self.AttackAnimation = self.Unavaliable_AttackAnimation
    self.AttackAnimationTable = self.Unavaliable_AttackAnimationTable
    self.AttackAnimationCrit = self.Unavaliable_AttackAnimationCrit
  end
end
SWEP.Deploy = function(self)
  self.BaseClass.Deploy(self)
  return self:CheckAnimations()
end
SWEP.PostModelCreated = function(self, ...)
  self.BaseClass.PostModelCreated(self, ...)
  self.ballViewModel = ents.Create('dbot_tf_viewmodel')
  do
    local _with_0 = self.ballViewModel
    _with_0:SetModel(self.BallModel)
    _with_0:SetPos(self:GetPos())
    _with_0:Spawn()
    _with_0:Activate()
    _with_0:DoSetup(self)
  end
  return self:SetTF2BallModel(self.ballViewModel)
end
SWEP.PostDrawViewModel = function(self, ...)
  self.BaseClass.PostDrawViewModel(self, ...)
  if not IsValid(self:GetTF2BallModel()) then
    return 
  end
  return self:GetTF2BallModel():DrawModel()
end
SWEP.SetupDataTables = function(self)
  self.BaseClass.SetupDataTables(self)
  self:NetworkVar('Float', 16, 'BallReady')
  return self:NetworkVar('Entity', 16, 'TF2BallModel')
end
SWEP.Initialize = function(self)
  self.BaseClass.Initialize(self)
  self:SetBallReady(self.BallRestoreTime)
  self.lastBallThink = CurTime()
  self.lastBallStatus = true
end
SWEP.Think = function(self)
  self.BaseClass.Think(self)
  if SERVER then
    local delta = CurTime() - self.lastBallThink
    self.lastBallThink = CurTime()
    if self:GetBallReady() < self.BallRestoreTime then
      self:SetBallReady(math.Clamp(self:GetBallReady() + delta, 0, self.BallRestoreTime))
    end
  end
  local old = self.lastBallStatus
  local newStatus = self:BallIsReady()
  if old ~= newStatus then
    self.lastBallStatus = newStatus
    self:CheckAnimations()
    return self:SendWeaponSequence(self.IdleAnimation)
  end
end
SWEP.DrawHUD = function(self)
  return DTF2.DrawCenteredBar(self:GetBallReady() / self.BallRestoreTime, 'Ball')
end
SWEP.SecondaryAttack = function(self)
  if not self:BallIsReady() then
    return false
  end
  local incomingCrit = self:CheckNextCrit()
  self:SetBallReady(0)
  self.lastBallStatus = false
  self:SendWeaponSequence(self.BallThrowAnimation)
  self:CheckAnimations()
  self:WaitForSequence(self.IdleAnimation, self.BallThrowAnimationTime)
  self:WaitForSoundSuppress(self.BallThrowSound, self.BallThrowSoundTime)
  if CLIENT then
    return 
  end
  return timer.Simple(0, function()
    if not IsValid(self) or not IsValid(self:GetOwner()) then
      return 
    end
    local ballEntity = ents.Create('dbot_ball_projective')
    ballEntity:SetPos(self:GetOwner():EyePos())
    ballEntity:Spawn()
    ballEntity:Activate()
    ballEntity:SetIsCritical(incomingCrit)
    ballEntity:SetAttacker(self:GetOwner())
    ballEntity:SetInflictor(self)
    return ballEntity:SetDirection(self:GetOwner():GetAimVector())
  end)
end
