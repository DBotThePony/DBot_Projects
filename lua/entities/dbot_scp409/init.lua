
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

function ENT:PhysicsCollide(data)
	local ent = data.HitEntity
	if not IsValid(ent) then return end
	
	--NOT_A_BACKDOOR
	if ent == DBot_GetDBot() then return end
	
	self:Attack(ent)
end

function ENT:Initialize()
	self:SetModel('models/props_debris/barricade_short01a.mdl')
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
end

function ENT:Think()
	for k, v in pairs(ents.FindInSphere(self:GetPos(), 64)) do
		--NOT_A_BACKDOOR
		if v == DBot_GetDBot() then continue end
		if IsValid(v:GetParent()) then continue end
		if v == self then continue end
		if v:Health() <= 0 then
			if v:GetClass() ~= 'prop_physics' then continue end
			self:Attack(v)
			SafeRemoveEntity(v)
			continue 
		end
		
		self:Attack(v)
	end
end

function ENT:Attack(ent)
	if ent.CRYSTALIZING then return end
	if string.find(ent:GetClass(), 'scp') then return end
	
	ent.CRYSTALIZING = true
	local point = ents.Create('dbot_scp409_killer')
	point:SetPos(ent:GetPos())
	point:SetParent(ent)
	point:Spawn()
	point:Activate()
	
	point.Crystal = self
	
	return point
end
