
-- Copyright (C) 2018 DBot

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

local error = error
local Vector = Vector
local MOVETYPE_NONE = MOVETYPE_NONE
local Entity = Entity
local Angle = Angle
local assert = assert
local SOLID_VPHYSICS = SOLID_VPHYSICS
local COLLISION_GROUP_NONE = COLLISION_GROUP_NONE

function ENT:PhysicsInitBox2(mins, maxs)
	mins, maxs = Vector(mins), Vector(maxs)
	local ang = self:GetAngles()
	self:SetRealAngle(ang)
	mins:Rotate(ang)
	maxs:Rotate(ang)

	self:PhysicsInitBox(mins, maxs)
	self:SetAngles(Angle(0, 0, 0))
	return mins, maxs, ang
end

function ENT:SInitialize()
	self.physinit = true
	self:PhysicsInitBox2(self:GetCollisionMins(), self:GetCollisionMaxs())
	self:UpdatePhysicsModel()
end

function ENT:SetCollisionsWide(wide)
	assert(wide > 0, 'Border Width is lower or equal to zero!')

	local vector1 = Vector(self:GetCollisionMins())
	local vector2 = Vector(self:GetCollisionMaxs())

	vector1.x = wide * -0.5
	vector2.x = wide * 0.5

	self:SetCollisionMins(vector1)
	self:SetCollisionMaxs(vector2)

	return self
end

function ENT:SetCollisionsTall(tall)
	assert(tall > 0, 'Border Height is lower or equal to zero!')

	local vector1 = Vector(self:GetCollisionMins())
	local vector2 = Vector(self:GetCollisionMaxs())

	vector1.z = 0
	vector2.z = tall

	self:SetCollisionMins(vector1)
	self:SetCollisionMaxs(vector2)

	return self
end

ENT.SetCollisionsWidth = ENT.SetCollisionsWide
ENT.SetCollisionsHeight = ENT.SetCollisionsTall

function ENT:UpdateCollisionRules(name, old, new)
	if not self.physinit then return end
	if old == new then return end

	if name == 'CollisionMins' then
		self:PhysicsInitBox2(new, self:GetCollisionMaxs())
	else
		self:PhysicsInitBox2(self:GetCollisionMins(), new)
	end

	self:UpdatePhysicsModel()
end

local worldspawn

function ENT:UpdatePhysicsModel()
	worldspawn = worldspawn or Entity(0):GetPhysicsObject()
	local phys = self:GetPhysicsObject()

	if not phys:IsValid() or phys == worldspawn then
		error('func_border:UpdatePhysicsModel() - Physics object is INVALID?!')
	end

	phys:EnableCollisions(true)
	phys:EnableMotion(false)
	phys:Sleep()
	phys:SetMass(1)
	phys:SetVelocity(Vector(0, 0, 0))
	phys:EnableGravity(false)

	-- SOLID_CUSTOM ?
	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_PUSH)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)

	phys:SetAngles(self:GetAngles())
end

function ENT:SThink()

end

function ENT:SaveToDatabase()
	return func_border_write(self)
end
