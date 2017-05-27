local BasicRoom
do
  local _class_0
  local _base_0 = {
    SetOwner = function(self, owner)
      if owner == nil then
        owner = NULL
      end
      self.CPPIOwner = owner
      local _list_0 = self.entities
      for _index_0 = 1, #_list_0 do
        local ent = _list_0[_index_0]
        if ent:IsValid() and ent.CPPISetOwner then
          ent:CPPISetOwner(owner)
        end
      end
    end,
    GetOwner = function(self)
      return self.CPPIOwner
    end,
    IsNorthOpen = function(self)
      return not self.closeN
    end,
    IsSouthOpen = function(self)
      return not self.closeS
    end,
    IsEastOpen = function(self)
      return not self.closeE
    end,
    IsWestOpen = function(self)
      return not self.closeW
    end,
    UpdateOwner = function(self)
      local _list_0 = self.entities
      for _index_0 = 1, #_list_0 do
        local ent = _list_0[_index_0]
        if ent:IsValid() and ent.CPPISetOwner then
          ent:CPPISetOwner(self:GetOwner())
        end
      end
    end,
    Remove = function(self)
      local _list_0 = self.entities
      for _index_0 = 1, #_list_0 do
        local ent = _list_0[_index_0]
        if ent:IsValid() then
          ent:Remove()
        end
      end
      self.entities = { }
    end,
    SpawnInWorld = function(self, tableTarget)
      self.floorModel = ents.Create('prop_physics')
      table.insert(tableTarget, self.floorModel)
      table.insert(self.entities, self.floorModel)
      do
        local _with_0 = self.floorModel
        _with_0:SetModel(self.__class.FLOOR_MODEL)
        _with_0:SetPos(self.pos)
        _with_0:Spawn()
        _with_0:Activate()
        _with_0:GetPhysicsObject():EnableMotion(false)
      end
      self.ceilingModel = ents.Create('prop_physics')
      table.insert(tableTarget, self.ceilingModel)
      table.insert(self.entities, self.ceilingModel)
      do
        local _with_0 = self.ceilingModel
        _with_0:SetModel(self.__class.CEILING_MODEL)
        _with_0:SetPos(self.pos + Vector(0, 0, self:GetHeight()))
        _with_0:Spawn()
        _with_0:Activate()
        _with_0:GetPhysicsObject():EnableMotion(false)
      end
      for direction, data in pairs(self.__class.WALL_STRUCTURE) do
        for _index_0 = 1, #data do
          local _des_0 = data[_index_0]
          local door, pos, ang, model
          door, pos, ang, model = _des_0.door, _des_0.pos, _des_0.ang, _des_0.model
          local newEnt = ents.Create('prop_physics')
          table.insert(tableTarget, newEnt)
          table.insert(self.entities, newEnt)
          do
            newEnt:SetModel(model)
            newEnt:SetPos(self.pos + pos)
            newEnt:SetAngles(ang)
            newEnt:Spawn()
            newEnt:Activate()
            newEnt:GetPhysicsObject():EnableMotion(false)
          end
        end
      end
      return self:UpdateOwner()
    end,
    GetMins = function(self)
      return self.__class.MINS
    end,
    GetMaxs = function(self)
      return self.__class.MAXS
    end,
    GetHeight = function(self)
      return self:GetMaxs().z - self:GetMins().z
    end,
    GetWest = function(self)
      return self.__class.WEST
    end,
    GetEast = function(self)
      return self.__class.EAST
    end,
    GetNorth = function(self)
      return self.__class.NORTH
    end,
    GetSouth = function(self)
      return self.__class.SOUTH
    end,
    GetSideAt = function(self, side)
      if side == nil then
        side = DProcedural.DIRECTION_NORTH
      end
      local _exp_0 = side
      if DProcedural.DIRECTION_NORTH == _exp_0 then
        return self:GetNorth()
      elseif DProcedural.DIRECTION_SOUTH == _exp_0 then
        return self:GetSouth()
      elseif DProcedural.DIRECTION_EAST == _exp_0 then
        return self:GetEast()
      elseif DProcedural.DIRECTION_WEST == _exp_0 then
        return self:GetWest()
      else
        return self:GetNorth()
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, pos, closeN, closeS, closeW, closeE)
      if pos == nil then
        pos = Vector()
      end
      if closeN == nil then
        closeN = true
      end
      if closeS == nil then
        closeS = true
      end
      if closeW == nil then
        closeW = true
      end
      if closeE == nil then
        closeE = true
      end
      self.closeN = closeN
      self.closeS = closeS
      self.closeW = closeW
      self.closeE = closeE
      self.pos = pos
      self.CPPIOwner = NULL
      self.entities = { }
    end,
    __base = _base_0,
    __name = "BasicRoom"
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
  self.MINS = Vector(-190, -190, 0)
  self.MAXS = Vector(190, 190, 190)
  self.NORTH = Vector(0, 100, 0)
  self.SOUTH = Vector(0, -100, 0)
  self.WEST = Vector(-100, 0, 0)
  self.EAST = Vector(100, 0, 0)
  self.CEILING_MODEL = 'models/hunter/plates/plate8x8.mdl'
  self.FLOOR_MODEL = 'models/hunter/plates/plate8x8.mdl'
  self.WALL_STRUCTURE = {
    [DProcedural.DIRECTION_NORTH] = {
      {
        ['door'] = false,
        ['pos'] = Vector(190 - 95 / 2, 190, 95),
        ['ang'] = Angle(0, 180, 90),
        ['model'] = 'models/hunter/plates/plate3x8.mdl'
      }
    }
  }
  BasicRoom = _class_0
end
DProcedural.BasicRoom = BasicRoom
