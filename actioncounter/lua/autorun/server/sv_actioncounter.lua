util.AddNetworkString('dactioncounter_network')
local NetworkedValues = {
  {
    'jump',
    4
  },
  {
    'speed',
    400
  },
  {
    'duck',
    200
  },
  {
    'walk',
    200
  },
  {
    'water',
    400
  },
  {
    'uwater',
    400
  },
  {
    'fall',
    100
  },
  {
    'climb',
    100
  }
}
local PlayerCache = { }
local LastThink = CurTime()
local Think
Think = function()
  local cTime = CurTime()
  local delta = LastThink - cTime
  LastThink = cTime
  local _list_0 = player.GetAll()
  for _index_0 = 1, #_list_0 do
    local ply = _list_0[_index_0]
    local i = ply:EntIndex()
    PlayerCache[i] = PlayerCache[i] or { }
    local self = PlayerCache[i]
    self.jump_cnt = self.jump_cnt or 0
    self.speed_cnt = self.speed_cnt or 0
    self.duck_cnt = self.duck_cnt or 0
    self.walk_cnt = self.walk_cnt or 0
    self.water_cnt = self.water_cnt or 0
    self.uwater_cnt = self.uwater_cnt or 0
    self.fall_cnt = self.fall_cnt or 0
    self.climb_cnt = self.climb_cnt or 0
    for _index_1 = 1, #NetworkedValues do
      local nData = NetworkedValues[_index_1]
      self[nData[1] .. '_timer'] = self[nData[1] .. '_timer'] or cTime
    end
    if self.jump_timer < cTime and not self.jump then
      self.jump_cnt = 0
    end
    local onGround = ply:OnGround()
    local pos = ply:GetPos()
    local lastPos = self.pos or pos
    self.pos = pos
    local speed = pos:Distance(lastPos)
    local deltaZ = pos.z - lastPos.z
    local waterLevel = ply:WaterLevel()
    local inVehicle = ply:InVehicle()
    local shift = ply:KeyDown(IN_SPEED)
    local walk = ply:KeyDown(IN_WALK)
    local duck = ply:KeyDown(IN_DUCK)
    if inVehicle then
      local vehicle = ply:GetVehicle()
      waterLevel = vehicle:WaterLevel()
      shift = false
      walk = false
      local jump = false
      duck = false
    end
    local inWater = waterLevel > 0
    local underWater = waterLevel >= 3
    if not onGround and ply:GetMoveType() == MOVETYPE_WALK then
      if deltaZ > 0 then
        self.climb_cnt = self.climb_cnt + deltaZ
      else
        self.fall_cnt = self.fall_cnt - deltaZ
      end
    else
      self.climb_cnt = 0
      self.fall_cnt = 0
    end
    if not onGround or speed < 0.5 or inWater then
      if self.duck_timer < cTime then
        self.duck_cnt = 0
      end
      if self.speed_timer < cTime then
        self.speed_cnt = 0
      end
      if self.walk_timer < cTime then
        self.walk_cnt = 0
      end
    else
      if duck then
        self.duck_cnt = self.duck_cnt + speed
        self.duck_timer = cTime + 1
      elseif walk then
        self.walk_cnt = self.walk_cnt + speed
        self.walk_timer = cTime + 1
      elseif shift then
        self.speed_cnt = self.speed_cnt + speed
        self.speed_timer = cTime + 1
      end
    end
    if not inWater then
      if self.water_timer < cTime then
        self.water_cnt = 0
      end
      if self.uwater_timer < cTime then
        self.uwater_cnt = 0
      end
      if not onGround and not self.jump then
        self.jump = true
        self.jump_cnt = self.jump_cnt + 1
        self.jump_timer = cTime + 4
      elseif onGround and self.jump then
        self.jump = false
        self.jump_timer = cTime + 4
      end
    else
      if underWater then
        self.uwater_cnt = self.uwater_cnt + speed
        self.uwater_timer = cTime + 1
      else
        self.water_cnt = self.water_cnt + speed
        self.water_timer = cTime + 1
      end
      if self.jump then
        self.jump = false
        self.jump_timer = cTime + 4
      end
    end
    local nwhit = false
    for _index_1 = 1, #NetworkedValues do
      local nData = NetworkedValues[_index_1]
      if self[nData[1] .. '_cnt'] ~= self[nData[1] .. '_ncnt'] and self[nData[1] .. '_cnt'] >= nData[2] then
        nwhit = true
        break
      end
    end
    if nwhit then
      net.Start('dactioncounter_network')
      for _index_1 = 1, #NetworkedValues do
        local nData = NetworkedValues[_index_1]
        if self[nData[1] .. '_cnt'] >= nData[2] then
          net.WriteUInt(self[nData[1] .. '_cnt'], 32)
          self[nData[1] .. '_ncnt'] = self[nData[1] .. '_cnt']
        else
          net.WriteUInt(0, 32)
        end
      end
      net.Send(ply)
    end
  end
end
return hook.Add('Think', 'DActionCounter', Think)
