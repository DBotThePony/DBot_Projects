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
return nil
