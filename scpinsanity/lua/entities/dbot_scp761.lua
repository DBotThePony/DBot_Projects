AddCSLuaFile()
ENT.Type = 'anim'
ENT.PrintName = 'SCP-761'
ENT.Author = 'DBot and MacDGuy/Voided'
ENT.Category = 'SCP Insanity'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true
ENT.Initialize = function(self)
  self:SetModel('models/gmod_tower/trampoline.mdl')
  self.trampoline_seq = self:LookupSequence('bounce')
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
    self.phys:SetMass(32)
    self.phys:Wake()
    self.mins, self.maxs = self:OBBMins(), self:OBBMaxs()
  end
end
if SERVER then
  util.AddNetworkString('SCPInsanity.761Boing')
  local EmptyVector = Vector()
  ENT.PhysicsCollide = function(self, data, collider)
    local ent = data.HitEntity
    local HitNormal, HitPos, TheirOldVelocity
    HitNormal, HitPos, TheirOldVelocity = data.HitNormal, data.HitPos, data.TheirOldVelocity
    if not IsValid(ent) then
      return 
    end
    local norm = HitNormal * -1
    local dot = self:GetUp():Dot(HitNormal)
    local scale = math.random(1, 1.5)
    local dist = 250 * scale
    local pitch = 100 * scale
    local mulNorm = norm * dist
    if mulNorm.z < 0 then
      mulNorm.z = -mulNorm.z
    end
    local phys
    if ent:IsPlayer() or ent:IsNPC() then
      phys = ent
    else
      phys = ent:GetPhysicsObject()
    end
    if IsValid(phys) then
      phys:SetVelocity(mulNorm)
    end
    self:ResetSequence(self.trampoline_seq)
    net.Start('SCPInsanity.761Boing')
    net.WriteEntity(self)
    net.WriteVector(HitPos)
    net.WriteNormal(HitNormal)
    net.WriteUInt(pitch, 8)
    net.Broadcast()
    if TheirOldVelocity:Length() > 400 then
      ent:SetPos(self:GetPos() + VectorRand() * math.random(160, 400))
    end
    if IsValid(phys) then
      return self.phys:SetVelocity(EmptyVector)
    end
  end
end
if CLIENT then
  return net.Receive('SCPInsanity.761Boing', function()
    local ent = net.ReadEntity()
    if not (IsValid(ent)) then
      return 
    end
    ent:ResetSequence(ent.trampoline_seq)
    local vOffset = net.ReadVector()
    local vNorm = net.ReadNormal()
    local pitch = net.ReadUInt(8)
    ent:EmitSound('gmodtower/misc/boing.wav', 85, pitch)
    local NumParticles = 0
    local emitter = ParticleEmitter(vOffset)
    for i = 0, NumParticles do
      local _continue_0 = false
      repeat
        local particle = emitter:Add('sprites/star', vOffset)
        if not (particle) then
          _continue_0 = true
          break
        end
        local angle = vNorm:Angle()
        local vel = angle:Forward() * math.random(0, 200) + angle:Right() * math.random(-200, 200) + angle:Up() * math.random(-200, 200)
        particle:SetVelocity(vel)
        particle:SetLifeTime(0)
        particle:SetDieTime(1)
        particle:SetStartAlpha(255)
        particle:SetEndAlpha(0)
        particle:SetStartSize(8)
        particle:SetEndSize(2)
        local col = Color(255, 0, 0)
        if i > 2 then
          col = Color(255, 255, 0)
          col.g = col.g - math.random(0, 50)
        end
        particle:SetColor(col.r, col.g, math.random(0, 50))
        particle:SetRoll(math.random(0, 360))
        particle:SetRollDelta(math.random(-2, 2))
        particle:SetAirResistance(100)
        particle:SetGravity(vNorm * 15)
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
    return emitter:Finish()
  end)
end
