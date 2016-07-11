
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
	self:SetModel('models/Combine_Helicopter/helicopter_bomb01.mdl')
	self:SetModelScale(0.4)
	
	self:PhysicsInitSphere(32)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(SOLID_VPHYSICS)
	
	timer.Simple(0, function()
		local phys = self:GetPhysicsObject()
		
		if IsValid(phys) then
			self.phys = phys
			phys:SetMass(128)
			phys:Sleep()
		end
	end)
end

function ENT:PhysicsCollide(data)
	if not self.phys then return end
	local vel = self.phys:GetVelocity()
	local mult = data.HitNormal
	
	local summ = vel.x + vel.y + vel.z
	
	self.phys:AddVelocity(-mult * summ * 5 + vel * 2)
end