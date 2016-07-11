
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

function ENT:Initialize()
	self:SetModel('models/weapons/w_missile_closed.mdl')
	
	self.Expires = CurTime() + 8
	
	self:PhysicsInitSphere(16)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	phys:Wake()
	phys:EnableGravity(false)
	phys:EnableMotion(true)
	self.phys = phys
	
	util.SpriteTrail(self, 0, color_white, false, 10, 200, 5, 1 / (10 + 600) * 0.5, 'trails/smoke.vmt')
end

function ENT:Detonate()
	self.DETONATED = true
	util.BlastDamage(self, IsValid(self.SOwner) and self.SOwner or self, self:GetPos() + Vector(0, 0, 3), 128, 100)
	
	local effect = EffectData()
	effect:SetOrigin(self:GetPos())
	util.Effect('explosion', effect)
	
	self:Remove()
end

function ENT:Think()
	if self.Expires < CurTime() then
		self:Detonate()
		return
	end
	
	if not IsValid(self.ent) then self.phys:SetVelocity(self:GetAngles():Forward() * 1500) return end
	
	local dir = DSentry_GetEntityHitpoint(self.ent) - self:GetPos()
	dir:Normalize()
	
	self:SetAngles(dir:Angle())
	self.phys:SetVelocity(dir * 900)
end

function ENT:OnTakeDamage()
	if self.DETONATED then return end
	self:Detonate()
end

function ENT:PhysicsCollide(data)
	if self.DETONATED then return end
	if data.HitEntity == self.Ignore then return end
	self:Detonate()
end
