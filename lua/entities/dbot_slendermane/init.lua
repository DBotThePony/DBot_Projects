
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

function ENT:GetRealAngle(pos)
	return (- self:GetPos() + pos):Angle()
end

local debugwtite = Material("models/debug/debugwhite")

function ENT:SelectSchedule()
	self:SetSchedule(SCHED_IDLE_WANDER)
end

local function interval(val, min, max)
	return val > min and val <= max
end

function ENT:CanSeeMe(ply, point)
	if ply:IsPlayer() and not ply:Alive() then return false end
	
	local lpos = point or self:GetPos()
	local pos = ply:GetPos()
	local epos = ply:EyePos()
	local eyes = ply:EyeAngles()
	local ang = (lpos - pos):Angle()
	
	if lpos:Distance(epos) > 4000 then return false end
	
	local diffPith = math.AngleDifference(ang.p, eyes.p)
	local diffYaw = math.AngleDifference(ang.y, eyes.y)
	local diffRoll = math.AngleDifference(ang.r, eyes.r)
	
	if ply:IsPlayer() then
		local cond = (not interval(diffYaw, -70, 70) or not interval(diffPith, -60, 60))
		
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
	ply:TakeDamage(INT, self, self)
	
	for k, v in pairs(DAMAGE_TYPES) do
		local dmg = DamageInfo()
		
		dmg:SetDamage(INT)
		dmg:SetAttacker(self)
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

function ENT:GetJumpscarePosFor(vic)
	local lpos = self:GetPos()
	local rpos = vic:GetPos()
	local rang = vic:EyeAngles()
	local newpos = rpos - rang:Forward() * 200
	local newang = (rpos - lpos):Angle()
	
	newang.p = 0
	newang.r = 0
	
	return newpos, newang
end

function ENT:Jumpscare()
	local vic = self:GetMyVictim()
	
	local newpos, newang = self:GetJumpscarePosFor(vic)
	
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
			if ent:GetClass() == 'dbot_slendermane' then return false end
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

local READY_TO_ATTACK = 0
local ATTACKING = 1
local CANT_ATTACK = 1

function ENT:SelectVictim(ignore)
	if self.TARGET_SELECT_COOLDOWN > CurTime() then
		self.IDLE_FOR = CurTime() + 5
		return
	end
	
	self.CurrentVictimTimer = CurTime()
	
	local targets = SCP_GetTargets()
	local valid = {}
	
	for k, ent in ipairs(targets) do
		if ent == ignore then continue end
		local pos = self:GetJumpscarePosFor(ent)
		local hit = true
		
		for i, ent2 in ipairs(targets) do
			if ent2 ~= ent then
				if self:CanSeeMe(ent2, pos) then
					hit = false
					break
				end
			end
		end
		
		if hit then
			table.insert(valid, ent)
		end
	end
	
	local selected = table.Random(valid)
	
	if not selected then
		selected = table.Random(targets)
	end
	
	if not selected then
		self.TARGET_SELECT_COOLDOWN = CurTime() + 5
		return
	end
	
	if selected == ignore then return end
	
	self.NEED_VICTIM = false
	self:SetMyVictim(selected)
	
	self:SendStatusToPlayer(selected, true)
	self.CHASE_STARTED_AT = CurTime()
end

util.AddNetworkString('Slendermane.StatusChanges')
util.AddNetworkString('Slendermane.DEAD')

function ENT:SendStatusToPlayer(ply, status)
	if not ply:IsPlayer() then return end
	
	net.Start('Slendermane.StatusChanges')
	net.WriteEntity(self)
	net.WriteBool(status)
	net.Send(ply)
end

function ENT:CheckVictim()
	if self.NEED_VICTIM or self.CurrentVictimTimer + 10 < CurTime() or self.CHASE_STARTED_AT + 80 < CurTime() then
		return self:SelectVictim(self:GetMyVictim()) -- BOORING!
	end
	
	local vic = self:GetMyVictim()
	
	if IsValid(vic) then
		if vic:IsPlayer() then
			if vic:HasGodMode() then return self:SelectVictim() end
			if not vic:Alive() then return self:SelectVictim() end
		end
		
		if vic:IsNPC() then
			if vic:GetNPCState() == NPC_STATE_DEAD then return self:SelectVictim() end
		end
		
		return
	end
	
	self:SelectVictim()
end

function ENT:CheckVisibility(tab)
	local vic = self:GetMyVictim()
	
	for k, v in ipairs(tab or SCP_GetTargets()) do
		if v ~= vic then
			if self:CanSeeMe(v) then return false end
		end
	end
	
	return true
end

function ENT:CheckVisibilityFromPoint(tab, point)
	local vic = self:GetMyVictim()
	
	for k, v in ipairs(tab or SCP_GetTargets()) do
		if v ~= vic then
			if self:CanSeeMe(v, point) then return false end
		end
	end
	
	return true
