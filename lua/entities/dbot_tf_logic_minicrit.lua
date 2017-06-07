ENT.Type = 'anim'
ENT.PrintName = 'Minicrit Logic'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Author = 'DBot'
ENT.RenderGroup = RENDERGROUP_OTHER
do
  local _with_0 = ENT
  _with_0.SetupDataTables = function(self)
    self:NetworkVar('Int', 0, 'Range')
    self:NetworkVar('Bool', 0, 'EnableBuff')
    self:NetworkVar('Bool', 1, 'AffectNPCs')
    self:NetworkVar('Bool', 2, 'AffectNextBots')
    return self:NetworkVar('Bool', 3, 'AffectEverything')
  end
  _with_0.Initialize = function(self)
    self:SetNoDraw(true)
    self:SetNotSolid(true)
    self.BuffedTargets = { }
    if CLIENT then
      return 
    end
    return self:SetMoveType(MOVETYPE_NONE)
  end
  _with_0.Think = function(self)
    local owner = self:GetOwner()
    local oldTargets = self.BuffedTargets
    self.BuffedTargets = { }
    if self:GetEnableBuff() and IsValid(owner) then
      table.insert(self.BuffedTargets, owner)
    end
    if self:GetEnableBuff()(self:GetRange() and self:GetRange() > 0) then
      local everything = self:GetAffectEverything()
      local npcs = self:GetAffectNPCs()
      local nextbots = self:GetAffectNextBots()
      local _list_0 = ents.FindInSphere(self:GetPos(), self:GetRange())
      for _index_0 = 1, #_list_0 do
        local ent = _list_0[_index_0]
        if ent:IsPlayer() then
          if ent:Alive() then
            table.insert(self.BuffedTargets, ent)
          end
        elseif everything then
          table.insert(self.BuffedTargets, ent)
        elseif npcs and ent:IsNPC() then
          table.insert(self.BuffedTargets, ent)
        elseif nextbots and ent.Type == 'nextbot' then
          table.insert(self.BuffedTargets, ent)
        end
      end
    end
    for _index_0 = 1, #oldTargets do
      local oldTarget = oldTargets[_index_0]
      local hit = false
      local _list_0 = self.BuffedTargets
      for _index_1 = 1, #_list_0 do
        local newTarget = _list_0[_index_1]
        if oldTarget == newTarget then
          hit = true
          break
        end
      end
      if not hit then
        oldTarget:RemoveMiniCritBuffer()
        oldTarget:UpdateMiniCritBuffers()
      end
    end
    local _list_0 = self.BuffedTargets
    for _index_0 = 1, #_list_0 do
      local newTarget = _list_0[_index_0]
      local hit = false
      for _index_1 = 1, #oldTargets do
        local oldTarget = oldTargets[_index_1]
        if oldTarget == newTarget then
          hit = true
          break
        end
      end
      if not hit then
        newTarget:AddMiniCritBuffer()
        newTarget:UpdateMiniCritBuffers()
      end
    end
    self:NextThink(CurTime() + .25)
    return true
  end
  _with_0.OnRemove = function(self)
    local _list_0 = self.BuffedTargets
    for _index_0 = 1, #_list_0 do
      local newTarget = _list_0[_index_0]
      newTarget:RemoveMiniCritBuffer()
      newTarget:UpdateMiniCritBuffers()
    end
  end
  _with_0.Draw = function(self)
    return false
  end
  return _with_0
end
