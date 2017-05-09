include('shared.lua')
AddCSLuaFile('cl_init.lua')
ENT.Initialize = function(self)
  self:SetModel('models/new173/new173.mdl')
  self.Killer = ents.Create('dbot_scp173_killer')
  self.Killer:SetPos(self:GetPos())
  self.Killer:Spawn()
  self.Killer:Activate()
  self.Killer:SetParent(self)
  self:PhysicsInitBox(Vector(-16, -16, 0), Vector(16, 16, 80))
  self:SetMoveType(MOVETYPE_NONE)
  self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
  self.LastMove = 0
  self.JumpTries = 0
end
local interval
interval = function(val, min, max)
  return val > min and val <= max
end
ENT.GetRealAngle = function(self, pos)
  return (self:GetPos() - pos):Angle()
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
    local cond = (not interval(diffYaw, -70, 70) or not interval(diffPith, -60, 60))
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
    endpos = lpos + Vector(0, 0, 40),
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
  return hit
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
ENT.Wreck = function(self, ply)
  if SCP_NoKill then
    if ply.SCP_Killed then
      return 
    end
    ply.SCP_Killed = true
    self:EmitSound('snap.wav', 100)
    if ply:IsPlayer() then
      PrintMessage(HUD_PRINTTALK, ply:Nick() .. ' should be dead now, but he is not :c')
      self:SetPFrags(self:GetPFrags() + 1)
    else
      ply.SCP_SLAYED = true
    end
    return 
  end
  ply:TakeDamage(INT, self, self.Killer)
  for _index_0 = 1, #DAMAGE_TYPES do
    local dtype = DAMAGE_TYPES[_index_0]
    local dmg = DamageInfo()
    dmg:SetDamage(INT)
    dmg:SetAttacker(self)
    dmg:SetInflictor(self.Killer)
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
    self:SetFrags(self:GetFrags() + 1)
    if ply:GetClass() == 'npc_turret_floor' or ply:GetClass() == 'npc_combinedropship' then
      ply:Fire('SelfDestruct')
    end
  else
    self:SetPFrags(self:GetPFrags() + 1)
    if ply:Alive() then
      ply:Kill()
    end
  end
  self:EmitSound('snap.wav', 100)
  if not ply:IsPlayer() then
    ply.SCP_SLAYED = true
  end
end
ENT.Jumpscare = function(self)
  local lpos = self:GetPos()
  local rand = table.Random(SCP_GetTargets())
  local rpos = rand:GetPos()
  local rang = rand:EyeAngles()
  local newpos = rpos - rang:Forward() * math.random(40, 120)
  local newang = (rpos - lpos):Angle()
  newang.p = 0
  newang.r = 0
  self:SetPos(newpos)
  return self:SetAngles(newang)
end
ENT.TryMoveTo = function(self, pos)
  local tr = util.TraceHull({
    start = self:GetPos(),
    endpos = pos,
    mins = self:OBBMins(),
    maxs = self:OBBMaxs(),
    filter = function(ent)
      if ent == self then
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
      return true
    end
  })
  return self:SetPos(tr.HitPos + tr.HitNormal)
end
ENT.TurnTo = function(self, pos)
  local ang = self:GetRealAngle(pos)
  ang.p = 0
  ang.r = 0
  return self:SetAngles(ang)
end
ENT.RealDropToFloor = function(self)
  return self:TryMoveTo(self:GetPos() + Vector(0, 0, -8000))
end
ENT.Think = function(self)
  if CLIENT then
    return 
  end
  local plys = SCP_GetTargets()
  for _index_0 = 1, #plys do
    local ply = plys[_index_0]
    if self:CanSeeMe(ply) then
      self:RealDropToFloor()
      return 
    end
  end
  local lpos = self:GetPos()
  local plyTarget
  local min = 99999
  for _index_0 = 1, #plys do
    local _continue_0 = false
    repeat
      local ply = plys[_index_0]
      if ply:IsPlayer() then
        if not ply:Alive() then
          _continue_0 = true
          break
        end
        if ply:InVehicle() then
          if ply:GetVehicle():GetParent() == self then
            self:Wreck(ply)
            _continue_0 = true
            break
          end
        end
      end
      local dist = ply:GetPos():Distance(lpos)
      if dist < min then
        plyTarget = ply
        min = dist
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  if not plyTarget then
    return 
  end
  if self.LastMove + 10 - CurTime() < 0 then
    self:Jumpscare()
    self.LastMove = CurTime()
    return 
  end
  self.LastMove = CurTime()
  local pos = plyTarget:GetPos()
  self:TurnTo(pos)
  local lerp = LerpVector(0.3, lpos, pos)
  local start = lpos + Vector(0, 0, 40)
  local filter = {
    self,
    plyTarget
  }
  local _list_0 = ents.FindByClass('dbot_scp173')
  for _index_0 = 1, #_list_0 do
    local val = _list_0[_index_0]
    table.insert(filter, val)
  end
  local _list_1 = player.GetAll()
  for _index_0 = 1, #_list_1 do
    local val = _list_1[_index_0]
    table.insert(filter, val)
  end
  local tr = util.TraceHull({
    start = start,
    endpos = lerp + self:OBBMaxs(),
    filter = filter,
    mins = self:OBBMins(),
    maxs = self:OBBMaxs()
  })
  if tr.Hit and not IsValid(tr.Entity) and start == tr.HitPos then
    self:Jumpscare()
  end
  if not tr.Hit then
    self:SetPos(lerp)
  else
    self:SetPos(tr.HitPos)
  end
  if self:GetPos():Distance(lpos) < 5 then
    self.JumpTries = self.JumpTries + 1
    if self.JumpTries > 10 then
      self:Jumpscare()
      return 
    end
  else
    self.JumpTries = 0
  end
  if self:GetPos():Distance(pos) < 128 then
    return self:Wreck(plyTarget)
  end
end
