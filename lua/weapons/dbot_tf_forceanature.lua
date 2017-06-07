AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_ranged')
SWEP.Base = 'dbot_tf_ranged'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Force-A-Nature'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_double_barrel.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false
SWEP.SingleCrit = true
SWEP.MuzzleAttachment = 'muzzle'
SWEP.BulletDamage = 5.4
SWEP.BulletsAmount = 12
SWEP.ReloadBullets = 2
SWEP.DefaultSpread = Vector(1, 1, 0) * 0.07
SWEP.DefaultViewPunch = Angle(-5, 0, 0)
SWEP.FireSoundsScript = 'Weapon_Scatter_Gun_Double.Single'
SWEP.FireCritSoundsScript = 'Weapon_Scatter_Gun_Double.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_Scatter_Gun_Double.Empty'
SWEP.Primary = {
  ['Ammo'] = 'Buckshot',
  ['ClipSize'] = 2,
  ['DefaultClip'] = 2,
  ['Automatic'] = true
}
SWEP.Think = function(self)
  return BaseClass.Think(self)
end
SWEP.CooldownTime = 0.3
SWEP.ReloadDeployTime = 1.4
SWEP.DrawAnimation = 'db_draw'
SWEP.IdleAnimation = 'db_idle'
SWEP.AttackAnimation = 'db_fire'
SWEP.AttackAnimationCrit = 'db_fire'
SWEP.ReloadStart = 'db_reload'
SWEP.SingleReloadAnimation = true
SWEP.SetupDataTables = function(self)
  return BaseClass.SetupDataTables(self)
end
SWEP.AfterFire = function(self, bulletData)
  BaseClass.AfterFire(bulletData)
  local Dir = bulletData.Dir
  if not self:GetOwner():OnGround() then
    return DTF2.ApplyVelocity(self:GetOwner(), -Dir * 300)
  end
end
SWEP.OnHit = function(self, ent, ...)
  BaseClass.OnHit(self, ent, ...)
  if SERVER and IsValid(ent) then
    local pos = ent:GetPos()
    local lpos = self:GetOwner():GetPos()
    local dir = pos - lpos
    dir:Normalize()
    local vel = dir * 200 + Vector(0, 0, 30)
    vel = vel * (10000 / pos:DistToSqr(lpos))
    return DTF2.ApplyVelocity(ent, vel)
  end
end
SWEP.ReloadCall = function(self)
  local oldClip = self:Clip1()
  local newClip = 2
  if SERVER then
    self:SetClip1(2)
    if self:GetOwner():IsPlayer() then
      self:GetOwner():RemoveAmmo(2, self.Primary.Ammo)
    end
  end
  return oldClip, newClip
end
