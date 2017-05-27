local DungeonMainRoom
do
  local _class_0
  local _parent_0 = DProcedural.BasicRoom
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "DungeonMainRoom",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  DungeonMainRoom = _class_0
end
local DungeonGeneratorController
do
  local _class_0
  local _base_0 = {
    Remove = function(self)
      local _list_0 = self.entities
      for _index_0 = 1, #_list_0 do
        local ent = _list_0[_index_0]
        if IsValid(ent) then
          ent:Remove()
        end
      end
      self.entities = { }
    end,
    AddRoom = function(self, room, position)
      if position == nil then
        position = Vector(0, 0, 0)
      end
      if self.roomsID[room:GetID()] then
        return 
      end
      table.insert(self.rooms, room)
      self.roomsID[room:GetID()] = room
      room:SetSkin(self.skin)
      room:SetPos(self.pos, false)
      local x, y, z
      x, y, z = position.x, position.y, position.z
      self.roomsSpace[x] = self.roomsSpace[x] or { }
      self.roomsSpace[x][y] = self.roomsSpace[x][y] or { }
      self.roomsSpace[x][y][z] = room
      room:SetRelativePos(position * self.__class.GRID_SIZE, false)
      room:UpdatePos()
      room.dungeonPos = position
    end,
    GetConnectedRooms = function(self)
      local _accum_0 = { }
      local _len_0 = 1
      local _list_0 = self.connectionsArray
      for _index_0 = 1, #_list_0 do
        local _des_0 = _list_0[_index_0]
        local r1, r2, sum, ang
        r1, r2, sum, ang = _des_0[1], _des_0[2], _des_0[3], _des_0[4]
        _accum_0[_len_0] = {
          r1,
          r2,
          sum,
          ang
        }
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end,
    CreateConnection = function(self, first, second)
      if first == nil then
        first = Vector()
      end
      if second == nil then
        second = Vector()
      end
      if first.z ~= second.z then
        return false
      end
      local sum = first - second
      if sum:Length() ~= 1 then
        return false
      end
      local sum2 = second - first
      if first == second then
        return false
      end
      local x, y, z
      x, y, z = first.x, first.y, first.z
      if not self.roomsSpace[x] then
        return false
      end
      if not self.roomsSpace[x][y] then
        return false
      end
      if not self.roomsSpace[x][y][z] then
        return false
      end
      local firstRoom = self.roomsSpace[x][y][z]
      x, y, z = second.x, second.y, second.z
      if not self.roomsSpace[x] then
        return false
      end
      if not self.roomsSpace[x][y] then
        return false
      end
      if not self.roomsSpace[x][y][z] then
        return false
      end
      local secondRoom = self.roomsSpace[x][y][z]
      self.connections[firstRoom:GetID()] = self.connections[firstRoom:GetID()] or { }
      self.connections[secondRoom:GetID()] = self.connections[secondRoom:GetID()] or { }
      if self.connections[firstRoom:GetID()][secondRoom:GetID()] then
        return false
      end
      if self.connections[secondRoom:GetID()][firstRoom:GetID()] then
        return false
      end
      self.connections[firstRoom:GetID()][secondRoom:GetID()] = true
      self.connections[secondRoom:GetID()][firstRoom:GetID()] = true
      table.insert(self.connectionsArray, {
        firstRoom,
        secondRoom,
        sum,
        sum:Angle()
      })
      firstRoom:SetSideOpen(DProcedural.GetSideByVector(sum2), true)
      secondRoom:SetSideOpen(DProcedural.GetSideByVector(sum), true)
      return true
    end,
    SetOwner = function(self, val)
      if val == nil then
        val = NULL
      end
      self.CPPIOwner = val
      local _list_0 = self.rooms
      for _index_0 = 1, #_list_0 do
        local room = _list_0[_index_0]
        room:SetOwner(val)
      end
    end,
    GetOwner = function(self)
      return self.CPPIOwner
    end,
    Spawn = function(self)
      local _list_0 = self.rooms
      for _index_0 = 1, #_list_0 do
        local room = _list_0[_index_0]
        room:SpawnInWorld(self.entities)
      end
      local _list_1 = self.connectionsArray
      for _index_0 = 1, #_list_1 do
        local _des_0 = _list_1[_index_0]
        local r1, r2, sum, ang
        r1, r2, sum, ang = _des_0[1], _des_0[2], _des_0[3], _des_0[4]
        local _list_2 = self.__class.CORRIDOR_STRUCTURE
        for _index_1 = 1, #_list_2 do
          local _des_1 = _list_2[_index_1]
          local model, position, angle
          model, position, angle = _des_1.model, _des_1.position, _des_1.angle
          local newAng = Angle(angle.p + ang.p, angle.y + ang.y, angle.r + ang.r)
          local newPos = Vector(position + sum)
          newPos:Rotate(ang)
          local newEnt = ents.Create('prop_physics')
          table.insert(self.entities, newEnt)
          do
            newEnt:SetModel(model)
            newEnt:SetPos(self.pos + newPos)
            newEnt:SetAngles(newAng)
            newEnt:Spawn()
            newEnt:Activate()
            newEnt:GetPhysicsObject():EnableMotion(false)
          end
        end
      end
      return self.entities
    end,
    SetSeed = function(self, val)
      if val == nil then
        val = self.seed
      end
      self.random:SetSeed(val)
      self.seed = val
    end,
    GetSeed = function(self)
      return self.seed
    end,
    GetSkin = function(self)
      return self.skin
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, seed, pos, skin)
      if seed == nil then
        seed = math.random(1, 1000)
      end
      if pos == nil then
        pos = Vector()
      end
      if skin == nil then
        skin = DProcedural.BuildingSkin(self)
      end
      self.seed = seed
      self.skin = skin
      self.random = DProcedural.Random(self.seed)
      self.rooms = { }
      self.roomsID = { }
      self.pos = pos
      self.CPPIOwner = NULL
      self.entities = { }
      self.roomsSpace = { }
      self.connections = { }
      self.connectionsArray = { }
      self:AddRoom(DungeonMainRoom())
      self:AddRoom(DProcedural.BasicRoom(), Vector(0, 1, 0))
      self:AddRoom(DProcedural.BasicRoom(), Vector(1, 0, 0))
      self:AddRoom(DProcedural.BasicRoom(), Vector(-1, 0, 0))
      self:AddRoom(DProcedural.BasicRoom(), Vector(0, -1, 0))
      self:CreateConnection(Vector(0, 0, 0), Vector(0, 1, 0))
      self:CreateConnection(Vector(0, 0, 0), Vector(0, -1, 0))
      self:CreateConnection(Vector(0, 0, 0), Vector(1, 0, 0))
      return self:CreateConnection(Vector(0, 0, 0), Vector(-1, 0, 0))
    end,
    __base = _base_0,
    __name = "DungeonGeneratorController"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.GRID_SIZE = 700
  self.CORRIDOR_STRUCTURE = {
    {
      ['model'] = 'models/hunter/plates/plate3x8.mdl',
      ['position'] = Vector(95 / 2, 195 / 2, 0),
      ['angle'] = Angle(0, 0, 0)
    },
    {
      ['model'] = 'models/hunter/plates/plate3x8.mdl',
      ['position'] = Vector(95 / 2, 190 / 2, 190),
      ['angle'] = Angle(0, 0, 0)
    }
  }
  DungeonGeneratorController = _class_0
end
DProcedural.Generator = DungeonGeneratorController
