local BaseClass = baseclass.Get('weapon_base')
SWEP.Base = 'weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'TF2 Weapon Base'
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.UseHands = false
SWEP.DrawCrosshair = true
SWEP.IsTF2Weapon = true
SWEP.DamageDegradation = true
SWEP.DrawTime = 0.66
SWEP.DrawTimeAnimation = 1.16
SWEP.PreFire = 0
SWEP.CooldownTime = 0.8
SWEP.BulletRange = 32000
SWEP.BulletDamage = 65
SWEP.BulletForce = 1
SWEP.BulletHull = 1
SWEP.ViewModel = 'models/weapons/c_models/c_engineer_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_wrench/c_wrench.mdl'
SWEP.DrawAnimation = 'fj_draw'
SWEP.IdleAnimation = 'fj_idle'
SWEP.AttackAnimation = 'fj_fire'
SWEP.AttackAnimationCrit = 'fj_fire'
SWEP.CritChance = 4
SWEP.CritExponent = 0.1
SWEP.CritExponentMax = 12
SWEP.SingleCrit = true
SWEP.CritDuration = 4
SWEP.CritsCooldown = 2
SWEP.CritsCheckCooldown = 0
SWEP.SetupDataTables = function(self)
  self:NetworkVar('Bool', 0, 'NextCrit')
  self:NetworkVar('Bool', 1, 'CritBoosted')
  self:NetworkVar('Bool', 2, 'TeamType')
  self:NetworkVar('Float', 0, 'CriticalsDuration')
  return self:NetworkVar('Entity', 0, 'TF2WeaponModel')
end
SWEP.CheckNextCrit = function(self)
  if self:GetCritBoosted() then
    return true
  end
  if self:GetNextCrit() then
    if self.SingleCrit then
      self:SetNextCrit(false)
    end
    return true
  end
  if SERVER then
    self:CheckCritical()
  end
  return false
end
SWEP.CheckNextMiniCrit = function(self)
  return self:GetOwner():GetMiniCritBoosted()
end
SWEP.Initialize = function(self)
  self:SetPlaybackRate(0.5)
  self:SendWeaponSequence(self.IdleAnimation)
  self.incomingFire = false
  self.incomingFireTime = 0
  self.damageDealtForCrit = 0
  self.lastCritsTrigger = 0
  self.lastCritsCheck = 0
  self.incomingCrit = false
  self.incomingMiniCrit = false
end
SWEP.WaitForAnimation = function(self, anim, time, callback)
  if anim == nil then
    anim = ACT_VM_IDLE
  end
  if time == nil then
    time = 0
  end
  if callback == nil then
    callback = (function() end)
  end
  return timer.Create("DTF2.WeaponAnim." .. tostring(self:EntIndex()), time, 1, function()
    if not IsValid(self) then
      return 
    end
    if not IsValid(self:GetOwner()) then
      return 
    end
    if self:GetOwner():GetActiveWeapon() ~= self then
      return 
    end
    self:SendWeaponAnim(anim)
    return callback()
  end)
end
SWEP.WaitForAnimation2 = function(self, anim, time, callback)
  if anim == nil then
    anim = ACT_VM_IDLE
  end
  if time == nil then
    time = 0
  end
  if callback == nil then
    callback = (function() end)
  end
  return timer.Create("DTF2.WeaponAnim." .. tostring(self:EntIndex()), time, 1, function()
    if not IsValid(self) then
      return 
    end
    if not IsValid(self:GetOwner()) then
      return 
    end
    if self:GetOwner():GetActiveWeapon() ~= self then
      return 
    end
    self:SendWeaponAnim2(anim)
    return callback()
  end)
end
SWEP.WaitForSequence = function(self, anim, time, callback)
  if anim == nil then
    anim = 0
  end
  if time == nil then
    time = 0
  end
  if callback == nil then
    callback = (function() end)
  end
  return timer.Create("DTF2.WeaponAnim." .. tostring(self:EntIndex()), time, 1, function()
    if not IsValid(self) then
      return 
    end
    if not IsValid(self:GetOwner()) then
      return 
    end
    if self:GetOwner():GetActiveWeapon() ~= self then
      return 
    end
    self:SendWeaponSequence(anim)
    return callback()
  end)
