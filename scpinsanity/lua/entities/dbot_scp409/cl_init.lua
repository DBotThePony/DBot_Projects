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
  local col = self:GetColor()
  SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
  self:DrawModel()
  ModelMaterialOverride()
  return SuppressEngineLighting(false)
end
