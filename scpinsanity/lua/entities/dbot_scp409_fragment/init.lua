AddCSLuaFile('cl_init.lua')
ENT.Type = 'anim'
ENT.PrintName = 'SCP-409 Fragment'
ENT.Author = 'DBot'
ENT.Base = 'dbot_scp409'
local CurTime, IsValid, math
do
  local _obj_0 = _G
  CurTime, IsValid, math = _obj_0.CurTime, _obj_0.IsValid, _obj_0.math
end
ENT.Initialize = function(self)
  self:SetModel('models/props_combine/breenbust_chunk03.mdl')
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self.Rem = CurTime() + 10
  self.phys = IsValid(self:GetPhysicsObject()) and self:GetPhysicsObject()
end
ENT.Push = function(self)
  if not self.phys then
    return 
  end
  self.phys:Wake()
  return self.phys:SetVelocity(VectorRand() * math.random(500, 5000))
end
ENT.Think = function(self)
  self.BaseClass.Think(self)
  if self.Rem < CurTime() then
    return self:Remove()
  end
end
ENT.Attack = function(self, ent)
  local point = self.BaseClass.Attack(self, ent)
  if not point then
    return 
  end
  point.Crystal = self.Crystal
  return point
end
