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
      self.rooms = {
        DungeonMainRoom(pos)
      }
      self.CPPIOwner = NULL
      self.entities = { }
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
  DungeonGeneratorController = _class_0
end
DProcedural.Generator = DungeonGeneratorController
