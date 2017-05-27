DProcedural = DProcedural or { }
DProcedural.SIDE_LEFT = 0
DProcedural.SIDE_RIGHT = 1
DProcedural.SIDE_FORWARD = 2
DProcedural.SIDE_BACKWARD = 3
DProcedural.SIDE_WEST = 0
DProcedural.SIDE_EAST = 1
DProcedural.DIRECTION_NORTH = 2
DProcedural.DIRECTION_SOUTH = 3
include('autorun/dbot_procedural/random.lua')
include('autorun/dbot_procedural/space.lua')
if SERVER then
  include('autorun/dbot_procedural/skin.lua')
  include('autorun/dbot_procedural/room.lua')
  return include('autorun/dbot_procedural/controller.lua')
end
