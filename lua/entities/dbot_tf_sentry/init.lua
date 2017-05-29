include('shared.lua')
AddCSLuaFile('shared.lua')
util.AddNetworkString('DTF2.SentryWing')
util.AddNetworkString('DTF2.SentryFire')
ENT.MAX_DISTANCE = 512 ^ 2
ENT.Initialize = function(self)
  self.BaseClass.Initialize(self)
  self.targetAngle = Angle(0, 0, 0)
  self.currentAngle = Angle(0, 0, 0)
  self.moveSpeed = 2
  self.idleAnim = true
  self.idleAngle = Angle(0, 0, 0)
  self.idleDirection = false
  self.idleYaw = 0
  self.currentTarget = NULL
  self.idleWaitOnAngle = 0
  self.lastSentryThink = CurTime()
  self.nextTargetUpdate = 0
  self.lastBulletFire = 0
  self.waitSequenceReset = 0
  self:SetAmmoAmount(self.MAX_AMMO_1)
  self:SetHealth(self.HealthLevel1)
  self:SetMaxHealth(self.HealthLevel1)
  self.fireNext = 0
  self.behavePause = 0
  self.nextPoseUpdate = 0
  self.muzzle = 0
  self.muzzle_l = 0
  self.muzzle_r = 0
  self.nextMuzzle = false
  return self:UpdateSequenceList()
end
ENT.HULL_SIZE = 2
ENT.HULL_TRACE_MINS = Vector(-ENT.HULL_SIZE, -ENT.HULL_SIZE, -ENT.HULL_SIZE)
ENT.HULL_TRACE_MAXS = Vector(ENT.HULL_SIZE, ENT.HULL_SIZE, ENT.HULL_SIZE)
ENT.UpdateSequenceList = function(self)
  self.BaseClass.UpdateSequenceList(self)
  self.fireSequence = self:LookupSequence('fire')
  self.muzzle = self:LookupAttachment('muzzle')
  self.muzzle_l = self:LookupAttachment('muzzle_l')
  self.muzzle_r = self:LookupAttachment('muzzle_r')
end
ENT.PlayScanSound = function(self)
  local _exp_0 = self:GetLevel()
  if 1 == _exp_0 then
    return self:EmitSound('weapons/sentry_scan.wav')
  elseif 2 == _exp_0 then
    return self:EmitSound('weapons/sentry_scan2.wav')
  elseif 3 == _exp_0 then
    return self:EmitSound('weapons/sentry_scan3.wav')
  end
end
ENT.BulletHit = function(self, tr, dmg)
  return dmg:SetDamage(self.BULLET_DAMAGE)
end
ENT.FireBullet = function(self, force)
  if force == nil then
    force = false
  end
  if self.lastBulletFire > CurTime() and not force then
    return false
  end
  local _exp_0 = self:GetLevel()
  if 1 == _exp_0 then
    self.lastBulletFire = CurTime() + self.BULLET_RELOAD_1
  elseif 2 == _exp_0 then
    self.lastBulletFire = CurTime() + self.BULLET_RELOAD_2
  elseif 3 == _exp_0 then
    self.lastBulletFire = CurTime() + self.BULLET_RELOAD_3
  end
  if self:GetAmmoAmount() <= 0 and not force then
    self:EmitSound('weapons/sentry_empty.wav')
    net.Start('DTF2.SentryFire', true)
    net.WriteEntity(self)
    net.WriteBool(false)
    net.Broadcast()
    return false
  end
  self:SetAmmoAmount(self:GetAmmoAmount() - 1)
  self:EmitSound('weapons/sentry_shoot.wav')
  self:SetPoseParameter('aim_pitch', self:GetAimPitch())
  self:SetPoseParameter('aim_yaw', self:GetAimYaw())
  local srcPos = self:GetPos()
  local _exp_1 = self:GetLevel()
  if 1 == _exp_1 then
    srcPos = srcPos + Vector(0, 0, 16)
  end
  local bulletData = {
    Attacker = self,
    Callback = self.BulletHit,
    Damage = self.BULLET_DAMAGE,
    Dir = self.currentAngle:Forward(),
    Src = srcPos
  }
  self:FireBullets(bulletData)
  net.Start('DTF2.SentryFire', true)
  net.WriteEntity(self)
  net.WriteBool(true)
  net.Broadcast()
  return true
