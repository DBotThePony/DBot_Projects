include('shared.lua')
AddCSLuaFile('shared.lua')
SWEP.FireTrigger = function(self)
  self.incomingFire = false
  self.bulletCallbackCalled = false
  self.onHitCalled = false
  local origin = self:GetOwner():EyePos()
  local dir = self:GetOwner():GetAimVector()
  self.incomingCrit = false
  self.incomingMiniCrit = false
end
