include('shared.lua')
ENT.Initialize = function(self)
  self.BaseClass.Initialize(self)
  self:SetAimPitch(0)
  return self:SetAimYaw(0)
end
ENT.Draw = function(self)
  self:SetPoseParameter('aim_pitch', self:GetAimPitch())
  self:SetPoseParameter('aim_yaw', self:GetAimYaw())
  self:InvalidateBoneCache()
  return self.BaseClass.Draw(self)
end
return net.Receive('DTF2.SentryWing', function()
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
