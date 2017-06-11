AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_bat')
SWEP.Base = 'dbot_tf_bat'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = "Fan O' War"
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_shogun_warfan/c_shogun_warfan.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.BulletDamage = 35 * .25
SWEP.PreOnHit = function(self, hitEntity, tr, dmginfo)
  if hitEntity == nil then
    hitEntity = NULL
  end
  if tr == nil then
    tr = { }
  end
  self.BaseClass.PreOnHit(self, hitEntity, tr, dmginfo)
  if IsValid(hitEntity) and hitEntity:IsMarkedForDeath() then
    self:ThatWasCrit(hitEntity, dmginfo)
  end
  if CLIENT then
    return 
  end
  if IsValid(hitEntity) and (hitEntity:IsNPC() or hitEntity:IsPlayer()) then
    if IsValid(self.deathMark) then
      if self.deathMark:GetOwner() ~= hitEntity then
        hitEntity:EmitSound('weapons/samurai/tf_marked_for_death_indicator.wav', 75, 100)
        self.deathMark:SetupOwner(hitEntity)
      end
      self.deathMark:UpdateDuration(15)
      return 
    end
    self.deathMark = ents.Create('dbot_tf_logic_mcreciever')
    do
      local _with_0 = self.deathMark
      _with_0:SetPos(tr.HitPos)
      _with_0:Spawn()
      _with_0:Activate()
      _with_0:SetupOwner(hitEntity)
      _with_0:UpdateDuration(15)
      _with_0:EmitSound('weapons/samurai/tf_marked_for_death_indicator.wav', 75, 100)
      return _with_0
    end
  end
end
