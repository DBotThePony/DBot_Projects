
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

local mc = MCSWEP2
local self = MCSWEP2

local cactus = self.GetBlockByName('cactus')
local function CactusCollide(self, data)
	local ent = data.HitEntity
	if not IsValid(ent) then return end
	ent:TakeDamage(3, self, self)
end

local function CactusStartTouch(self, ent)
	if not IsValid(ent) then return end
	--if ent.IsMCBlock then return end
	self.TouchEntity = ent
	ent:TakeDamage(3, self, self)
end

local function CactusThink(self)
	if IsValid(self.TouchEntity) then
		self.TouchEntity:TakeDamage(3, self, self)
	end
end

local function CactusEndTouch(self, ent)
	if not IsValid(ent) then return end
	--if ent.IsMCBlock then return end
	self.TouchEntity = nil
end

self.RegisterEventHook(cactus, 'PhysicsCollide', nil, CactusCollide, nil)
self.RegisterEventHook(cactus, 'StartTouch', nil, CactusStartTouch, nil)
self.RegisterEventHook(cactus, 'EndTouch', nil, CactusEndTouch, nil)
self.RegisterEventHook(cactus, 'Think', nil, CactusThink, nil)

local grass = self.GetBlockByName('grass')
local dirt = self.GetBlockByName('dirt')

local function GrassUpdate(self)
	local block = self:GetBlockAtSide(mc.SIDE_TOP)
	
	if IsValid(block) and block:IsOpaque() then
		timer.Create(self:EntIndex() .. '_grass_block_think', math.random(5, 15), 1, function()
			if not IsValid(self) then return end
			local block = self:GetBlockAtSide(mc.SIDE_TOP)
			
			if IsValid(block) and block:IsOpaque() then
				self:InitializeBlockID(dirt, true)
			end
		end)
	end
end

local function GrassThink(self)
	self.NextGrassThink = self.NextGrassThink or (CurTime() + math.random(5, 10))
	
	if self.NextGrassThink < CurTime() then
		self.NextGrassThink = CurTime() + math.random(5, 10)
		
		local tblock = self:GetBlockAtSide(mc.SIDE_TOP)
		if IsValid(tblock) and tblock:IsOpaque() then return end
		
		local blocks = self:GetNearBlocks()
		
		for k, v in pairs(blocks) do
			if not IsValid(v) then continue end
			if math.random(1, 2) ~= 1 then continue end
			if v:GetBlockID() ~= dirt then continue end
			
			local block = v:GetBlockAtSide(mc.SIDE_TOP)
			if IsValid(block) and block:IsOpaque() then continue end
			
			v:InitializeBlockID(grass, true)
		end
		
		local blocks2 = mc.CheckNearBlocks(self:GetPos() + mc.GetSideVector(mc.SIDE_TOP) * mc.STEP, tblock)
		
		for k, v in pairs(blocks2) do
			if not IsValid(v) then continue end
			if math.random(1, 2) ~= 1 then continue end
			if v:GetBlockID() ~= dirt then continue end
			
			local block = v:GetBlockAtSide(mc.SIDE_TOP)
			if IsValid(block) and block:IsOpaque() then continue end
			
			v:InitializeBlockID(grass, true)
		end
	end
end

self.RegisterEventHook(grass, 'Think', nil, GrassThink, nil)
self.RegisterEventHook(grass, 'BlockUpdate', nil, GrassUpdate, nil)

local FixAngle = Angle(0, -90, 0)

local function LadderUpdate(self)
	local dir = mc.GetSideVector(mc.GetSideByRotate(self:GetRotate()))
	
	--FIXME: Ladder have invalid angles
	dir:Rotate(FixAngle)
	
	local block = self:GetBlockAtSideByVector(dir)
	local cond = not IsValid(block) or
		not block:IsOpaque() or
		not block:IsSolid()
	
	if cond then
		self:OnDestruct()
	end
end

self.RegisterEventHook(self.GetBlockByName('ladder'), 'BlockUpdate', nil, LadderUpdate, nil)
