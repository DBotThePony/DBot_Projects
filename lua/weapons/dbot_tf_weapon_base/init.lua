include('shared.lua')
AddCSLuaFile('shared.lua')
SWEP.EmitSoundServerside = function(self, ...)
  if self.suppressing then
    SuppressHostEvents(NULL)
  end
  self:EmitSound(...)
  if self.suppressing then
    return SuppressHostEvents(self:GetOwner())
  end
end
SWEP.CheckCritical = function(self)
  if self:GetNextCrit() then
    return 
  end
  if self.lastCritsTrigger > CurTime() then
    return 
  end
  if self.lastCritsCheck > CurTime() then
    return 
  end
  if self.CritsCheckCooldown ~= 0 then
    self.lastCritsCheck = CurTime() + self.CritsCheckCooldown
  end
  local chance = self.CritChance + math.min(self.CritExponent * self.damageDealtForCrit, self.CritExponentMax)
  if math.random(1, 100) < chance then
    return self:TriggerCriticals()
  end
end
SWEP.TriggerCriticals = function(self)
  if self.lastCritsTrigger > CurTime() then
    return 
  end
  self.damageDealtForCrit = 0
  self.lastCritsTrigger = CurTime() + self.CritsCooldown
  self:SetNextCrit(true)
  if not self.SingleCrit then
    self.lastCritsTrigger = CurTime() + self.CritDuration + self.CritsCooldown
    self:SetCriticalsDuration(CurTime() + self.CritDuration)
    return timer.Create("DTF2.CriticalsTimer." .. tostring(self:EntIndex()), self.CritDuration, 1, function()
      if not self:IsValid() then
        return self:SetNextCrit(false)
      end
    end)
  end
end
return nil
