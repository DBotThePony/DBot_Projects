local ATTACK_PLAYERS = CreateConVar('dtf2_attack_players', '1', {
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
ENT.BodyUpdate = function(self) end
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
hook.Add('Think', 'DTF2.FetchTagrets', function()
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
        if not isEnemy(ent) then
          _continue_0 = true
          break
        end
        local _value_0 = {
          ent,
          ent:GetPos(),
          ent:OBBMins(),
          ent:OBBMaxs(),
          ent:OBBCenter()
        }
        _accum_0[_len_0] = _value_0
        _len_0 = _len_0 + 1
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
    VALID_TARGETS = _accum_0
  end
  if ATTACK_PLAYERS:GetBool() then
    local _list_0 = player.GetAll()
    for _index_0 = 1, #_list_0 do
      local ent = _list_0[_index_0]
      table.insert(VALID_TARGETS, {
        ent,
        ent:GetPos(),
        ent:OBBMins(),
        ent:OBBMaxs(),
        ent:OBBCenter()
      })
    end
  end
end)
include('shared.lua')
AddCSLuaFile('shared.lua')
ENT.Initialize = function(self)
  self:SetModel(self.IdleModel1)
  self:SetHP(self.HealthLevel1)
  self:SetMHP(self.HealthLevel1)
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
  return self:StartActivity(ACT_OBJ_RUNNING)
end
ENT.GetTargetsVisible = function(self)
  local output = { }
  local pos = self:GetPos()
  for _index_0 = 1, #VALID_TARGETS do
    local _des_0 = VALID_TARGETS[_index_0]
    local target, tpos, mins, maxs, center
    target, tpos, mins, maxs, center = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5]
    local dist = pos:DistToSqr(tpos)
    if target:IsValid() and dist < self.MAX_DISTANCE then
      table.insert(output, {
        target,
        tpos,
        dist,
        center
      })
    end
  end
  table.sort(output, function(a, b)
    return a[3] < b[3]
  end)
  local newOutput = { }
  for _index_0 = 1, #output do
    local _des_0 = output[_index_0]
    local target, tpos, dist, center
    target, tpos, dist, center = _des_0[1], _des_0[2], _des_0[3], _des_0[4]
    local trData = {
      filter = self,
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
    local target, tpos, mins, maxs, center
    target, tpos, mins, maxs, center = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5]
    local dist = pos:DistToSqr(tpos)
    if target:IsValid() and dist < self.MAX_DISTANCE then
      table.insert(output, {
        target,
        tpos,
        dist,
        center
      })
    end
  end
  table.sort(output, function(a, b)
    return a[3] < b[3]
  end)
  for _index_0 = 1, #output do
    local _des_0 = output[_index_0]
    local target, tpos, dist, center
    target, tpos, dist, center = _des_0[1], _des_0[2], _des_0[3], _des_0[4]
    local trData = {
      filter = self,
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
ENT.UpdateSequenceList = function(self)
  self.buildSequence = self:LookupSequence('build')
  self.upgradeSequence = self:LookupSequence('upgrade')
  self.idleSequence = self:LookupSequence(self.IDLE_ANIM)
end
ENT.GetLevel = function(self)
  return self:GetnwLevel()
end
ENT.SetLevel = function(self, val, playAnimation)
  if val == nil then
    val = 1
  end
  if playAnimation == nil then
    playAnimation = true
  end
  val = math.Clamp(math.floor(val), 1, 3)
  self:SetnwLevel(val)
  self.mLevel = val
  local _exp_0 = val
  if 1 == _exp_0 then
    self:SetModel(self.IdleModel1)
    self:SetHP(self.HealthLevel1)
    self:SetMHP(self.HealthLevel1)
    return self:UpdateSequenceList()
  elseif 2 == _exp_0 then
    self:SetModel(self.IdleModel2)
    if self:GetHP() == self:GetMHP() then
      self:SetHP(self.HealthLevel2)
    end
    self:SetMHP(self.HealthLevel2)
    self:UpdateSequenceList()
    if playAnimation then
      return self:PlayUpgradeAnimation()
    end
  elseif 3 == _exp_0 then
    self:SetModel(self.IdleModel3)
    self:SetHP(self.HealthLevel3)
    self:SetMHP(self.HealthLevel3)
    self:UpdateSequenceList()
    if playAnimation then
      return self:PlayUpgradeAnimation()
    end
  end
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
  return true
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
    self.buildSpeedupUntil = 0
    self:StartActivity(ACT_OBJ_PLACING)
    self.buildFinishAt = CurTime() + self.BuildTime
    self:OnBuildStart()
  else
    self:SetModel(self.IdleModel1)
    self:UpdateSequenceList()
    self:StartActivity(ACT_OBJ_RUNNING)
    self:OnBuildFinish()
  end
  return true
end
ENT.OnBuildStart = function(self) end
ENT.OnBuildFinish = function(self) end
ENT.OnUpgradeFinish = function(self) end
ENT.BuildThink = function(self) end
ENT.IsAvaliable = function(self)
  return not self:GetIsBuilding() and not self:GetIsUpgrading()
end
ENT.Think = function(self)
  local cTime = CurTime()
  local delta = cTime - self.lastThink
  self.lastThink = cTime
  if self:GetIsBuilding() then
    if self.buildSpeedupUntil > cTime then
      self.buildFinishAt = self.buildFinishAt - delta
    end
    if self.buildFinishAt < cTime then
      self:SetBuildSpeedup(false)
      self:SetIsBuilding(false)
      self:SetModel(self.IdleModel1)
      self:UpdateSequenceList()
      self:StartActivity(ACT_OBJ_RUNNING)
      return self:OnBuildFinish()
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
      return self:OnUpgradeFinish()
    end
  end
end
