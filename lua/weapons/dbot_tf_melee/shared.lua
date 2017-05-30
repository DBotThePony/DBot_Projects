SWEP.Base = 'weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'TF2 Melee Base'
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.SlotPos = 16
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
SWEP.DrawTime = 0.66
SWEP.DrawTimeAnimation = 1.16
SWEP.PreSwing = 0.24
SWEP.ReloadTime = 0.96
SWEP.MeleeRange = 78
SWEP.MeleeDamage = 65
SWEP.Initialize = function(self)
  self:SetPlaybackRate(0.5)
  self:SendWeaponAnim(ACT_VM_IDLE)
  self.incomingHit = false
  self.incomingHitTime = 0
end
SWEP.WaitForAnimation = function(self, anim, time)
  if anim == nil then
    anim = ACT_VM_IDLE
  end
  if time == nil then
    time = 0
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
    return self:SendWeaponAnim(anim)
  end)
end
SWEP.Deploy = function(self)
  self:SendWeaponAnim(ACT_VM_DRAW)
  self:WaitForAnimation(ACT_VM_IDLE, self.DrawTimeAnimation)
  self:SetNextPrimaryFire(CurTime() + self.DrawTime)
  self.incomingHit = false
  return true
end
SWEP.Holster = function(self)
  return self:GetNextPrimaryFire() < CurTime()
end
SWEP.PlayMissSound = function(self)
  local playSound = table.Random(self.MissSounds)
  if playSound then
    return self:EmitSound(playSound, 50, 100, 1, CHAN_WEAPON)
  end
end
SWEP.PlayHitSound = function(self)
  local playSound = table.Random(self.HitSounds)
  if playSound then
    return self:EmitSound(playSound, 50, 100, 1, CHAN_WEAPON)
  end
end
SWEP.PlayFleshHitSound = function(self)
  local playSound = table.Random(self.HitSoundsFlesh)
  if playSound then
    return self:EmitSound(playSound, 75, 100, 1, CHAN_WEAPON)
  end
end
SWEP.OnMiss = function(self)
  return self:PlayMissSound()
end
SWEP.OnHit = function(self, hitEntity, tr, dmginfo)
  if hitEntity == nil then
    hitEntity = NULL
  end
  if tr == nil then
    tr = { }
  end
  if not IsValid(hitEntity) then
    self:PlayHitSound()
  end
  if IsValid(hitEntity) and (hitEntity:IsPlayer() or hitEntity:IsNPC()) then
    self:PlayFleshHitSound()
  end
  return dmginfo:SetDamageType(DMG_CLUB)
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
SWEP.Think = function(self)
  if self.incomingHit and self.incomingHitTime < CurTime() then
    self.suppressing = true
    if SERVER and self:GetOwner():IsPlayer() then
      SuppressHostEvents(self:GetOwner())
    end
    self.incomingHit = false
    self.bulletCallbackCalled = false
    local bulletData = {
      ['Damage'] = self.MeleeDamage,
      ['Attacker'] = self:GetOwner(),
      ['Callback'] = self.BulletCallback,
      ['Src'] = self:GetOwner():EyePos(),
      ['Dir'] = self:GetOwner():GetAimVector(),
      ['Distance'] = self.MeleeRange,
      ['HullSize'] = 8
    }
    self:FireBullets(bulletData)
    if not self.bulletCallbackCalled then
      self:OnMiss()
    end
    if SERVER then
      SuppressHostEvents(NULL)
    end
    self.suppressing = false
  end
end
SWEP.PrimaryAttack = function(self)
  self:SetNextPrimaryFire(CurTime() + self.ReloadTime)
  self:SendWeaponAnim(ACT_VM_SWINGHARD)
  self:WaitForAnimation(ACT_VM_IDLE, self.ReloadTime)
  self.incomingHit = true
  self.incomingHitTime = CurTime() + self.PreSwing
  self:NextThink(self.incomingHitTime)
  return true
end
SWEP.SecondaryAttack = function(self)
  return false
end
