ENT.Type = 'anim'
ENT.PrintName = 'Bleeding Logic'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Author = 'DBot'
ENT.RenderGroup = RENDERGROUP_OTHER
if SERVER then
  local entMeta = FindMetaTable('Entity')
  entMeta.TF2Bleed = function(self, duration)
    if duration == nil then
      duration = 0
    end
    if IsValid(self.__dtf2_bleed_logic) then
      return self.__dtf2_bleed_logic
    end
    self.__dtf2_bleed_logic = ents.Create('dbot_tf_logic_bleed')
    self.__dtf2_bleed_logic:SetPos(self:GetPos())
    self.__dtf2_bleed_logic:Spawn()
    self.__dtf2_bleed_logic:Activate()
    self.__dtf2_bleed_logic:SetParent(self)
    self.__dtf2_bleed_logic:SetOwner(self)
    self.__dtf2_bleed_logic:UpdateDuration(duration)
    return self.__dtf2_bleed_logic
  end
end
do
  local _with_0 = ENT
  _with_0.SetupDataTables = function(self)
    self:NetworkVar('Entity', 0, 'Attacker')
    self:NetworkVar('Entity', 1, 'Inflictor')
    self:NetworkVar('Float', 0, 'HitDelay')
    return self:NetworkVar('Float', 1, 'Damage')
  end
  _with_0.Initialize = function(self)
    self:SetNoDraw(true)
    self:SetNotSolid(true)
    self:SetHitDelay(.75)
    self:SetDamage(3)
    if CLIENT then
      return 
    end
    self.burnStart = CurTime()
    self.duration = 4
    self.burnEnd = self.burnStart + 4
    return self:SetMoveType(MOVETYPE_NONE)
  end
  _with_0.UpdateDuration = function(self, newtime)
    if newtime == nil then
      newtime = 0
    end
    if self.burnEnd - CurTime() > newtime then
      return 
    end
    self.duration = newtime
    self.burnEnd = CurTime() + newtime
  end
  _with_0.Think = function(self)
    if CLIENT then
      return 
    end
    if self.burnEnd < CurTime() then
      return self:Remove()
    end
    local owner = self:GetOwner()
    if not IsValid(self:GetOwner()) then
      return self:Remove()
    end
    local dmginfo = DamageInfo()
    dmginfo:SetAttacker(IsValid(self:GetAttacker()) and self:GetAttacker() or self)
    dmginfo:SetInflictor(IsValid(self:GetInflictor()) and self:GetInflictor() or self)
    dmginfo:SetDamageType(DMG_SLASH)
    dmginfo:SetDamage(self:GetDamage())
    owner:TakeDamageInfo(dmginfo)
    self:NextThink(CurTime() + self:GetHitDelay())
    return true
  end
  _with_0.OnRemove = function(self)
    if self.particles and self.particles:IsValid() then
      return self.particles:StopEmission()
    end
  end
  _with_0.Draw = function(self)
    if self.particles then
      return 
    end
    if not IsValid(self:GetParent()) then
      return 
    end
  end
  return _with_0
end
