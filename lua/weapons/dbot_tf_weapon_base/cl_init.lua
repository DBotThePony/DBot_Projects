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
  local hands = LocalPlayer():GetHands()
  if not IsValid(hands) then
    return 
  end
  local seqId = hands:SelectWeightedSequence(act)
  if seqId then
    return hands:ResetSequence(seqId)
  end
end
return nil
