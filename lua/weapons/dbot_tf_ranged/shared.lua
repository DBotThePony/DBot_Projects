local BaseClass = baseclass.Get('dbot_tf_weapon_base')
SWEP.Base = 'dbot_tf_weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'TF2 Melee Base'
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.Slot = 2
SWEP.SlotPos = 16
SWEP.Primary = {
  ['Ammo'] = 'SMG1',
  ['ClipSize'] = 15,
  ['DefaultClip'] = 15,
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
SWEP.PreFire = 0.05
SWEP.ReloadDeployTime = 0.4
SWEP.ReloadTime = 0.5
SWEP.ReloadFinishAnimTime = 0.3
SWEP.ReloadFinishAnimTimeIdle = 0.96
SWEP.ReloadBullets = 15
SWEP.TakeBulletsOnFire = 1
SWEP.CooldownTime = 0.7
SWEP.BulletDamage = 12
SWEP.DefaultSpread = Vector(0, 0, 0)
SWEP.BulletsAmount = 1
SWEP.MuzzleAttachment = 'muzzle'
SWEP.MuzzleEffect = 'muzzle_shotgun'
SWEP.Reloadable = true
SWEP.Initialize = function(self)
  self.isReloading = false
  self.reloadNext = 0
end
SWEP.Reload = function(self)
  if not self.Reloadable then
    return false
  end
  if self:Clip1() == self:GetMaxClip1() then
    return false
  end
  if self.isReloading then
    return false
  end
  if self:GetNextPrimaryFire() > CurTime() then
    return false
  end
  if self:GetOwner():IsPlayer() and self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 then
    return false
  end
  self.isReloading = true
  self.reloadNext = CurTime() + self.ReloadDeployTime
  self:SendWeaponAnim(ACT_RELOAD_START)
  self:ClearTimeredAnimation()
  return true
end
SWEP.GetBulletSpread = function(self)
  return self.DefaultSpread
end
SWEP.GetBulletAmount = function(self)
  return self.BulletsAmount
end
SWEP.UpdateBulletData = function(self, bulletData)
  if bulletData == nil then
    bulletData = { }
  end
  bulletData.Spread = self:GetBulletSpread()
  bulletData.Num = self:GetBulletAmount()
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
SWEP.PlayFireSound = function(self)
  local playSound
  if self.FireSounds then
    playSound = table.Random(self.FireSounds)
  end
  if playSound then
    return self:EmitSound(playSound, SNDLVL_GUNSHOT, 100, .7, CHAN_WEAPON)
  end
end
SWEP.PrimaryAttack = function(self)
  if self:Clip1() <= 0 then
    self:Reload()
    return false
  end
  self.isReloading = false
  self:TakePrimaryAmmo(self.TakeBulletsOnFire)
  self:PlayFireSound()
  if CLIENT and self:GetOwner() == LocalPlayer() then
    self:GetOwner():GetViewModel():CreateParticleEffect(self.MuzzleEffect, self:LookupAttachment(self.MuzzleAttachment))
  end
  return BaseClass.PrimaryAttack(self)
end
