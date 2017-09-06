AddCSLuaFile('cl_init.lua')
include('shared.lua')
do
  local model = 'models/props_wasteland/laundry_washer003.mdl'
  ENT.ModelsToSpawn = { }
  for x = 0, 1 do
    for y = -1, 1 do
      for z = 0, 1 do
        table.insert(ENT.ModelsToSpawn, {
          model = model,
          pos = Vector(x * 100 - 200, y * 40, z * 40)
        })
      end
    end
  end
end
do
  local height = 80
  table.insert(ENT.ModelsToSpawn, {
    model = 'models/props_junk/ibeam01a.mdl',
    pos = Vector(-50, 60, height),
    ang = Angle(90, 0, 0)
  })
  table.insert(ENT.ModelsToSpawn, {
    model = 'models/props_junk/ibeam01a.mdl',
    pos = Vector(-50, -60, height),
    ang = Angle(90, 0, 0)
  })
  table.insert(ENT.ModelsToSpawn, {
    model = 'models/props_junk/ibeam01a.mdl',
    pos = Vector(-260, -60, height),
    ang = Angle(90, 0, 0)
  })
  table.insert(ENT.ModelsToSpawn, {
    model = 'models/props_junk/ibeam01a.mdl',
    pos = Vector(-260, 60, height),
    ang = Angle(90, 0, 0)
  })
end
ENT.PISTONS_START = #ENT.ModelsToSpawn + 1
do
  local model = 'models/props_wasteland/laundry_washer003.mdl'
  for x = 0, 1 do
    for y = -1, 1 do
      table.insert(ENT.ModelsToSpawn, {
        model = model,
        pos = Vector(x * 100 - 200, y * 40, 200)
      })
    end
  end
end
ENT.PISTONS_END = #ENT.ModelsToSpawn
ENT.PISTON_MAX = 200
ENT.PISTON_MIN = 100
for i = 0, 3 do
  table.insert(ENT.ModelsToSpawn, {
    model = 'models/props_lab/harddrive02.mdl',
    pos = Vector(0, 0, -i * 8),
    ang = Angle(0, 0, 90)
  })
end
ENT.MovePistonTo = function(self, z)
  local lpos = self:GetPos()
  local vec = Vector(0, 0, z)
  for i = self.PISTONS_START, self.PISTONS_END do
    local ent = self.props[i]
    ent:SetPos(ent.RealPos + vec)
  end
end
ENT.CreatePart = function(self, num)
  local data = self.ModelsToSpawn[num]
  local ent = ents.Create('prop_physics')
  local lang = self:GetAngles()
  local x, y, z
  do
    local _obj_0 = data.pos
    x, y, z = _obj_0.x, _obj_0.y, _obj_0.z
  end
  local newpos = Vector(x, y, z)
  newpos:Rotate(lang)
  ent:SetPos(self:GetPos() + newpos)
  if data.ang then
    ent:SetAngles(lang + data.ang)
  else
    ent:SetAngles(lang)
  end
  ent:SetModel(data.model)
  ent:Spawn()
  ent:Activate()
  ent.RealPos = data.pos
  ent:SetParent(self)
  if self.CPPIGetOwner and ent.CPPISetOwner then
    ent:CPPISetOwner(self:CPPIGetOwner())
  end
  self.props[num] = ent
end
ENT.CheckParts = function(self)
  for k, v in pairs(self.ModelsToSpawn) do
    if not IsValid(self.props[k]) then
      self:CreatePart(k)
    end
  end
end
ENT.Initialize = function(self)
  self:SetModel('models/props_lab/monitor02.mdl')
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self.props = { }
  self.strength = 1
  self.stamp = 0
  self.nextpunch = 0
  self.shift = 0
  self.rshift = 0
  self.lerpval = 0.05
end
ENT.OnTakeDamage = function(self, dmg)
  if not self.enabled then
    return 
  end
  self.HP = self.HP - dmg:GetDamage()
  if self.HP <= 0 then
    return self:Shutdown()
  end
