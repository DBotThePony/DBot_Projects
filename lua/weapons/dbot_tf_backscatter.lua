AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_scattergun')
SWEP.Base = 'dbot_tf_scattergun'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Back Scatter'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/workshop/weapons/c_models/c_scatterdrum/c_scatterdrum.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.RandomCriticals = false
SWEP.DefaultSpread = Vector(1, 1, 0) * 0.055
SWEP.PreOnHit = function(self, hitEntity, tr, dmginfo)
  if hitEntity == nil then
    hitEntity = NULL
  end
  if tr == nil then
    tr = { }
  end
  if hitEntity:IsValid() and hitEntity:GetPos():Distance(self:GetOwner():GetPos()) < 500 and self:AttackingAtSpine(hitEntity) then
    return self:ThatWasMinicrit(hitEntity, dmginfo)
  end
end
SWEP.FireSoundsScript = 'Weapon_Back_Scatter.Single'
SWEP.FireCritSoundsScript = 'Weapon_Back_Scatter.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_Back_Scatter.Empty'
SWEP.Primary = {
  ['Ammo'] = 'Buckshot',
  ['ClipSize'] = 4,
  ['DefaultClip'] = 4,
  ['Automatic'] = true
}
