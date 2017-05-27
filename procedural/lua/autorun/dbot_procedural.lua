DProcedural = DProcedural or { }
DProcedural.SIDE_LEFT = 0
DProcedural.SIDE_RIGHT = 1
DProcedural.SIDE_FORWARD = 2
DProcedural.SIDE_BACKWARD = 3
DProcedural.DIRECTION_WEST = 0
DProcedural.DIRECTION_EAST = 1
DProcedural.DIRECTION_NORTH = 2
DProcedural.DIRECTION_SOUTH = 3
DProcedural.DIRECTION_NORTH_VECTOR = Vector(0, 1, 0)
DProcedural.DIRECTION_SOUTH_VECTOR = Vector(0, -1, 0)
DProcedural.DIRECTION_WEST_VECTOR = Vector(1, 0, 0)
DProcedural.DIRECTION_EAST_VECTOR = Vector(-1, 0, 0)
DProcedural.GetSideByVector = function(vec)
  local _exp_0 = vec
  if DProcedural.DIRECTION_NORTH_VECTOR == _exp_0 then
    return DProcedural.DIRECTION_NORTH
  elseif DProcedural.DIRECTION_SOUTH_VECTOR == _exp_0 then
    return DProcedural.DIRECTION_SOUTH
  elseif DProcedural.DIRECTION_WEST_VECTOR == _exp_0 then
    return DProcedural.DIRECTION_WEST
  elseif DProcedural.DIRECTION_EAST_VECTOR == _exp_0 then
    return DProcedural.DIRECTION_EAST
  end
  return DProcedural.DIRECTION_NORTH
end
include('autorun/dbot_procedural/random.lua')
include('autorun/dbot_procedural/space.lua')
if SERVER then
  include('autorun/dbot_procedural/skin.lua')
  include('autorun/dbot_procedural/room.lua')
  return include('autorun/dbot_procedural/controller.lua')
end
