
-- Copyright (C) 2016-2018 DBot

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

	self:PhysicsInitBox(Mins, Maxs)
	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
		self.Phys = phys
	end

	table.insert(DBOT_ACTIVE_DUCKS, self)
end

function ENT:Push()
	if not self.Phys then return end
	local Ang = Angle(math.random(45, 90), math.random(-180, 180), math.random(45, 90))

	if not CRAZY_PHYS:GetBool() then
		self.Phys:SetVelocity(Ang:Forward() * math.random(50, 200) + Vector(0, 0, 300))
	else
		local vel = Ang:Forward() * math.random(3000, 10000)
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
	if self.SLEEPING then return end
	if not self.Phys then return end
	local ent = data.HitEntity

	if IsValid(ent) then return end

	self.Phys:EnableMotion(false)
	self.Phys:Sleep()
	self.SLEEPING = true
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
