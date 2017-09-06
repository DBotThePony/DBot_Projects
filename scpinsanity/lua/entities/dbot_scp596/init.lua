AddCSLuaFile('cl_init.lua')
ENT.Type = 'anim'
ENT.PrintName = 'SCP-596'
ENT.Author = 'DBot'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true
ENT.Initialize = function(self)
  self:SetModel('models/props_combine/breenbust.mdl')
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self.CurrentPly = NULL
end
local MAX = 10 ^ 5
ENT.Think = function(self)
  if not IsValid(self.CurrentPly) then
    return 
  end
  if not self.CurrentPly:Alive() then
    self.CurrentPly = NULL
    return 
  end
  self.CurrentPly:SetMaxHealth(MAX)
  self.CurrentPly:SetHealth(math.min(MAX, self.CurrentPly:Health() + 100))
  self.TOUCH_POS = self.TOUCH_POS or self:GetPos()
  self.CurrentPly:SetPos(self.TOUCH_POS)
  self:NextThink(CurTime())
  return true
end
ENT.PhysicsCollide = function(self, data)
  local ent = data.HitEntity
  if not IsValid(ent) then
    return 
  end
  if ent == self.CurrentPly then
    return 
  end
  if not ent:IsPlayer() then
    return 
  end
  if not SCP_INSANITY_ATTACK_PLAYERS:GetBool() then
    return 
  end
  if SCP_INSANITY_ATTACK_NADMINS:GetBool() and ent:IsAdmin() then
    return 
  end
  if SCP_INSANITY_ATTACK_NSUPER_ADMINS:GetBool() and ent:IsSuperAdmin() then
    return 
  end
  if IsValid(self.CurrentPly) and self.CurrentPly:Alive() then
    self.CurrentPly:Kill()
  end
  self.CurrentPly = ent
  self.TOUCH_POS = ent:GetPos()
end
