AddCSLuaFile()
SWEP.Base = 'dbot_tf_melee'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Engineer'
SWEP.PrintName = 'Wrench'
SWEP.ViewModel = 'models/weapons/c_models/c_engineer_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_wrench/c_wrench.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.DrawAnimation = 'pdq_draw'
SWEP.IdleAnimation = 'pdq_idle_tap'
SWEP.AttackAnimation = 'pdq_swing_a'
SWEP.AttackAnimationTable = {
  'pdq_swing_a',
  'pdq_swing_b'
}
SWEP.AttackAnimationCrit = 'pdq_swing_c'
SWEP.MissSoundsScript = 'Weapon_Wrench.Miss'
SWEP.MissCritSoundsScript = 'Weapon_Wrench.MissCrit'
SWEP.HitSoundsScript = 'Weapon_Wrench.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_Wrench.HitFlesh'
SWEP.DrawHUD = function(self)
  return DTF2.DrawMetalCounter()
end
SWEP.OnHit = function(self, hitEntity, tr, dmginfo)
  if hitEntity == nil then
    hitEntity = NULL
  end
  if tr == nil then
    tr = { }
  end
  if not hitEntity.IsTF2Building then
    return self.BaseClass.OnHit(self, hitEntity, tr, dmginfo)
  end
  if CLIENT then
    return 
  end
  if not hitEntity:IsAlly(self:GetOwner()) then
    if self.suppressing then
      SuppressHostEvents(NULL)
    end
    self.BaseClass.OnHit(self, hitEntity, tr, dmginfo)
    if self.suppressing then
      SuppressHostEvents(self:GetOwner())
    end
    return 
  end
  dmginfo:SetDamage(0)
  dmginfo:SetDamageType(0)
  local amount = hitEntity:SimulateRepair(self:GetOwner():GetTF2Metal())
  if amount > 0 then
    self:GetOwner():SimulateTF2MetalRemove(amount)
    return self:EmitSoundServerside('Weapon_Wrench.HitBuilding_Success')
  else
    return self:EmitSoundServerside('Weapon_Wrench.HitBuilding_Failure')
  end
end
