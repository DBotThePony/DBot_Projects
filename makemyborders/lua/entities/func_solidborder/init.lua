
-- Copyright (C) 2018-2019 DBot

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


AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')
include('shared.lua')

local BaseClass = baseclass.Get('func_border')
local Angle = Angle
local assert = assert

function ENT:PhysicsInitBox2(...)
	self:SetRealAngle(Angle(0, 0, 0))
	self:SetAngles(Angle(0, 0, 0))
	return BaseClass.PhysicsInitBox2(self, ...)
end

function ENT:SetCollisionsLength(length)
	assert(tall > 0, 'Box Length is lower or equal to zero!')

	local vector1 = Vector(self:GetCollisionMins())
	local vector2 = Vector(self:GetCollisionMaxs())

	vector1.y = length * -0.5
	vector2.z = length * 0.5

	self:SetCollisionMins(vector1)
	self:SetCollisionMaxs(vector2)

	return self
end

function ENT:SetCollisionsBox(boxVector)
	self:SetCollisionMins(Vector(boxVector.x * -0.5, boxVector.y * -0.5, 0))
	self:SetCollisionMaxs(Vector(boxVector.x * 0.5, boxVector.y * 0.5, boxVector.z))
	return self
end

ENT.SetCollisionsDepth = ENT.SetCollisionsLength
