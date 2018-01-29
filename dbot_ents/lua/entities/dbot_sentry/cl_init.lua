
--[[
Copyright (C) 2016 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	local pos = self:GetPos()
	local lpos = LocalPlayer():GetPos()
	if lpos:Distance(pos) > 700 then return end
	
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
	
	cam.End3D2D()
end
