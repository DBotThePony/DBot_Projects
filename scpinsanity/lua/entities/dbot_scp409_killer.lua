ENT.PrintName = 'Crystalization'
ENT.Author = 'DBot'
ENT.Type = 'point'
local ents, IsValid, CurTime, math
do
  local _obj_0 = _G
  ents, IsValid, CurTime, math = _obj_0.ents, _obj_0.IsValid, _obj_0.CurTime, _obj_0.math
end
local _list_0 = ents.FindByClass('dbot_scp409_killer')
for _index_0 = 1, #_list_0 do
  local v = _list_0[_index_0]
  v:Remove()
end
local _list_1 = ents.FindByClass('dbot_scp409_fragment')
for _index_0 = 1, #_list_1 do
  local v = _list_1[_index_0]
  v:Remove()
end
ENT.Think = function(self)
  if CLIENT then
    return 
  end
  local obj = self:GetParent()
  if not IsValid(obj) then
    self:Remove()
    return 
  elseif obj:IsPlayer() and not obj:Alive() then
    self:objRemove()
    return 
  end
  local dmg = DamageInfo()
  dmg:SetDamage(math.max(10, obj:Health() * .1))
  dmg:SetAttacker(IsValid(self.Crystal) and self.Crystal or self)
  dmg:SetInflictor(self)
  dmg:SetDamageType(DMG_ACID)
  obj:TakeDamageInfo(dmg)
  if obj:IsPlayer() then
    obj:GodDisable()
  end
  self:NextThink(CurTime() + .3)
  return true
end
ENT.OnRemove = function(self)
  for i = 1, math.random(1, 4) do
    local ent = ents.Create('dbot_scp409_fragment')
    do
      ent:SetPos(self:GetPos())
      ent:Spawn()
      ent:Push()
      ent.Crystal = self.Crystal
    end
  end
  if not IsValid(self:GetParent()) then
    return 
  end
  self:GetParent().CRYSTALIZING = false
end
