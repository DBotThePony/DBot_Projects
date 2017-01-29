
--[[
Copyright (C) 2016-2017 DBot

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

if VLL then
	VLL.LoadGMA('mcswep2_2')
end

MCSWEP2 = MCSWEP2 or {}
local self = MCSWEP2

if SERVER then
	AddCSLuaFile()
	include('sv_init.lua')
else
	include('cl_init.lua')
end

self.mcswep2_blocklimit = CreateConVar('mcswep2_blocklimit', '1024', {FCVAR_ARCHIVE, FCVAR_REPLICATED}, 'Limit of blocks for entrie server')
self.mcswep2_playerlimit = CreateConVar('mcswep2_playerlimit', '256', {FCVAR_ARCHIVE, FCVAR_REPLICATED}, 'Limit of blocks for each player')

self.BlockHooks = self.BlockHooks or {}
self.RegisteredBlocks = self.RegisteredBlocks or {}

self.DEFAULT_ID = 2
self.DEFAULT_SKIN = 0

self.MAT_STONE = 1
self.MAT_WOOD = 2
self.MAT_SNOW = 3
self.MAT_GRAVEL = 4
self.MAT_GRASS = 5
self.MAT_GLASS = 6
self.MAT_CLOTH = 7

--Eh
self.MAT_DIRT = 8
self.MAT_LEAVES = 9
self.MAT_IRON = 10
self.MAT_SAND = 11

self.MatNames = {
	[self.MAT_STONE] = 'Stone',
	[self.MAT_WOOD] = 'Wood',
	[self.MAT_SNOW] = 'Snow',
	[self.MAT_GRAVEL] = 'Gravel',
	[self.MAT_GRASS] = 'Grass',
	[self.MAT_GLASS] = 'Glass',
	[self.MAT_CLOTH] = 'Cloth',
	[self.MAT_DIRT] = 'Dirt',
	[self.MAT_LEAVES] = 'Leaves',
	[self.MAT_IRON] = 'Iron/Solid Block',
	[self.MAT_SAND] = 'Sand',
}

function self.GetMaterialName(mat)
	mat = mat or self.MAT_STONE
	return self.MatNames[mat] or self.MatNames[self.MAT_STONE]
end

self.ROTATE_SOUTH = 0
self.ROTATE_NORTH = 1
self.ROTATE_WEST = 2
self.ROTATE_EAST = 3

self.ROTATE_ANGLES = {
	[self.ROTATE_SOUTH] = 0,
	[self.ROTATE_NORTH] = 180,
	[self.ROTATE_WEST] = -90,
	[self.ROTATE_EAST] = 90,
}

self.SIDE_TOP = 1
self.SIDE_UP = self.SIDE_TOP
self.SIDE_DOWN = 2
self.SIDE_LEFT = 3
self.SIDE_RIGHT = 4
self.SIDE_FORWARD = 5
self.SIDE_BACKWARD = 6

self.SIDES = {
	self.SIDE_TOP,
	self.SIDE_DOWN,
	self.SIDE_LEFT,
	self.SIDE_RIGHT,
	self.SIDE_FORWARD,
	self.SIDE_BACKWARD,
}

self.SIDE_NAMES = {
	[self.SIDE_TOP] = 'SIDE_TOP',
	[self.SIDE_DOWN] = 'SIDE_DOWN',
	[self.SIDE_LEFT] = 'SIDE_LEFT',
	[self.SIDE_RIGHT] = 'SIDE_RIGHT',
	[self.SIDE_FORWARD] = 'SIDE_FORWARD',
	[self.SIDE_BACKWARD] = 'SIDE_BACKWARD',
}

self.SIDE_VECTORS = {
	[self.SIDE_TOP] = Vector(0, 0, 1),
	[self.SIDE_DOWN] = Vector(0, 0, -1),
	[self.SIDE_LEFT] = Vector(-1, 0, 0),
	[self.SIDE_RIGHT] = Vector(1, 0, 0),
	[self.SIDE_FORWARD] = Vector(0, 1, 0),
	[self.SIDE_BACKWARD] = Vector(0, -1, 0),
}

self.SIDE_ROTATE = {
	--holy shit this is dumb
	[self.SIDE_FORWARD] = self.ROTATE_NORTH,
	[self.SIDE_BACKWARD] = self.ROTATE_SOUTH,
	[self.SIDE_LEFT] = self.ROTATE_WEST,
	[self.SIDE_RIGHT] = self.ROTATE_EAST,
}

self.SIDE_ROTATE_INVERSED = {}

for k, v in pairs(self.SIDE_ROTATE) do
	self.SIDE_ROTATE_INVERSED[v] = k
end

self.SIDE_ANGLES = {}

for k, v in pairs(self.SIDE_VECTORS) do
	self.SIDE_ANGLES[k] = v:Angle()
end

function self.GetSideAngle(side)
	local ang = self.SIDE_ANGLES[side] or self.SIDE_ANGLES[self.SIDE_FORWARD]
	return Angle(ang.p, ang.y, ang.r)
end

function self.GetSideVector(side)
	return Vector(self.SIDE_VECTORS[side] or self.SIDE_VECTORS[self.SIDE_FORWARD])
end

function self.GetRotateAngle(side)
	return self.ROTATE_ANGLES[side]
end

function self.GetSideByRotate(rotate)
	return self.SIDE_ROTATE_INVERSED[rotate]
end

function self.GetRotateBySide(side)
	return self.SIDE_ROTATE[side]
end

local function interval(x, min, max)
	return x > min and x <= max
end

function self.AngleDir(ang)
	if interval(ang, -45, 45) then
		return self.ROTATE_SOUTH
	elseif interval(ang, 45, 135) then
		return self.ROTATE_EAST
	elseif interval(ang, 135, 180) or interval(ang, -180, -135) then
		return self.ROTATE_NORTH
	else
		return self.ROTATE_WEST
	end
end

function self.TranslateAngle(ang)
	return self.ROTATE_ANGLES[self.AngleDir(ang)]
end

function self.IsPosFreeFromBlock(pos, ignorenonopaque)
	pos = Vector(pos.x, pos.y, pos.z + 7)
	
	for k, v in ipairs(ents.FindInSphere(pos, 5)) do
		if v.MC_IGNORE then continue end
		if v.IsMCBlock then
			if ignorenonopaque and not v:IsOpaque() then continue end
			return false
		end
	end
	
	return true
end

function self.ClearPositionFromBlocks(pos)
	pos = Vector(pos.x, pos.y, pos.z + 7)
	
	for k, v in ipairs(ents.FindInSphere(pos, 5)) do
		if v.IsMCBlock then
			v:Remove()
		end
	end
end

local function Format(start, endpos, str)
	local t = {}
	
	for i = start, endpos do
		table.insert(t, string.format(str, i))
	end
	
	return t
end

self.MatSounds = {}
self.MatSounds[self.MAT_STONE] = Format(1, 4, 'minecraft/dig/stone%s.ogg')
self.MatSounds[self.MAT_WOOD] = Format(1, 4, 'minecraft/dig/wood%s.ogg')
self.MatSounds[self.MAT_SNOW] = Format(1, 4, 'minecraft/dig/snow%s.ogg')
self.MatSounds[self.MAT_GRAVEL] = Format(1, 4, 'minecraft/dig/gravel%s.ogg')
self.MatSounds[self.MAT_GRASS] = Format(1, 4, 'minecraft/dig/grass%s.ogg')
self.MatSounds[self.MAT_GLASS] = Format(1, 3, 'minecraft/dig/glass%s.ogg')
self.MatSounds[self.MAT_CLOTH] = Format(1, 4, 'minecraft/dig/cloth%s.ogg')
self.MatSounds[self.MAT_DIRT] = self.MatSounds[self.MAT_GRAVEL]
self.MatSounds[self.MAT_LEAVES] = self.MatSounds[self.MAT_GRASS]
self.MatSounds[self.MAT_IRON] = self.MatSounds[self.MAT_STONE]
self.MatSounds[self.MAT_SAND] =  Format(1, 4, 'minecraft/dig/sand%s.ogg')

--Make blacklist
self.PlaceSounds = table.Copy(self.MatSounds)
self.PlaceSounds[self.MAT_GLASS] = self.PlaceSounds[self.MAT_STONE]

self.WalkSounds = {}
self.WalkSounds[self.MAT_STONE] = Format(1, 6, 'minecraft/step/stone%s.ogg')
self.WalkSounds[self.MAT_WOOD] = Format(1, 6, 'minecraft/step/wood%s.ogg')
self.WalkSounds[self.MAT_SNOW] = Format(1, 4, 'minecraft/step/snow%s.ogg')
self.WalkSounds[self.MAT_GRAVEL] = Format(1, 4, 'minecraft/step/gravel%s.ogg')
self.WalkSounds[self.MAT_GRASS] = Format(1, 6, 'minecraft/step/grass%s.ogg')
self.WalkSounds[self.MAT_CLOTH] = Format(1, 4, 'minecraft/step/cloth%s.ogg')
self.WalkSounds[self.MAT_DIRT] = self.WalkSounds[self.MAT_GRAVEL]
self.WalkSounds[self.MAT_LEAVES] = self.WalkSounds[self.MAT_GRASS]
self.WalkSounds[self.MAT_IRON] = self.WalkSounds[self.MAT_STONE]
self.WalkSounds[self.MAT_SAND] =  Format(1, 5, 'minecraft/step/sand%s.ogg')

self.ImpactSounds = table.Copy(self.MatSounds)

function self.GetPlaceSound(mat)
	mat = mat or self.MAT_STONE
	local t = self.PlaceSounds[mat]
	
	if t then
		return t[math.random(1, #t)]
	else
		return 'minecraft/block_break.ogg'
	end
end

function self.HaveImpactSound(mat)
	mat = mat or self.MAT_STONE
	return self.ImpactSounds[mat] ~= nil
end

function self.GetImpactSounds(mat)
	mat = mat or self.MAT_STONE
	return self.ImpactSounds[mat] or self.ImpactSounds[self.MAT_STONE]
end

function self.GetImpactSound(mat)
	local t = self.GetImpactSounds(mat)
	local s = t[math.random(1, #t)]
	return s
end

function self.HaveWalkSound(mat)
	mat = mat or self.MAT_STONE
	return self.WalkSounds[mat] ~= nil
end

function self.GetWalkSounds(mat)
	mat = mat or self.MAT_STONE
	return self.WalkSounds[mat] or self.WalkSounds[self.MAT_STONE]
end

function self.GetWalkSound(mat)
	local t = self.GetWalkSounds(mat)
	local s = t[math.random(1, #t)]
	return s
end

function self.SafeWireInputs(...)
	if not WireLib then return end
	return WireLib.CreateInputs(...)
end

function self.SafeWireOutputs(...)
	if not WireLib then return end
	return WireLib.CreateOutputs(...)
end

function self.SafeTriggerOutput(...)
	if not WireLib then return end
	return WireLib.TriggerOutput(...)
end

self.RAINBOW_COLORS = {
	Color(255, 0, 0),
	Color(255, 0, 0),
}

local DefaultData = {
	flame = false,
	canignite = false,
	liquid = false,
	destructable = true,
	material = self.MAT_STONE,
	health = 100,
	rotate = false,
	flip = false,
	physics = false,
	canfloat = true,
	canchoke = true,
	opaque = true,
	glow = false,
	redstone = false,
	solid = true,
	rotateblock = false,
	glowmult = 1,
	glowr = 255,
	glowg = 255,
	glowb = 255,
	colors = {Color(255, 255, 255)},
	--Class is used to spawn entity.
	--Custom class will point to block with same methods as dbot_mcblock, but not same mechanics
	class = 'dbot_mcblock',
	model = 'models/mcmodelpack/blocks/bedrock.mdl',
	skins = {0},
}

function self.tonumber(val)
	local t = type(val)
	
	if t == 'number' then
		return val
	elseif t == 'boolean' then
		return val and 1 or 0
	elseif t == 'string' then
		return (val == '0' or val == 'false' or val == '') and 0 or 1
	end
end

function self.GetRegisteredBlocks()
	return self.RegisteredBlocks
end

function self.GetSounds(mat)
	mat = mat or self.MAT_STONE
	return self.MatSounds[mat] or self.MatSounds[self.MAT_STONE]
end

function self.GetSound(mat)
	local t = self.GetSounds(mat)
	local s = t[math.random(1, #t)]
	return s
end

function self.ValidateBlockID(id)
	return self.RegisteredBlocks[id] ~= nil and id or self.DEFAULT_ID
end

function self.ValidateBlockSkin(id, skin)
	return self.RegisteredBlocks[id] ~= nil and table.HasValue(self.RegisteredBlocks[id].skins, skin) and skin or self.DEFAULT_SKIN
end

function self.RegisterBlock(id, model, data, name)
	if type(data) == 'string' then
		name = data
		data = nil
	end
	
	data = data or {}
	
	data.name = name or 'undefined'
	
	if data.glowcolor then
		data.glowr = data.glowcolor.r
		data.glowg = data.glowcolor.g
		data.glowb = data.glowcolor.b
	end
	
	local newdata = table.Copy(DefaultData)
	table.Merge(newdata, data)
	newdata.model = model
	
	self.RegisteredBlocks[id] = newdata
	
	return newdata
end

function self.GetBlockByName(name)
	for id, data in pairs(self.RegisteredBlocks) do
		if data.name == name then
			return id, data
		end
	end
	
	return false
end

function self.GetBlockByID(id)
	return self.RegisteredBlocks[self.ValidateBlockID(id)]
end

self.STEP = 36.5

function self.TranslateVector(pos)
	return Vector(math.ceil((pos.x - self.STEP / 2) / self.STEP), math.ceil((pos.y - self.STEP / 2) / self.STEP), math.ceil((pos.z - self.STEP / 2) / self.STEP))
end

function self.SharpVector(pos)
	return self.UpdateVector(self.TranslateVector(pos))
end

function self.UpdateVector(pos)
	return Vector(pos.x * self.STEP, pos.y * self.STEP, pos.z * self.STEP)
end

local EMPTY_FUNC = function(self) end

self.THINK_SHARED = 0
self.THINK_SERVER = 1
self.THINK_CLIENT = 2

function self.RegisterThink(id, funcClient, funcServer, funcShared)
	return self.RegisterEventHook(id, 'Think', funcClient, funcServer, funcShared)
end

function self.BlockEvent(id, event, ...)
	if not self.BlockHooks[id] then return end
	if not self.BlockHooks[id][event] then return end
	
	self.BlockHooks[id][event].shared(...)
	
	if CLIENT then
		self.BlockHooks[id][event].client(...)
	else
		self.BlockHooks[id][event].server(...)
	end
end

function self.RegisterEventHook(id, event, funcClient, funcServer, funcShared)
	funcClient = funcClient or EMPTY_FUNC
	funcServer = funcServer or EMPTY_FUNC
	funcShared = funcShared or EMPTY_FUNC
	
	self.BlockHooks[id] = self.BlockHooks[id] or {}
	self.BlockHooks[id][event] = {
		server = funcServer,
		client = funcClient,
		shared = funcShared,
	}
	
	return self.BlockHooks[id][event]
end

function self.GetBlockData(id)
	return self.RegisteredBlocks[id] or DefaultData
end

function self.GetBlockModel(id)
	return self.GetBlockData(id).model
end

function self.EventCreate(idToCreate)
	return function(self, dmg)
		local ent = ents.Create('dbot_mcblock')
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:Spawn()
		ent:Activate()
		
		ent:InitializeBlockID(idToCreate)
		if self:HaveOwner() then
			ent:SetupOwner(self:GetNWOwner())
			
			undo.Create('MCBlock')
			undo.AddEntity(ent)
			undo.SetPlayer(self:GetNWOwner())
			undo.Finish()
		end
		
		if dmg then
			ent:TakeDamageInfo(dmg)
		end
	end
end

function self.SimpleSkins(start, endpos)
	local t = {}
	
	for i = start, endpos do
		table.insert(t, i)
	end
	
	return t
end

function self.CheckSpaceDirection(pos, side, filter)
	filter = filter or {}
	
	if type(filter) ~= 'table' then
		filter = {filter}
	end
	
	side = side or self.SIDE_FORWARD
	
	local start = self.SharpVector(pos)
	start.z = start.z + self.STEP / 2
	
	local add = self.GetSideVector(side)
	
	local tr = util.TraceLine{
		start = start,
		endpos = start + add * (self.STEP + 2),
		filter = function(ent)
			if table.HasValue(filter, ent) then return false end
			if ent.IsMCBlock then return true end
			return false
		end
	}
	
	return tr.Entity
end

function self.CheckSpaceNear(pos, filter)
	local t = {}
	
	for k, side in ipairs(self.SIDES) do
		t[side] = self.CheckSpaceDirection(pos, side, filter)
	end
	
	return t
end

function self.CheckNearBlocks(pos, filter)
	local t = {}
	
	t[self.SIDE_LEFT] = self.CheckSpaceDirection(pos, self.SIDE_LEFT, filter)
	t[self.SIDE_RIGHT] = self.CheckSpaceDirection(pos, self.SIDE_RIGHT, filter)
	t[self.SIDE_FORWARD] = self.CheckSpaceDirection(pos, self.SIDE_FORWARD, filter)
	t[self.SIDE_BACKWARD] = self.CheckSpaceDirection(pos, self.SIDE_BACKWARD, filter)
	
	return t
end

self.VALID_ENTITIES = {}

function self.GetActiveBlocks()
	local toRemove = {}
	
	for k, ent in ipairs(self.VALID_ENTITIES) do
		if not IsValid(ent) then
			table.insert(toRemove, k)
		end
	end
	
	for i = #toRemove, 1, -1 do
		table.remove(self.VALID_ENTITIES, toRemove[i])
	end
	
	return self.VALID_ENTITIES
end

function self.GetActiveBlocksByPlayer(ply)
	local reply = {}
	
	for k, ent in ipairs(self.GetActiveBlocks()) do
		if ent:GetNWOwner() == ply then
			table.insert(reply, ent)
		end
	end
	
	return reply
end

local function Timer()
	self.VALID_ENTITIES = {}
	
	for k, ent in ipairs(ents.GetAll()) do
		if ent.IsMCBlock then
			table.insert(self.VALID_ENTITIES, ent)
		end
	end
end

timer.Create('MCSWEP2.UpdateBlocksRegistry', 1, 0, Timer)

self.RegisterBlock(1, 'models/mcmodelpack/blocks/bedrock.mdl', {destructable = false}, 'undestructuble')
self.RegisterBlock(2, 'models/mcmodelpack/blocks/stone.mdl', 'stone')
self.RegisterBlock(3, 'models/mcmodelpack/blocks/cobblestone.mdl', {skins = {0, 1}}, 'cobblestone')
self.RegisterEventHook(2, 'OnDestruct', nil, self.EventCreate(3))

include('sh_block.lua')
include('sh_swep.lua')
