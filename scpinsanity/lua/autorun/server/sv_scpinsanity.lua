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
SCP_NoKill = false
SCP_Ignore = {
  bullseye_strider_focus = true
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
timer.Create('SCPInsanity.UpdateNPCs', 1, 0, function()
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = ents.GetAll()
    for _index_0 = 1, #_list_0 do
      local _continue_0 = false
      repeat
        local ent = _list_0[_index_0]
        if not ent:IsNPC() then
          _continue_0 = true
          break
        end
        if ent:GetNPCState() == NPC_STATE_DEAD then
          _continue_0 = true
          break
        end
        if SCP_Ignore[ent:GetClass()] then
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
end)
SCP_GetTargets = function()
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
  if SCP_INSANITY_ATTACK_PLAYERS:GetBool() then
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
local ENT = { }
ENT.PrintName = 'MAGIC'
ENT.Author = 'DBot'
ENT.Type = 'point'
scripted_ents.Register(ENT, 'dbot_scp173_killer')
hook.Add('OnNPCKilled', 'DBot.SCPInsanity', OnNPCKilled)
hook.Add('PlayerDeath', 'DBot.SCPInsanity', PlayerDeath)
return hook.Add('ACF_BulletDamage', 'DBot.SCPInsanity', function(Activated, Entity, Energy, FrAera, Angle, Inflictor, Bone, Gun)
  if Entity:GetClass():find('scp') then
    return false
  end
end)
