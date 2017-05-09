AddCSLuaFile('cl_init.lua')
ENT.Type = 'anim'
ENT.PrintName = 'SCP-689'
ENT.Author = 'DBot'
ENT.Category = 'DBot'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true
ENT.Initialize = function(self)
  self:SetModel('models/props_lab/huladoll.mdl')
  self:PhysicsInitBox(Vector(-4, -4, 0), Vector(4, 4, 16))
  self:SetMoveType(MOVETYPE_NONE)
  self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
  self.ARGETS = { }
end
local interval
interval = function(val, min, max)
  return val > min and val <= max
end
ENT.CanSeeMe = function(self, ply)
  if ply:IsPlayer() and not ply:Alive() then
    return false
  end
  local lpos = self:GetPos()
  local pos = ply:GetPos()
  local epos = ply:EyePos()
  local eyes = ply:EyeAngles()
  local ang = (lpos - pos):Angle()
  if lpos:Distance(epos) > 6000 then
    return false
  end
  local diffPith = math.AngleDifference(ang.p, eyes.p)
  local diffYaw = math.AngleDifference(ang.y, eyes.y)
  local diffRoll = math.AngleDifference(ang.r, eyes.r)
  if ply:IsPlayer() then
    local cond = (not interval(diffYaw, -60, 60) or not interval(diffPith, -45, 45))
    if cond then
      return false
    end
  elseif ply:IsNPC() then
    if ply:GetNPCState() == NPC_STATE_DEAD then
      return false
    end
    local cond = (not interval(diffYaw, -50, 50) or not interval(diffPith, -45, 45))
    if cond then
      return false
    end
  else
    local cond = (not interval(diffYaw, -50, 50) or not interval(diffPith, -45, 45))
    if cond then
      return false
    end
  end
  local hit = false
  local tr = util.TraceLine({
    start = epos,
    endpos = lpos,
    filter = function(ent)
      if ent == self then
        hit = true
        return true
      end
      if ent == ply then
        return false
      end
      if not IsValid(ent) then
        return true
      end
      if ent:IsPlayer() then
        return false
      end
      if ent:IsNPC() then
        return false
      end
      if ent:IsVehicle() then
        return false
      end
      if ent:GetClass() == 'dbot_scp173' then
        return false
      end
      if ent:GetClass() == 'dbot_scp173p' then
        return false
      end
      return true
    end
  })
  if not hit then
    return false
  end
  self.TARGETS[ply] = ply
  return true
end
local INT = 2 ^ 31 - 1
local DAMAGE_TYPES = {
  DMG_GENERIC,
  DMG_CRUSH,
  DMG_BULLET,
  DMG_SLASH,
  DMG_VEHICLE,
  DMG_BLAST,
  DMG_CLUB,
  DMG_ENERGYBEAM,
  DMG_ALWAYSGIB,
  DMG_PARALYZE,
  DMG_NERVEGAS,
  DMG_POISON,
  DMG_ACID,
  DMG_AIRBOAT,
  DMG_BLAST_SURFACE,
  DMG_BUCKSHOT,
  DMG_DIRECT,
  DMG_DISSOLVE,
  DMG_DROWNRECOVER,
  DMG_PHYSGUN,
  DMG_PLASMA,
  DMG_RADIATION,
  DMG_SLOWBURN
}
ENT.Wreck = function(ply)
  self:EmitSound('snap.wav', 100)
  ply:TakeDamage(INT, self, self)
  for _index_0 = 1, #DAMAGE_TYPES do
    local dtype = DAMAGE_TYPES[_index_0]
    local dmg = DamageInfo()
    dmg:SetDamage(INT)
    dmg:SetAttacker(self)
    dmg:SetInflictor(self)
    dmg:SetDamageType(dtype)
    ply:TakeDamageInfo(dmg)
    if ply:IsPlayer() then
      if not ply:Alive() then
        break
      end
    elseif not SCP_HaveZeroHP[ply:GetClass()] then
      if ply:Health() <= 0 then
        break
      end
    end
  end
  if not ply:IsPlayer() then
    if ply:GetClass() == 'npc_turret_floor' or ply:GetClass() == 'npc_combinedropship' then
      ply:Fire('SelfDestruct')
    end
  else
    if ply:Alive() then
      ply:Kill()
    end
  end
  if not ply:IsPlayer() then
    ply.SCP_SLAYED = true
  end
end
ENT.Think = function(self)
  if IsValid(self.Attacking) then
    self.AttackAt = self.AttackAt or 0
    if self.AttackAt > CurTime() then
      return 
    end
    self.AttackAt = nil
    self:SetPos(self.Attacking:GetPos())
    self:Wreck(self.Attacking)
    self.Attacking = nil
    self.LastPos = nil
    return 
  elseif self.LastPos then
    self:SetPos(self.LastPos)
    self.LastPos = nil
  end
  local _list_0 = SCP_GetTargets()
  for _index_0 = 1, #_list_0 do
    local _continue_0 = false
    repeat
      local ply = _list_0[_index_0]
      if ply == PLY then
        _continue_0 = true
        break
      end
      if self:CanSeeMe(ply) then
        return 
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  local lpos = self:GetPos()
  local min = 99999
  for k, v in pairs(self.TARGETS) do
    local _continue_0 = false
    repeat
      if not IsValid(v) then
        self.TARGETS[k] = nil
        _continue_0 = true
        break
      end
      if v:IsPlayer() and not v:Alive() then
        self.TARGETS[k] = nil
        _continue_0 = true
        break
      end
      if v:IsPlayer() and v:InVehicle() then
        if v:GetVehicle():GetParent() == self then
          self:Wreck(v)
          self.TARGETS[k] = nil
          _continue_0 = true
          break
        end
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  local ply = table.Random(self.TARGETS)
  if not ply then
    return 
  end
  self.Attacking = ply
  self.LastPos = lpos
  self.AttackAt = CurTime() + math.random(3, 8)
  return self:SetPos(Vector(0, 0, -16000))
end
