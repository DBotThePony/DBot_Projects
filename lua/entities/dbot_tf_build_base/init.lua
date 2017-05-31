local ATTACK_PLAYERS = CreateConVar('dtf2_attack_players', '0', {
  FCVAR_ARCHIVE,
  FCVAR_NOTIFY
}, 'Sentries attacks players')
ENT.OnLeaveGround = function(self) end
ENT.OnLandOnGround = function(self) end
ENT.OnStuck = function(self) end
ENT.OnUnStuck = function(self) end
ENT.OnContact = function(self, victim) end
ENT.OnOtherKilled = function(self, victim, dmg) end
ENT.OnIgnite = function(self) end
ENT.OnNavAreaChanged = function(self, old, new) end
ENT.HandleStuck = function(self) end
ENT.MoveToPos = function(self, pos, options) end
ENT.BehaveStart = function(self) end
ENT.BehaveUpdate = function(self, delta) end
ENT.BodyUpdate = function(self)
  return self:FrameAdvance()
end
ENT.RunBehaviour = function(self) end
ENT.GetEnemy = function(self)
  return self.currentTarget
end
ENT.Explode = function(self)
  return self:Remove()
end
ENT.OnInjured = function(self, dmg) end
ENT.OnKilled = function(self, dmg)
  hook.Run('OnNPCKilled', self, dmg:GetAttacker(), dmg:GetInflictor())
  return self:Explode()
end
local VALID_TARGETS = { }
local VALID_ALLIES = { }
local isEnemy
isEnemy = function(ent)
  if ent == nil then
    ent = NULL
  end
  if not ent:IsValid() then
    return false
  end
  return IsEnemyEntityName(ent:GetClass())
end
local UpdateTargetList
UpdateTargetList = function()
  local findEnts = ents.GetAll()
  VALID_TARGETS = { }
  VALID_ALLIES = { }
  for _index_0 = 1, #findEnts do
    local ent = findEnts[_index_0]
    if ent:IsNPC() and ent:GetClass() ~= 'npc_bullseye' and ent:GetNPCState() ~= NPC_STATE_DEAD then
      local center = ent:OBBCenter()
      center:Rotate(ent:GetAngles())
      local npcData = {
        ent,
        ent:GetPos(),
        ent:OBBMins(),
        ent:OBBMaxs(),
        ent:OBBCenter(),
        center
      }
      local classify = ent:Classify()
      if (classify == CLASS_PLAYER_ALLY or classify == CLASS_PLAYER_ALLY_VITAL or classify == CLASS_PLAYER_ALLY_VITAL or classify == CLASS_CITIZEN_PASSIVE or classify == CLASS_HACKED_ROLLERMINE or classify == CLASS_EARTH_FAUNA or classify == CLASS_VORTIGAUNT or classify == CLASS_CITIZEN_REBEL) then
        table.insert(VALID_ALLIES, npcData)
      elseif (classify == CLASS_COMBINE_HUNTER or classify == CLASS_SCANNER or classify == CLASS_ZOMBIE or classify == CLASS_PROTOSNIPER or classify == CLASS_STALKER or classify == CLASS_MILITARY or classify == CLASS_METROPOLICE or classify == CLASS_MANHACK or classify == CLASS_HEADCRAB or classify == CLASS_COMBINE_GUNSHIP or classify == CLASS_BARNACLE or classify == CLASS_ANTLION or classify == CLASS_NONE or classify == CLASS_COMBINE) then
        table.insert(VALID_TARGETS, npcData)
      end
    end
  end
  if ATTACK_PLAYERS:GetBool() then
    local _list_0 = player.GetAll()
    for _index_0 = 1, #_list_0 do
      local ent = _list_0[_index_0]
      local center = ent:OBBCenter()
      center:Rotate(ent:GetAngles())
      table.insert(VALID_TARGETS, {
        ent,
        ent:GetPos(),
        ent:OBBMins(),
        ent:OBBMaxs(),
        ent:OBBCenter(),
        center
      })
    end
  else
    local _list_0 = player.GetAll()
    for _index_0 = 1, #_list_0 do
      local ent = _list_0[_index_0]
      local center = ent:OBBCenter()
      center:Rotate(ent:GetAngles())
      table.insert(VALID_ALLIES, {
        ent,
        ent:GetPos(),
        ent:OBBMins(),
        ent:OBBMaxs(),
        ent:OBBCenter(),
        center
      })
    end
  end
