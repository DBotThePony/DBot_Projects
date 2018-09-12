
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

ENT.PrintName = 'DBot Artilery Sentry'
ENT.Author = 'DBot'
ENT.Type = 'anim'
ENT.Base = 'dbot_sentry'

function ENT:SetupDataTables()
	self:NetworkVar('Bool', 0, 'IsLocking')
	self:NetworkVar('Entity', 0, 'LockTarget')
	self:NetworkVar('Float', 0, 'LockTime')
end

hook.Add('EntityTakeDamage', 'dbot_sentry_r', function(ent, dmg)
	local a = dmg:GetAttacker()
	if not IsValid(a) then return end
	if a:GetClass() ~= 'dbot_sentry_r' then return end
	ApplyDSentryDamage(ent, dmg)
end)

function ENT:FireBullet()
	if not DSENTRY_CHEAT_MODE and self.NextShot > CurTimeL() then return end

	local sang = self:GetAngles():Forward()
	local tang = self.Tower:GetAngles()
	tang:RotateAroundAxis(tang:Up(), 90)

	local TAdd = Vector(0, 6, 6)
	TAdd:Rotate(tang)
	local mpos = self.Tower:GetPos() + tang:Forward() * 70 + TAdd

	self.NextShot = CurTimeL() + 3

	local ent = ents.Create('dbot_srocket_a')
	ent:SetAngles(self:GetAngles())
	ent:SetPos(mpos)
	ent:Spawn()
	ent.dir = sang
	ent.ent = self:GetTarget()
	ent.SOwner = self
	ent.Ignore = self.Tower
	ent:SetCurTarget(self:GetTarget())
	local newdir = Vector(sang) * 1500
	newdir.z = self.CurrZ
	ent.phys:SetVelocity(newdir)

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

	--[[if not DSENTRY_CHEAT_MODE then
		self.AngleTo = (-spos + hitpos + Change):Angle()
	else
		self.AngleTo = (-spos + hitpos):Angle()
	end]]

	self.TLock = self.TLock or 0

	local dist = spos:Distance(hitpos)
	self.CurrZ = dist / 20

	self.AngleTo = (-spos + hitpos + Change):Angle()
	---self.AngleTo.p = math.abs(self.CurrZ) ^ (1 / 2)
	--self.AngleTo.r = 0

	self:FireBullet()
end