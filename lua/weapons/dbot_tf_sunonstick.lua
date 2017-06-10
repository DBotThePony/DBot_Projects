AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_bat')
SWEP.Base = 'dbot_tf_bat'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Sun on a Stick'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_rift_fire_mace/c_rift_fire_mace.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.BulletDamage = 35 * .75
SWEP.PreOnHit = function(self, hitEntity, tr, dmginfo)
  if hitEntity == nil then
    hitEntity = NULL
  end
  if tr == nil then
    tr = { }
  end
  self.BaseClass.PreOnHit(self, hitEntity, tr, dmginfo)
  if IsValid(hitEntity) and hitEntity:IsTF2Burning() then
    return self:ThatWasCrit(hitEntity, dmginfo)
  end
end
if SERVER then
  return hook.Add('EntityTakeDamage', 'DTF2.SunOnAStick', function(ent, dmg)
    if not (ent:IsPlayer()) then
      return 
    end
    local wep = ent:GetWeapon('dbot_tf_sunonstick')
    if not IsValid(wep) then
      return 
    end
    return dmg:ScaleDamage(.75)
  end)
end
