local BaseClass = baseclass.Get('dbot_tf_weapon_base')
SWEP.Base = 'dbot_tf_weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'TF2 Projectiled Weapon Base'
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.SlotPos = 16
SWEP.DamageDegradation = false
SWEP.Slot = 3
SWEP.DefaultViewPunch = Angle(0, 0, 0)
SWEP.DrawAnimation = 'dh_draw'
SWEP.IdleAnimation = 'dh_idle'
SWEP.AttackAnimation = 'dh_fire'
SWEP.AttackAnimationCrit = 'dh_fire'
SWEP.ReloadStart = 'dh_reload_start'
SWEP.ReloadLoop = 'dh_reload_loop'
SWEP.ReloadEnd = 'dh_reload_end'
SWEP.TakeBulletsOnFire = 1
SWEP.ProjectileName = ''
SWEP.Initialize = function(self)
  BaseClass.Initialize(self)
  self.isReloading = false
  self.reloadNext = 0
end
SWEP.ReloadCall = function(self)
  local oldClip = self:Clip1()
  local newClip = math.Clamp(oldClip + self.ReloadBullets, 0, self:GetMaxClip1())
  if SERVER then
    self:SetClip1(newClip)
    if self:GetOwner():IsPlayer() then
      self:GetOwner():RemoveAmmo(newClip - oldClip, self.Primary.Ammo)
    end
  end
  return oldClip, newClip
end
SWEP.Think = function(self)
  BaseClass.Think(self)
  if self.isReloading and self.reloadNext < CurTime() then
    if self:GetOwner():IsPlayer() and self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0 then
      self.reloadNext = CurTime() + self.ReloadTime
      local oldClip, newClip = self:ReloadCall()
      if not self.SingleReloadAnimation then
        if self.ReloadLoopRestart then
          self:SendWeaponSequence(self.ReloadLoop)
        else
          if not self.reloadLoopStart then
            self:SendWeaponSequence(self.ReloadLoop)
          end
          self.reloadLoopStart = true
        end
      end
      if newClip == self:GetMaxClip1() then
        self.isReloading = false
        self.reloadLoopStart = false
        if not self.SingleReloadAnimation then
          self:WaitForSequence(self.ReloadEnd, self.ReloadFinishAnimTime, (function()
            if IsValid(self) then
              return self:WaitForSequence(self.IdleAnimation, self.ReloadFinishAnimTimeIdle)
            end
          end))
        end
        if self.SingleReloadAnimation then
          self:SendWeaponSequence(self.IdleAnimation, self.ReloadFinishAnimTimeIdle)
        end
      end
    elseif self:GetOwner():IsPlayer() and self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 or newClip == self:GetMaxClip1() then
      self.isReloading = false
      self.reloadLoopStart = false
      if not self.SingleReloadAnimation then
        self:WaitForSequence(self.ReloadEnd, self.ReloadFinishAnimTime, (function()
          if IsValid(self) then
            return self:WaitForSequence(self.IdleAnimation, self.ReloadFinishAnimTimeIdle)
          end
        end))
      end
      if self.SingleReloadAnimation then
        self:SendWeaponSequence(self.IdleAnimation, self.ReloadFinishAnimTimeIdle)
      end
    end
  end
  self:NextThink(CurTime() + 0.1)
  return true
end
SWEP.Deploy = function(self)
  BaseClass.Deploy(self)
  self.isReloading = false
  self.lastEmptySound = 0
  return true
end
SWEP.GetViewPunch = function(self)
  return self.DefaultViewPunch
end
SWEP.OnHit = function(self, ...)
  return BaseClass.OnHit(self, ...)
end
SWEP.OnMiss = function(self)
  return BaseClass.OnMiss(self)
end
SWEP.PlayFireSound = function(self, isCrit)
  if isCrit == nil then
    isCrit = self.incomingCrit
  end
  if not isCrit then
    if self.FireSoundsScript then
      return self:EmitSound('DTF2_' .. self.FireSoundsScript)
    end
    local playSound
    if self.FireSounds then
      playSound = table.Random(self.FireSounds)
    end
    if playSound then
      return self:EmitSound(playSound, SNDLVL_GUNSHOT, 100, .7, CHAN_WEAPON)
    end
  else
    if self.FireCritSoundsScript then
      return self:EmitSound('DTF2_' .. self.FireCritSoundsScript)
    end
    local playSound
    if self.FireCritSounds then
      playSound = table.Random(self.FireCritSounds)
    end
    if playSound then
      return self:EmitSound(playSound, SNDLVL_GUNSHOT, 100, .7, CHAN_WEAPON)
    end
  end
end
SWEP.EmitMuzzleFlash = function(self) end
SWEP.PrimaryAttack = function(self)
  if self:GetNextPrimaryFire() > CurTime() then
    return false
  end
  if self:Clip1() <= 0 then
    self:Reload()
    return false
  end
  local status = BaseClass.PrimaryAttack(self)
  if status == false then
    return status
  end
  self.isReloading = false
  self:TakePrimaryAmmo(self.TakeBulletsOnFire)
  self:PlayFireSound()
  self:GetOwner():ViewPunch(self:GetViewPunch())
  if game.SinglePlayer() and SERVER then
    self:CallOnClient('EmitMuzzleFlash')
  end
  if CLIENT and self:GetOwner() == LocalPlayer() and self.lastMuzzle ~= FrameNumber() then
    self.lastMuzzle = FrameNumber()
    self:EmitMuzzleFlash()
  end
  return true
end
