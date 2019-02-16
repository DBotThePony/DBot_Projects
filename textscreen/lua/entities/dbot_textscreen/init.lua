
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
