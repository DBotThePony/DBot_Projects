ENT.Type = 'anim'
ENT.Base = 'base_anim'
ENT.PrintName = 'Beam effect'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Author = 'DBot'
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.SetupDataTables = function(self)
  self:NetworkVar('Bool', 0, 'BeamType')
  self:NetworkVar('Entity', 0, 'EntityTarget')
  return self:NetworkVar('Entity', 1, 'DummyTarget')
end
ENT.Initialize = function(self)
  if SERVER then
    self:SetModel('models/props_junk/popcan01a.mdl')
    self:DrawShadow(false)
    self:SetSolid(SOLID_NONE)
    return self:SetMoveType(MOVETYPE_NONE)
  else
    self:SetModel('models/props_junk/popcan01a.mdl')
    self:DrawShadow(false)
    self.beamSound = CreateSound(self, 'weapons/dispenser_heal.wav')
    self.beamSound:ChangeVolume(0.75)
    self.beamSound:SetSoundLevel(60)
    return self.beamSound:Play()
  end
end
ENT.UpdateDummy = function(self)
  if not IsValid(self:GetEntityTarget()) then
    return 
  end
  if IsValid(self.dummyTarget) then
    self.dummyTarget:Remove()
  end
  self.dummyTarget = ents.Create('prop_dynamic')
  self.dummyTarget:SetModel('models/props_junk/popcan01a.mdl')
  self.dummyTarget:SetPos(self:GetEntityTarget():GetPos() + self:GetEntityTarget():OBBCenter() + Vector(0, 0, 20))
  self.dummyTarget:SetParent(self:GetEntityTarget())
  self.dummyTarget:Spawn()
  self.dummyTarget:Activate()
  self.dummyTarget:DrawShadow(false)
  return self:SetDummyTarget(self.dummyTarget)
end
ENT.OnRemove = function(self)
  if IsValid(self.particleEffect) then
    self.particleEffect:StopEmission()
  end
  if IsValid(self.dummyTarget) then
    self.dummyTarget:Remove()
  end
  if self.beamSound then
    return self.beamSound:Stop()
  end
end
if CLIENT then
  local translucentMaterual = CreateMaterial('DTF2_Translucent_Beam', 'VertexLitGeneric', {
    ['$translucent'] = '1',
    ['$alpha'] = '0',
    ['$color'] = '[0 0 0]'
  })
  ENT.Draw = function(self)
    if not IsValid(self:GetDummyTarget()) then
      return 
    end
    if IsValid(self.particleEffect) then
      do
        local _with_0 = self:GetDummyTarget()
        _with_0:SetNoDraw(true)
        _with_0:DrawShadow(false)
        _with_0:SetModelScale(0.01)
        _with_0:SetMaterial('!DTF2_Translucent_Beam')
      end
      return 
    end
    do
      local _with_0 = self:GetDummyTarget()
      _with_0:SetNoDraw(true)
      _with_0:DrawShadow(false)
      _with_0:SetModelScale(0.01)
      _with_0:SetMaterial('!DTF2_Translucent_Beam')
    end
    local pointOne = {
      ['entity'] = self,
      ['attachtype'] = PATTACH_ABSORIGIN_FOLLOW
    }
    local pointTwo = {
      ['entity'] = self:GetDummyTarget(),
      ['attachtype'] = PATTACH_ABSORIGIN_FOLLOW
    }
    self.particleEffect = self:CreateParticleEffect(self:GetBeamType() and 'dispenser_heal_blue' or 'dispenser_heal_red', {
      pointOne,
      pointTwo
    })
  end
end
