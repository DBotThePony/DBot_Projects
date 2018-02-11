
-- Copyright (C) 2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

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

ENT.SetCollisionsDepth = ENT.SetCollisionsLength
