
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

hook.Add('EntityTakeDamage', 'dbot_sentry_r', function(ent, dmg)
	local a = dmg:GetAttacker()
	if not IsValid(a) then return end
	if a:GetClass() ~= 'dbot_sentry_r' then return end
	ApplyDSentryDamage(ent, dmg)
end)

function ENT:FireBullet()
	if not DSENTRY_CHEAT_MODE and self.NextShot > CurTime() then return end
	
	local sang = self:GetAngles():Forward()
	local tang = self.Tower:GetAngles()
	tang:RotateAroundAxis(tang:Up(), 90)
	
	local TAdd = Vector(0, 6, 6)
	TAdd:Rotate(tang)
	local mpos = self.Tower:GetPos() + tang:Forward() * 70 + TAdd
	
	self.NextShot = CurTime() + 3
	
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