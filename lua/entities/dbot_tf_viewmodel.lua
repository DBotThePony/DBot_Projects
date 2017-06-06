AddCSLuaFile()
ENT.PrintName = 'TF2 dumb model'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Type = 'anim'
ENT.RenderGroup = RENDERGROUP_OTHER
ENT.Initialize = function(self)
  self:SetNotSolid(true)
  self:DrawShadow(false)
  self:SetTransmitWithParent(true)
  self:SetNoDraw(true)
  self:SetMoveType(MOVETYPE_NONE)
  return self:AddEffects(EF_BONEMERGE)
end
ENT.DoSetup = function(self, wep)
  local ply = wep:GetOwner()
  local viewmodel = ply:GetViewModel()
  self:SetParent(viewmodel)
  self:SetPos(viewmodel:GetPos())
  self:SetAngles(Angle(0, 0, 0))
  wep:DeleteOnRemove(self)
  ply:DeleteOnRemove(self)
  return viewmodel:DeleteOnRemove(self)
end
