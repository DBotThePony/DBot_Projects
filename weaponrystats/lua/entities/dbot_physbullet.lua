
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

function ENT:Initialize()
	self:SetModel('models/ryu-gi/effect_props/incendiary/bullet_tracer.mdl')

	if CLIENT then
		self:SetOwner(LocalPlayer())
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:PhysicsInitSphere(0)
		self:SetSolid(SOLID_NONE)
		return
	end

	self:PhysicsInitSphere(1)
	self.phys = self:GetPhysicsObject()
	self.ricochets = 0
	self.phys:EnableDrag(false)
	self.phys:EnableMotion(true)
	self.phys:EnableGravity(true)
	self.setup = false
	self.dissapearTime = CurTime() + 10
	self:SetCustomCollisionCheck(true)
end

hook.Add('PhysgunPickup', 'WeaponryStats.Bullets', function(ply, ent)
	if ent.IS_BULLET then return false end
end)

if CLIENT then return end

AccessorFunc(ENT, 'm_tr', 'InitialTrace')
AccessorFunc(ENT, 'm_distance', 'Distance')
AccessorFunc(ENT, 'm_callback', 'BulletCallback')
AccessorFunc(ENT, 'm_force', 'Force')
AccessorFunc(ENT, 'm_dir', 'Direction')
AccessorFunc(ENT, 'm_attacker', 'Attacker')
AccessorFunc(ENT, 'm_inflictor', 'Inflictor')
AccessorFunc(ENT, 'm_damage', 'Damage')
AccessorFunc(ENT, 'm_maxDamage', 'MaxDamage')
AccessorFunc(ENT, 'm_reportedPosiotion', 'ReportedPosition')
AccessorFunc(ENT, 'm_damagePosition', 'DamagePosition')
AccessorFunc(ENT, 'm_damageType', 'DamageType')

function ENT:GetFinalDamage()
	return self:GetDamage() - self:GetDamage() * math.min(4, self.ricochets) / 6
end

function ENT:GetRicochetDamage()
	return self:GetFinalDamage() * 0.2
end

function ENT:GetPenetrationStrength()
	return self:GetForce() * 100 * self:GetFinalDamage()
end

function ENT:CalculateForce()
	return math.max((math.max(self:GetForce(), 5) + 10) * 80 - math.min(4, self.ricochets) * 60, 200)
end

function ENT:DoSetup()
	if self.invalidBullet then return end
	self.setup = true
	local ang = self:GetDirection():Angle()
	ang:RotateAroundAxis(ang:Right(), 90)
	self:SetAngles(ang)
	self.phys:ApplyForceCenter(self:GetDirection() * self:CalculateForce() * self:GetDistance() / 10000)
end

function ENT:Think()
	if self.invalidBullet then return end
	if self.dissapearTime < CurTime() then
		return self:Remove()
	end

	if not self.setup then
		self:DoSetup()
	end
end

function ENT:UpdateRules(damagePos)
	self:SetMaxDamage(self:GetMaxDamage() or self:GetDamage())
	self:SetAttacker(self:GetAttacker():IsValid() and self:GetAttacker() or self)
	self:SetInflictor(self:GetInflictor():IsValid() and self:GetInflictor() or self)
	self:SetReportedPosition(self:GetPos())
	self:SetDamagePosition(damagePos or self:GetPos())
end

local ricochetSurfaces = {
	[MAT_COMPUTER] = 1.5,
	[MAT_CONCRETE] = 0.85,
	[MAT_GRATE] = 1,
	[MAT_METAL] = 0.5,
	[MAT_SAND] = 2.25,
	[MAT_TILE] = 1,
}

function ENT:PhysicsCollide(info, collider)
	if self.invalidBullet then return end
	local normal = info.HitNormal
	local normalAngle = normal:Angle()

	local trData = {
		filter = self,
		start = info.HitPos - normal,
		endpos = info.HitPos + normal,
	}

	if false then
		local tr = util.TraceLine(trData)
		tr.MatType = tr.MatType or MAT_TILE
		local mForce = self:CalculateForce()
		local surfaceType = tr.MatType
		local canRicochet = ricochetSurfaces[surfaceType] and ricochetSurfaces[surfaceType] * mForce <= 500
	else
		self:UpdateRules()
		local dmginfo = DamageInfo():Receive(self)

		if self.m_callback and self:GetAttacker() ~= self then
			local tr = util.TraceLine(trData)
			self.m_callback(self:GetAttacker(), tr, dmginfo)
		end

		if IsValid(info.HitEntity) then
			info.HitEntity:TakeDamageInfo(dmginfo)
		end

		self.invalidBullet = true

		timer.Simple(0, function() self:Remove() end)
	end
end

hook.Add('ShouldCollide', 'WeaponryStats.Bullets', function(ent1, ent2)
	if ent1.IS_BULLET and ent2.IS_BULLET then return false end
end)

