local CreateConVar
CreateConVar = _G.CreateConVar
local timer
timer = _G.timer
local concommand
concommand = _G.concommand
local IsValid
IsValid = _G.IsValid
local scripted_ents
scripted_ents = _G.scripted_ents
local hook
hook = _G.hook
local table
table = _G.table
local ents
ents = _G.ents
local player
player = _G.player
resource.AddWorkshop('924100738')
SCP_NoKill = false
SCP_Ignore = {
  bullseye_strider_focus = true,
  npc_bullseye = true,
  ai_relationship = true
}
SCP_HaveZeroHP = {
  npc_rollermine = true
}
SCP_INSANITY_ATTACK_PLAYERS = CreateConVar('sv_scpi_players', '1', {
  FCVAR_NOTIFY,
  FCVAR_ARCHIVE
}, 'Whatever attack players')
SCP_INSANITY_ATTACK_NADMINS = CreateConVar('sv_scpi_not_admins', '0', {
  FCVAR_NOTIFY,
  FCVAR_ARCHIVE
}, 'Whatever to NOT to attack admins')
SCP_INSANITY_ATTACK_NSUPER_ADMINS = CreateConVar('sv_scpi_not_superadmins', '0', {
  FCVAR_NOTIFY,
  FCVAR_ARCHIVE
}, 'Whatever to NOT to attack superadmins')
local VALID_NPCS = { }
SCP_IsValidTarget = function(ent)
  if not (IsValid(ent)) then
    return false
  end
  if SCP_Ignore[ent:GetClass()] then
    return false
  end
  return true
end
local UpdateNPCs
UpdateNPCs = function()
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = ents.GetAll()
    for _index_0 = 1, #_list_0 do
      local _continue_0 = false
      repeat
        local ent = _list_0[_index_0]
        local nclass = ent:GetClass()
        if not nclass then
          _continue_0 = true
          break
        end
        if not ent:IsNPC() then
          _continue_0 = true
          break
        end
        if ent:GetNPCState() == NPC_STATE_DEAD then
          _continue_0 = true
          break
        end
        if SCP_Ignore[nclass] then
          _continue_0 = true
          break
        end
        local _value_0 = ent
        _accum_0[_len_0] = _value_0
        _len_0 = _len_0 + 1
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
    VALID_NPCS = _accum_0
  end
end
SCP_GetTargets = function(noPlayers)
  if noPlayers == nil then
    noPlayers = false
  end
  local reply
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #VALID_NPCS do
      local _continue_0 = false
      repeat
        local ent = VALID_NPCS[_index_0]
        if not IsValid(ent) then
          _continue_0 = true
          break
        end
        if ent.SCP_SLAYED then
          _continue_0 = true
          break
        end
        if ent.SCP_Killed then
          _continue_0 = true
          break
        end
        local _value_0 = ent
        _accum_0[_len_0] = _value_0
        _len_0 = _len_0 + 1
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
    reply = _accum_0
  end
  if SCP_INSANITY_ATTACK_PLAYERS:GetBool() and not noPlayers then
    local _list_0 = player.GetAll()
    for _index_0 = 1, #_list_0 do
      local _continue_0 = false
      repeat
        local ply = _list_0[_index_0]
        if ply:HasGodMode() then
          _continue_0 = true
          break
        end
        if ply.SCP_Killed then
          _continue_0 = true
          break
        end
        if SCP_INSANITY_ATTACK_NADMINS:GetBool() and ply:IsAdmin() then
          _continue_0 = true
          break
        end
        if SCP_INSANITY_ATTACK_NSUPER_ADMINS:GetBool() and ply:IsSuperAdmin() then
          _continue_0 = true
          break
        end
        table.insert(reply, ply)
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
  end
  return reply
