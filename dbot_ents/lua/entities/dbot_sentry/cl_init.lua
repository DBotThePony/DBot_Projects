
--[[
Copyright (C) 2016-2019 DBotThePony


-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

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
