include('shared.lua')
net.Receive('DTF2.SendWeaponAnim', function()
  local act = net.ReadUInt(16)
  local wep = LocalPlayer():GetActiveWeapon()
  if not IsValid(wep) then
    return 
  end
  return wep:SendWeaponAnim2(act)
end)
net.Receive('DTF2.SendWeaponSequence', function()
  local act = net.ReadUInt(16)
  local wep = LocalPlayer():GetActiveWeapon()
  if not IsValid(wep) then
    return 
  end
  return wep:SendWeaponSequence(act)
end)
SWEP.SendWeaponSequence = function(self, seq)
  if seq == nil then
    seq = 0
  end
  if not IsValid(self:GetOwner()) then
    return 
  end
  local hands = self:GetOwner():GetViewModel()
  if not IsValid(hands) then
    return 
  end
  if type(seq) ~= 'number' then
    seq = hands:LookupSequence(seq)
  end
  return hands:SendViewModelMatchingSequence(seq)
end
SWEP.SendWeaponAnim2 = function(self, act)
  if act == nil then
    act = ACT_INVALID
  end
  if not IsValid(self:GetOwner()) then
    return 
  end
  local hands = self:GetOwner():GetHands()
  if not IsValid(hands) then
    return 
  end
  local seqId = hands:SelectWeightedSequence(act)
  if seqId then
    return hands:ResetSequence(seqId)
  end
end
SWEP.PostDrawViewModel = function(self, viewmodel, weapon, ply)
  if viewmodel == nil then
    viewmodel = NULL
  end
  if weapon == nil then
    weapon = NULL
  end
  if ply == nil then
    ply = NULL
  end
  if not IsValid(self:GetTF2WeaponModel()) then
    return 
  end
  return self:GetTF2WeaponModel():DrawModel()
end
return nil
