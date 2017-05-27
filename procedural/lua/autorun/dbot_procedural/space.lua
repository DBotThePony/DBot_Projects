local SpaceState
do
  local _class_0
  local _base_0 = {
    IsPosFree = function(self, x, y, z)
      if x == nil then
        x = 0
      end
      if y == nil then
        y = 0
      end
      if z == nil then
        z = 0
      end
      x = math.floor(x / self.size)
      y = math.floor(y / self.size)
      z = math.floor(z / self.size)
      if not self.states[x] then
        return true
      end
      if not self.states[x][y] then
        return true
      end
      if not self.states[x][y][z] then
        return true
      end
      return #self.states[x][y][z] == 0
    end,
    PutVector = function(self, pos, id)
      if pos == nil then
        pos = Vector()
      end
      if id == nil then
        id = 'generic'
      end
      local x, y, z
      x, y, z = pos.x, pos.y, pos.z
      return self:Put(x, y, z, id)
    end,
    Put = function(self, x, y, z, id)
      if x == nil then
        x = 0
      end
      if y == nil then
        y = 0
      end
      if z == nil then
        z = 0
      end
      if id == nil then
        id = 'generic'
      end
      x = math.floor(x / self.size)
      y = math.floor(y / self.size)
      z = math.floor(z / self.size)
      self.states[x] = self.states[x] or { }
      self.states[x][y] = self.states[x][y] or { }
      self.states[x][y][z] = self.states[x][y][z] or { }
      local _list_0 = self.states[x][y][z]
      for _index_0 = 1, #_list_0 do
        local state = _list_0[_index_0]
        if state == id then
          return false
        end
      end
      table.insert(self.states[x][y][z], id)
      return true
    end,
    GenerateBox = function(self, pos, mins, maxs)
      if pos == nil then
        pos = Vector()
      end
      if mins == nil then
        mins = Vector()
      end
      if maxs == nil then
        maxs = Vector()
      end
      local output = { }
      local x, y, z
      x, y, z = pos.x, pos.y, pos.z
      local minx, miny, minz
      minx, miny, minz = mins.x, mins.y, mins.z
      local maxx, maxy, maxz
      maxx, maxy, maxz = maxs.x, maxs.y, maxs.z
      x = math.floor(x / self.size)
      y = math.floor(y / self.size)
      z = math.floor(z / self.size)
      maxx = math.floor(maxx / self.size)
      maxy = math.floor(maxy / self.size)
      maxz = math.floor(maxz / self.size)
      minx = math.floor(minx / self.size)
      miny = math.floor(miny / self.size)
      minz = math.floor(minz / self.size)
      local i = 1
      for tx = x + minx, x + maxx do
        for ty = y + miny, y + maxy do
          for tz = z + miny, z + maxz do
            output[i] = {
              tx,
              ty,
              tz
            }
            i = i + 1
          end
        end
      end
      return output
    end,
    PutBox = function(self, pos, mins, maxs, id)
      if pos == nil then
        pos = Vector()
      end
      if mins == nil then
        mins = Vector()
      end
      if maxs == nil then
        maxs = Vector()
      end
      if id == nil then
        id = 'generic'
      end
      local _list_0 = self:GenerateBox(pos, mins, maxs)
      for _index_0 = 1, #_list_0 do
        local _des_0 = _list_0[_index_0]
        local x, y, z
        x, y, z = _des_0[1], _des_0[2], _des_0[3]
        self:Put(tx, ty, tz, id)
      end
    end,
    RemoveBox = function(self, pos, mins, maxs, id)
      if pos == nil then
        pos = Vector()
      end
      if mins == nil then
        mins = Vector()
      end
      if maxs == nil then
        maxs = Vector()
      end
      if id == nil then
        id = 'generic'
      end
      local _list_0 = self:GenerateBox(pos, mins, maxs)
      for _index_0 = 1, #_list_0 do
        local _des_0 = _list_0[_index_0]
        local x, y, z
        x, y, z = _des_0[1], _des_0[2], _des_0[3]
        self:Remove(tx, ty, tz, id)
      end
    end,
    GetPos = function(self, x, y, z)
      if x == nil then
        x = 0
      end
      if y == nil then
        y = 0
      end
      if z == nil then
        z = 0
      end
      x = math.floor(x / self.size)
      y = math.floor(y / self.size)
      z = math.floor(z / self.size)
      if not self.states[x] then
        return { }
      end
      if not self.states[x][y] then
        return { }
      end
      if not self.states[x][y][z] then
        return { }
      end
      local _accum_0 = { }
      local _len_0 = 1
      local _list_0 = self.states[x][y][z]
      for _index_0 = 1, #_list_0 do
        local val = _list_0[_index_0]
        _accum_0[_len_0] = val
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end,
    Remove = function(self, x, y, z, id)
      if x == nil then
        x = 0
      end
      if y == nil then
        y = 0
      end
      if z == nil then
        z = 0
      end
      if id == nil then
        id = 'generic'
      end
      x = math.floor(x / self.size)
      y = math.floor(y / self.size)
      z = math.floor(z / self.size)
      if not self.states[x] then
        return false
      end
      if not self.states[x][y] then
        return false
      end
      if not self.states[x][y][z] then
        return false
      end
      for i, state in pairs(self.states[x][y][z]) do
        if state == id then
          table.remove(self.states[x][y][z], i)
          return true
        end
      end
      return false
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, precacheX, precacheY, precacheZ, size)
      if precacheX == nil then
        precacheX = 10
      end
      if precacheY == nil then
        precacheY = 10
      end
      if precacheZ == nil then
        precacheZ = 10
      end
      if size == nil then
        size = 1
      end
      size = math.floor(size)
      if size <= 0 then
        error('Size <= 0!')
      end
      self.states = { }
      for x = -precacheX, precacheX do
        self.states[x] = { }
        for y = -precacheY, precacheY do
          self.states[x][y] = { }
          for z = -precacheZ, precacheZ do
            self.states[x][y][z] = { }
          end
        end
      end
      self.size = size
    end,
    __base = _base_0,
    __name = "SpaceState"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  SpaceState = _class_0
end
DProcedural.SpaceState = SpaceState
