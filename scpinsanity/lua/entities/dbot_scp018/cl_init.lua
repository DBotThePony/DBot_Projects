include('shared.lua')
local render, Material
do
  local _obj_0 = _G
  render, Material = _obj_0.render, _obj_0.Material
end
local SuppressEngineLighting, ModelMaterialOverride, ResetModelLighting, SetColorModulation
SuppressEngineLighting, ModelMaterialOverride, ResetModelLighting, SetColorModulation = render.SuppressEngineLighting, render.ModelMaterialOverride, render.ResetModelLighting, render.SetColorModulation
local debugwtite = Material('models/debug/debugwhite')
ENT.Draw = function(self)
  SuppressEngineLighting(true)
  ModelMaterialOverride(debugwtite)
  ResetModelLighting(1, 1, 1)
  local r, g, b
  do
    local _obj_0 = self:GetBallColor()
    r, g, b = _obj_0.x, _obj_0.y, _obj_0.z
  end
  SetColorModulation(r, g, b)
  self:DrawModel()
  ModelMaterialOverride()
  return SuppressEngineLighting(false)
end
