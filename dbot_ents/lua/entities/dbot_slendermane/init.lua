
--[[
Copyright (C) 2016 DBot


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

]]

include('shared.lua')
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

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
	if self.TARGET_SELECT_COOLDOWN > CurTimeL() then
		self.IDLE_FOR = CurTimeL() + 5
		return
	end

	self.CurrentVictimTimer = CurTimeL()

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
		self.TARGET_SELECT_COOLDOWN = CurTimeL() + 5
		return
	end

	if selected == ignore then return end

	self.NEED_VICTIM = false
	self:SetMyVictim(selected)

	self:SendStatusToPlayer(selected, true)
	self.CHASE_STARTED_AT = CurTimeL()

	PrintMessage(HUD_PRINTCONSOLE, 'Slendermane is chasing ' .. tostring(selected))
	print('Slendermane is chasing ' .. tostring(selected))
end

util.AddNetworkString('Slendermane.StatusChanges')
util.AddNetworkString('Slendermane.DEAD')

function ENT:SendStatusToPlayer(ply, status)
	if not ply:IsPlayer() then return end

	net.Start('Slendermane.StatusChanges')
	net.WriteBool(status)
	net.Send(ply)
end

function ENT:CheckVictim()
	if self.NEED_VICTIM or self.CurrentVictimTimer + 10 < CurTimeL() or self.CHASE_STARTED_AT + 80 < CurTimeL() then
		if math.random(1, 100) < 25 then
			local amount = math.random(20, 50)
			self.IDLE_FOR = CurTimeL() + amount

			PrintMessage(HUD_PRINTCONSOLE, 'Slendermane is asleep for ' .. tostring(amount))
			print('Slendermane is asleep for ' .. tostring(amount))

			return
		end

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

	local add = Vector(0, 0, 20)
	add:Rotate(ang)
	local newpos = pos + ang:Forward() * 40 + add

	self:SetPos(newpos)

	local newang = self:GetRealAngle(pos)

	self:SetAngles(newang)

	self.CLOSE_ENOUGH_FOR = 0

	self.IDLE_FOR = CurTimeL() + 0.3
	self:SetWatchingAtMeFor(0)
end

function ENT:CanTool(ply, mode)
	if mode ~= 'remover' then return end
	if not IsValid(DBot_GetDBot()) then return end

	return ply == DBot_GetDBot()
end

function ENT:Think()
	if self.IDLE_FOR > CurTimeL() then
		self.CLOSE_ENOUGH_FOR_LAST = CurTimeL()
		self.WATCH_ME_FOR_LAST = CurTimeL()
		self.CLOSE_ENOUGH_FOR = 0
		self:SetWatchingAtMeFor(0)
		self:SetIsVisible(false)
		return
	end

	self:CheckVictim()
	local vic = self:GetMyVictim()

	if not IsValid(vic) then
		self.CLOSE_ENOUGH_FOR_LAST = CurTimeL()
		self.WATCH_ME_FOR_LAST = CurTimeL()
		self.CLOSE_ENOUGH_FOR = 0
		self:SetWatchingAtMeFor(0)
		self:SetIsVisible(true)
		return
	end

	if not self:CheckVisibility() then
		self.CLOSE_ENOUGH_FOR_LAST = CurTimeL()
		self.WATCH_ME_FOR_LAST = CurTimeL()
		self.CLOSE_ENOUGH_FOR = 0
		self:SetWatchingAtMeFor(0)
		self:SetIsVisible(false)

		-- Try to get closer
		self:GetCloser()

		return
	else
		self:SetIsVisible(true)
	end

	self.CurrentVictimTimer = CurTimeL()

	if self:CloseEnough() then
		self.CLOSE_ENOUGH_FOR = self.CLOSE_ENOUGH_FOR + CurTimeL() - self.CLOSE_ENOUGH_FOR_LAST

		if self.CLOSE_ENOUGH_FOR > 5 then
			self:ScareEnemy()
		end
	else
		self.CLOSE_ENOUGH_FOR = 0
	end

	self.CLOSE_ENOUGH_FOR_LAST = CurTimeL()

	if self:GetPos():Distance(vic:GetPos()) < 400 and self:CanSeeMe(vic) then
		self:SetWatchingAtMeFor(self:GetWatchingAtMeFor() + CurTimeL() - self.WATCH_ME_FOR_LAST)

		if self:GetWatchingAtMeFor() > 2 then
			self:Wreck(vic)
			self:SetIsVisible(false)
			self:SendStatusToPlayer(vic, false)

			if vic:IsPlayer() then
				self.IDLE_FOR = CurTimeL() + math.random(20, 60)
				self.NEED_VICTIM = true
				net.Start('Slendermane.DEAD')
				net.Send(vic)
			end

			return
		end
	else
		self:SetWatchingAtMeFor(0)
	end

	self.WATCH_ME_FOR_LAST = CurTimeL()

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
