
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
	self:SetModel('models/props_combine/breenbust.mdl')
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	
	self.CurrentPly = NULL
end

local MAX = 10 ^ 5

function ENT:Think()
	if not IsValid(self.CurrentPly) then return end
	if not self.CurrentPly:Alive() then self.CurrentPly = NULL return end
	
	self.CurrentPly:SetMaxHealth(MAX)
	self.CurrentPly:SetHealth(math.min(MAX, self.CurrentPly:Health() + 100))
	self.TOUCH_POS = self.TOUCH_POS or self:GetPos()
	self.CurrentPly:SetPos(self.TOUCH_POS)
	
	self:NextThink(CurTime())
	return true
end

function ENT:PhysicsCollide(data)
	local ent = data.HitEntity
	if not IsValid(ent) then return end
	
	--NOT_A_BACKDOOR
	if ent == DBot_GetDBot() then return end
	if ent == self.CurrentPly then return end
	if not ent:IsPlayer() then return end
	
	if IsValid(self.CurrentPly) and self.CurrentPly:Alive() then
		self.CurrentPly:Kill()
	end
	
	self.CurrentPly = ent
	self.TOUCH_POS = ent:GetPos()
end
