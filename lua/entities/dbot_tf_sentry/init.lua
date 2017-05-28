include('shared.lua')
AddCSLuaFile('shared.lua')
util.AddNetworkString('DTF2.SentryWing')
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
timer.Create('DTF2.FetchTargets', 0.5, 0, function()
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
end)
ENT.MAX_DISTANCE = 512 ^ 2
ENT.Initialize = function(self)
  self.BaseClass.Initialize(self)
  self.targetAngle = Angle(0, 0, 0)
  self.currentAngle = Angle(0, 0, 0)
  self.moveSpeed = 2
  self.idleAnim = true
  self.idleAngle = Angle(0, 0, 0)
  self.idleDirection = false
  self.idleYaw = 0
  self.center = self:OBBCenter()
  self.currentTarget = NULL
  self.idleWaitOnAngle = 0
  self.lastSentryThink = CurTime()
  self.nextTargetUpdate = 0
end
ENT.GetTargetsVisible = function(self)
  local output = { }
  local pos = self:GetPos()
  local _list_0 = player.GetAll()
  for _index_0 = 1, #_list_0 do
    local ply = _list_0[_index_0]
    local ppos = ply:GetPos()
    local dist = pos:DistToSqr(ppos)
    if ply ~= self:GetPlayer() and dist < self.MAX_DISTANCE then
      table.insert(output, {
        ply,
        ppos,
        dist,
        ply:OBBCenter()
      })
    end
  end
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
      start = self.center + pos,
      endpos = center + tpos
    }
    local tr = util.TraceLine(trData)
    if tr.Hit and tr.Entity == target then
      table.insert(newOutput, target)
    end
  end
  return newOutput
end
ENT.GetFirstVisible = function(self)
  local output = { }
  local pos = self:GetPos()
  local _list_0 = player.GetAll()
  for _index_0 = 1, #_list_0 do
    local ply = _list_0[_index_0]
    local ppos = ply:GetPos()
    local dist = pos:DistToSqr(ppos)
    if ply ~= self:GetPlayer() and dist < self.MAX_DISTANCE then
      table.insert(output, {
        ply,
        ppos,
        dist,
        ply:OBBCenter()
      })
    end
  end
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
      start = self.center + pos,
      endpos = center + tpos
    }
    local tr = util.TraceLine(trData)
    if tr.Hit and tr.Entity == target then
      return target
    end
  end
  return NULL
end
ENT.Think = function(self)
  local cTime = CurTime()
  local delta = cTime - self.lastSentryThink
  self.lastSentryThink = cTime
  self.BaseClass.Think(self)
  if not self:IsAvaliable() then
    self.currentTarget = NULL
    return 
  end
  if self.nextTargetUpdate < cTime then
    self.nextTargetUpdate = cTime + 0.1
    local newTarget = self:GetFirstVisible()
    if newTarget ~= self.currentTarget then
      self.currentTarget = newTarget
      if IsValid(newTarget) then
        net.Start('DTF2.SentryWing', true)
        net.WriteEntity(self)
        net.WriteEntity(newTarget)
        net.Broadcast()
      end
    end
  end
  if IsValid(self.currentTarget) then
    self.currentTargetPosition = self.currentTarget:GetPos() + self.currentTarget:OBBCenter()
    self.idleWaitOnAngle = cTime + 2
    self.targetAngle = (self.currentTargetPosition - self:GetPos()):Angle()
    self.idleAngle = self.targetAngle
    self.idleAnim = false
    self.idleDirection = false
    self.idleYaw = 0
  else
    self.idleAnim = true
    if self.idleWaitOnAngle < cTime then
      self.idleAngle = Angle(0, 0, 0)
    end
    if self.idleDirection then
      self.idleYaw = self.idleYaw + delta
    end
    if not self.idleDirection then
      self.idleYaw = self.idleYaw - delta
    end
    if self.idleYaw > 30 or self.idleYaw < -30 then
      self.idleDirection = not self.idleDirection
    end
    local p, y, r
    do
      local _obj_0 = self.idleAngle
      p, y, r = _obj_0.p, _obj_0.y, _obj_0.r
    end
    self.targetAngle = Angle(p, y + self.idleYaw, r)
  end
  local diffPitch = math.Clamp(math.AngleDifference(self.currentAngle.p, self.targetAngle.p), -2, 2)
  local diffYaw = math.Clamp(math.AngleDifference(self.currentAngle.y, self.targetAngle.y), -2, 2)
  self.currentAngle = Angle(self.currentAngle.p - diffPitch, self.currentAngle.y - diffYaw, 0)
  local p, y, r
  do
    local _obj_0 = self.currentAngle
    p, y, r = _obj_0.p, _obj_0.y, _obj_0.r
  end
  local cp, cy, cr
  do
    local _obj_0 = self:GetAngles()
    cp, cy, cr = _obj_0.p, _obj_0.y, _obj_0.r
  end
  local posePitch = math.floor(math.NormalizeAngle(cp - p))
  local poseYaw = math.floor(math.NormalizeAngle(cy - y))
  self:SetAimPitch(posePitch)
  self:SetAimYaw(poseYaw)
  self:NextThink(cTime)
  return true
end
