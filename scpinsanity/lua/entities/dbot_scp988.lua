AddCSLuaFile()
ENT.Type = 'anim'
ENT.PrintName = 'SCP-988'
ENT.Author = 'DBot'
ENT.Category = 'SCP Insanity'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true
ENT.Initialize = function(self)
  self:SetModel('models/treasurechest/treasurechest.mdl')
  if CLIENT then
    return 
  end
  self:SetSolid(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self.phys = self:GetPhysicsObject()
  self:SetUseType(SIMPLE_USE)
  self:UseTriggerBounds(true, 24)
  if IsValid(self.phys) then
    self.phys:SetMass(256)
    self.phys:Wake()
  end
  self.LAST_SOUND = 0
end
if SERVER then
  ENT.Use = function(self, ply)
    if self.LAST_SOUND > CurTime() then
      return 
    end
    self.LAST_SOUND = CurTime() + 1
    return self:EmitSound('doors/latchlocked2.wav')
  end
  ENT.OnTakeDamage = function(self, dmg)
    local attacker = dmg:GetAttacker()
    if not (IsValid(attacker)) then
      return 
    end
    local infl = dmg:GetInflictor()
    if not (IsValid(infl)) then
      infl = self
    end
    local newDMG = DamageInfo()
    newDMG:SetAttacker(self)
    newDMG:SetInflictor(infl)
    newDMG:SetDamage(dmg:GetDamage())
    newDMG:SetDamageType(dmg:GetDamageType())
    return attacker:TakeDamageInfo(newDMG)
  end
end