end
SCP_CreateNPCTargets = function(self)
  local mins, maxs, center = self:OBBMins(), self:OBBMaxs(), self:OBBCenter()
  local box = {
    Vector(0, 0, mins.z),
    Vector(0, 0, maxs.z),
    Vector(mins.x, center.y, center.z),
    Vector(-mins.x, center.y, center.z),
    Vector(center.x, mins.y, center.z),
    Vector(center.x, -mins.y, center.z)
  }
  if self.bullseyes then
    local _list_0 = self.bullseyes
    for _index_0 = 1, #_list_0 do
      local eye = _list_0[_index_0]
      if IsValid(eye) then
        eye:Remove()
      end
    end
  end
  local nclass = tostring(self:GetClass()) .. "_bullseye"
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #box do
      local vec = box[_index_0]
      do
        local _with_0 = ents.Create('npc_bullseye')
        _with_0:SetKeyValue('targetname', nclass)
        _with_0:SetKeyValue('spawnflags', '131072')
        _with_0:SetPos(self:LocalToWorld(vec))
        _with_0:Spawn()
        _with_0:Activate()
        _with_0:SetCollisionGroup(COLLISION_GROUP_WORLD)
        _with_0:PhysicsInitBox(Vector(-2, -2, -2), Vector(2, 2, 2))
        _with_0:SetHealth(2 ^ 31 - 1)
        _with_0:SetParent(self)
        _with_0.SCPInsanity = true
        _with_0.SCPParent = self
        _accum_0[_len_0] = _with_0
      end
      _len_0 = _len_0 + 1
    end
    self.bullseyes = _accum_0
  end
end
concommand.Add('scpi_reset173', function(ply)
  if not ply:IsAdmin() then
    return 
  end
  local _list_0 = player.GetAll()
  for _index_0 = 1, #_list_0 do
    local v = _list_0[_index_0]
    v.SCP_Killed = nil
  end
end)
timer.Create('SCPInsanity.UpdateNPCs', 1, 0, UpdateNPCs)
hook.Add('OnNPCKilled', 'DBot.SCPInsanity', OnNPCKilled)
hook.Add('PlayerDeath', 'DBot.SCPInsanity', PlayerDeath)
local _list_0 = ents.FindByClass('ai_relationship')
for _index_0 = 1, #_list_0 do
  local ship = _list_0[_index_0]
  if ship.SCP_INSANITY then
    ship:Remove()
  end
end
local SCP_INSANITY_RELATIONSHIPS = { }
local TO_ATTACK = {
  {
    '173',
    D_FR
  },
  {
    '689',
    D_FR
  },
  {
    '522',
    D_FR
  }
}
local OnEntityCreated
OnEntityCreated = function(self)
  return timer.Simple(0, function()
    if not IsValid(self) then
      return 
    end
    if not self:IsNPC() then
      return 
    end
    local entClass = self:GetClass()
    if SCP_INSANITY_RELATIONSHIPS[entClass] then
      return 
    end
    if SCP_Ignore[entClass] then
      return 
    end
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #TO_ATTACK do
        local _des_0 = TO_ATTACK[_index_0]
        local scp, relation
        scp, relation = _des_0[1], _des_0[2]
        do
          local _with_0 = ents.Create('ai_relationship')
          _with_0:SetKeyValue('subject', entClass)
          _with_0:SetKeyValue('target', "dbot_scp" .. tostring(scp) .. "_bullseye")
          _with_0:SetKeyValue('StartActive', '1')
          _with_0:SetKeyValue('Disposition', tostring(relation))
          _with_0:SetKeyValue('Reciprocal', '1')
          _with_0:Spawn()
          _with_0:Activate()
          _with_0:Fire('ApplyRelationship', '', 0)
          _with_0.SCPName = "dbot_scp" .. tostring(scp)
          _with_0.NPCName = entClass
          _with_0.SCP_INSANITY = true
          _accum_0[_len_0] = _with_0
        end
        _len_0 = _len_0 + 1
      end
      SCP_INSANITY_RELATIONSHIPS[entClass] = _accum_0
    end
  end)
end
local _list_1 = ents.GetAll()
for _index_0 = 1, #_list_1 do
  local ent = _list_1[_index_0]
  OnEntityCreated(ent)
end
hook.Add('OnEntityCreated', 'SCPInsanity.Relationships', OnEntityCreated)
return hook.Add('ACF_BulletDamage', 'DBot.SCPInsanity', function(Activated, Entity, Energy, FrAera, Angle, Inflictor, Bone, Gun)
  if Entity:GetClass():find('scp') then
    return false
  end
end)
