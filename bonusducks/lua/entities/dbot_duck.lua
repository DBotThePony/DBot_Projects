
-- Copyright (C) 2016-2019 DBotThePony

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


AddCSLuaFile()

local DUCK_TOUCH_SOUND = {
	'ambient_mp3/bumper_car_quack1.mp3',
	'ambient_mp3/bumper_car_quack2.mp3',
	'ambient_mp3/bumper_car_quack3.mp3',
	'ambient_mp3/bumper_car_quack4.mp3',
	'ambient_mp3/bumper_car_quack5.mp3',
	'ambient_mp3/bumper_car_quack9.mp3',
	'ambient_mp3/bumper_car_quack11.mp3',
}

local DISSAPEAR = CreateConVar('sv_ducks_time', '20', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'How long duck exists')
local CRAZY_PHYS = CreateConVar('sv_ducks_duckboom', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'DUCK-BOOM! Forces ducks to have crazy velocity')
DBOT_ACTIVE_DUCKS = DBOT_ACTIVE_DUCKS or {}

ENT.Type = 'anim'
ENT.Author = 'DBotThePony'
ENT.Spawnable = false
ENT.PrintName = 'DUCK'

local Mins, Maxs = Vector(-5, -5, 0), Vector(5, 5, 5)

function ENT:Initialize()
	self:SetModel('models/workshop/player/items/pyro/eotl_ducky/eotl_bonus_duck.mdl')

	self.CreatedAt = CurTimeL()
	self.Expires = CurTimeL() + DISSAPEAR:GetInt()
	self.Fade = CurTimeL() + DISSAPEAR:GetInt() - 4
	self.SurfaceBounces = 0

	if CLIENT then
		self.NextFadeState = 0
		self:SetSolid(SOLID_NONE)
		self.ClientsideModel = ClientsideModel('models/workshop/player/items/pyro/eotl_ducky/eotl_bonus_duck.mdl')
		self.ClientsideModel:SetNoDraw(true)
		self.ClientsideModel:SetModelScale(0.6)
		self.ClientsideModel:SetSkin(math.random(0, 19))

		self.CAngle = Angle()
		return
	end

	--self:PhysicsInitBox(Mins, Maxs)
	self:PhysicsInitSphere(16)
	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
		self.Phys = phys
	end

	if self:GetClass() == 'dbot_duck' then
		table.insert(DBOT_ACTIVE_DUCKS, self)
	end
end

function ENT:Push()
	if not self.Phys then return end
	local Ang = Vector(math.random(-50, 50), math.random(-50, 50), math.random(300, 600))

	if not CRAZY_PHYS:GetBool() then
		self.Phys:SetVelocity(Ang)
	else
		local vel = Ang * math.random(3000, 10000)
		vel.z = math.max(vel.z, -2000) + 3000
		self.Phys:SetVelocity(vel)
	end
end

function ENT:Collect(ply)
	hook.Run('PreCollectDuck', self, ply)

	self:EmitSound(table.frandom(DUCK_TOUCH_SOUND), 75)
	self:Remove()

	if IsValid(ply) and ply:IsPlayer() then
		ply.CurrentDucksCollected = (ply.CurrentDucksCollected or 0) + 1

		net.Start('DBot_DuckOMeter', true)
		net.WriteUInt(ply.CurrentDucksCollected, 16)
		net.Send(ply)

		sql.Query(string.format('REPLACE INTO dbot_duckometr_sv (steamid, cval) VALUES (%q, %q)', ply:SteamID(), ply.CurrentDucksCollected))
	end

	hook.Run('PostCollectDuck', self, ply)
end

function ENT:PhysicsCollide(data)
	if self.SLEEPING then return end -- ???
	if not self.Phys then return end
	local ent = data.HitEntity

	if IsValid(ent) then return end

	--print('hit', self)
	self.SurfaceBounces = self.SurfaceBounces + 1

	if self.SurfaceBounces >= 3 then
		self.Phys:EnableMotion(false)
		self.Phys:Sleep()
		self.SLEEPING = true
		self:SetSolid(SOLID_NONE)
		return
	end

	self.Phys:AddVelocity(data.HitNormal * data.OurOldVelocity * 0.4)
end

function ENT:Think()
	-- use fast think on Think loop
end

function ENT:Draw()
	if not IsValid(self.ClientsideModel) then return end
	self.CAngle.y = self.CAngle.y + (FrameTime() * 66)

	if self.Fade < CurTimeL() then
		local ctime = CurTimeL()
		local left = self.Expires
		local percent = (left - ctime) / 4

		if self.NextFadeState < ctime then
			self.CurrentState = not self.CurrentState
			self.NextFadeState = ctime + percent * .5
		end

		render.SetBlend(self.CurrentState and 0.2 or 1)
	end

	self.ClientsideModel:SetPos(self:GetPos())
	self.ClientsideModel:SetAngles(self.CAngle)
	self.ClientsideModel:DrawModel()

	if self.Fade < CurTimeL() then
		render.SetBlend(1)
	end
end

function ENT:OnRemove()
	if CLIENT and IsValid(self.ClientsideModel) then
		self.ClientsideModel:Remove()
	end
end
