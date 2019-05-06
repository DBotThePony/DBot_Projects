
--
-- Copyright (C) 2017-2019 DBotThePony

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


AddCSLuaFile()

ENT.Type = 'anim'
ENT.PrintName = 'Pickup Base'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
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

function ENT:CreateModel()
	if IsValid(self.ClientsideModel) then self.ClientsideModel:Remove() end
	self.ClientsideModel = ClientsideModel(self.Model or 'error.mdl')
	self.ClientsideModel:SetPos(self:GetPos())
	self.ClientsideModel:SetAngles(self:GetAngles())
	self.ClientsideModel:SetParent(self)
	self.ClientsideModel:SetNoDraw(true)
	self.CurrAng = Angle()
	self.LastDraw = 0
end

function ENT:Initialize()
	self:SetModel(self.Model or 'error.mdl')
	self:DrawShadow(false)

	if CLIENT then
		self:CreateModel()
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
	self.Timer = CurTimeL() + self.RespawnTimer
	self:SetNoDraw(true)
	if not self:GetShouldRespawn() then self:Remove() end
end

function ENT:Think()
	if CLIENT then return end

	if self.Used then
		if self.Timer < CurTimeL() then
			self:BringBack()
		else
			return
		end
	end

	local pos = self:GetPos()

	for k, v in ipairs(player.GetAll()) do
		if not v:IsPlayer() then continue end
		if not v:Alive() then continue end
		if v:GetPos():Distance(pos) > 70 then continue end
		if not self:OnUse(v) then continue end

		self:End()

		break
	end
end

function ENT:Draw()
	self.CurrAng.y = self.CurrAng.y + (self.LastDraw - CurTimeL()) * 44
	self.LastDraw = CurTimeL()
	self.CurrAng:Normalize()
	if IsValid(self.ClientsideModel) then
		self.ClientsideModel:SetAngles(self.CurrAng)
		self.ClientsideModel:DrawModel()
	else
		self:CreateModel()
	end
end
