AddCSLuaFile()
ENT.Type = 'anim'
ENT.PrintName = 'SCP-522'
ENT.Author = 'DBot'
ENT.Category = 'SCP Insanity'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true
ENT.Initialize = function(self)
  self:SetModel('models/props_pony/carpet_round.mdl')
  if CLIENT then
    return 
  end
  self:SetSolid(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self.phys = self:GetPhysicsObject()
  self:SetUseType(SIMPLE_USE)
  self:UseTriggerBounds(true, 24)
  self.ATTACKED_ENTITIES = { }
  self.LAST_SOUND = 0
  if IsValid(self.phys) then
    self.phys:SetMass(64)
    self.phys:Sleep()
    self.phys:EnableMotion(false)
    self.mins, self.maxs = self:OBBMins(), self:OBBMaxs()
  end
  return SCP_CreateNPCTargets(self)
end
if SERVER then
  ENT.ClearEnts = function(self, ent)
    for i, Ent in pairs(self.ATTACKED_ENTITIES) do
      local _continue_0 = false
      repeat
        if not (IsValid(Ent)) then
          self.ATTACKED_ENTITIES[i] = nil
          _continue_0 = true
          break
        end
        if Ent == ent then
          _continue_0 = true
          break
        end
        self.ATTACKED_ENTITIES[i] = nil
        if Ent.SCP522_MOVETYPE then
          Ent:SetMoveType(Ent.SCP522_MOVETYPE)
          Ent.SCP522_MOVETYPE = nil
        end
        if Ent:IsPlayer() then
          Ent:SetNWEntity('SCP522.ENT', NULL)
          Ent:SetMoveType(MOVETYPE_WALK)
        end
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
  end
  ENT.Think = function(self)
    if not (self.mins or self.maxs) then
      return 
    end
    local pos = self:GetPos()
    local ang = self:GetAngles()
    local up = ang:Up()
    local start = pos
    local trData = {
      start = start,
      endpos = start + up * 30,
      mins = self.mins,
      maxs = self.maxs,
      filter = function(ent)
        if ent == self then
          return false
        end
        if not IsValid(ent) then
          return true
        end
        if (ent:IsPlayer() and ent:Alive() and not ent:HasGodMode() or ent:IsNPC() and ent:GetNPCState() ~= NPC_STATE_DEAD) and SCP_IsValidTarget(ent) then
          return true
        end
        return false
      end
    }
    local tr = util.TraceHull(trData)
    local ent = tr.Entity
    if not IsValid(ent) then
      return 
    end
    local hp = ent:Health()
    local mhp = ent:GetMaxHealth()
    if mhp == 0 then
      mhp = 1
    end
    local dmg = DamageInfo()
    dmg:SetDamage(math.max(mhp * 0.01, 1))
    dmg:SetAttacker(self)
    dmg:SetInflictor(self)
    dmg:SetDamageType(DMG_ACID)
    ent:TakeDamageInfo(dmg)
    if self.LAST_SOUND < CurTime() then
      self.LAST_SOUND = CurTime() + 1
      self:EmitSound("npc/barnacle/barnacle_gulp" .. tostring(math.random(1, 2)) .. ".wav")
    end
    local newHP = ent:Health()
    local stage = 1 - math.Clamp(newHP / mhp, 0, 1)
    self.ATTACKED_ENTITIES[ent] = ent
    if ent:IsPlayer() then
      ent:SetNWEntity('SCP522.ENT', self)
    end
    ent.SCP522_MOVETYPE = ent.SCP522_MOVETYPE or ent:GetMoveType()
    ent:SetMoveType(MOVETYPE_NONE)
    if IsValid(self.phys) then
      self.phys:EnableMotion(false)
    end
    local deltaPos = ent:EyePos() - pos
    ent:SetPos(pos - Vector(0, 0, (deltaPos.z + 10) * stage))
    return self:ClearEnts(ent)
  end
  ENT.OnRemove = function(self)
    return self:ClearEnts()
  end
end
if CLIENT then
  local DOWN = Vector(0, 0, 1)
  hook.Add('PrePlayerDraw', 'SCPInsanity.SCP522', function(self)
    if self.SCP522_CLIP then
      self.SCP522_CLIP = false
      render.PopCustomClipPlane()
    end
    if not IsValid(self:GetNWEntity('SCP522.ENT')) then
      return 
    end
    local hp = self:Health()
    local mhp = self:GetMaxHealth()
    if mhp == 0 then
      mhp = 1
    end
    local stage = math.Clamp(hp / mhp, 0, 1)
    local pos = self:EyePos()
    local delta = pos.z - self:GetPos().z + 10
    pos.z = pos.z - (delta * stage)
    local dot = pos:Dot(DOWN)
    render.PushCustomClipPlane(DOWN, dot)
    self.SCP522_CLIP = true
  end)
  return hook.Add('PostPlayerDraw', 'SCPInsanity.SCP522', function(self)
    if not self.SCP522_CLIP then
      return 
    end
    render.PopCustomClipPlane()
    self.SCP522_CLIP = false
  end)
end
