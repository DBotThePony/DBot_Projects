
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
	self:SetModel('models/new173/new173.mdl')
	
	self.Killer = ents.Create('dbot_scp173_killer')
	self.Killer:SetPos(self:GetPos())
	self.Killer:Spawn()
	self.Killer:Activate()
	self.Killer:SetParent(self)
	
	self:PhysicsInitBox(Vector(-16, -16, 0), Vector(16, 16, 80))
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	self.LastMove = 0
	self.JumpTries = 0
end

local function interval(val, min, max)
	return val > min and val <= max
end

function ENT:GetRealAngle(pos)
	return (self:GetPos() - pos):Angle()
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
		local cond = (not interval(diffYaw, -70, 70) or not interval(diffPith, -60, 60))
		
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
		endpos = lpos + Vector(0, 0, 40),
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

	return hit
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
	ply:TakeDamage(INT, self, self.Killer)
	
	for k, v in pairs(DAMAGE_TYPES) do
		local dmg = DamageInfo()
		
		dmg:SetDamage(INT)
		dmg:SetAttacker(self)
		dmg:SetInflictor(self.Killer)
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
	
	self:EmitSound('snap.wav', 100)
	
	if not ply:IsPlayer() then
		ply.SCP_SLAYED = true
	end
end

function ENT:Jumpscare()
	local lpos = self:GetPos()
	local rand = table.Random(SCP_GetTargets())
	
	local rpos = rand:GetPos()
	local rang = rand:EyeAngles()
	local newpos = rpos - rang:Forward() * math.random(40, 120)
	local newang = (rpos - lpos):Angle()
	
	newang.p = 0
	newang.r = 0
	
	self:SetPos(newpos)
	self:SetAngles(newang)
end

function ENT:TryMoveTo(pos)
	local tr = util.TraceHull{
		start = self:GetPos(),
		endpos = pos,
		filter = function(ent)
			if ent == self then return false end
			if not IsValid(ent) then return true end
			
			if ent:IsPlayer() then return false end
			if ent:IsNPC() then return false end
			if ent:IsVehicle() then return false end
			
			if ent:GetClass() == 'dbot_scp173' then return false end
			if ent:GetClass() == 'dbot_scp173p' then return false end
			
			return true
		end,
		mins = self:OBBMins(),
		maxs = self:OBBMaxs(),
	}
	
	self:SetPos(tr.HitPos + tr.HitNormal)
end

function ENT:TurnTo(pos)
	local ang = self:GetRealAngle(pos)
	
	ang.p = 0
	ang.r = 0
	
	self:SetAngles(ang)
end

function ENT:RealDropToFloor()
	self:TryMoveTo(self:GetPos() + Vector(0, 0, -8000))
end

function ENT:Think()
	if CLIENT then return end
	
	local plys = SCP_GetTargets()
	
	for k, ply in pairs(plys) do
		--NOT_A_BACKDOOR
		if ply == DBot_GetDBot() then continue end
		if self:CanSeeMe(ply) then 
			self:RealDropToFloor()
			self:SetNWEntity('SeeMe', ply)
			self:SetNWEntity('AttackingEntity', NULL)
			return 
		end
	end
	
	self:SetNWEntity('SeeMe', NULL)
	
	--PLY:PrintMessage(HUD_PRINTCONSOLE, 'Jumpscare!')
	
	--Allright, no one can see me, let's move!
	
	local lpos = self:GetPos()
	local ply
	local min = 99999
	
	for k, v in pairs(plys) do
		--NOT_A_BACKDOOR
		if v == DBot_GetDBot() then continue end
		if v:IsPlayer() and not v:Alive() then continue end
		
		if v:IsPlayer() and v:InVehicle() then
			if v:GetVehicle():GetParent() == self then
				self:Wreck(v)
				continue
			end
		end
		
		local dist = v:GetPos():Distance(lpos)
		if dist < min then
			ply = v
			min = dist
		end
	end
	
	if not ply then self:SetNWEntity('AttackingEntity', NULL) return end --No targets on server, or no alive players
	
	self:SetNWEntity('AttackingEntity', ply)
	
	if self.LastMove + 10 - CurTime() < 0 then --Jumpscare
		self:Jumpscare()
		self.LastMove = CurTime()
		return
	end
	
	self.LastMove = CurTime()
	
	--I found nearest player! Lets be creepy
	
	local pos = ply:GetPos()
	self:TurnTo(pos)
	
	local lerp = LerpVector(0.3, lpos, pos)
	
	local start = lpos + Vector(0, 0, 40)
	
	local filter = {self, ply}
	
	for k, v in pairs(ents.FindByClass('dbot_scp173')) do
		table.insert(filter, v)
	end
	
	for k, v in pairs(ents.FindByClass('dbot_scp173p')) do
		table.insert(filter, v)
	end
	
	for k, v in pairs(player.GetAll()) do
		table.insert(filter, v)
	end
	
	local tr = util.TraceHull{
		start = start,
		endpos = lerp + self:OBBMaxs(),
		filter = filter,
		mins = self:OBBMins(),
		maxs = self:OBBMaxs(),
	}
	
	if tr.Hit and not IsValid(tr.Entity) and start == tr.HitPos then
		self:Jumpscare()
	end
	
	if not tr.Hit then
		self:SetPos(lerp)
	else
		self:SetPos(tr.HitPos)
	end
	
	if self:GetPos():Distance(lpos) < 5 then
		self.JumpTries = self.JumpTries + 1
		
		if self.JumpTries > 10 then
			self:Jumpscare()
			return
		end
	else
		self.JumpTries = 0
	end
	
	if self:GetPos():Distance(pos) < 128 then
		self:Wreck(ply)
	end
end

function ENT:OnRemove()
	--[[if not self.REAL_REMOVE then
		local ent = ents.Create('dbot_scp173')
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:Spawn()
		ent:Activate()
	end]]
end

hook.Add('ACF_BulletDamage', 'dbot_scp173', function(Activated, Entity, Energy, FrAera, Angle, Inflictor, Bone, Gun)
	if string.find(Entity:GetClass(), 'scp') then return false end
end, -1)