end
SWEP.ClearTimeredAnimation = function(self)
  return timer.Remove("DTF2.WeaponAnim." .. tostring(self:EntIndex()))
end
SWEP.CreateWeaponModel = function(self)
  if IsValid(self.weaponModel) then
    self:SetTF2WeaponModel(self.weaponModel)
    return self.weaponModel
  end
  if CLIENT or IsValid(self:GetTF2WeaponModel()) then
    return self:GetTF2WeaponModel()
  end
  self.weaponViewModel = ents.Create('dbot_tf_viewmodel')
  do
    local _with_0 = self.weaponViewModel
    _with_0:SetModel(self.WorldModel)
    _with_0:SetPos(self:GetPos())
    _with_0:Spawn()
    _with_0:Activate()
    _with_0:DoSetup(self)
    print(self.WorldModel)
  end
  self:SetTF2WeaponModel(self.weaponViewModel)
  return self.weaponViewModel
end
SWEP.Deploy = function(self)
  self:SendWeaponSequence(self.DrawAnimation)
  self:WaitForSequence(self.IdleAnimation, self.DrawTimeAnimation)
  self:SetNextPrimaryFire(CurTime() + self.DrawTime)
  self.incomingFire = false
  if SERVER and self:GetOwner():IsPlayer() then
    self:CreateWeaponModel()
  end
  return true
end
SWEP.Holster = function(self)
  if self:GetNextPrimaryFire() < CurTime() then
    if self.critBoostSound then
      self.critBoostSound:Stop()
      self.critBoostSound = nil
    end
    if self.critEffect then
      self.critEffect:StopEmissionAndDestroyImmediately()
      self.critEffect = nil
    end
    if self.critEffectGlow then
      self.critEffectGlow:StopEmissionAndDestroyImmediately()
      self.critEffectGlow = nil
    end
    return true
  end
  return false
end
SWEP.OnMiss = function(self) end
SWEP.OnHit = function(self, hitEntity, tr, dmginfo)
  if hitEntity == nil then
    hitEntity = NULL
  end
  if tr == nil then
    tr = { }
  end
  if not self.incomingCrit and IsValid(hitEntity) then
    self.damageDealtForCrit = self.damageDealtForCrit + dmginfo:GetDamage()
  end
  if (self.incomingCrit or self.incomingMiniCrit) and IsValid(hitEntity) then
    local mins, maxs = hitEntity:GetRotatedAABB(hitEntity:OBBMins(), hitEntity:OBBMaxs())
    local pos = hitEntity:GetPos()
    local newZ = math.max(pos.z, pos.z + mins.z, pos.z + maxs.z)
    pos.z = newZ
    local effData = EffectData()
    effData:SetOrigin(pos)
    util.Effect(self.incomingCrit and 'dtf2_critical_hit' or 'dtf2_minicrit', effData)
    hitEntity:EmitSound(self.incomingCrit and 'TFPlayer.CritHit' or 'TFPlayer.CritHitMini')
  end
  if self.DamageDegradation and not self.incomingCrit then
    local pos = tr.HitPos
    local lpos = self:GetOwner():GetPos()
    local dist = pos:DistToSqr(lpos) * 4
    return dmginfo:ScaleDamage(math.Clamp(dist / 180, 0.2, 1.2))
  end
end
SWEP.BulletCallback = function(self, tr, dmginfo)
  if tr == nil then
    tr = { }
  end
  local weapon = self:GetActiveWeapon()
  weapon.bulletCallbackCalled = true
  if tr.Hit then
    return weapon:OnHit(tr.Entity, tr, dmginfo)
  else
    return weapon:OnMiss(tr, dmginfo)
  end
