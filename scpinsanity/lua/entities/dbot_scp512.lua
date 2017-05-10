AddCSLuaFile()
ENT.Type = 'anim'
ENT.PrintName = 'SCP-512'
ENT.Author = 'DBot'
ENT.Category = 'SCP Insanity'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true
ENT.Initialize = function(self)
  self:SetModel('models/umbrella.mdl')
  if CLIENT then
    return 
  end
  self:SetSkin(1)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self.phys = self:GetPhysicsObject()
  self:SetUseType(SIMPLE_USE)
  self:UseTriggerBounds(true, 24)
  if IsValid(self.phys) then
    self.phys:SetMass(32)
    self.phys:Wake()
    self.mins, self.maxs = self:OBBMins(), self:OBBMaxs()
  end
end
if SERVER then
  ENT.Use = function(self, ply)
    if self:IsPlayerHolding() then
      return 
    end
    if self:GetPos():Distance(ply:GetPos()) < 130 then
      return ply:PickupObject(self)
    end
  end
  ENT.Think = function(self)
    if not (self.mins or self.maxs) then
      return 
    end
    local pos = self:GetPos()
    local ang = self:GetAngles()
    local up = ang:Up()
    local start = pos + up * 30
    local trData = {
      start = start,
      endpos = start + up * 100,
      mins = self.mins,
      maxs = self.maxs,
      filter = function(ent)
        if ent == self then
          return false
        end
        if not IsValid(ent) then
          return true
        end
        if ent:IsPlayer() or ent:IsNPC() or ent:IsVehicle() or ent:IsRagdoll() or ent:GetClass() == 'dbot_scp512' then
          return false
        end
        return true
      end
    }
    local tr = util.TraceHull(trData)
    if not IsValid(tr.Entity) then
      return 
    end
    local ent = tr.Entity
    local phys = tr.Entity:GetPhysicsObject()
    if not IsValid(phys) then
      return 
    end
    return phys:AddVelocity(up * 200)
  end
end
if CLIENT then
  ENT.Draw = function(self)
    render.SetColorModulation(0.4, 0.4, 0.4)
    self:DrawModel()
    return render.SetColorModulation(1, 1, 1)
  end
end
