local BaseClass = baseclass.Get('dbot_tf_weapon_base')
SWEP.Base = 'dbot_tf_weapon_base'
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
SWEP.PreFire = 0.24
SWEP.BulletRange = 78
SWEP.BulletDamage = 65
SWEP.BulletForce = 20
SWEP.AttackAnimation = ACT_VM_HITCENTER
SWEP.AttackAnimationCrit = ACT_VM_SWINGHARD
SWEP.BulletHull = 8
SWEP.PlayMissSound = function(self)
  if not self.icomingCrit then
    if self.MissSoundsScript then
      return self:EmitSound(self.MissSoundsScript)
    end
    local playSound = table.Random(self.MissSounds)
    if playSound then
      return self:EmitSound(playSound, 50, 100, 1, CHAN_WEAPON)
    end
  else
    if self.MissCritSoundsScript then
      return self:EmitSound(self.MissCritSoundsScript)
    end
    local playSound = table.Random(self.MissSoundsCrit)
    if playSound then
      return self:EmitSound(playSound, 50, 100, 1, CHAN_WEAPON)
    end
  end
end
SWEP.PlayHitSound = function(self)
  if self.HitSoundsScript then
    return self:EmitSound(self.HitSoundsScript)
  end
  local playSound = table.Random(self.HitSounds)
  if playSound then
    return self:EmitSound(playSound, 50, 100, 1, CHAN_WEAPON)
  end
end
SWEP.PlayFleshHitSound = function(self)
  if self.HitSoundsFleshScript then
    return self:EmitSound(self.HitSoundsFleshScript)
  end
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
  BaseClass.OnHit(self, hitEntity, tr, dmginfo)
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