end
SWEP.UpdateBulletData = function(self, bulletData)
  if bulletData == nil then
    bulletData = { }
  end
end
SWEP.AfterFire = function(self, bulletData)
  if bulletData == nil then
    bulletData = { }
  end
end
SWEP.FireTrigger = function(self)
  self.suppressing = true
  if SERVER and self:GetOwner():IsPlayer() then
    SuppressHostEvents(self:GetOwner())
  end
  self.incomingFire = false
  self.bulletCallbackCalled = false
  local bulletData = {
    ['Damage'] = self.BulletDamage * (self.incomingCrit and 3 or self.incomingMiniCrit and 1.3 or 1),
    ['Attacker'] = self:GetOwner(),
    ['Callback'] = self.BulletCallback,
    ['Src'] = self:GetOwner():EyePos(),
    ['Dir'] = self:GetOwner():GetAimVector(),
    ['Distance'] = self.BulletRange,
    ['HullSize'] = self.BulletHull,
    ['Force'] = self.BulletForce
  }
  self:UpdateBulletData(bulletData)
  self:FireBullets(bulletData)
  self:AfterFire(bulletData)
  if not self.bulletCallbackCalled then
    self:OnMiss()
  end
  if SERVER then
    SuppressHostEvents(NULL)
  end
  self.incomingCrit = false
  self.incomingMiniCrit = false
  self.suppressing = false
end
SWEP.Think = function(self)
  if self.incomingFire and self.incomingFireTime < CurTime() then
    self:FireTrigger()
  end
  if CLIENT then
    if self:GetCritBoosted() then
      if not self.critBoostSound then
        self.critBoostSound = CreateSound(self, 'Weapon_General.CritPower')
        self.critBoostSound:Play()
      end
      if self:GetOwner() == LocalPlayer() then
        if not self.critEffect then
          self.critEffect = CreateParticleSystem(self:GetOwner():GetViewModel(), self:GetTeamType() and 'critgun_weaponmodel_blu' or 'critgun_weaponmodel_red', PATTACH_ABSORIGIN_FOLLOW, 0, Vector(0, 0, 0))
        end
        if not self.critEffectGlow then
          self.critEffectGlow = CreateParticleSystem(self:GetOwner():GetViewModel(), self:GetTeamType() and 'critgun_weaponmodel_blu_glow' or 'critgun_weaponmodel_red_glow', PATTACH_ABSORIGIN_FOLLOW, 0, Vector(0, 0, 0))
        end
      end
    else
      if self.critBoostSound then
        self.critBoostSound:Stop()
        self.critBoostSound = nil
      end
      if self.critEffect then
        self.critEffect:StopEmissionAndDestroyImmediately()
        self.critEffect = nil
      end
      if self.critEffectGlow then
        self.critEffectGlow:StopEmissionAndDestroyImmediately()
        self.critEffectGlow = nil
      end
    end
  end
end
SWEP.PrimaryAttack = function(self)
  if self:GetNextPrimaryFire() > CurTime() then
    return false
  end
  self.incomingCrit = self:CheckNextCrit()
  if not self.incomingCrit then
    self.incomingMiniCrit = self:CheckNextMiniCrit()
  end
  self:SetNextPrimaryFire(CurTime() + self.CooldownTime)
  if not self.incomingCrit then
    self:SendWeaponSequence(self.AttackAnimationTable and DTF2.TableRandom(self.AttackAnimationTable) or self.AttackAnimation)
  end
  if self.incomingCrit then
    self:SendWeaponSequence(self.AttackAnimationCritTable and DTF2.TableRandom(self.AttackAnimationCritTable) or self.AttackAnimationCrit)
  end
  self:WaitForSequence(self.IdleAnimation, self.CooldownTime)
  self.incomingFire = true
  self.incomingFireTime = CurTime() + self.PreFire
  self:NextThink(self.incomingFireTime)
  return true
end
SWEP.SecondaryAttack = function(self)
  return false
end
