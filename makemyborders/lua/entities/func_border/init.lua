
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
local GetTable = FindMetaTable('Entity').GetTable

function ENT:SInitialize()
	self:PhysicsInitBox(self:GetCollisionMins(), self:GetCollisionMaxs())
	self:UpdatePhysicsModel()
end

function ENT:UpdateCollisionRules(name, old, new)
	if old == new then return end

	if name == 'CollisionMins' then
		self:PhysicsInitBox(new, self:GetCollisionMaxs())
	else
		self:PhysicsInitBox(self:GetCollisionMins(), new)
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

	phys:EnableMotion(false)
	phys:Sleep()
	phys:SetMass(1)
	phys:SetVelocity(Vector(0, 0, 0))
	phys:EnableGravity(false)

	self:SetMoveType(MOVETYPE_NONE)
end

function ENT:ShouldCollide(target)
	return self:AllowObjectPass(target, false)
end

hook.Add('ShouldCollide', 'func_border', function(ent1, ent2)
	local tab1 = GetTable(ent1)

	if tab1 and tab1.IS_FUNC_BORDER then
		return ent1:ShouldCollide(ent2)
	end

	tab1 = GetTable(ent2)

	if tab1 and tab1.IS_FUNC_BORDER then
		return ent2:ShouldCollide(ent1)
	end
end, -1)
