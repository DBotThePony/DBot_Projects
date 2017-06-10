ENT.Type = 'anim'
ENT.PrintName = 'MadMilk Logic'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Author = 'DBot'
ENT.RenderGroup = RENDERGROUP_OTHER
local entMeta = FindMetaTable('Entity')
if SERVER then
  entMeta.TF2MadMilk = function(self, duration)
    if duration == nil then
      duration = 0
    end
    if IsValid(self.__dtf2_madmilk_logic) then
      self.__dtf2_madmilk_logic:UpdateDuration(duration)
      return self.__dtf2_madmilk_logic
    end
    self.__dtf2_madmilk_logic = ents.Create('dbot_tf_logic_madmilk')
    self.__dtf2_madmilk_logic:SetPos(self:GetPos())
    self.__dtf2_madmilk_logic:Spawn()
    self.__dtf2_madmilk_logic:Activate()
    self.__dtf2_madmilk_logic:SetParent(self)
    self.__dtf2_madmilk_logic:SetOwner(self)
    self.__dtf2_madmilk_logic:UpdateDuration(duration)
    self:SetNWEntity('DTF2.MadMilkLogic', self.__dtf2_madmilk_logic)
    return self.__dtf2_madmilk_logic
  end
  hook.Add('PlayerDeath', 'DTF2.MadMilkLogic', function(self)
    if IsValid(self.__dtf2_madmilk_logic) then
      return self.__dtf2_madmilk_logic:Remove()
    end
  end)
  hook.Add('OnNPCKilled', 'DTF2.MadMilkLogic', function(self)
    if IsValid(self.__dtf2_madmilk_logic) then
      return self.__dtf2_madmilk_logic:Remove()
    end
  end)
  hook.Add('EntityTakeDamage', 'DTF2.MadMilkLogic', function(ent, dmg)
    local milk = ent.__dtf2_madmilk_logic
    if not IsValid(milk) then
      return 
    end
    local attacker = dmg:GetAttacker()
    if not IsValid(attacker) or not attacker:IsPlayer() then
      return 
    end
    do
      local _with_0 = attacker
      local hp = _with_0:Health()
      local mhp = _with_0:GetMaxHealth()
      if hp < mhp then
        _with_0:SetHealth(math.Clamp(hp + math.max(0, dmg:GetDamage() * milk:GetHealthPercent()), 0, mhp))
      end
      if IsValid(milk:GetAttacker()) and milk:GetAttacker() ~= attacker then
        do
          local _with_1 = milk:GetAttacker()
          hp = _with_1:Health()
          mhp = _with_1:GetMaxHealth()
          if hp < mhp then
            _with_1:SetHealth(math.Clamp(hp + math.max(0, dmg:GetDamage() * milk:GetOwnerHealthPercent()), 0, mhp))
          end
        end
      end
      return _with_0
    end
  end)
end
entMeta.IsMadMilked = function(self)
  return IsValid(self:GetNWEntity('DTF2.MadMilkLogic'))
end
ENT.SetupDataTables = function(self)
  self:NetworkVar('Entity', 0, 'Attacker')
  self:NetworkVar('Float', 0, 'HealthPercent')
  return self:NetworkVar('Float', 1, 'OwnerHealthPercent')
end
ENT.Initialize = function(self)
  self:SetNoDraw(true)
  self:SetNotSolid(true)
  self:SetHealthPercent(0.6)
  self:SetOwnerHealthPercent(0.2)
  if CLIENT then
    return 
  end
  self.milkStart = CurTime()
  self.duration = 10
  self.milkEnd = self.milkStart + 10
  return self:SetMoveType(MOVETYPE_NONE)
end
ENT.UpdateDuration = function(self, newtime)
  if newtime == nil then
    newtime = 10
  end
  if self.milkEnd - CurTime() > newtime then
    return 
  end
  self.duration = newtime
  self.milkEnd = CurTime() + newtime
end
ENT.Think = function(self)
  if CLIENT then
    return false
  end
  if self.milkEnd < CurTime() then
    return self:Remove()
  end
end
ENT.OnRemove = function(self)
  if self.particles and self.particles:IsValid() then
    return self.particles:StopEmission()
  end
end
ENT.Draw = function(self)
  if self.particles then
    return 
  end
  if not IsValid(self:GetParent()) then
    return 
  end
  self.particles = CreateParticleSystem(self:GetParent(), 'peejar_drips_milk', PATTACH_ABSORIGIN_FOLLOW)
end