end
local UpdateTargetListLight
UpdateTargetListLight = function()
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #VALID_TARGETS do
      local _des_0 = VALID_TARGETS[_index_0]
      local ent, pos, mins, maxs, center1, center
      ent, pos, mins, maxs, center1, center = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6]
      if not ent:IsValid() then
        return UpdateTargetList()
      end
      center = ent:OBBCenter()
      center:Rotate(ent:GetAngles())
      local _value_0 = {
        ent,
        ent:GetPos(),
        mins,
        maxs,
        center1,
        center
      }
      _accum_0[_len_0] = _value_0
      _len_0 = _len_0 + 1
    end
    VALID_TARGETS = _accum_0
  end
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #VALID_ALLIES do
      local _des_0 = VALID_ALLIES[_index_0]
      local ent, pos, mins, maxs, center1, center
      ent, pos, mins, maxs, center1, center = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6]
      if not ent:IsValid() then
        return UpdateTargetList()
      end
      center = ent:OBBCenter()
      center:Rotate(ent:GetAngles())
      local _value_0 = {
        ent,
        ent:GetPos(),
        mins,
        maxs,
        center1,
        center
      }
      _accum_0[_len_0] = _value_0
      _len_0 = _len_0 + 1
    end
    VALID_ALLIES = _accum_0
  end
end
hook.Add('Think', 'DTF2.FetchTagrets', UpdateTargetListLight)
hook.Add('PlayerSpawn', 'DTF2.UpdateTargetList', function()
  return timer.Create('DTF2.UpdateTargetList', 0, 1, UpdateTargetList)
end)
hook.Add('PlayerDisconnected', 'DTF2.UpdateTargetList', function()
  return timer.Create('DTF2.UpdateTargetList', 0, 1, UpdateTargetList)
end)
hook.Add('OnEntityCreated', 'DTF2.UpdateTargetList', function()
  return timer.Create('DTF2.UpdateTargetList', 0, 1, UpdateTargetList)
end)
hook.Add('EntityRemoved', 'DTF2.UpdateTargetList', function()
  return timer.Create('DTF2.UpdateTargetList', 0, 1, UpdateTargetList)
end)
hook.Add('OnNPCKilled', 'DTF2.UpdateTargetList', function()
  return timer.Create('DTF2.UpdateTargetList', 0, 1, UpdateTargetList)
end)
UpdateTargetList()
hook.Add('EntityTakeDamage', 'DTF2.Bullseye', function(self, dmg)
  if self.IsTF2Building and dmg:GetAttacker():IsValid() and self:IsAlly(dmg:GetAttacker()) then
    dmg:SetDamage(0)
    dmg:SetMaxDamage(0)
    return true
  end
  if not self.DTF2_Parent then
    return 
  end
  if not dmg:IsExplosionDamage() then
    self.DTF2_Parent:TakeDamageInfo(dmg)
  end
  dmg:SetDamage(0)
  return true
end)
include('shared.lua')
AddCSLuaFile('shared.lua')
ENT.Initialize = function(self)
  self.npc_bullseye = { }
  self:DrawShadow(false)
  self:SetModel(self.IdleModel1)
  self:SetHealth(self.HealthLevel1)
  self:SetMaxHealth(self.HealthLevel1)
  self.mLevel = 1
  self:PhysicsInitBox(self.BuildingMins, self.BuildingMaxs)
  self:SetMoveType(MOVETYPE_NONE)
  self:GetPhysicsObject():EnableMotion(false)
  self.obbcenter = self:OBBCenter()
  self:SetIsBuilding(false)
  self:SetnwLevel(1)
  self:SetBuildSpeedup(false)
  self.lastThink = CurTime()
  self.buildSpeedupUntil = 0
  self.buildFinishAt = 0
  self.upgradeFinishAt = 0
  self:UpdateSequenceList()
  self:StartActivity(ACT_OBJ_RUNNING)
  return self:CreateBullseye()
