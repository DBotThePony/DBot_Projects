DTF2 = DTF2 or { }
local AMMO_TO_GIVE = {
  {
    ['name'] = 'Pistol',
    ['weight'] = 1,
    ['maximal'] = 200,
    ['nominal'] = 17
  },
  {
    ['name'] = 'SMG1',
    ['weight'] = 1,
    ['maximal'] = 400,
    ['nominal'] = 25
  },
  {
    ['name'] = 'Buckshot',
    ['weight'] = 2,
    ['maximal'] = 72,
    ['nominal'] = 6
  },
  {
    ['name'] = '357',
    ['weight'] = 4,
    ['maximal'] = 36,
    ['nominal'] = 2
  },
  {
    ['name'] = 'Grenade',
    ['weight'] = 5,
    ['maximal'] = 10,
    ['nominal'] = 1
  },
  {
    ['name'] = 'SMG1_Grenade',
    ['weight'] = 4,
    ['maximal'] = 12,
    ['nominal'] = 1
  },
  {
    ['name'] = 'RPG_Round',
    ['weight'] = 8,
    ['maximal'] = 10,
    ['nominal'] = 1
  },
  {
    ['name'] = 'XBowBolt',
    ['weight'] = 10,
    ['maximal'] = 50,
    ['nominal'] = 3
  },
  {
    ['name'] = 'SniperPenetratedRound',
    ['weight'] = 13,
    ['maximal'] = 32,
    ['nominal'] = 4
  },
  {
    ['name'] = 'SniperRound',
    ['weight'] = 10,
    ['maximal'] = 32,
    ['nominal'] = 4
  }
}
DTF2.GiveAmmo = function(self, weightThersold)
  if weightThersold == nil then
    weightThersold = 40
  end
  if weightThersold <= 0 then
    return 0
  end
  if not IsValid(self) then
    return 0
  end
  if not self:IsPlayer() then
    return 0
  end
  local oldWeight = weightThersold
  weightThersold = weightThersold - self:SimulateTF2MetalAdd(weightThersold)
  if weightThersold == 0 then
    return oldWeight
  end
  for _index_0 = 1, #AMMO_TO_GIVE do
    local _continue_0 = false
    repeat
      local _des_0 = AMMO_TO_GIVE[_index_0]
      local name, weight, maximal, nominal
      name, weight, maximal, nominal = _des_0.name, _des_0.weight, _des_0.maximal, _des_0.nominal
      local count = self:GetAmmoCount(name)
      if count >= maximal then
        _continue_0 = true
        break
      end
      local deltaNeeded = math.Clamp(maximal - count, 0, math.min(nominal, math.floor(weightThersold / weight)))
      if deltaNeeded == 0 then
        _continue_0 = true
        break
      end
      local weightedDelta = deltaNeeded * weight
      if weightedDelta > weightThersold then
        _continue_0 = true
        break
      end
      weightThersold = weightThersold - weightedDelta
      self:GiveAmmo(deltaNeeded, name)
      if weightedDelta <= 0 then
        return oldWeight
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  return oldWeight - weightThersold
end
