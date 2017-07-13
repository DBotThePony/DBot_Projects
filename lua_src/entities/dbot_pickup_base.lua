
--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

AddCSLuaFile()

ENT.Type = 'anim'
ENT.PrintName = 'Pickup Base'
ENT.Author = 'DBot'
ENT.Category = 'DBot'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Used = false
ENT.OneUse = false
ENT.Timer = 0
ENT.RespawnTimer = 10
ENT.Sound = 'items/spawn_item.wav'

AccessorFunc(ENT, 'm_Respawn', 'ShouldRespawn')

function ENT:SpawnFunction(ply, tr, class)
	if not tr.Hit then return end

	local ent = ents.Create(class)
	ent:SetPos(tr.HitPos + tr.HitNormal * 8)
	ent:Spawn()
	ent:Activate()
	ent:SetShouldRespawn(true)

	return ent
end

function ENT:Initialize()
	self:SetModel(self.Model or 'error.mdl')
	self:DrawShadow(false)

	if CLIENT then
		self.ClientsideModel = ClientsideModel(self.Model or 'error.mdl')
		self.ClientsideModel:SetPos(self:GetPos())
		self.ClientsideModel:SetAngles(self:GetAngles())
		self.ClientsideModel:SetParent(self)
		self.ClientsideModel:SetNoDraw(true)
		self.CurrAng = Angle()
		self.LastDraw = 0
		return
	end

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
end

function ENT:OnRemove()
	if CLIENT and IsValid(self.ClientsideModel) then
		self.ClientsideModel:Remove()
	end
end

function ENT:Use()
	return
end

function ENT:OnUse(ply)
	--To override
end

function ENT:BringBack()
	self.Used = false
	self.Timer = 0
	self:SetNoDraw(false)
	self:EmitSound(self.Sound)
end

function ENT:End()
	if self.OneUse then
		SafeRemoveEntity(self)
		return
	end

	self.Used = true
	self.Timer = CurTime() + self.RespawnTimer
	self:SetNoDraw(true)
	if not self:GetShouldRespawn() then self:Remove() end
end

function ENT:Think()
	if CLIENT then return end

	if self.Used then
		if self.Timer < CurTime() then
			self:BringBack()
		else
			return
		end
	end

	local pos = self:GetPos()

	for k, v in ipairs(player.GetAll()) do
		if not v:IsPlayer() then continue end
		if not v:Alive() then continue end
		if v:GetPos():Distance(pos) > 128 then continue end
		if not self:OnUse(v) then continue end

		self:End()

		break
	end
end

function ENT:Draw()
	self.CurrAng.y = self.CurrAng.y + (self.LastDraw - CurTime()) * 44
	self.LastDraw = CurTime()
	self.CurrAng:Normalize()
	self.ClientsideModel:SetAngles(self.CurrAng)
	self.ClientsideModel:DrawModel()
end