end
ENT.Shutdown = function(self)
  self.enabled = false
  self.rshift = 0
  self.lerpval = 0.01
  return self:EmitSound('ambient/machines/thumper_shutdown1.wav', SNDLVL_180dB)
end
ENT.Enable = function(self, strength, time)
  strength = math.Clamp(strength or 1, 1, 50)
  time = math.Clamp(time or 15, 5, 600)
  self.enabled = true
  self.stamp = CurTime() + time
  self.strength = strength
  self.nextpunch = CurTime() + 2
  self.HP = 100
  self:EmitSound('ambient/machines/thumper_startup1.wav', SNDLVL_180dB)
  local str = 'Piston Resonator (SCP-219) activated with strength of ' .. strength .. ' amp and time ' .. time
  PrintMessage(HUD_PRINTCONSOLE, str)
  PrintMessage(HUD_PRINTTALK, str)
  return PrintMessage(HUD_PRINTCENTER, str)
end
ENT.Punch = function(self)
  for i = 1, self.strength * 3 do
    self:EmitSound('ambient/machines/thumper_hit.wav', SNDLVL_180dB)
  end
  local _list_0 = ents.GetAll()
  for _index_0 = 1, #_list_0 do
    local _continue_0 = false
    repeat
      local ent = _list_0[_index_0]
      if ent == self or ent:GetParent() == self then
        _continue_0 = true
        break
      end
      local phys = ent:GetPhysicsObject()
      if not IsValid(phys) then
        _continue_0 = true
        break
      end
      if not ent:IsPlayer() and not ent:IsNPC() then
        phys:AddVelocity(VectorRand() * self.strength * 200)
      else
        if ent:IsPlayer() then
          if not SCP_INSANITY_ATTACK_PLAYERS:GetBool() then
            _continue_0 = true
            break
          end
          if SCP_INSANITY_ATTACK_NADMINS:GetBool() and ent:IsAdmin() then
            _continue_0 = true
            break
          end
          if SCP_INSANITY_ATTACK_NSUPER_ADMINS:GetBool() and ent:IsSuperAdmin() then
            _continue_0 = true
            break
          end
          ent:SetMoveType(MOVETYPE_WALK)
          ent:ExitVehicle()
        end
        ent:SetVelocity(VectorRand() * self.strength * 200)
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
end
ENT.Think = function(self)
  self:CheckParts()
  if self.enabled and self.stamp < CurTime() then
    self:Shutdown()
  end
  if self.enabled then
    if self.nextpunch - 0.3 < CurTime() and not self.readysound then
      self.rshift = 0
      self.readysound = true
      self:EmitSound('ambient/machines/thumper_top.wav', 150)
    end
    if self.nextpunch - 0.8 < CurTime() and not self.readyanim then
      self.rshift = 0
      self.lerpval = 0.05
      self.readyanim = true
    end
    if self.nextpunch < CurTime() then
      self:Punch()
      self.readysound = false
      self.readyanim = false
      self.rshift = -130
      self.lerpval = 0.3
      self.nextpunch = CurTime() + 2
      util.ScreenShake(self:GetPos(), self.strength * 5, 5, 1, self.strength * 400)
    end
  end
  self.shift = Lerp(self.lerpval, self.shift, self.rshift)
  self:MovePistonTo(self.shift)
  self:SetUseType(SIMPLE_USE)
  self:NextThink(CurTime())
  return true
end
util.AddNetworkString('SCP-219Menu')
net.Receive('SCP-219Menu', function(len, ply)
  local ent = net.ReadEntity()
  local str = net.ReadUInt(32)
  local time = net.ReadUInt(32)
  if not IsValid(ent) then
    return 
  end
  if ent:GetPos():Distance(ply:GetPos()) > 128 then
    return 
  end
  if ent.enabled then
    return 
  end
  return ent:Enable(str, time)
end)
ENT.Use = function(self, ply)
  if self.enabled then
    return 
  end
  net.Start('SCP-219Menu')
  net.WriteEntity(self)
  return net.Send(ply)
end
