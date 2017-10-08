
-- Copyright (C) 2017 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

AddCSLuaFile()

ENT.PrintName = 'Physical Bullet'
ENT.Author = 'DBot'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Type = 'anim'
ENT.IS_BULLET = true
ENT.RenderGroup = RENDERGROUP_BOTH

local VALID_BULLETS = {}
local IsValidEntity = FindMetaTable('Entity').IsValid

local function cleanup()
	local old = VALID_BULLETS
	VALID_BULLETS = {}

	for i, ent in ipairs(old) do
		if IsValidEntity(ent) then
			VALID_BULLETS[#VALID_BULLETS + 1] = ent
		end
	end
end

function ENT:Initialize()
	table.insert(VALID_BULLETS, self)

	if SERVER and #VALID_BULLETS >= 800 then
		cleanup()

		if #VALID_BULLETS >= 800 then

			for i, ent in ipairs(VALID_BULLETS) do
				if IsValidEntity(ent) then
					ent:Remove()
				end
			end

			VALID_BULLETS = {}

			error('WARNING - >800 bullets were created; Possibly infinite recursion. Tell SWEP(s) author(s) to fix this issue')
			return
		end
	end

	self:SetModel('models/ryu-gi/effect_props/incendiary/bullet_tracer.mdl')
	self:SetSkin(7)

	if CLIENT then
		self:SetOwner(LocalPlayer())
		--self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		--self:PhysicsInitSphere(0)
		--self:SetSolid(SOLID_NONE)
		return
	end

	self:PhysicsInitSphere(4)
	self.phys = self:GetPhysicsObject()
	self.ricochets = 0
	self.penetrations = 0
	self.phys:EnableDrag(false)
	self.phys:EnableMotion(true)
	self.phys:EnableGravity(false)
	self.phys:SetMass(1)
	self.setup = false
	self.dissapearTime = CurTime() + 10
	self:SetCustomCollisionCheck(true)
	self.m_modifSpeed = self.m_modifSpeed or 1
	self.m_modifPenet = self.m_modifPenet or 1
	self.m_modifRicoc = self.m_modifRicoc or 1
	self.m_modifVelocity = self.m_modifVelocity or Vector(0, 0, 0)
end

hook.Add('PhysgunPickup', 'WeaponryStats.Bullets', function(ply, ent)
	if ent.IS_BULLET then return false end
end)

hook.Add('GravGunPickupAllowed', 'WeaponryStats.Bullets', function(ply, ent)
	if ent.IS_BULLET then return false end
end)

hook.Add('GravGunPunt', 'WeaponryStats.Bullets', function(ply, ent)
	if ent.IS_BULLET then return false end
end)

if CLIENT then return end

function ENT:SetupBulletData(bulletData, firer)
	self:SetPos(bulletData.Src)
	self:SetAngles(bulletData.Dir:Angle())
	self:SetDistance(bulletData.Distance)
	self:SetForce(bulletData.Force or 1)
	self:SetAttacker(bulletData.Attacker or firer)
	self:SetDamage(bulletData.Damage)
	self:SetMaxDamage(bulletData.Damage)
	self:SetReportedPosition(bulletData.Src)
end

AccessorFunc(ENT, 'm_tr', 'InitialTrace')
AccessorFunc(ENT, 'm_distance', 'Distance')
AccessorFunc(ENT, 'm_initialEntity', 'InitialEntity')
AccessorFunc(ENT, 'm_callback', 'BulletCallback')
AccessorFunc(ENT, 'm_bulletData', 'BulletData')
AccessorFunc(ENT, 'm_force', 'Force')
AccessorFunc(ENT, 'm_dir', 'Direction')
AccessorFunc(ENT, 'm_attacker', 'Attacker')
AccessorFunc(ENT, 'm_inflictor', 'Inflictor')
AccessorFunc(ENT, 'm_damage', 'Damage')
AccessorFunc(ENT, 'm_maxDamage', 'MaxDamage')
AccessorFunc(ENT, 'm_reportedPosiotion', 'ReportedPosition')
AccessorFunc(ENT, 'm_damagePosition', 'DamagePosition')
AccessorFunc(ENT, 'm_damageType', 'DamageType')

AccessorFunc(ENT, 'm_modifSpeed', 'SpeedModifier')
AccessorFunc(ENT, 'm_modifPenet', 'PenetrationModifier')
AccessorFunc(ENT, 'm_modifRicoc', 'RicochetModifier')
AccessorFunc(ENT, 'm_modifVelocity', 'InitialVelocity')

function ENT:CanRicochet()
	return true
end

function ENT:CanPenetrate()
	return true
end

function ENT:GetFinalDamage()
	return math.max(self:GetDamage() - self:GetDamage() * math.min(4, self.ricochets) / 20 - self:GetDamage() * math.min(4, self.penetrations) / 10, self:GetDamage() / 8)
end

function ENT:GetRicochetDamage()
	return self:GetFinalDamage() * 0.2
end

function ENT:GetPenetrationStrength()
	return self:GetPenetrationModifier() * self:CalculateForce() / 32
end

function ENT:CalculateBulletForce()
	return self:CalculateForce()
end

function ENT:CalculateRicochetForce()
	return self:CalculateForce() * self:GetRicochetModifier()
end

function ENT:CalculateGravity()
	return Vector(0, 0, -self:CalculateBulletForce() * 0.02)
end

function ENT:CalculateForce()
	return math.max((math.max(self:GetForce(), 3) + 5) * 15 * self:GetSpeedModifier() + math.max(5, self:GetDamage()) * 10 * self:GetSpeedModifier() - math.min(4, self.ricochets) * 40 - math.min(8, self.penetrations) * 80, 400)
end

function ENT:UpdatePhys()
	if not self.phys:IsValid() then return end

	if not self.wakeOnNext then
		self.phys:AddAngleVelocity(-self.phys:GetAngleVelocity())
		if self.phys:GetAngleVelocity():Length() > 1 then
			self.phys:Sleep()
			self.phys:EnableMotion(false)
			self.wakeOnNext = true
		end
	else
		self.phys:EnableMotion(true)
		self.phys:Wake()
		self.wakeOnNext = false
		self.phys:AddAngleVelocity(-self.phys:GetAngleVelocity())
	end

	if not self.nPenetrationOfNPC then
		self.phys:ApplyForceCenter(self:GetDirection() * self:CalculateBulletForce() * self:GetDistance() / 10000 + self:GetInitialVelocity())
	else
		self.phys:SetVelocity(self:GetDirection() * 10)
		self.nGravityIgnore = true
	end

	self.nPenetrationOfNPC = false
	self.phys:SetAngleDragCoefficient(0)
end

function ENT:TraceForward()
	cleanup()

	local pos = self:GetPos()
	local dir = self:GetDirection()

	local trData = {
		start = pos,
		endpos = pos + dir * 16,
		filter = VALID_BULLETS
	}

	return util.TraceLine(trData)
end

function ENT:DoSetup()
	if self.invalidBullet then return end
	self.setup = true
	if self.nextpos then self:SetPos(self.nextpos) end
	self.nextpos = nil
	local ang = self:GetDirection():Angle()
	ang:RotateAroundAxis(ang:Right(), 90)
	self:SetAngles(ang)
	self:UpdatePhys()
end

local function isValid(ent)
	return IsValidEntity(ent) and ent or nil
end

function ENT:GetFirer()
	return isValid(self:GetInitialEntity()) or isValid(self:GetInflictor()) or isValid(self:GetAttacker()) or self
end

function ENT:GetRealAttacker()
	return isValid(self:GetAttacker()) or isValid(self:GetInflictor()) or isValid(self:GetFirer()) or self
end

function ENT:DamageInfo()
	self:UpdateRules()
	local dmginfo = DamageInfo():Receive(self)
	dmginfo:SetDamage(self:GetFinalDamage())
	dmginfo:SetDamageType(DMG_BULLET)
	return dmginfo
end

local ricochetSurfaces = {
	[MAT_COMPUTER] = 1.5,
	[MAT_CONCRETE] = 0.85,
	[MAT_GRATE] = 2,
	[MAT_EGGSHELL] = 1.5,
	[MAT_METAL] = 0.5,
	[MAT_CLIP] = 0.5,
	[MAT_VENT] = 0.75,
	[MAT_DIRT] = 2,
	[MAT_SAND] = 1.75,
	[MAT_TILE] = 1,
	[MAT_DEFAULT] = 3,
	[MAT_FLESH] = 3.5,
	[MAT_BLOODYFLESH] = 3,
	[MAT_ANTLION] = 4,
	[MAT_ALIENFLESH] = 3.5,
	[MAT_PLASTIC] = 3.5,
	[MAT_SNOW] = 3.5,
	[MAT_WOOD] = 3,
	[MAT_FOLIAGE] = 5,
	[MAT_WARPSHIELD] = 0.25,
}

function ENT:OnSurfaceHit(tr, guessPos)

end

function ENT:OnHitObject(hitpos, normal, tr, hitent)
	if self.invalidBullet then return end
	local normalAngle = normal:Angle()

	local spos = self:GetPos()
	local delta = spos - tr.HitPos
	delta:Normalize()
	local dot = delta:Dot(tr.HitNormal)
	local ang = math.deg(math.acos(dot))
	local angDiff = math.AngleDifference(0, ang)
	tr.MatType = tr.MatType or MAT_FLESH
	local surfaceType = tr.MatType
	local mult = (ricochetSurfaces[surfaceType] or 1) / 0.65
	local mult2 = (ricochetSurfaces[surfaceType] or 1) ^ 3
	local ricochetCond = self:CanRicochet() and
		type(hitent) ~= 'NPC' and
		type(hitent) ~= 'NextBot' and
		type(hitent) ~= 'Player' and
		(angDiff < -40 * mult or angDiff > 40 * mult) and
		self.ricochets < 4

	if ricochetCond then
		local mForce = self:CalculateRicochetForce()
		local canRicochet = ricochetSurfaces[surfaceType] and mForce / ricochetSurfaces[surfaceType] >= 350

		if canRicochet then
			local ang2 = delta:Angle()
			ang2:RotateAroundAxis(tr.HitNormal, 180)
			local ricochetDir = ang2:Forward()

			local cp = table.Copy(self:GetBulletData())
			cp.Src = spos
			cp.Dir = self:GetDirection()
			cp.Damage = self:GetRicochetDamage()
			local inflictor = self:GetInflictor()
			cp.Callback = function(attacker, tr, dmginfo)
				if IsValid(inf) then dmginfo:SetInflictor(inflictor) end

				if cp.PhysDamageType then
					dmginfo:SetDamageType(cp.PhysDamageType)
				end
			end

			weaponrystats.SKIP_NEXT = true
			self:GetFirer():weaponrystats_FireBullets(cp)
			self:OnSurfaceHit(tr, tr.HitPos + ricochetDir * 12)

			self.ricochets = self.ricochets + 1
			self.setup = false
			self:SetDirection(ricochetDir)
			self.nextpos = tr.HitPos + ricochetDir * 12
			(IsValidEntity(hitent) and hitent or self):EmitSound('weapons/fx/rics/ric' .. math.random(1, 5) .. '.wav')

			return
		end
	end

	local penetratePower = math.min(self:GetPenetrationStrength() * mult2 * 3, 125)

	if self:CanPenetrate() and penetratePower >= 40 then
		local trPen
		local penCondition2 = IsValidEntity(hitent) and (type(hitent) == 'Player' or type(hitent) == 'NPC' or type(hitent) == 'NextBot')

		if penCondition2 then
			local filter = table.qcopy(VALID_BULLETS)
			table.insert(filter, hitent)

			trPen = {
				start = hitpos - self:GetDirection() * 5,
				endpos = hitpos + self:GetDirection() * penetratePower / 4,
				filter = filter
			}
		elseif IsValidEntity(hitent) then
			trPen = {
				start = hitpos + self:GetDirection() * penetratePower / 2,
				endpos = hitpos - self:GetDirection() * 5,
				filter = VALID_BULLETS
			}
		else
			trPen = {
				start = hitpos + self:GetDirection() * penetratePower / 3,
				endpos = hitpos - self:GetDirection() * 5,
				filter = VALID_BULLETS
			}
		end

		local newTr = util.TraceLine(trPen)
		local npcfix = false

		-- nobody behind us
		if penCondition2 and newTr.Fraction == 1 then
			trPen = {
				start = hitpos + self:GetDirection() * penetratePower / 2,
				endpos = hitpos - self:GetDirection() * 5,
				filter = VALID_BULLETS
			}

			newTr = util.TraceLine(trPen)
			npcfix = true
		end

		if newTr.Fraction >= 0.05 and newTr.Fraction ~= 1 then
			local cp = table.Copy(self:GetBulletData())
			cp.Src = spos
			cp.Dir = self:GetDirection()
			cp.Damage = self:GetFinalDamage()
			local inflictor = self:GetInflictor()

			cp.Callback = function(attacker, tr, dmginfo)
				if IsValid(inf) then dmginfo:SetInflictor(inflictor) end

				if cp.PhysDamageType then
					dmginfo:SetDamageType(cp.PhysDamageType)
				end
			end

			local incomingPos = newTr.HitPos + self:GetDirection() * 10

			if penCondition2 and not npcfix then
				incomingPos = spos + self:GetDirection() * 3
			end

			if not IsValidEntity(newTr.Entity) then
				local cp = table.Copy(self:GetBulletData())
				cp.Src = incomingPos
				cp.Dir = -self:GetDirection()
				cp.Damage = 0
				cp.Callback = function() end
				self:weaponrystats_FireBullets(cp)
			end

			self:OnSurfaceHit(newTr, incomingPos)

			weaponrystats.SKIP_NEXT = true
			self:GetFirer():weaponrystats_FireBullets(cp)

			self.penetrations = self.penetrations + 1
			self.setup = false

			self.nextpos = incomingPos

			self.nPenetrationOfNPC = penCondition2

			return
		end
	end

	self:UpdateRules()

	local cp = table.Copy(self:GetBulletData())
	cp.Src = spos
	cp.Dir = self:GetDirection()
	cp.Damage = self:GetFinalDamage()
	weaponrystats.SKIP_NEXT = true
	self:GetFirer():weaponrystats_FireBullets(cp)

	self:OnSurfaceHit(tr, tr.HitPos + tr.HitNormal * 3)

	self.invalidBullet = true

	timer.Simple(0, function() self:Remove() end)
end

function ENT:Think()
	if self.invalidBullet then return end

	if self.dissapearTime < CurTime() then
		return self:Remove()
	end

	if not self.setup then
		self:DoSetup()
	end

	self:UpdatePhys()

	if not self.nGravityIgnore and self.phys:IsValid() then
		self.phys:ApplyForceCenter(self:CalculateGravity())
	end

	self.nGravityIgnore = false
end

function ENT:UpdateRules(damagePos)
	self:SetMaxDamage(self:GetMaxDamage() or self:GetDamage())
	self:SetAttacker(self:GetAttacker():IsValid() and self:GetAttacker() or self)
	self:SetInflictor(self:GetInflictor():IsValid() and self:GetInflictor() or self)
	self:SetReportedPosition(self:GetPos())
	self:SetDamagePosition(damagePos or self:GetPos())
end

function ENT:PhysicsCollide(info, collider)
	local normal = info.HitNormal
	local hitpos = info.HitPos
	local hitent = info.HitEntity
	local tr = self:TraceForward()

	if IsValidEntity(hitent) then
		hitent:SetVelocity(info.TheirOldVelocity)
	end

	self:OnHitObject(hitpos, normal, tr, hitent)
end

hook.Add('ShouldCollide', 'WeaponryStats.Bullets', function(ent1, ent2)
	if ent1.IS_BULLET and ent2.IS_BULLET then return false end
end)

