local BuildingSkin
do
  local _class_0
  local _base_0 = {
    GetParent = function(self)
      return self.parent
    end,
    GetFloor = function(self)
      return self.__class.FLOR_TEXTURE
    end,
    GetWall = function(self, side)
      if side == nil then
        side = DProcedural.SIDE_LEFT
      end
      return self.__class.WALL_TEXTURE
    end,
    GetCeiling = function(self)
      return self.__class.CEILING_TEXTURE
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, parent)
      self.parent = parent
    end,
    __base = _base_0,
    __name = "BuildingSkin"
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
  self.FLOR_TEXTURE = 'wood/woodfloor001a'
  self.WALL_TEXTURE = 'brick/brickwall034e'
  self.CEILING_TEXTURE = 'brick/brickwall017a'
  BuildingSkin = _class_0
end
DProcedural.BuildingSkin = BuildingSkin
