
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

	vector1.z = tall * -0.5
	vector2.z = tall * 0.5

	self:SetCollisionMins(vector1)
	self:SetCollisionMaxs(vector2)

	return self
end

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
