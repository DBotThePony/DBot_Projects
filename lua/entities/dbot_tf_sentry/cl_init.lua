include('shared.lua')
local OLD_SENTRY_MUZZLEFLASH = CreateConVar('dtf2_sentry_muzzleflash', '1', {
  FCVAR_ARCHIVE
}, 'Use old sentry muzzleflash')
local MUZZLE_BONE_ID_1 = 4
local MUZZLE_BONE_ID_2_L = 7
local MUZZLE_BONE_ID_2_R = 8
local MUZZLE_BONE_ID_3_L = 5
local MUZZLE_BONE_ID_3_R = 12
local MUZZLE_ANIM_TIME = 0.3
ENT.Initialize = function(self)
  self.BaseClass.Initialize(self)
  self:SetAimPitch(0)
  self:SetAimYaw(0)
  self.lastPitch = 0
  self.lastYaw = 0
  self.fireAnim = 0
  self.isEmpty = false
end
ENT.GetHUDText = function(self)
  local text = "Bullets: " .. tostring(self:GetAmmoAmount()) .. "/" .. tostring(self:GetMaxAmmo()) .. "\n"
  if self:GetLevel() == 3 then
    text = text .. "Rockets: " .. tostring(self:GetRockets()) .. "/" .. tostring(self.MAX_ROCKETS) .. "\n"
  end
  return text
end
ENT.CreateMuzzleflashModel = function(self, attach)
  if attach == nil then
    attach = ''
  end
  attach = self:GetAttachment(self:LookupAttachment(attach))
  if not attach then
    return 
  end
  local muzzleflash = ClientsideModel('models/effects/sentry1_muzzle/sentry1_muzzle.mdl')
  timer.Simple(0.1, function()
    return muzzleflash:Remove()
  end)
  do
    muzzleflash:SetPos(attach.Pos)
    muzzleflash:SetAngles(attach.Ang)
  end
  muzzleflash:SetModelScale(math.random(80, 100) / 100)
  return muzzleflash
end
ENT.Draw = function(self)
  local deltaFireAnim = self.fireAnim - CurTime()
  local pitchAdd = 0
  local _exp_0 = self:GetLevel()
  if 1 == _exp_0 then
    if deltaFireAnim > 0 then
      local deltaFireAnimNormal = math.abs(0.3 - deltaFireAnim / MUZZLE_ANIM_TIME)
      if not self.isEmpty then
        pitchAdd = pitchAdd + (deltaFireAnimNormal * 5)
      end
      self:ManipulateBonePosition(MUZZLE_BONE_ID_1, Vector(0, 0, -deltaFireAnimNormal * 4))
    else
      self:ManipulateBonePosition(MUZZLE_BONE_ID_1, Vector())
    end
  elseif 2 == _exp_0 then
    if deltaFireAnim > 0 then
      local deltaFireAnimNormal = math.abs(deltaFireAnim / MUZZLE_ANIM_TIME)
      local ang = Angle(0, -180 + deltaFireAnimNormal * 360, 0)
      self:ManipulateBoneAngles(MUZZLE_BONE_ID_2_L, ang)
      self:ManipulateBoneAngles(MUZZLE_BONE_ID_2_R, ang)
    else
      local ang = Angle(0, 0, 0)
      self:ManipulateBoneAngles(MUZZLE_BONE_ID_2_L, ang)
      self:ManipulateBoneAngles(MUZZLE_BONE_ID_2_R, ang)
    end
  elseif 3 == _exp_0 then
    if deltaFireAnim > 0 then
      local deltaFireAnimNormal = math.abs(deltaFireAnim / MUZZLE_ANIM_TIME)
      local ang = Angle(0, -180 + deltaFireAnimNormal * 360, 0)
      self:ManipulateBoneAngles(MUZZLE_BONE_ID_3_L, ang)
      self:ManipulateBoneAngles(MUZZLE_BONE_ID_3_R, ang)
    else
      local ang = Angle(0, 0, 0)
      self:ManipulateBoneAngles(MUZZLE_BONE_ID_3_L, ang)
      self:ManipulateBoneAngles(MUZZLE_BONE_ID_3_R, ang)
    end
  end
  local diffPitch = math.AngleDifference(self.lastPitch, self:GetAimPitch())
  local diffYaw = math.AngleDifference(self.lastYaw, self:GetAimYaw())
  self.lastPitch = Lerp(FrameTime() * 10, self.lastPitch, self.lastPitch - diffPitch)
  self.lastYaw = Lerp(FrameTime() * 10, self.lastYaw, self.lastYaw - diffYaw)
  self.aim_pitch = self.lastPitch + pitchAdd + math.random(1, 2) / 100
  self.aim_yaw = self.lastYaw + math.random(1, 2) / 100
  self:SetPoseParameter('aim_pitch', self.aim_pitch)
  self:SetPoseParameter('aim_yaw', self.aim_yaw)
  self:InvalidateBoneCache()
  return self.BaseClass.Draw(self)
end
net.Receive('DTF2.SentryWing', function()
  local sentry = net.ReadEntity()
  if not IsValid(sentry) then
    return 
  end
  local target = net.ReadEntity()
  if target ~= LocalPlayer() then
    return sentry:EmitSound('weapons/sentry_spot.wav', 75, 100, 0.3)
  else
    return sentry:EmitSound('weapons/sentry_spot_client.wav', SNDLVL_105dB)
  end
end)
return net.Receive('DTF2.SentryFire', function()
  local sentry = net.ReadEntity()
  if not IsValid(sentry) then
    return 
  end
  local isEmpty = not net.ReadBool()
  sentry.isEmpty = isEmpty
  sentry.fireAnim = CurTime() + MUZZLE_ANIM_TIME
  if not isEmpty then
    sentry:EmitSound('weapons/sentry_shoot.wav', 75, 100, 0.6, CHAN_WEAPON)
  end
  if isEmpty then
    sentry:EmitSound('weapons/sentry_empty.wav', 75, 100, 0.8, CHAN_WEAPON)
  end
  sentry:SetPoseParameter('aim_pitch', (sentry.aim_pitch or 0) + math.random(1, 2) / 2)
  sentry:SetPoseParameter('aim_yaw', (sentry.aim_yaw or 0) + math.random(1, 2) / 2)
  sentry:InvalidateBoneCache()
  if not isEmpty then
    if OLD_SENTRY_MUZZLEFLASH:GetBool() then
      local _exp_0 = sentry:GetLevel()
      if 1 == _exp_0 then
        return sentry:CreateMuzzleflashModel('muzzle')
      elseif 2 == _exp_0 or 3 == _exp_0 then
        sentry.nextMuzzle = not sentry.nextMuzzle
        return sentry:CreateMuzzleflashModel(sentry.nextMuzzle and 'muzzle_l' or 'muzzle_r')
      end
    else
      local _exp_0 = sentry:GetLevel()
      if 1 == _exp_0 then
        do
          local _with_0 = sentry:GetAttachment(sentry:LookupAttachment('muzzle'))
          ParticleEffect('muzzle_sentry', _with_0.Pos, _with_0.Ang, self)
          return _with_0
        end
      elseif 2 == _exp_0 or 3 == _exp_0 then
        sentry.nextMuzzle = not sentry.nextMuzzle
        do
          local _with_0 = sentry:GetAttachment(sentry:LookupAttachment(sentry.nextMuzzle and 'muzzle_l' or 'muzzle_r'))
          ParticleEffect('muzzle_sentry2', _with_0.Pos, _with_0.Ang, self)
          return _with_0
        end
      end
    end
  end
end)
