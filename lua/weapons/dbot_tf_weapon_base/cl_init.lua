include('shared.lua')
hook.Add('PreDrawPlayerHands', 'DTF2.WeaponHandsFix', function(hands, viewmodel, ply, weapon)
  if hands == nil then
    hands = NULL
  end
  if viewmodel == nil then
    viewmodel = NULL
  end
  if ply == nil then
    ply = NULL
  end
  if weapon == nil then
    weapon = NULL
  end
  if not (IsValid(hands) or IsValid(viewmodel) or IsValid(ply) or IsValid(weapon)) then
    return 
  end
  if weapon.IsTF2Weapon then
    hands.__dtf2_old_model = hands.__dtf2_old_model or hands:GetModel()
    return hands:SetModel(weapon.HandsModel)
  else
    if hands.__dtf2_old_model then
      hands:SetModel(hands.__dtf2_old_model)
      hands.__dtf2_old_model = nil
    end
  end
end)
return nil
