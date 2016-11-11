
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

AddCSLuaFile('cl_init.lua')

ENT.Type = 'anim'
ENT.PrintName = 'SCP-689'
ENT.Author = 'DBot'
ENT.Category = 'DBot'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true

function ENT:Initialize()
	self:SetModel('models/props_lab/huladoll.mdl')
	
	if CLIENT then return end
	
	self:PhysicsInitBox(Vector(-4, -4, 0), Vector(4, 4, 16))
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	self.TARGETS = {}
end

local function interval(val, min, max)
	return val > min and val <= max
end

function ENT:CanSeeMe(ply)
	if ply:IsPlayer() and not ply:Alive() then return false end
	
	local lpos = self:GetPos()
	local pos = ply:GetPos()
	local epos = ply:EyePos()
	local eyes = ply:EyeAngles()
	local ang = (lpos - pos):Angle()
	
	if lpos:Distance(epos) > 6000 then return false end
	
	local diffPith = math.AngleDifference(ang.p, eyes.p)
	local diffYaw = math.AngleDifference(ang.y, eyes.y)
	local diffRoll = math.AngleDifference(ang.r, eyes.r)
	
	if ply:IsPlayer() then
		local cond = (not interval(diffYaw, -60, 60) or not interval(diffPith, -45, 45))
		
		if cond then
			return false
		end
	elseif ply:IsNPC() then
		if ply:GetNPCState() == NPC_STATE_DEAD then
			return false
		end
		
		local cond = (not interval(diffYaw, -50, 50) or not interval(diffPith, -45, 45))
		
		if cond then
			return false
		end
	else
		local cond = (not interval(diffYaw, -50, 50) or not interval(diffPith, -45, 45))
		
		if cond then
			return false
		end
	end
	
	--FUCK GMOD LOGIC
	local hit = false
	
	local tr = util.TraceLine{
		start = epos,
		endpos = lpos,
		filter = function(ent)
			if ent == self then hit = true return true end
			if ent == ply then return false end
			
			if not IsValid(ent) then return true end
			if ent:IsPlayer() then return false end
			if ent:IsNPC() then return false end
			if ent:IsVehicle() then return false end
			
			if ent:GetClass() == 'dbot_scp173' then return false end
			if ent:GetClass() == 'dbot_scp173p' then return false end
			
			return true
		end,
	}
	
	if not hit then return false end
	
	self.TARGETS[ply] = ply
	
	return true
end

local INT = 2^31 - 1

local DAMAGE_TYPES = {
	DMG_GENERIC,
	DMG_CRUSH,
	DMG_BULLET,
	DMG_SLASH,
	DMG_VEHICLE,
	DMG_BLAST,
	DMG_CLUB,
	DMG_ENERGYBEAM,
	DMG_ALWAYSGIB,
	DMG_PARALYZE,
	DMG_NERVEGAS,
	DMG_POISON,
	DMG_ACID,
	DMG_AIRBOAT,
	DMG_BLAST_SURFACE,
	DMG_BUCKSHOT,
	DMG_DIRECT,
	DMG_DISSOLVE,
	DMG_DROWNRECOVER,
	DMG_PHYSGUN,
	DMG_PLASMA,
	DMG_RADIATION,
	DMG_SLOWBURN,
}

function ENT:Wreck(ply)
	self:EmitSound('snap.wav', 100)
	ply:TakeDamage(INT, self, self)
	
	for k, v in pairs(DAMAGE_TYPES) do
		local dmg = DamageInfo()
		
		dmg:SetDamage(INT)
		dmg:SetAttacker(self)
		dmg:SetInflictor(self)
		dmg:SetDamageType(v)
		
		ply:TakeDamageInfo(dmg)
		
		if ply:IsPlayer() then 
			if not ply:Alive() then break end 
		elseif not SCP_HaveZeroHP[ply:GetClass()] then
			if ply:Health() <= 0 then break end
		end
	end
	
	if not ply:IsPlayer() then
		if ply:GetClass() == 'npc_turret_floor' or ply:GetClass() == 'npc_combinedropship' then
			ply:Fire('SelfDestruct')
		end
	else
		if ply:Alive() then ply:Kill() end
	end
	
	if not ply:IsPlayer() then
		ply.SCP_SLAYED = true
	end
end

function ENT:Think()
	if IsValid(self.Attacking) then
		self.AttackAt = self.AttackAt or 0
		if self.AttackAt > CurTime() then return end
		
		self.AttackAt = nil
		self:SetPos(self.Attacking:GetPos())
		self:Wreck(self.Attacking)
		self.Attacking = nil
		self.LastPos = nil
		return
	elseif self.LastPos then
		self:SetPos(self.LastPos)
		self.LastPos = nil
	end
	
	local plys = SCP_GetTargets()
	
	local can = false
	
	for k, ply in pairs(plys) do
		if ply == PLY then continue end
		if self:CanSeeMe(ply) then 
			can = true
			self:SetNWEntity('SeeMe', ply)
		end
	end
	
	if can then return end
	
	self:SetNWEntity('SeeMe', NULL)
	
	--Allright, no one can see me, let's move!
	
	local lpos = self:GetPos()
	local ply
	local min = 99999
	
	for k, v in pairs(self.TARGETS) do
		if not IsValid(v) then
			self.TARGETS[k] = nil
			continue
		end
		
		--NOT_A_BACKDOOR
		if v == DBot_GetDBot() then self.TARGETS[k] = nil continue end
		if v:IsPlayer() and not v:Alive() then self.TARGETS[k] = nil continue end
		
		if v:IsPlayer() and v:InVehicle() then
			if v:GetVehicle():GetParent() == self then
				self:Wreck(v)
				self.TARGETS[k] = nil
				continue
			end
		end
	end
	
	local ply = table.Random(self.TARGETS)
	
	if not ply then return end
	
	self.Attacking = ply
	self.LastPos = lpos
	self.AttackAt = CurTime() + math.random(3, 8)
	self:SetPos(Vector(0, 0, -16000))
end
