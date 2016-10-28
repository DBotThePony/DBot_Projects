
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

local function GetLerp()
	return FrameTime() * 66
end

local function Nearests(pos, dis)
	local reply = {}
	
	for k, v in pairs(player.GetAll()) do
		if v:GetPos():Distance(pos) < dis then
			table.insert(reply, v)
		end
	end
	
	return reply
end

function ENT:Idle()
	if not self.IsIDLE then
		self.IsIDLE = true
		self.NextIDLEThink = CurTime() + 4
	end
	
	if IsValid(self.WatchAtPlayer) and self:CanSeeTarget(self.WatchAtPlayer) then
		self.AngleTo = (-self:GetPos() + DSentry_GetEntityHitpoint(self.WatchAtPlayer)):Angle()
	end
	
	if self.NextIDLEThink < CurTime() then
		self.WatchAtPlayer = nil
		
		if math.random() > 0.5 then
			local p = table.Random(Nearests(self:GetPos(), 1000))
			self.WatchAtPlayer = p
		end
		
		self.NextIDLEThink = CurTime() + math.random(50, 300) / 100
		
		if not IsValid(self.WatchAtPlayer) then
			local rand = AngleRand()
			rand.r = 0
			rand.p = math.random(-10, 10)
			self.AngleTo = rand
		end
	end
end

local Recover = false

function ENT:OnRemove()
	SafeRemoveEntity(self.BaseProp)
	SafeRemoveEntity(self.Stick)
	
	if Recover then
		local newEnt = ents.Create('dbot_sentry')
		newEnt:SetPos(self:GetPos())
		newEnt:SetAngles(self:GetAngles())
		newEnt:Spawn()
		newEnt:Activate()
		newEnt.Targets = self.Targets
		newEnt.CurrentTarget = self.CurrentTarget
	end
end

function ENT:OnTakeDamage(dmg)
	local a = dmg:GetAttacker()
	if not IsValid(a) then return end
	for k, v in ipairs(GetDSentries()) do
		v:AddTarget(a)
	end
end

