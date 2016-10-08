
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

local DockOMetrValue = 0

if SERVER then
	util.AddNetworkString('DBot_DuckOMeter')
else
	sql.Query('CREATE TABLE IF NOT EXISTS dbot_duckometr (cval integer not null)')
	local select = sql.Query('SELECT * FROM dbot_duckometr')
	DockOMetrValue = select and select[1] and select[1].cval or 0
end

local DUCK_SOUND = {
	'vo/halloween_merasmus/sf14_merasmus_minigame_duckhunt_bonusducks_01.mp3',
	'vo/halloween_merasmus/sf14_merasmus_minigame_duckhunt_bonusducks_02.mp3',
	'vo/halloween_merasmus/sf14_merasmus_minigame_duckhunt_bonusducks_03.mp3',
}

local DUCK_TOUCH_SOUND = {
	'ambient_mp3/bumper_car_quack1.mp3',
	'ambient_mp3/bumper_car_quack2.mp3',
	'ambient_mp3/bumper_car_quack3.mp3',
	'ambient_mp3/bumper_car_quack4.mp3',
	'ambient_mp3/bumper_car_quack5.mp3',
	'ambient_mp3/bumper_car_quack9.mp3',
	'ambient_mp3/bumper_car_quack11.mp3',
}

local ENABLE = CreateConVar('sv_ducks_enable', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'BONUS DUCKS!')
local ENABLE_NPC = CreateConVar('sv_ducks_npc', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'BONUS DUCKS FOR NPC!')
local ENABLE_PLAYER = CreateConVar('sv_ducks_drop', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'BONUS DUCKS for Players')
local MIN = CreateConVar('sv_ducks_min', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Minimal Ducks')
local MAX = CreateConVar('sv_ducks_max', '12', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Maximum Ducks')
local CHANCE = CreateConVar('sv_ducks_chance', '2', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Chance. 2 means 50%, 4 means 20%, etc.')
local DISSAPEAR = CreateConVar('sv_ducks_time', '20', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'How long duck exists')
local CRAZY_PHYS = CreateConVar('sv_ducks_duckboom', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'DUCK-BOOM! Forces ducks to have crazy velocity')

DBOT_ACTIVE_DUCKS = DBOT_ACTIVE_DUCKS or {} --Prefix DBOT_ for not to conflict with other quacky addons

local ENT = {}
local DUCK_TABLE = ENT
ENT.Type = 'anim'
ENT.Author = 'DBot'
ENT.Spawnable = false
ENT.PrintName = 'DUCK'

local Mins, Maxs = Vector(-5, -5, 0), Vector(5, 5, 5)

function ENT:Initialize()
	self:SetModel('models/workshop/player/items/pyro/eotl_ducky/eotl_bonus_duck.mdl')
	
	self.CreatedAt = CurTime()
	self.Expires = CurTime() + DISSAPEAR:GetInt()
	self.Fade = CurTime() + DISSAPEAR:GetInt() - 4
	
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
	
	self:EmitSound(table.Random(DUCK_TOUCH_SOUND), 75)
	self:Remove()
	
	net.Start('DBot_DuckOMeter')
	net.Send(ply)
	
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
	--Do nothing, real think code is below on serverside
end

function ENT:Draw()
	if not IsValid(self.ClientsideModel) then return end
	self.CAngle.y = self.CAngle.y + (FrameTime() * 66)
	
	if self.Fade < CurTime() then
		local ctime = CurTime()
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
	
	if self.Fade < CurTime() then
		render.SetBlend(1)
	end
end

function ENT:OnRemove()
	if CLIENT and IsValid(self.ClientsideModel) then
		self.ClientsideModel:Remove()
	end
end

scripted_ents.Register(ENT, 'dbot_duck')

local BEER_ENABLE = CreateConVar('sv_beer_enable', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable Mann Bear')
local BEER_ENABLE_NPC = CreateConVar('sv_beer_npc', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Beer drop for NPC')
local BEER_ENABLE_PLAYER = CreateConVar('sv_beer_drop', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Beer drop for Players')
local BEER_MIN = CreateConVar('sv_beer_min', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Minimal Mann Beer')
local BEER_MAX = CreateConVar('sv_beer_max', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Maximum Mann Beer')
local BEER_CHANCE = CreateConVar('sv_beer_chance', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Chance. 1 means 100%, 4 means 20%, etc.')
local BEER_DISSAPEAR = CreateConVar('sv_beer_time', '60', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'How long beer exists')

DBOT_ACTIVE_BEER = DBOT_ACTIVE_BEER or {}

local ENT = {}
ENT.Type = 'anim'
ENT.Author = 'DBot'
ENT.Spawnable = false
ENT.PrintName = 'Mann Bear'

function ENT:Initialize()
	self:SetModel('models/props_watergate/bottle_pickup.mdl')
	
	self.CreatedAt = CurTime()
	self.Expires = CurTime() + BEER_DISSAPEAR:GetInt()
	self.Fade = CurTime() + BEER_DISSAPEAR:GetInt() - 4
	
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

--I know i can make it by setting ENT.Base, but in this case i want this
ENT.Push = DUCK_TABLE.Push
ENT.PhysicsCollide = DUCK_TABLE.PhysicsCollide
ENT.Think = DUCK_TABLE.Think
ENT.Draw = DUCK_TABLE.Draw
ENT.OnRemove = DUCK_TABLE.OnRemove

scripted_ents.Register(ENT, 'dbot_mannbeer')

if CLIENT then
	surface.CreateFont('DBot_DuckOMeter', {
		font = 'Roboto',
		size = 18,
		weight = 500,
	})
	
	local DuckDisplayTimer = 0
	
	hook.Add('HUDPaint', 'DBot_DuckOMeter', function()
		if DuckDisplayTimer < CurTime() then return end
		local fade = (DuckDisplayTimer - CurTime()) / 4
		local x, y = ScrW() - 200, ScrH() / 2 + 100
		draw.DrawText('Ducks collected: ' .. DockOMetrValue, 'DBot_DuckOMeter', x, y, Color(255, 255, 255, fade * 255))
	end)
	
	net.Receive('DBot_DuckOMeter', function()
		DockOMetrValue = DockOMetrValue + 1
		sql.Query('DELETE FROM dbot_duckometr')
		sql.Query('INSERT INTO dbot_duckometr (cval) VALUES (' .. DockOMetrValue .. ')')
		DuckDisplayTimer = CurTime() + 4
	end)
	
	return
end

resource.AddWorkshop('690794994')

local function DoAction(ply)
	if not ENABLE:GetBool() then return end
	if math.random(1, CHANCE:GetInt()) ~= 1 then return end
	
	local epos = ply:EyePos()
	local count = math.random(MIN:GetInt(), MAX:GetInt())
	ply:EmitSound(table.Random(DUCK_SOUND), 75)
	
	for i = 1, count do
		local ent = ents.Create('dbot_duck')
		ent:SetPos(epos)
		ent:Spawn()
		ent:Activate()
		ent:Push()
	end
end

local function DoActionBeer(ply)
	if not BEER_ENABLE:GetBool() then return end
	if math.random(1, BEER_CHANCE:GetInt()) ~= 1 then return end
	
	local epos = ply:EyePos()
	local count = math.random(BEER_MIN:GetInt(), BEER_MAX:GetInt())
	ply:EmitSound('vo/watergate/drop_beer.mp3', 75)
	
	for i = 1, count do
		local ent = ents.Create('dbot_mannbeer')
		ent:SetPos(epos)
		ent:Spawn()
		ent:Activate()
		ent:Push()
	end
end

local function Think()
	local plys = player.GetAll()
	
	local positions = {}
	
	for k, v in pairs(plys) do
		if not v:Alive() then continue end
		positions[v] = v:GetPos()
	end
	
	for k, self in pairs(DBOT_ACTIVE_DUCKS) do
		if not IsValid(self) then
			DBOT_ACTIVE_DUCKS[k] = nil
			continue
		end
		
		local lpos = self:GetPos()
	
		if self.CreatedAt + 0.4 > CurTime() then continue end
		
		local hit = false
		
		for ply, pos in pairs(positions) do
			if pos:Distance(lpos) > 70 then continue end
			
			local can = hook.Run('CanCollectDuck', ply, self, pos, lpos)
			if can == false then continue end
			
			self:Collect(ply)
			hit = true
			break
		end
		
		if hit then continue end
		
		if self.Expires < CurTime() then
			self:Remove()
		end
	end
	
	for k, self in pairs(DBOT_ACTIVE_BEER) do
		if not IsValid(self) then
			DBOT_ACTIVE_BEER[k] = nil
			continue
		end
		
		local lpos = self:GetPos()
	
		if self.CreatedAt + 0.4 > CurTime() then continue end
		
		local hit = false
		
		for ply, pos in pairs(positions) do
			if pos:Distance(lpos) > 70 then continue end
			
			local can = hook.Run('CanCollectBeer', ply, self, pos, lpos)
			if can == false then continue end
			
			self:Collect(ply)
			hit = true
			break
		end
		
		if hit then continue end
		
		if self.Expires < CurTime() then
			self:Remove()
		end
	end
end

hook.Add('Think', 'DBot_BONUS_DUCKS', Think)

hook.Add('DoPlayerDeath', 'DBot_BONUS_DUCKS', function(ply) 
	if BEER_ENABLE_PLAYER:GetBool() then DoActionBeer(ply)  end
	if ENABLE_PLAYER:GetBool() then DoAction(ply)  end
end)

hook.Add('OnNPCKilled', 'DBot_BONUS_DUCKS', function(npc)
	if BEER_ENABLE_NPC:GetBool() then DoActionBeer(npc) end
	if ENABLE_NPC:GetBool() then DoAction(npc) end
end)

local BEER_HEALTH = CreateConVar('sv_beer_health', '10', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'How much beer gives health on pickup. 0 to disable')

hook.Add('PostCollectBeer', 'DBot_BeerHookExample', function(self, ply)
	if BEER_HEALTH:GetInt() <= 0 then return end
	if ply:IsPlayer() then
		ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + BEER_HEALTH:GetInt()))
	end
end)
