
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

local BEER_DISSAPEAR = CreateConVar('sv_beer_time', '60', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'How long beer exists')
DBOT_ACTIVE_BEER = DBOT_ACTIVE_BEER or {}

ENT.Type = 'anim'
ENT.Author = 'DBotThePony'
ENT.Base = 'dbot_duck'
ENT.Spawnable = false
ENT.PrintName = 'Mann Bear'

local Mins, Maxs = Vector(-5, -5, 0), Vector(5, 5, 5)

function ENT:Initialize()
	self:SetModel('models/props_watergate/bottle_pickup.mdl')

	self.CreatedAt = CurTimeL()
	self.Expires = CurTimeL() + BEER_DISSAPEAR:GetInt()
	self.Fade = CurTimeL() + BEER_DISSAPEAR:GetInt() - 4

	if CLIENT then
		self:SetSolid(SOLID_NONE)
		self.ClientsideModel = ClientsideModel('models/props_watergate/bottle_pickup.mdl')
		self.ClientsideModel:SetNoDraw(true)

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

	table.insert(DBOT_ACTIVE_BEER, self)
end

function ENT:Collect(ply)
	hook.Run('PreCollectBeer', self, ply)

	self:EmitSound('vo/watergate/pickup_beer.mp3', 75)
	self:Remove()

	hook.Run('PostCollectBeer', self, ply)
end