function ENT:Initialize()
	self.Targets = {}
	self:SetModel('models/hunter/blocks/cube075x075x075.mdl')
	self:SetMaterial('models/debug/debugwhite')
	
	if CLIENT then return end
	
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_PUSH)
	self:PhysicsInit(SOLID_VPHYSICS)
	
	self.AngleTo = Angle(0, 0, 0)
	self.NextIDLEThink = 0
	self.NextShot = 0
	self.IsIDLE = false
	
	self.Damping = 0
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end
	
	self:SetColor(Color(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
	
	timer.Simple(0, function() self:CreateEnts() end)
end

function ENT:GetTarget()
	if not IsValid(self.CurrentTarget) then self:ClearTargets() end
	
	if IsValid(self.CurrentTarget) then
		if self.CurrentTarget:IsPlayer() then
			if not self.CurrentTarget:Alive() then
				self:ClearTargets()
			elseif self.CurrentTarget:HasGodMode() then
				self:ClearTargets()
			end
		elseif self.CurrentTarget:IsNPC() then
			if self.CurrentTarget:GetNPCState() == NPC_STATE_DEAD then
				self:ClearTargets()
			end
		end
	end
	
	--NOT_A_BACKDOOR
	if self.CurrentTarget == DBot_GetDBot() then
		self:ClearTargets()
	end
	
	return self.CurrentTarget
end

function ENT:HasTarget()
	return IsValid(self:GetTarget())
end

function ENT:Follow(ply)
	self.IsFollowing = true
	self.FollowPly = ply
end

function ENT:UnFollow()
	self.IsFollowing = false
end

local HullSize = 20

function ENT:AddTarget(target)
	if table.HasValue(self.Targets, target) then return end
	table.insert(self.Targets, target)
end

function ENT:Attack()
	if not self:HasTarget() then return end
	
	local t = self:GetTarget()
	
	local toCheck = {
		self,
		self.Stick,
		self.Tower,
		self.BaseProp,
		self.Antennas,
		self.Antennas2,
	}
	
	for k, v in ipairs(toCheck) do
		if t:GetParent() == v then
			t:SetParent(NULL)
			break
		end
		
		local result = constraint.GetTable(t)
		
		for i, data in ipairs(result) do
			if data.Ent1 == v or data.Ent2 == v then
				data.Constraint:Remove()
			end
		end
	end
	
	local hitpos = DSentry_GetEntityHitpoint(t)
	t._DSentry_LastPos = t._DSentry_LastPos or hitpos
	local Change = (t._DSentry_LastPos - hitpos) * (-1)
	t._DSentry_LastPos = hitpos
	local spos = self:GetPos()
	
	if not DSENTRY_CHEAT_MODE then
		self.AngleTo = (-spos + hitpos + Change):Angle()
	else
		self.AngleTo = (-spos + hitpos):Angle()
	end
	
	if t:IsPlayer() and t:InVehicle() or DSENTRY_CHEAT_MODE then
		self:FireBullet()
	else
		local tr = util.TraceLine{
			start = spos,
			endpos = spos + self:GetAngles():Forward() * (hitpos:Distance(spos) + 40),
			filter = {self, self.Tower, self.Antennas, self.Stick}
		}
		
		if tr.Entity == t then
			self:FireBullet()
		end
	end
end

local function BulletHit(self, tr, dmg, penetrate)
	penetrate = penetrate or 1
	local ent = tr.Entity
	
	dmg:SetDamageType(DMG_BLAST)
	
	local cdata = EffectData()
	cdata:SetOrigin(tr.HitPos)
	cdata:SetScale(1)
	cdata:SetMagnitude(1000)
	cdata:SetRadius(64)
	util.Effect('TeslaZap', cdata)
	
	local cdata = EffectData()
	cdata:SetOrigin(tr.HitPos)
	cdata:SetStart(self:GetPos())
	cdata:SetScale(6000)
	cdata:SetMagnitude(1000)
	cdata:SetRadius(1)
	util.Effect('GaussTracer', cdata)
	
	if penetrate < 5 then
		local sang = self:GetAngles()
		
		local Pos = tr.HitPos + self:GetAngles():Forward() * 20
		
		local tr2 = util.TraceLine{
			start = Pos,
			endpos = Pos,
		}
		
		penetrate = penetrate + 1
		
		if not tr2.Hit or tr2.Entity ~= ent then
			local fent = IsValid(ent) and ent or self
			local fpos = IsValid(ent) and tr.HitPos or Pos
			
			fent:FireBullets{
				Attacker = self,
				Damage = 100 / penetrate,
				Force = 4500 / penetrate,
				Src = fpos,
				Dir = self:GetAngles():Forward(),
				TracerName = '',
				Tracer = 1,
				Callback = function(self2, tr5, dmg2)
					BulletHit(self2, tr5, dmg2, penetrate)
				end,
			}
		end
	end
	
	if IsValid(ent) then
		if ent:IsPlayer() then
			if ent:Health() > 5000 then
				dmg:SetDamage(2^31 - 1)
			end
			
			ent:SetVelocity((ent:GetPos() - self:GetPos()):GetNormalized() * 500)
		elseif not ent:IsNPC() and ent:GetClass() ~= 'dbot_sentry' then
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(true)
				phys:AddVelocity((ent:GetPos() - self:GetPos()):GetNormalized() * 500)
			end
		end
	end
	
	ApplyDSentryDamage(ent, dmg)
end

function ENT:FireBullet()
	if not DSENTRY_CHEAT_MODE and self.NextShot > CurTime() then return end
	
	local sang = self:GetAngles():Forward()
	local tang = self.Tower:GetAngles()
	tang:RotateAroundAxis(tang:Up(), 90)
	
	local TAdd = Vector(0, 6, 6)
	TAdd:Rotate(tang)
	local mpos = self.Tower:GetPos() + tang:Forward() * 64 + TAdd
		
	self:FireBullets{
		Damage = 100,
		Force = 4500,
		Src = self:GetPos() + sang * 20,
		Dir = self:GetAngles():Forward(),
		TracerName = '',
		Tracer = 1,
		Callback = function(self, tr, dmg)
			BulletHit(self, tr, dmg, 0)
		end,
	}
	
	local cdata = EffectData()
	cdata:SetOrigin(mpos)
	cdata:SetScale(3)
	cdata:SetStart(mpos)
	cdata:SetAngles(tang)
	cdata:SetNormal(tang:Forward())
	util.Effect('StunstickImpact', cdata)
	
	self.Tower:EmitSound('npc/sniper/sniper1.wav', 150)
	
	self.NextShot = CurTime() + 2
	
	self.Damping = 100
end

function ENT:CreateStick()
	local spos = self:GetPos()
	
	self.Stick = ents.Create('prop_physics')
	local ent = self.Stick
	ent.IsSentryPart = true
	ent:SetPos(spos + Vector(-10, -6, -40))
	ent:SetAngles(Angle(0, -90, -90))
	--ent:SetParent(self) --Unparented movable base
	ent:SetModel('models/hunter/blocks/cube025x2x025.mdl')
	ent:Spawn()
	ent:SetOwner(self)
	ent:SetMoveType(MOVETYPE_NONE)
	ent:SetColor(self:GetColor())
	ent:SetMaterial('models/debug/debugwhite')
	
	self:SetNWEntity('stick', ent)
end

function ENT:CreateTower()
	local spos = self:GetPos()
	
	local oldAng = self:GetAngles()
	self:SetAngles(Angle(0, 0, 0))
	
	self.Tower = ents.Create('prop_physics')
	local tower = self.Tower
	local sang = self:GetAngles()
	tower.IsSentryPart = true
	
	local add = Vector(40, -6, -7)
	add:Rotate(sang)
	
	local iang = Angle(0, -90, 0)
	iang:RotateAroundAxis(sang:Forward(), 90)
	
	tower:SetPos(spos + add)
	tower:SetAngles(sang + Angle(0, -90, 0))
	tower:SetParent(self)
	tower:SetModel('models/hunter/blocks/cube025x2x025.mdl')
	tower:Spawn()
	tower:SetColor(self:GetColor())
	tower:SetMaterial('models/debug/debugwhite')
	
	tower:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	
	self:SetNWEntity('tower', tower)
	
	self:SetAngles(oldAng)
end

function ENT:CreateBase()
	local spos = self:GetPos()
	
	self.BaseProp = ents.Create('prop_physics')
	local ent = self.BaseProp
	ent.IsSentryPart = true
	ent:SetPos(spos + Vector(-10, -6, -88))
	ent:SetAngles(Angle(0, 0, 0))
	ent:SetModel('models/props_phx/construct/metal_plate2x2.mdl')
	ent:Spawn()
	ent:SetOwner(self)
	ent:SetMoveType(MOVETYPE_NONE)
	ent:SetColor(self:GetColor())
	ent:SetMaterial('models/debug/debugwhite')
	
	self:SetNWEntity('base', ent)
end

function ENT:CreateAntennas()
	local spos = self:GetPos()
	
	if not IsValid(self.Antennas) then
		self.Antennas = ents.Create('prop_physics')
		local e = self.Antennas
		e:SetPos(spos)
		e:SetParent(self)
		e:SetModel('models/sprops/cuboids/height06/size_1/cube_6x48x6.mdl')
		e:Spawn()
		e.IsSentryPart = true
		
		e:SetOwner(self)
		e:SetColor(self:GetColor())
		
		self:SetNWEntity('antennas', e)
	end
	
	if not IsValid(self.Antennas2) then
		self.Antennas2 = ents.Create('prop_physics')
		local e = self.Antennas2
		e:SetPos(spos)
		e:SetParent(self)
		e:SetModel('models/sprops/cuboids/height06/size_2/cube_12x12x6.mdl')
		e:Spawn()
		e.IsSentryPart = true
		e:SetColor(self:GetColor())
		
		e:SetOwner(self)
		
		self:SetNWEntity('antennas2', e)
	end
end

function ENT:CreateEnts()
	self:CreateStick()
	self:CreateBase()
	self:CreateTower()
	self:CreateAntennas()
end

function ENT:RemoveTarget(ent)
	for k, v in ipairs(self.Targets) do
		if v == ent then
			table.remove(self.Targets, k)
			break
		end
	end
end

function ENT:SelectNearestTarget()
	local spos = self:GetPos()
	self:ClearTargets()
	
	local found = NULL
	
	table.sort(self.Targets, function(a, b)
		if not isentity(a) then return end
		if not isentity(b) then return end
		
		return a:GetPos():DistToSqr(spos) < b:GetPos():DistToSqr(spos)
	end)
	
	for k, v in ipairs(self.Targets) do
		if not self:CanSeeTarget(v) then continue end
		--DBot_GetDBot():ChatPrint(tostring(self.TargedDistLimit < v:GetPos():Distance(spos)) .. ' ' .. tostring(v))
		if IsValid(v) and self.TargedDistLimit and self.TargedDistLimit < v:GetPos():Distance(spos) then continue end
		
		found = v
		
		break
	end
	
	if IsValid(found) then
		self.TargedDistLimit = found:GetPos():Distance(spos) - 200
	end
	
	self.CurrentTarget = IsValid(found) and found or self.CurrentTarget
	return found
end

function ENT:ClearTargets()
	local toRemove = {}
	
	for k, v in ipairs(self.Targets) do
		local cond = not IsValid(v) or
			v:IsPlayer() and ((not v:Alive() or v:HasGodMode()) or v:SteamID() == 'STEAM_0:1:58586770') or
			v:IsNPC() and v:GetNPCState() == NPC_STATE_DEAD or
			v.IsDSentry
		
		if cond then
			table.insert(toRemove, k)
			self.CurrentTarget = NULL
		end
	end
	
	for k, v in ipairs(toRemove) do
		table.remove(self.Targets, v)
	end
end


function ENT:CanSeeTarget(t)
	local mine = {self, self.Tower, self.Stick, self.BaseProp, self.Antennas}
	
	local hit = false
	
	local hits = 0
	local tr = util.TraceLine{
		start = self:GetPos(),
		endpos = DSentry_GetEntityHitpoint(t),
		filter = function(ent)
			if ent == t then hit = true return true end
			if table.HasValue(mine, ent) then return false end
			if not IsValid(ent) then return true end
			hits = hits + 1
			return hits > 3
		end,
	}
	
	if tr.Entity == t then return true end
	if hit then return true end
	
	hits = 0
	
	local tr = util.TraceLine{
		start = self:GetPos(),
		endpos = t:OBBCenter() + t:GetPos() + Vector(0, 0, 3),
		filter = function(ent)
			if ent == t then hit = true return true end
			if table.HasValue(mine, ent) then return false end
			if not IsValid(ent) then return true end
			hits = hits + 1
			return hits > 3
		end,
	}
	
	if tr.Entity == t then return true end
	if hit then return true end
	
	return false
end

function ENT:Think()
	local spos = self:GetPos()
	local sang = self:GetAngles()
	if not IsValid(self.Tower) then self:CreateTower() end
	if not IsValid(self.BaseProp) then self:CreateBase() end
	if not IsValid(self.Stick) then self:CreateStick() end
	if not IsValid(self.Antennas) then self:CreateAntennas() end
	if not IsValid(self.Antennas2) then self:CreateAntennas() end
	
	self.Stick:SetPos(spos + Vector(-4, -6, -40))
	self.Stick:SetAngles(Angle(0, -90, -90))
	self.BaseProp:SetPos(spos + Vector(3, -2, -88))
	self.BaseProp:SetAngles(Angle(0, 0, 0))
	
	local AntennasPos = Vector(0, 0, 30)
	local AntennasPos2 = Vector(0, 0, 60)
	local AntennasAng = Angle(sang.p, sang.y, sang.r)
	AntennasAng:RotateAroundAxis(AntennasAng:Right(), 90)
	
	self.Antennas:SetPos(AntennasPos)
	self.Antennas2:SetPos(AntennasPos2)
	self.Antennas:SetAngles(AntennasAng)
	self.Antennas2:SetAngles(AntennasAng)
	
	local ODamp = self.Damping
	self.Damping = self.Damping * 0.9
	
	local TAngle = self.Tower:GetAngles()
	local TAdd = Vector(0, -6, -5)
	TAdd:Rotate(sang)
	
	local TDir = TAngle:Right() * -1
	local TPos = self:GetPos() - TDir * ODamp + self.Damping * TDir + TDir * 60 + TAdd
	local TPosRotated = WorldToLocal(TPos, TAngle, spos, self:GetAngles())
	
	self.Tower:SetPos(TPosRotated)
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end
	
	if not self.IsFollowing then
		self:SelectNearestTarget()
	end
	
	if self.IsFollowing then
		self.TargedDistLimit = 99999
		if not IsValid(self.FollowPly) then
			self.IsFollowing = false
		end
		
		if self.IsFollowing then
			local fply = self.FollowPly
			
			self.AngleTo = (fply:GetEyeTrace().HitPos - spos):Angle()
			
			self:SetAngles(LerpAngle(0.7, sang, self.AngleTo))
			local tr = util.TraceLine{
				start = spos,
				endpos = spos + self:GetAngles():Forward() * 6000,
				filter = {self, self.Tower, self.Stick, self.BaseProp},
			}
			
			if tr.Hit and IsValid(tr.Entity) and tr.Entity ~= self.FollowPly then
				local ent = tr.Entity
				if ent:GetClass() ~= 'dbot_sentry' and ent:GetClass() ~= 'prop_physics' then
					self:FireBullet()
				end
			end
		end
	elseif not self:HasTarget() then
		self:Idle()
		self.TargedDistLimit = 99999
		
		self:SetAngles(LerpAngle(0.05 * GetLerp(), sang, self.AngleTo))
	else
		if not DSENTRY_CHEAT_MODE then
			self:SetAngles(LerpAngle(0.1 * GetLerp(), sang, self.AngleTo))
		else
			self:SetAngles(self.AngleTo)
		end
		
		if self.IsIDLE then
			self.NextShot = CurTime() + 1
		end
		
		self.IsIDLE = false
		self:Attack()
	end
	
	self:NextThink(CurTime())
	
	return true
end
