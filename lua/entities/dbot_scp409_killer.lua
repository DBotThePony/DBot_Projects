
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

ENT.PrintName = 'Crystalization'
ENT.Author = 'DBot'
ENT.Type = 'point'

for k, v in ipairs(ents.FindByClass('dbot_scp409_killer')) do
	v:Remove()
end

for k, v in ipairs(ents.FindByClass('dbot_scp409_fragment')) do
	v:Remove()
end

function ENT:Think()
	if CLIENT then return end
	
	local o = self:GetParent()
	
	if not IsValid(o) then 
		self:Remove() 
		return
	elseif o:IsPlayer() and not o:Alive() then 
		self:Remove() 
		return
	end
	
	o:TakeDamage(math.max(10, o:Health() * .1), IsValid(self.Crystal) and self.Crystal or self, self)
	
	if o:IsPlayer() then
		o:GodDisable()
	end
	
	self:NextThink(CurTime() + .3)
	
	return true
end

function ENT:OnRemove()
	for i = 1, math.random(1, 4) do
		local ent = ents.Create('dbot_scp409_fragment')
		ent:SetPos(self:GetPos())
		ent:Spawn()
		ent:Push()
		ent.Crystal = self.Crystal
	end
	
	if not IsValid(self:GetParent()) then return end
	self:GetParent().CRYSTALIZING = false
end
