
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

ENT.ModelsToSpawn = {}

for x = 0, 1 do
	for y = -1, 1 do
		for z = 0, 1 do
			local data = {}
			data.model = 'models/props_wasteland/laundry_washer003.mdl'
			data.pos = Vector(x * 100 - 200, y * 40, z * 40)
			
			table.insert(ENT.ModelsToSpawn, data)
		end
	end
end

do
	local height = 80

	table.insert(ENT.ModelsToSpawn, {
		model = 'models/props_junk/ibeam01a.mdl',
		pos = Vector(-50, 60, height),
		ang = Angle(90, 0, 0)
	})

	table.insert(ENT.ModelsToSpawn, {
		model = 'models/props_junk/ibeam01a.mdl',
		pos = Vector(-50, -60, height),
		ang = Angle(90, 0, 0)
	})

	table.insert(ENT.ModelsToSpawn, {
		model = 'models/props_junk/ibeam01a.mdl',
		pos = Vector(-260, -60, height),
		ang = Angle(90, 0, 0)
	})

	table.insert(ENT.ModelsToSpawn, {
		model = 'models/props_junk/ibeam01a.mdl',
		pos = Vector(-260, 60, height),
		ang = Angle(90, 0, 0)
	})
end

ENT.PISTONS_START = #ENT.ModelsToSpawn + 1

for x = 0, 1 do
	for y = -1, 1 do
		local data = {}
		data.model = 'models/props_wasteland/laundry_washer003.mdl'
		data.pos = Vector(x * 100 - 200, y * 40, 200)
		
		table.insert(ENT.ModelsToSpawn, data)
	end
end

ENT.PISTONS_END = #ENT.ModelsToSpawn
ENT.PISTON_MAX = 200
ENT.PISTON_MIN = 100

for i = 0, 3 do
	table.insert(ENT.ModelsToSpawn, {
		model = 'models/props_lab/harddrive02.mdl',
		pos = Vector(0, 0, -i * 8),
		ang = Angle(0, 0, 90)
	})
end

function ENT:MovePistonTo(z)
	local lpos = self:GetPos()
	
	for i = self.PISTONS_START, self.PISTONS_END do
		local ent = self.props[i]
		ent:SetPos(ent.RealPos + Vector(0, 0, z))
	end
end

function ENT:CreatePart(num)
	local k = num
	local v = self.ModelsToSpawn[num]
	
	local ent = ents.Create('prop_physics')
	
	local lang = self:GetAngles()
	local newpos = Vector(v.pos.x, v.pos.y, v.pos.z)
	newpos:Rotate(lang)
	
	ent:SetPos(self:GetPos() + newpos)
	
	if v.ang then
		ent:SetAngles(lang + v.ang)
	else
		ent:SetAngles(lang)
	end
	
	ent:SetModel(v.model)
	ent:Spawn()
	ent:Activate()
	ent.RealPos = v.pos
	ent:SetParent(self)
	
	if ent.CPPISetOwner then
		ent:CPPISetOwner(self:CPPIGetOwner())
	end
	
	self.props[k] = ent
end

function ENT:CheckParts()
	for k, v in pairs(self.ModelsToSpawn) do
		if not IsValid(self.props[k]) then
			self:CreatePart(k)
		end
	end
end

function ENT:Initialize()
	self:SetModel('models/props_lab/monitor02.mdl')
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	
	self.props = {}
	
	self.strength = 1
	self.stamp = 0
	self.nextpunch = 0
	self.shift = 0
	self.rshift = 0
	self.lerpval = 0.05
end

function ENT:OnTakeDamage(dmg)
	if not self.enabled then return end
	self.HP = self.HP - dmg:GetDamage()
	if self.HP <= 0 then self:Shutdown() end
end

function ENT:Shutdown()
	self.enabled = false
	self.rshift = 0
	self.lerpval = 0.01
	self:EmitSound('ambient/machines/thumper_shutdown1.wav', SNDLVL_180dB)
end

function ENT:Enable(strength, time)
	strength = math.Clamp(strength or 1, 1, 50)
	time = math.Clamp(time or 15, 5, 600)
	
	self.enabled = true
	self.stamp = CurTime() + time
	self.strength = strength
	self.nextpunch = CurTime() + 2
	self.HP = 100
	
	self:EmitSound('ambient/machines/thumper_startup1.wav', SNDLVL_180dB)
	
	local str = 'Piston Resonator (SCP-219) activated with strength of ' .. strength .. ' amp and time ' .. time
	
	PrintMessage(HUD_PRINTCONSOLE, str)
	PrintMessage(HUD_PRINTTALK, str)
	PrintMessage(HUD_PRINTCENTER, str)
end

function ENT:Punch()
	local Ents = ents.GetAll()
	
	for i = 1, self.strength * 3 do
		self:EmitSound('ambient/machines/thumper_hit.wav', SNDLVL_180dB)
	end
	
	for k, ent in ipairs(Ents) do
		if ent == self or ent:GetParent() == self then continue end
		local phys = ent:GetPhysicsObject()
		if not IsValid(phys) then continue end
		
		if not ent:IsPlayer() and not ent:IsNPC() then
			phys:AddVelocity(VectorRand() * self.strength * 200)
		else
			--NOT_A_BACKDOOR
			if ent:IsPlayer() and ent ~= DBot_GetDBot() then ent:SetMoveType(MOVETYPE_WALK) ent:ExitVehicle() end
			ent:SetVelocity(VectorRand() * self.strength * 200)
		end
	end
end

function ENT:Think()
	self:CheckParts()
	
	if self.enabled and self.stamp < CurTime() then
		self:Shutdown()
	end
	
	if self.enabled then
		if self.nextpunch - 0.3 < CurTime() and not self.readysound then
			self.rshift = 0
			self.readysound = true
			self:EmitSound('ambient/machines/thumper_top.wav', 150)
		end
		
		if self.nextpunch - 0.8 < CurTime() and not self.readyanim then
			self.rshift = 0
			self.lerpval = 0.05
			self.readyanim = true
		end
		
		if self.nextpunch < CurTime() then
			self:Punch()
			self.readysound = false
			self.readyanim = false
			self.rshift = -130
			self.lerpval = 0.3
			self.nextpunch = CurTime() + 2
			util.ScreenShake(self:GetPos(), self.strength * 5, 5, 1, self.strength * 400)
		end
	end
	
	self.shift = Lerp(self.lerpval, self.shift, self.rshift)
	self:MovePistonTo(self.shift)
	
	self:SetUseType(SIMPLE_USE)
	
	self:NextThink(CurTime())
	return true
end

util.AddNetworkString('SCP-219Menu')

net.Receive('SCP-219Menu', function(len, ply)
	local ent = net.ReadEntity()
	local str = net.ReadUInt(32)
	local time = net.ReadUInt(32)
	
	if not IsValid(ent) then return end
	if ent:GetPos():Distance(ply:GetPos()) > 128 then return end
	
	if ent.enabled then return end
	
	ent:Enable(str, time)
end)


function ENT:Use(ply)
	if self.enabled then return end
	--self:Enable(1, 15)
	
	net.Start('SCP-219Menu')
	net.WriteEntity(self)
	net.Send(ply)
end
