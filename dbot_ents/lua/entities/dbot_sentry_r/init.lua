
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

AddCSLuaFile('cl_init.lua')

ENT.PrintName = 'DBot Rocket Sentry'
ENT.Author = 'DBot'
ENT.Category = 'DBot'
ENT.Type = 'anim'
ENT.Base = 'dbot_sentry'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
	self:NetworkVar('Bool', 0, 'IsLocking')
	self:NetworkVar('Entity', 0, 'LockTarget')
	self:NetworkVar('Float', 0, 'LockTime')

	self:NetworkVar('Int', 0, 'Frags')
	self:NetworkVar('Int', 1, 'PFrags')
end

local function EntityTakeDamage(ent, dmg)
	local a = dmg:GetAttacker()
	if not IsValid(a) then return end
	if a:GetClass() ~= 'dbot_sentry_r' then return end
	ApplyDSentryDamage(ent, dmg)
end

function ENT:FireBullet()
	if not DSENTRY_CHEAT_MODE and self.NextShot > CurTimeL() then return end

	local sang = self:GetAngles():Forward()
	local tang = self.Tower:GetAngles()
	tang:RotateAroundAxis(tang:Up(), 90)

	local TAdd = Vector(0, 6, 6)
	TAdd:Rotate(tang)
	local mpos = self.Tower:GetPos() + tang:Forward() * 70 + TAdd

	self.NextShot = CurTimeL() + 3

	local ent = ents.Create('dbot_srocket')
	ent:SetAngles(self:GetAngles())
	ent:SetPos(mpos)
	ent:Spawn()
	ent.dir = sang
	ent.ent = self:GetTarget()
	ent.SOwner = self
	ent.Ignore = self.Tower
	ent:SetCurTarget(self:GetTarget())

	self.Damping = 200
end

function ENT:Attack()
	if not self:HasTarget() then return end

	local t = self:GetTarget()
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

	self.TLock = self.TLock or 0

	if t:IsPlayer() and t:InVehicle() or DSENTRY_CHEAT_MODE then
		self:FireBullet()
	else
		local tr = util.TraceLine{
			start = spos,
			endpos = spos + self:GetAngles():Forward() * (hitpos:Distance(spos) + 40),
			filter = {self, self.Tower, self.Antennas, self.Stick}
		}

		self:SetLockTarget(t)

		if self.NextShot < CurTimeL() and tr.Entity == t then
			self.TLock = self.TLock + FrameTime()
			self:SetIsLocking(true)

			if self.TLock > 1 then
				self:FireBullet()
				self.TLock = 0
			end
		else
			self:SetIsLocking(true)
			self.TLock = 0
		end

		if self.NextShot > CurTimeL() then
			self:SetIsLocking(false)
		end

		self:SetLockTime(self.TLock)
	end
end

hook.Add('EntityTakeDamage', 'DBot.RocketSentry', EntityTakeDamage)
