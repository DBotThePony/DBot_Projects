include('shared.lua')
AddCSLuaFile('cl_init.lua')
local IsValid, ents, SafeRemoveEntity
do
  local _obj_0 = _G
  IsValid, ents, SafeRemoveEntity = _obj_0.IsValid, _obj_0.ents, _obj_0.SafeRemoveEntity
end
ENT.PhysicsCollide = function(self, data)
  local ent = data.HitEntity
  if not IsValid(ent) then
    return 
  end
  return self:Attack(ent)
end
ENT.Initialize = function(self)
  self:SetModel('models/props_debris/barricade_short01a.mdl')
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  return self:SetMoveType(MOVETYPE_NONE)
end
ENT.Think = function(self)
  for k, v in pairs(ents.FindInSphere(self:GetPos(), 64)) do
    local _continue_0 = false
    repeat
      if IsValid(v:GetParent()) then
        _continue_0 = true
        break
      end
      if v == self then
        _continue_0 = true
        break
      end
      if v:Health() <= 0 then
        if v:GetClass() ~= 'prop_physics' then
          _continue_0 = true
          break
        end
        self:Attack(v)
        SafeRemoveEntity(v)
        _continue_0 = true
        break
      end
      self:Attack(v)
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
end
ENT.Attack = function(self, ent)
  if ent.CRYSTALIZING then
    return 
  end
  if ent:GetClass():find('scp') then
    return 
  end
  ent.CRYSTALIZING = true
  local point = ents.Create('dbot_scp409_killer')
  point:SetPos(ENT.GetPos())
  point:SetParent(ent)
  point:Spawn()
  point:Activate()
  point.Crystal = self
  return point
end
