AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_bat')
SWEP.Base = 'dbot_tf_bat'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Boston Basher'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_boston_basher/c_boston_basher.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.MissSoundsScript = 'BostonBasher.Impact'
SWEP.MissCritSoundsScript = 'BostonBasher.ImpactCrit'
SWEP.HitSoundsScript = 'BostonBasher.HitWorld'
SWEP.HitSoundsFleshScript = 'BostonBasher.Impact'
if SERVER then
  SWEP.OnMiss = function(self)
    self.BaseClass.OnMiss(self)
    local ent = self:GetOwner():TF2Bleed(5)
    ent:SetAttacker(self:GetOwner())
    return ent:SetInflictor(self)
  end
  SWEP.OnHit = function(self, hitEntity, ...)
    if hitEntity == nil then
      hitEntity = NULL
    end
    self.BaseClass.OnHit(self, hitEntity, ...)
    if IsValid(hitEntity) and (hitEntity:IsNPC() or hitEntity:IsPlayer()) then
      local ent = hitEntity:TF2Bleed(5)
      ent:SetAttacker(self:GetOwner())
      return ent:SetInflictor(self)
    end
  end
end