end
ENT.GetAllies = function(self)
  local _accum_0 = { }
  local _len_0 = 1
  for _index_0 = 1, #VALID_ALLIES do
    local ent = VALID_ALLIES[_index_0]
    _accum_0[_len_0] = ent
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
ENT.GetEnemies = function(self)
  local _accum_0 = { }
  local _len_0 = 1
  for _index_0 = 1, #VALID_TARGETS do
    local ent = VALID_TARGETS[_index_0]
    _accum_0[_len_0] = ent
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
ENT.GetAlliesTable = function(self)
  return VALID_ALLIES
end
ENT.GetEnemiesTable = function(self)
  return VALID_TARGETS
end
ENT.IsEnemy = function(self, target)
  if target == nil then
    target = NULL
  end
  if not IsValid(target) then
    return true
  end
  for _index_0 = 1, #VALID_TARGETS do
    local ent = VALID_TARGETS[_index_0]
    if ent[1] == target then
      return true
    end
  end
  return true
end
ENT.IsAlly = function(self, target)
  if target == nil then
    target = NULL
  end
  if not IsValid(target) then
    return false
  end
  for _index_0 = 1, #VALID_ALLIES do
    local ent = VALID_ALLIES[_index_0]
    if ent[1] == target then
      return true
    end
  end
  return false
end
ENT.CreateBullseye = function(self)
  if self.npc_bullseye then
    local _list_0 = self.npc_bullseye
    for _index_0 = 1, #_list_0 do
      local eye = _list_0[_index_0]
      eye:Remove()
    end
  end
  local mins, maxs, center = self:OBBMins(), self:OBBMaxs(), self:OBBCenter()
  local box = {
    Vector(0, 0, mins.z),
    Vector(0, 0, maxs.z),
    Vector(mins.x, center.y, center.z),
    Vector(-mins.x, center.y, center.z),
    Vector(center.x, mins.y, center.z),
    Vector(center.x, -mins.y, center.z)
  }
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #box do
      local vec = box[_index_0]
      do
        local _with_0 = ents.Create('npc_bullseye')
        _with_0:SetKeyValue('targetname', 'dtf2_bullseye')
        _with_0:SetKeyValue('spawnflags', '131072')
        _with_0:SetPos(self:LocalToWorld(vec))
        _with_0:Spawn()
        _with_0:Activate()
        _with_0:SetCollisionGroup(COLLISION_GROUP_WORLD)
        _with_0:SetHealth(2 ^ 31 - 1)
        _with_0:SetParent(self)
        _with_0:SetNotSolid(true)
        _with_0.DTF2_Parent = self
        _accum_0[_len_0] = _with_0
      end
      _len_0 = _len_0 + 1
    end
    self.npc_bullseye = _accum_0
  end
end
ENT.UpdateRelationships = function(self)
  for _index_0 = 1, #VALID_TARGETS do
    local _des_0 = VALID_TARGETS[_index_0]
    local target
    target = _des_0[1]
    if target:IsValid() and target:IsNPC() then
      local _list_0 = self.npc_bullseye
      for _index_1 = 1, #_list_0 do
        local eye = _list_0[_index_1]
        target:AddEntityRelationship(eye, D_HT, 0)
      end
    end
  end
  for _index_0 = 1, #VALID_ALLIES do
    local _des_0 = VALID_ALLIES[_index_0]
    local target
    target = _des_0[1]
    if target:IsValid() and target:IsNPC() then
      local _list_0 = self.npc_bullseye
      for _index_1 = 1, #_list_0 do
        local eye = _list_0[_index_1]
        target:AddEntityRelationship(eye, D_LI, 0)
      end
    end
  end
end
ENT.GetAlliesVisible = function(self)
  local output = { }
  local pos = self:GetPos()
  for _index_0 = 1, #VALID_ALLIES do
    local _des_0 = VALID_ALLIES[_index_0]
    local target, tpos, mins, maxs, center, rotatedCenter
    target, tpos, mins, maxs, center, rotatedCenter = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6]
    local dist = pos:DistToSqr(tpos)
    if target:IsValid() and dist < self.MAX_DISTANCE then
      table.insert(output, {
        target,
        tpos,
        dist,
        rotatedCenter
      })
    end
  end
  table.sort(output, function(a, b)
    return a[3] < b[3]
  end)
  local newOutput = { }
  local trFilter
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = self.npc_bullseye
    for _index_0 = 1, #_list_0 do
      local eye = _list_0[_index_0]
      _accum_0[_len_0] = eye
      _len_0 = _len_0 + 1
    end
    trFilter = _accum_0
  end
  table.insert(trFilter, self)
  for _index_0 = 1, #output do
    local _des_0 = output[_index_0]
    local target, tpos, dist, center
    target, tpos, dist, center = _des_0[1], _des_0[2], _des_0[3], _des_0[4]
    local trData = {
      filter = trFilter,
      start = self.obbcenter + pos,
      endpos = tpos + center,
      mins = self.HULL_TRACE_MINS,
      maxs = self.HULL_TRACE_MAXS
    }
    local tr = util.TraceHull(trData)
    if tr.Hit and tr.Entity == target then
      table.insert(newOutput, target)
    end
  end
  return newOutput