end
ENT.BehaveUpdate = function(self, delta)
  local cTime = CurTime()
  if self.behavePause > cTime then
    return 
  end
  if not self:IsAvaliable() then
    self.currentTarget = NULL
    return 
  end
  local newTarget = self:GetFirstVisible()
  if newTarget ~= self.currentTarget then
    self.currentTarget = newTarget
    if IsValid(newTarget) then
      net.Start('DTF2.SentryWing', true)
      net.WriteEntity(self)
      net.WriteEntity(newTarget)
      net.Broadcast()
    end
  end
  if IsValid(self.currentTarget) then
    self.currentTargetPosition = self.currentTarget:GetPos() + self.currentTarget:OBBCenter()
    self.idleWaitOnAngle = cTime + 6
    self.targetAngle = (self.currentTargetPosition - self:GetPos() - self.obbcenter):Angle()
    self.idleAngle = self.targetAngle
    self.idleAnim = false
    self.idleDirection = false
    self.idleYaw = 0
  else
    self.idleAnim = true
    if self.idleWaitOnAngle < cTime then
      self.idleAngle = self:GetAngles()
    end
    if self.idleDirection then
      self.idleYaw = self.idleYaw + (delta * self.SENTRY_SCAN_YAW_MULT)
    end
    if not self.idleDirection then
      self.idleYaw = self.idleYaw - (delta * self.SENTRY_SCAN_YAW_MULT)
    end
    if self.idleYaw > self.SENTRY_SCAN_YAW_CONST or self.idleYaw < -self.SENTRY_SCAN_YAW_CONST then
      self.idleDirection = not self.idleDirection
      self:PlayScanSound()
    end
    local p, y, r
    do
      local _obj_0 = self.idleAngle
      p, y, r = _obj_0.p, _obj_0.y, _obj_0.r
    end
    self.targetAngle = Angle(p, y + self.idleYaw, r)
  end
end
ENT.RunBehaviour = function(self) end
ENT.GetEnemy = function(self)
  return self.currentTarget
end
ENT.Explode = function(self)
  return self:Remove()
end
ENT.OnInjured = function(self, dmg) end
ENT.OnKilled = function(self, dmg)
  hook.Run('OnNPCKilled', self, dmg:GetAttacker(), dmg:GetInflictor())
  return self:Explode()
end
ENT.Think = function(self)
  local cTime = CurTime()
  if self.behavePause > cTime then
    return 
  end
  local delta = cTime - self.lastSentryThink
  self.lastSentryThink = cTime
  self.BaseClass.Think(self)
  if not self:IsAvaliable() then
    self.currentTarget = NULL
    return 
  end
  local diffPitch = math.Clamp(math.AngleDifference(self.currentAngle.p, self.targetAngle.p), -2, 2)
  local diffYaw = math.Clamp(math.AngleDifference(self.currentAngle.y, self.targetAngle.y), -2, 2)
  local newPitch = self.currentAngle.p - diffPitch * delta * self.SENTRY_ANGLE_CHANGE_MULT
  local newYaw = self.currentAngle.y - diffYaw * delta * self.SENTRY_ANGLE_CHANGE_MULT
  self.currentAngle = Angle(newPitch, newYaw, 0)
  local cp, cy, cr
  do
    local _obj_0 = self:GetAngles()
    cp, cy, cr = _obj_0.p, _obj_0.y, _obj_0.r
  end
  local posePitch = math.floor(math.NormalizeAngle(cp - newPitch))
  local poseYaw = math.floor(math.NormalizeAngle(cy - newYaw))
  self:SetAimPitch(posePitch)
  self:SetAimYaw(poseYaw)
  if self.nextPoseUpdate < cTime then
    self.nextPoseUpdate = cTime + 0.5
    self:SetPoseParameter('aim_pitch', self:GetAimPitch())
    self:SetPoseParameter('aim_yaw', self:GetAimYaw())
  end
  if IsValid(self.currentTarget) then
    local lookingAtTarget = diffPitch ~= -2 and diffPitch ~= 2 and diffYaw ~= -2 and diffYaw ~= 2
    if lookingAtTarget then
      return self:FireBullet()
    end
  end
end