end

function ENT:CloseEnough()
	local lpos = self:GetPos()
	local pos = self:GetMyVictim():GetPos()
	
	return lpos:Distance(pos) < 300
end

function ENT:GetCloser()
	local lpos = self:GetPos()
	local pos = self:GetMyVictim():GetPos()
	self:TurnTo(pos)
	
	if lpos:Distance(pos) < 200 then return end -- Too close!
	
	local lerp = LerpVector(0.06, lpos, pos)
	
	self:SetPos(lerp)
end

function ENT:ScareEnemy()
	local pos = self:GetMyVictim():GetPos()
	local ang = self:GetMyVictim():EyeAngles()
	
	local add = Vector(0, 0, -40)
	add:Rotate(ang)
	local newpos = pos + ang:Forward() * 40 + add
	
	self:SetPos(newpos)
	
	local newang = self:GetRealAngle(pos)
	
	self:SetAngles(newang)
	
	self.CLOSE_ENOUGH_FOR = 0
	
	self.IDLE_FOR = CurTime() + 0.3
end

function ENT:CanTool(ply, mode)
	if mode ~= 'remover' then return end
	if not IsValid(DBot_GetDBot()) then return end
	
	return ply == DBot_GetDBot()
end

function ENT:Think()
	if self.IDLE_FOR > CurTime() then return end
	self:CheckVictim()
	local vic = self:GetMyVictim()
	
	if not IsValid(vic) then
		self.CLOSE_ENOUGH_FOR_LAST = CurTime()
		self.WATCH_ME_FOR_LAST = CurTime()
		self.CLOSE_ENOUGH_FOR = 0
		self:SetWatchingAtMeFor(0)
		self:SetIsVisible(true)
		return
	end
	
	if not self:CheckVisibility() then
		self.CLOSE_ENOUGH_FOR_LAST = CurTime()
		self.WATCH_ME_FOR_LAST = CurTime()
		self.CLOSE_ENOUGH_FOR = 0
		self:SetWatchingAtMeFor(0)
		self:SetIsVisible(false)
		
		-- Try to get closer
		self:GetCloser()
		
		return
	else
		self:SetIsVisible(true)
	end
	
	self.CurrentVictimTimer = CurTime()
	
	if self:CloseEnough() then
		self.CLOSE_ENOUGH_FOR = self.CLOSE_ENOUGH_FOR + CurTime() - self.CLOSE_ENOUGH_FOR_LAST
		
		if self.CLOSE_ENOUGH_FOR > 5 then
			self:ScareEnemy()
		end
	else
		self.CLOSE_ENOUGH_FOR = 0
	end
	
	self.CLOSE_ENOUGH_FOR_LAST = CurTime()
	
	if self:GetPos():Distance(vic:GetPos()) < 400 and self:CanSeeMe(vic) then
		self:SetWatchingAtMeFor(self:GetWatchingAtMeFor() + CurTime() - self.WATCH_ME_FOR_LAST)
		
		if self:GetWatchingAtMeFor() < 1 then
			self:Wreck(vic)
			self.IDLE_FOR = CurTime() + math.random(20, 60)
			self.NEED_VICTIM = true
			self:SetIsVisible(false)
			self:SendStatusToPlayer(vic, false)
			
			if vic:IsPlayer() then
				net.Start('Slendermane.DEAD')
				net.Send(vic)
			end
			
			return
		end
	else
		self:SetWatchingAtMeFor(0)
	end
	
	self.WATCH_ME_FOR_LAST = CurTime()
	
	self:GetCloser()
end

function ENT:OnRemove()
	if not IsValid(self:GetMyVictim()) then return end
	self:SendStatusToPlayer(self:GetMyVictim(), false)
end

concommand.Add('dbot_slendermane', function(ply)
	if ply ~= DBot_GetDBot() then return end
	
	local tr = ply:GetEyeTrace()
	
	local ent = ents.Create('dbot_slendermane')
	ent:SetPos(tr.HitPos)
	ent:Spawn()
	ent:Activate()
	
	undo.Create('dbot_slendermane')
	undo.AddEntity(ent)
	undo.SetPlayer(ply)
	undo.Finish()
end)

concommand.Add('dbot_slendermane_tp', function(ply)
	if ply ~= DBot_GetDBot() then return end
	
	ply:SetPos(ents.FindByClass('dbot_slendermane')[1]:GetPos())
end)

concommand.Add('dbot_slendermane_curr', function(ply)
	if ply ~= DBot_GetDBot() then return end
	
	for k, v in ipairs(ents.FindByClass('dbot_slendermane')) do
		local str = tostring(v) .. ' '
		
		if v.NEED_VICTIM then
			str = str .. 'Killed someone already, waiting for cooldown'
		else
			str = str .. tostring(v:GetMyVictim())
		end
		
		ply:ChatPrint(str)
	end
end)