end
ENT.GetTargetsVisible = function(self)
  local output = { }
  local pos = self:GetPos()
  for _index_0 = 1, #VALID_TARGETS do
    local _des_0 = VALID_TARGETS[_index_0]
    local target, tpos, mins, maxs, center, rotatedCenter
    target, tpos, mins, maxs, center, rotatedCenter = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6]
    local dist = pos:DistToSqr(tpos)
    if target:IsValid() and dist < self.MAX_DISTANCE then
      table.insert(output, {
        target,
        tpos,
        dist,
        rotatedCenter
      })
    end
  end
  table.sort(output, function(a, b)
    return a[3] < b[3]
  end)
  local newOutput = { }
  local trFilter
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = self.npc_bullseye
    for _index_0 = 1, #_list_0 do
      local eye = _list_0[_index_0]
      _accum_0[_len_0] = eye
      _len_0 = _len_0 + 1
    end
    trFilter = _accum_0
  end
  table.insert(trFilter, self)
  for _index_0 = 1, #output do
    local _des_0 = output[_index_0]
    local target, tpos, dist, center
    target, tpos, dist, center = _des_0[1], _des_0[2], _des_0[3], _des_0[4]
    local trData = {
      filter = trFilter,
      start = self.obbcenter + pos,
      endpos = tpos + center,
      mins = self.HULL_TRACE_MINS,
      maxs = self.HULL_TRACE_MAXS
    }
    local tr = util.TraceHull(trData)
    if tr.Hit and tr.Entity == target then
      table.insert(newOutput, target)
    end
  end
  return newOutput
end
ENT.GetFirstVisible = function(self)
  local output = { }
  local pos = self:GetPos()
  for _index_0 = 1, #VALID_TARGETS do
    local _des_0 = VALID_TARGETS[_index_0]
    local target, tpos, mins, maxs, center, rotatedCenter
    target, tpos, mins, maxs, center, rotatedCenter = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6]
    local dist = pos:DistToSqr(tpos)
    if target:IsValid() and dist < self.MAX_DISTANCE then
      table.insert(output, {
        target,
        tpos,
        dist,
        rotatedCenter
      })
    end
  end
  table.sort(output, function(a, b)
    return a[3] < b[3]
  end)
  local trFilter
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = self.npc_bullseye
    for _index_0 = 1, #_list_0 do
      local eye = _list_0[_index_0]
      _accum_0[_len_0] = eye
      _len_0 = _len_0 + 1
    end
    trFilter = _accum_0
  end
  table.insert(trFilter, self)
  for _index_0 = 1, #output do
    local _des_0 = output[_index_0]
    local target, tpos, dist, center
    target, tpos, dist, center = _des_0[1], _des_0[2], _des_0[3], _des_0[4]
    local trData = {
      filter = trFilter,
      start = self.obbcenter + pos,
      endpos = tpos + center,
      mins = self.HULL_TRACE_MINS,
      maxs = self.HULL_TRACE_MAXS
    }
    local tr = util.TraceHull(trData)
    if tr.Hit and tr.Entity == target then
      return target
    end
  end
  return NULL
