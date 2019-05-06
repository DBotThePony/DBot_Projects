
--[[
Copyright (C) 2016-2019 DBotThePony

Licensed under the Apache License, Version 2.0 (the 'License');
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http: /  / www.apache.org / licenses / LICENSE - 2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an 'AS IS' BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]


local ENT = {}
ENT.Type = 'anim'
ENT.Base = 'base_anim'

ENT.PrintName = 'Spawner base'
ENT.Author = 'DBot'

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = true
ENT.A = -10
ENT.B = 10
ENT.Step = 2
ENT.ModelToCreate = 'models/sprops/rectangles/size_1_5/rect_6x6x3.mdl'

ENT.Category = 'DBot'

ENT.RotateAng = Angle(0, -90, 0)

function ENT:SpawnFunction(ply, tr, class)
	if not tr.Hit then return end

	local ent = ents.Create(class)
	ent:SetPos(tr.HitPos + tr.HitNormal * 40)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	self:SetModel('models/props_c17/FurnitureWashingmachine001a.mdl')

	if CLIENT then return end

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	self.Tab = {}
	self.Ents = {}
	self.CurrIndex = 0
end

function ENT:GetPosFor(x, y)
	return x, y ^ 2
end

function ENT:GenerateTab()
	self.Tab = {}

	if self.nlinear then
		for x = self.A, self.B do
			for y = self.A, self.B do
				table.insert(self.Tab, {self:GetPosFor(x, y)})
			end
		end
	else
		for x = self.A, self.B do
			table.insert(self.Tab, {self:GetPosFor(x, x)})
		end
	end
end

function ENT:Use(ply)
	if self.Active then return end
	self.Finished = false
	self.Active = true

	for k = 1, #self.Ents do
		SafeRemoveEntity(self.Ents[k])
	end

	self.Ply = ply
	self.Ents = {}

	self:GenerateTab()
	self.LastPly = ply
	self.CurrIndex = 0

	self:NextThink(CurTimeL())
end

function ENT:IDLE()
	self:NextThink(CurTimeL() + 4)
	return true
end

function ENT:OnFinish()
	if self.Finished then return end
	self.Finished = true
	self.Active = false

	self.CurrIndex = 0
	self.Tab = {}

	undo.Create('Function_Plot')
	undo.SetPlayer(self:CPPIGetOwner())

	for k, v in ipairs(self.Ents) do
		undo.AddEntity(v)
	end

	undo.Finish()

	return self:IDLE()
end

function ENT:Think()
	if CLIENT then return end

	if self.CurrIndex == #self.Tab then
		return self:OnFinish()
	end

	self.CurrIndex = self.CurrIndex + 1

	if not self.Tab[self.CurrIndex] then return self:IDLE() end

	local look = self.Tab[self.CurrIndex]
	local x, y, z = (look[1] or 0), (look[2] or 0), (look[3] or 0)

	if (x ~= x or y ~= y or z ~= z) then return end
	if (x == math.huge or y == math.huge or z == math.huge) then return end

	local canCreate = hook.Run('PlayerSpawnProp', self.LastPly, self.ModelToCreate)

	if canCreate == false then return self:IDLE() end

	local ent = ents.Create('prop_physics')
	ent:SetModel(self.ModelToCreate)

	local vec = Vector(x, y, z)
	vec:Rotate(self.RotateAng)

	local calc = self:GetPos() + self:GetAngles():Forward() * 25 + vec * self.Step
	calc.z = calc.z + 50

	ent:SetPos(calc)
	ent:Spawn()
	ent:Activate()

	if IsValid(ent) then
		hook.Run('PlayerSpawnedProp', self.LastPly, self.ModelToCreate, ent)

		local phys = ent:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end

		table.insert(self.Ents, ent)
	end

	self:NextThink(CurTimeL())
	return true
end

function ENT:OnRemove()
	if CLIENT then return end

	for k = 1, #self.Ents do
		SafeRemoveEntity(self.Ents[k])
	end
end

scripted_ents.Register(ENT, 'dbot_plot_generator_base')

local Funcs = {
	{
		Func = function(x, y)
			return x, y ^ 2, 0
		end,
		name = '(x ^ 2)'
	},

	{
		Func = function(x, y)
			return x, y ^ 2, y ^ 2
		end,
		name = '(y = x ^ 2, z = y ^ 2)'
	},

	{
		Func = function(x, y)
			return x, y ^ (1 / 2)
		end,
		name = '(y = x ^ (1 / 2))'
	},

	{
		Func = function(x, y)
			return x, x
		end,
		name = '(y = x)'
	},

	{
		Func = function(x, y)
			return x ^ 3, y, 0
		end,
		name = '(x ^ 3)'
	},

	{
		Func = function(x, y)
			return x + y, y, y ^ 2
		end,
		name = '(x = x + y, y, z = y ^ 2)',
		nlinear = true,
	},

	{
		Func = function(x, y)
			return (math.sin(math.pi * x) / (math.pi * x)) * 5, y
		end,
		name = 'x = sin(pi * x) / (pi * x)'
	},

	{
		Func = function(x, y)
			return x, y,(math.sin(x ^ 2 + y ^ 2) / math.sqrt(x ^ 2 + y ^ 2)) * 10
		end,
		name = 'z = sin(x ^ 2 + y ^ 2) / sqrt(x ^ 2 + y ^ 2)',
		nlinear = true,
	},

	{
		Func = function(x, y)
			return x, y, math.sin(x ^ 2 + y) / (x + y)
		end,
		name = 'z = sin(x ^ 2 + y) / (x + y)',
		nlinear = true,
	},

	{
		Func = function(x, y)
			return x, y, y
		end,
		name = 'x, y, y',
		nlinear = true,
	},

	{
		Func = function(x, y)
			return x, y,(x ^ 2 + y ^ 2) / 5
		end,
		name = 'z = (y ^ 2 + x ^ 2) / 5',
		nlinear = true,
	},

	{
		Func = function(x, y)
			return x, y, math.sin(x / 5) * 5 + math.sin(y / 5) * 5
		end,
		name = 'z = sin(x / 5) * 5 + sin(y / 5) * 5',
		nlinear = true,
	},

	{
		Func = function(x, y)
			return x, y, math.sin(x / 5) * 5 + math.cos(y / 5) * 5
		end,
		name = 'z = sin(x / 5) * 5 + cos(y / 5) * 5',
		nlinear = true,
	},

	{
		Func = function(x, y)
			return x, y, - (x ^ 2 + y ^ 2) / 5 + 100
		end,
		name = 'z =  - (y ^ 2 + x ^ 2) / 5 + 100',
		nlinear = true,
	},

	{
		Func = function(x, y)
			return x, y, math.sqrt(x ^ 2 + y ^ 2)
		end,
		name = 'z = sqrt(x ^ 2 + y ^ 2)',
		nlinear = true,
	},

	{
		Func = function(x, y)
			return x, y,(x - y) ^ 2
		end,
		name = 'z = (x - y) ^ 2',
		nlinear = true,
	},

	{
		Func = function(x, y)
			return x, y, 10 - (x ^ 2 + y ^ 2) / 10
		end,
		name = 'z = 10 - (x ^ 2 + y ^ 2) / 10',
		nlinear = true,
	},
}

for k, v in pairs(Funcs) do
	local ENT = {}
	ENT.Type = 'anim'
	ENT.Base = 'dbot_plot_generator_base'

	ENT.PrintName		= 'Function Plot ' .. v.name
	ENT.Author			= 'DBot'

	ENT.Spawnable = true
	ENT.AdminSpawnable = true
	ENT.AdminOnly = true
	ENT.A = -10
	ENT.B = 10
	ENT.Step = 6
	ENT.nlinear = v.nlinear

	ENT.Category = 'DBot'

	function ENT:GetPosFor(x, y, z)
		return v.Func(x, y, z)
	end

	scripted_ents.Register(ENT, 'dbot_plot_generator' .. k)
end
