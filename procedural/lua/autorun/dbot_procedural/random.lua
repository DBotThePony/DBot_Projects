local Random
do
  local _class_0
  local _base_0 = {
    SetSeed = function(self, val)
      if val == nil then
        val = self.seed
      end
      if val == 0 then
        error('Seed == 0!')
      end
      self.seed = val
    end,
    Reset = function(self)
      self.state = 0
    end,
    NextInt = function(self, min, max)
      if min == nil then
        min = 0
      end
      if max == nil then
        max = 1
      end
      local delta = max - min
      if delta < 0 then
        error('Delta < 0')
      end
      self.state = self.state + (((self.seed + min * 2 * max - max * .5 * min) % self.seed + self.seed * 242 - delta * 1.5 + max * delta) % self.__class.MAX_STATE_VALUE)
      return math.floor(self.state % delta + min)
    end,
    NextBoolean = function(self)
      return self:NextInt(1, 100) > 50
    end,
    NextFloat = function(self, min, max, points)
      if min == nil then
        min = 0
      end
      if max == nil then
        max = 1
      end
      if points == nil then
        points = 4
      end
      local delta = max - min
      if delta < 0 then
        error('Delta < 0')
      end
      if points < 0 then
        error('points < 0')
      end
      self.state = self.state + (((self.seed * (1 / points) + min * points - max * (points ^ .5) + points * points) % self.seed + self.seed * 123 - delta * 2.25 + points * 5) % self.__class.MAX_STATE_VALUE)
      local pointVal = 10 * (points + 1)
      return math.floor(self.state % (delta * pointVal) + min) / pointVal
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, seed)
      if seed == nil then
        seed = 1
      end
      if seed == 0 then
        error('Seed == 0!')
      end
      self.seed = seed
      self.state = 0
    end,
    __base = _base_0,
    __name = "Random"
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
  self.MAX_STATE_VALUE = 2 ^ 31 - 1
  Random = _class_0
end
DProcedural.Random = Random
