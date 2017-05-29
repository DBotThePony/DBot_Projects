include('shared.lua')
AddCSLuaFile('shared.lua')
ENT.Initialize = function(self)
  self.BaseClass.Initialize(self)
  self.healing = { }
  self.beams = { }
  self.nextAmmo = CurTime()
  self.nextChangeUp = CurTime()
end
ENT.HealTarget = function(self, ent, delta, cTime)
  if ent == nil then
    ent = NULL
  end
  if delta == nil then
    delta = 1
  end
  if cTime == nil then
    cTime = CurTime()
  end
  if not IsValid(ent) then
    return 
  end
  local hp = ent:Health()
  local mhp = ent:GetMaxHealth()
  if hp < mhp then
    local healAdd = math.Clamp(mhp - hp, 0, delta * self:GetRessuplyMultiplier() * self.HEAL_SPEED_MULT)
    ent:SetHealth(hp + healAdd)
  end
  if not ent:IsPlayer() then
    return 
  end
  if self.nextAmmo > cTime then
    return 
  end
  local deltaGive = DTF2_GiveAmmo(ent, self:GetAvaliableForAmmo())
  if deltaGive == 0 then
    return 
  end
  return self:SetRessuplyAmount(self:GetRessuplyAmount() - deltaGive)
end
ENT.BehaveUpdate = function(self, delta)
  self:UpdateRelationships()
  if not self:IsAvaliable() then
    self.currentTarget = NULL
    return 
  end
  self.healing = self:GetAlliesVisible()
  for ply, beam in pairs(self.beams) do
    beam.__isValid = false
  end
  local _list_0 = self.healing
  for _index_0 = 1, #_list_0 do
    local ply = _list_0[_index_0]
    if not self.beams[ply] then
      self.beams[ply] = ents.Create('dbot_info_healbeam')
      do
        local _with_0 = self.beams[ply]
        _with_0:SetBeamType(self:GetTeamType())
        _with_0:SetEntityTarget(ply)
        _with_0:SetPos(self:GetPos() + self:OBBCenter())
        _with_0:Spawn()
        _with_0:Activate()
        _with_0:SetParent(self)
        _with_0:UpdateDummy()
      end
    end
    self.beams[ply].__isValid = true
  end
  for ply, beam in pairs(self.beams) do
    if not beam.__isValid then
      beam:Remove()
      self.beams[ply] = nil
    end
  end
  local cTime = CurTime()
  local _list_1 = self.healing
  for _index_0 = 1, #_list_1 do
    local ply = _list_1[_index_0]
    self:HealTarget(ply, delta, cTime)
  end
  if self.nextAmmo < cTime then
    self.nextAmmo = cTime + 1
  end
end
ENT.ChargeUp = function(self, force)
  if force == nil then
    force = false
  end
  if self:GetRessuplyAmount() >= self:GetMaxRessuply() and not force then
    self.nextChangeUp = CurTime() + self:GetChargeTime()
    return 
  end
  if self.nextChangeUp > CurTime() and not force then
    return 
  end
  self.nextChangeUp = CurTime() + self:GetChargeTime()
  local toAdd = math.Clamp(self:GetMaxRessuply() - self:GetRessuplyAmount(), 0, self:GetChargeAmount())
  self:SetRessuplyAmount(self:GetRessuplyAmount() + toAdd)
  return self:EmitSound('weapons/dispenser_generate_metal.wav')
end
ENT.Think = function(self)
  self.BaseClass.Think(self)
  self:ChargeUp()
  self:NextThink(CurTime() + 0.1)
  return true
end
