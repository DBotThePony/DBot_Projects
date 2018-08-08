
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

local MOVETYPE_VPHYSICS = MOVETYPE_VPHYSICS
local SOLID_VPHYSICS = SOLID_VPHYSICS
local COLLISION_GROUP_WORLD = COLLISION_GROUP_WORLD

include('shared.lua')

AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

local FORCE_NO_COLLIDE = DLib.util.CreateSharedConvar('textscreens_force_nocollide', '0', 'Always No-collide textscreens (useful when no-collide property is disabled)')

function ENT:InitializeSV()
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:UpdatePhysics()

	if FORCE_NO_COLLIDE:GetBool() then
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end
end

function ENT:UpdatePhysics()
	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		if self:GetIsMovable() then
			phys:EnableMotion(true)
			phys:SetMass(20)
			phys:Wake()
		else
			phys:EnableMotion(false)
		end
	end

	if FORCE_NO_COLLIDE:GetBool() then
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end
end

hook.Add('PhysgunDrop', 'DBot_TextScreens', function(ply, ent)
	if ent:GetClass() ~= 'dbot_textscreen' then return end

	if not ent:GetIsMovable() then
		local phys = ent:GetPhysicsObject()

		if phys:IsValid() then
			phys:EnableMotion(false)
		end
	end
end)