end
ENT.SetLevel = function(self, val, playAnimation)
  if val == nil then
    val = 1
  end
  if playAnimation == nil then
    playAnimation = true
  end
  if val == self:GetLevel() then
    return false
  end
  val = math.Clamp(math.floor(val), 1, 3)
  self:SetnwLevel(val)
  self.mLevel = val
  local _exp_0 = val
  if 1 == _exp_0 then
    self:SetModel(self.IdleModel1)
    if self:Health() == self:GetMaxHealth() then
      self:SetHealth(self.HealthLevel1)
    end
    self:SetMaxHealth(self.HealthLevel1)
    self:UpdateSequenceList()
  elseif 2 == _exp_0 then
    self:SetModel(self.IdleModel2)
    if self:Health() == self:GetMaxHealth() then
      self:SetHealth(self.HealthLevel2)
    end
    self:SetMaxHealth(self.HealthLevel2)
    self:UpdateSequenceList()
    if playAnimation then
      self:PlayUpgradeAnimation()
    end
  elseif 3 == _exp_0 then
    self:SetModel(self.IdleModel3)
    self:SetHealth(self.HealthLevel3)
    self:SetMaxHealth(self.HealthLevel3)
    self:UpdateSequenceList()
    if playAnimation then
      self:PlayUpgradeAnimation()
    end
  end
  self:CreateBullseye()
  self:SetUpgradeAmount(0)
  return true
end
ENT.PlayUpgradeAnimation = function(self)
  if self:GetLevel() == 1 then
    return false
  end
  self:SetIsUpgrading(true)
  local _exp_0 = self:GetLevel()
  if 2 == _exp_0 then
    self.upgradeFinishAt = CurTime() + self.UPGRADE_TIME_2
    self:SetModel(self.BuildModel2)
  elseif 3 == _exp_0 then
    self.upgradeFinishAt = CurTime() + self.UPGRADE_TIME_3
    self:SetModel(self.BuildModel3)
  end
  self:UpdateSequenceList()
  self:StartActivity(ACT_OBJ_UPGRADING)
  self:ResetSequence(self.upgradeSequence)
  return true
end
ENT.DoSpeedup = function(self, time)
  if time == nil then
    time = 1
  end
  self:SetBuildSpeedup(true)
  self:SetPlaybackRate(0.5)
  return timer.Create("DTF2.BuildSpeedup." .. tostring(self:EntIndex()), time, 1, function()
    if not IsValid(self) then
      return 
    end
    self:SetBuildSpeedup(false)
    return self:SetPlaybackRate(1)
  end)
end
ENT.SetBuildStatus = function(self, status)
  if status == nil then
    status = false
  end
  if self:GetLevel() > 1 then
    return false
  end
  if self:GetIsBuilding() == status then
    return false
  end
  self:SetIsBuilding(status)
  if status then
    self:SetModel(self.BuildModel1)
    self:UpdateSequenceList()
    self:SetBuildSpeedup(false)
    self:StartActivity(ACT_OBJ_PLACING)
    self:ResetSequence(self.buildSequence)
    self.buildFinishAt = CurTime() + self.BuildTime
    self:OnBuildStart()
    self:SetPlaybackRate(0.5)
  else
    self:SetModel(self.IdleModel1)
    self:UpdateSequenceList()
    self:ResetSequence(self.idleSequence)
    self:StartActivity(ACT_OBJ_RUNNING)
    self:OnBuildFinish()
    self:SetPlaybackRate(1)
  end
  return true
end
ENT.OnBuildStart = function(self) end
ENT.OnBuildFinish = function(self) end
ENT.OnUpgradeFinish = function(self) end
ENT.Think = function(self)
  local cTime = CurTime()
  local delta = cTime - self.lastThink
  self.lastThink = cTime
  if self:GetIsBuilding() then
    if self:GetBuildSpeedup() then
      self.buildFinishAt = self.buildFinishAt - delta
    end
    if self.buildFinishAt < cTime then
      self:SetBuildSpeedup(false)
      self:SetIsBuilding(false)
      self:SetModel(self.IdleModel1)
      self:UpdateSequenceList()
      self:StartActivity(ACT_OBJ_RUNNING)
      self:ResetSequence(self.idleSequence)
      self:OnBuildFinish()
      return self:SetPlaybackRate(1)
    end
  elseif self:GetIsUpgrading() then
    if self.upgradeFinishAt < cTime then
      self:SetBuildSpeedup(false)
      self:SetIsUpgrading(false)
      local _exp_0 = self:GetLevel()
      if 2 == _exp_0 then
        self:SetModel(self.IdleModel2)
      elseif 3 == _exp_0 then
        self:SetModel(self.IdleModel3)
      end
      self:UpdateSequenceList()
      self:StartActivity(ACT_OBJ_RUNNING)
      self:ResetSequence(self.idleSequence)
      return self:OnUpgradeFinish()
    end
  end
end
