AddCSLuaFile()
ENT.Type = 'anim'
ENT.PrintName = 'SCP-485'
ENT.Author = 'DBot'
ENT.Category = 'SCP Insanity'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true
ENT.Initialize = function(self)
  self:SetModel('models/props_vtmb/pen.mdl')
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
    self.phys:SetMass(5)
    return self.phys:Wake()
  end
end
if SERVER then
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
  ENT.Wreck = function(self, ent, ply)
    if ply == nil then
      ply = self
    end
    ent:TakeDamage(INT, ply, self)
    for _index_0 = 1, #DAMAGE_TYPES do
      local dtype = DAMAGE_TYPES[_index_0]
      local dmg = DamageInfo()
      dmg:SetDamage(INT)
      dmg:SetAttacker(ply)
      dmg:SetInflictor(self)
      dmg:SetDamageType(dtype)
      ent:TakeDamageInfo(dmg)
      if ent:IsPlayer() then
        if not ent:Alive() then
          break
        end
      elseif not SCP_HaveZeroHP[ent:GetClass()] then
        if ent:Health() <= 0 then
          break
        end
      end
    end
    if not ent:IsPlayer() then
      if ent:GetClass() == 'npc_turret_floor' or ent:GetClass() == 'npc_combinedropship' then
        ent:Fire('SelfDestruct')
      end
    else
      if ent:Alive() then
        ent:Kill()
      end
    end
    return self:EmitSound('buttons/button9.wav', SNDLVL_50dB)
  end
  ENT.Use = function(self, user)
    if SCP_INSANITY_ATTACK_PLAYERS:GetBool() then
      local _list_0 = player.GetAll()
      for _index_0 = 1, #_list_0 do
        local _continue_0 = false
        repeat
          do
            local ply = _list_0[_index_0]
            if SCP_INSANITY_ATTACK_NADMINS:GetBool() and ply:IsAdmin() then
              _continue_0 = true
              break
            end
            if SCP_INSANITY_ATTACK_NSUPER_ADMINS:GetBool() and ply:IsSuperAdmin() then
              _continue_0 = true
              break
            end
            if not ply:Alive() then
              _continue_0 = true
              break
            end
            if ply == user then
              _continue_0 = true
              break
            end
            self:Wreck(ply, user)
            return 
          end
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
    end
    local _list_0 = SCP_GetTargets(true)
    for _index_0 = 1, #_list_0 do
      local ent = _list_0[_index_0]
      self:Wreck(ent, user)
      return 
    end
    return self:EmitSound('buttons/button9.wav', SNDLVL_50dB)
  end
end
