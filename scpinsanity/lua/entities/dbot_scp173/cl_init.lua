include('shared.lua')
ENT.Draw = function(self)
  return self:DrawModel()
end
ENT.DrawTranslucent = function(self)
  local pos = self:GetPos()
  local lpos = LocalPlayer():GetPos()
  if lpos:Distance(pos) > 400 then
    return 
  end
  local delta = (pos - lpos):Angle()
  delta:RotateAroundAxis(delta:Right(), 90)
  delta:RotateAroundAxis(delta:Up(), -90)
  delta:RotateAroundAxis(delta:Forward(), 30)
  pos.z = pos.z + 140
  local add = Vector(-40, 0, 0)
  add:Rotate(delta)
  cam.Start3D2D(pos + add, delta, 0.5)
  surface.SetTextColor(color_white)
  surface.SetFont('DermaLarge')
  surface.SetTextPos(0, 0)
  surface.DrawText('Kills: ' .. self:GetFrags())
  surface.SetTextPos(0, 30)
  surface.DrawText('Player Kills: ' .. self:GetPFrags())
  surface.SetTextPos(0, 60)
  surface.DrawText('Total Kills: ' .. (self:GetFrags() + self:GetPFrags()))
  return cam.End3D2D()
end
