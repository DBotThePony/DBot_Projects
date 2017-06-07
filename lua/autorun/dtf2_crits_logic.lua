DTF2 = DTF2 or { }
local entMeta = FindMetaTable('Entity')
local EntityClass = {
  CritBoosted = function(self)
    return self:GetNWBool('DTF2.CritBoosted')
  end,
  IsCritBoosted = function(self)
    return self:GetNWBool('DTF2.CritBoosted')
  end,
  GetCritBoosted = function(self)
    return self:GetNWBool('DTF2.CritBoosted')
  end,
  SetCritBoosted = function(self, val)
    if val == nil then
      val = self:CritBoosted()
    end
    return self:SetNWBool('DTF2.CritBoosted', val)
  end,
  MiniCritBoosted = function(self)
    return self:GetNWBool('DTF2.MiniCritBoosted')
  end,
  IsMiniCritBoosted = function(self)
    return self:GetNWBool('DTF2.MiniCritBoosted')
  end,
  GetMiniCritBoosted = function(self)
    return self:GetNWBool('DTF2.MiniCritBoosted')
  end,
  SetMiniCritBoosted = function(self, val)
    if val == nil then
      val = self:MiniCritBoosted()
    end
    return self:SetNWBool('DTF2.MiniCritBoosted', val)
  end,
  GetCritModifier = function(self)
    return self:CritBoosted() and 3 or self:MiniCritBoosted() and 1.3 or 1
  end,
  GetMiniCritBuffers = function(self)
    return self:GetNWInt('DTF2.MiniCritBuffers')
  end,
  SetMiniCritBuffers = function(self, val)
    if val == nil then
      val = self:GetMiniCritBuffers()
    end
    return self:GetNWInt('DTF2.MiniCritBuffers', val)
  end,
  AddMiniCritBuffer = function(self)
    return self:GetNWInt('DTF2.MiniCritBuffers', self:GetMiniCritBuffers() + 1)
  end,
  RemoveMiniCritBuffer = function(self)
    return self:GetNWInt('DTF2.MiniCritBuffers', self:GetMiniCritBuffers() - 1)
  end,
  UpdateMiniCritBuffers = function(self)
    return self:SetMiniCritBoosted(self:GetNWInt('DTF2.MiniCritBuffers') > 0)
  end
}
for k, v in pairs(EntityClass) do
  entMeta[k] = v
end
if SERVER then
  return hook.Add('PlayerSpawn', 'DTF2.Crits', function(self)
    self:SetCritBoosted(false)
    return self:SetMiniCritBoosted(false)
  end)
end
