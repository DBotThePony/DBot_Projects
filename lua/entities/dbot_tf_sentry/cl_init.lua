include('shared.lua')
local MUZZLE_BONE_ID_1 = 4
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
ENT.Draw = function(self)
  local deltaFireAnim = self.fireAnim - CurTime()
  local pitchAdd = 0
  if deltaFireAnim > 0 then
    local deltaFireAnimNormal = math.abs(0.3 - deltaFireAnim / MUZZLE_ANIM_TIME)
    if not self.isEmpty then
      pitchAdd = pitchAdd + (deltaFireAnimNormal * 5)
    end
    self:ManipulateBonePosition(MUZZLE_BONE_ID_1, Vector(0, 0, -deltaFireAnimNormal * 4))
  else
    self:ManipulateBonePosition(MUZZLE_BONE_ID_1, Vector())
  end
  local diffPitch = math.AngleDifference(self.lastPitch, self:GetAimPitch())
  local diffYaw = math.AngleDifference(self.lastYaw, self:GetAimYaw())
  self.lastPitch = Lerp(FrameTime() * 10, self.lastPitch, self.lastPitch - diffPitch)
  self.lastYaw = Lerp(FrameTime() * 10, self.lastYaw, self.lastYaw - diffYaw)
  self:SetPoseParameter('aim_pitch', self.lastPitch + pitchAdd)
  self:SetPoseParameter('aim_yaw', self.lastYaw)
  self:InvalidateBoneCache()
  return self.BaseClass.Draw(self)
end
net.Receive('DTF2.SentryWing', function()
  local sentry = net.ReadEntity()
  if not IsValid then
    return 
  end
  local target = net.ReadEntity()
  if target ~= LocalPlayer() then
    return sentry:EmitSound('weapons/sentry_spot.wav', SNDLVL_85dB)
  else
    return sentry:EmitSound('weapons/sentry_spot_client.wav', SNDLVL_105dB)
  end
end)
return net.Receive('DTF2.SentryFire', function()
  local sentry = net.ReadEntity()
  if not IsValid then
    return 
  end
  local isEmpty = not net.ReadBool()
  sentry.isEmpty = isEmpty
  sentry.fireAnim = CurTime() + MUZZLE_ANIM_TIME
end)
