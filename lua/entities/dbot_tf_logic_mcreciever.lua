ENT.Type = 'anim'
ENT.PrintName = 'Minicrit receiver'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Author = 'DBot'
ENT.RenderGroup = RENDERGROUP_OTHER
local entMeta = FindMetaTable('Entity')
entMeta.IsMarkedForDeath = function(self)
  return self:GetNWInt('DTF2.MarksForDeath') > 0
end
do
  local _with_0 = ENT
  _with_0.SetupDataTables = function(self)
    return self:NetworkVar('Entity', 0, 'MarkOwner')
  end
  _with_0.Initialize = function(self)
    self:SetNoDraw(true)
    self:SetNotSolid(true)
    if CLIENT then
      return 
    end
    self.markStart = CurTime()
    self.duration = 4
    self.markEnd = self.markStart + 4
    return self:SetMoveType(MOVETYPE_NONE)
  end
  _with_0.UpdateDuration = function(self, newtime)
    if newtime == nil then
      newtime = 0
    end
    if self.markEnd - CurTime() > newtime then
      return 
    end
    self.duration = newtime
    self.markEnd = CurTime() + newtime
  end
  _with_0.SetupOwner = function(self, owner)
    self:SetPos(owner:GetPos())
    if owner == self:GetOwner() then
      return 
    end
    if IsValid(self:GetOwner()) then
      self:GetOwner():SetNWInt('DTF2.MarksForDeath', self:GetOwner():GetNWInt('DTF2.MarksForDeath') - 1)
    end
    self:SetOwner(owner)
    self:SetParent(owner)
    return owner:SetNWInt('DTF2.MarksForDeath', owner:GetNWInt('DTF2.MarksForDeath') + 1)
  end
  _with_0.Think = function(self)
    if CLIENT then
      return 
    end
    if self.markEnd < CurTime() then
      return self:Remove()
    end
    if not IsValid(self:GetOwner()) then
      return self:Remove()
    end
  end
  _with_0.OnRemove = function(self)
    local owner = self:GetOwner()
    if not IsValid(owner) then
      return 
    end
    return owner:SetNWInt('DTF2.MarksForDeath', owner:GetNWInt('DTF2.MarksForDeath') - 1)
  end
  _with_0.Draw = function(self)
    return false
  end
  return _with_0
end
