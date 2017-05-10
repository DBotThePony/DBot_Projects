AddCSLuaFile()
local SPEED = CreateConVar('sv_scpi_094_speed', '1', {
  FCVAR_ARCHIVE,
  FCVAR_REPLICATED,
  FCVAR_NOTIFY
}, 'Period of SCP 094 growth')
local SIZE = CreateConVar('sv_scpi_094_size', '0.5', {
  FCVAR_ARCHIVE,
  FCVAR_REPLICATED,
  FCVAR_NOTIFY
}, 'Size of SCP 094 growth')
local MAX_SIZE = CreateConVar('sv_scpi_094_maxsize', '60', {
  FCVAR_ARCHIVE,
  FCVAR_REPLICATED,
  FCVAR_NOTIFY
}, 'Max size of SCP 094')
ENT.Type = 'anim'
ENT.PrintName = 'SCP-094'
ENT.Author = 'DBot'
ENT.Category = 'SCP Insanity'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true
ENT.Initialize = function(self)
  self:SetModel('models/combine_helicopter/helicopter_bomb01.mdl')
  if CLIENT then
    return 
  end
  self.SIZE = 1
  self.NEXT_SIZE_CHANGE = CurTime() + SPEED:GetFloat()
  self:SetModelScale(0.4 * self.SIZE)
  self:SetUseType(SIMPLE_USE)
  self:SetMoveType(MOVETYPE_NONE)
  self:PhysicsInitSphere(8 * self.SIZE, 'water')
  self.phys = self:GetPhysicsObject()
  if IsValid(self.phys) then
    self.phys:SetMass(50000)
    self.phys:Sleep()
    return self.phys:EnableMotion(false)
  end
end
if SERVER then
  local damage = 2 ^ 31 - 1
  ENT.Wreck = function(self, ent)
    if ent:IsWeapon() or ent:CreatedByMap() then
      return 
    end
    if ent:IsNPC() or ent:IsPlayer() then
      if ent:IsPlayer() then
        ent:GodDisable()
      end
      local newDMG = DamageInfo()
      newDMG:SetAttacker(self)
      newDMG:SetInflictor(self)
      newDMG:SetDamage(damage)
      newDMG:SetDamageType(DMG_REMOVENORAGDOLL + DMG_DISSOLVE)
      ent:TakeDamageInfo(newDMG)
      if ent:IsPlayer() and ent:Alive() then
        ent:KillSilent()
      end
      self:EmitSound('physics/flesh/flesh_bloody_break.wav', SNDLVL_140dB)
    end
    self:EmitSound("physics/concrete/rock_impact_hard" .. tostring(math.random(1, 6)) .. ".wav", SNDLVL_140dB)
    return SafeRemoveEntity(ent)
  end
  ENT.PhysicsCollide = function(self, data)
    local ent = data.HitEntity
    if not (IsValid(ent)) then
      return 
    end
    return self:Wreck(ent)
  end
  ENT.Think = function(self)
    if self.NEXT_SIZE_CHANGE < CurTime() and self.SIZE < MAX_SIZE:GetFloat() then
      self.SIZE = self.SIZE + SIZE:GetFloat()
      self.NEXT_SIZE_CHANGE = CurTime() + SPEED:GetFloat()
      self:PhysicsInitSphere(8 * self.SIZE, 'water')
      self:SetModelScale(0.4 * self.SIZE)
      self.phys = self:GetPhysicsObject()
      if IsValid(self.phys) then
        self.phys:SetMass(50000)
        self.phys:Sleep()
      end
      local hits = { }
      local trData = {
        start = self:GetPos(),
        endpos = self:GetPos() + Vector(0, 0, 10),
        mins = self:OBBMins() * 2,
        maxs = self:OBBMaxs() * 2,
        mask = CONTENTS_HITBOX + CONTENTS_MONSTER,
        filter = function(ent)
          if ent == self then
            return false
          end
          if not IsValid(ent) then
            return false
          end
          table.insert(hits, ent)
          return false
        end
      }
      util.TraceHull(trData)
      for _index_0 = 1, #hits do
        local ent = hits[_index_0]
        self:Wreck(ent)
      end
    end
    if IsValid(self.phys) then
      return self.phys:EnableMotion(false)
    end
  end
end
if CLIENT then
  local render, Material
  do
    local _obj_0 = _G
    render, Material = _obj_0.render, _obj_0.Material
  end
  local SuppressEngineLighting, ModelMaterialOverride, ResetModelLighting, SetColorModulation
  SuppressEngineLighting, ModelMaterialOverride, ResetModelLighting, SetColorModulation = render.SuppressEngineLighting, render.ModelMaterialOverride, render.ResetModelLighting, render.SetColorModulation
  local debugwtite = Material('models/debug/debugwhite')
  ENT.Draw = function(self)
    SuppressEngineLighting(true)
    ModelMaterialOverride(debugwtite)
    ResetModelLighting(1, 1, 1)
    render.SetColorModulation(0, 0, 0)
    self:DrawModel()
    render.SetColorModulation(1, 1, 1)
    ModelMaterialOverride()
    return SuppressEngineLighting(false)
  end
end
