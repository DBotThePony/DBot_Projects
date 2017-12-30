
--[[
Copyright (C) 2016-2018 DBot

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

--Minecraft Content

local self = MCSWEP2
local mc = self

local ID_START = 3

local function ID()
	ID_START = ID_START + 1
	return ID_START
end

local ENT = {}
ENT.Type = 'anim'
ENT.Base = 'dbot_mcblock'
ENT.Author = 'DBot'
ENT.Category = 'MCSWEP2'
ENT.PrintName = 'Cake'
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	--NumNum
	self:NetworkVar('Int', 10, 'NomLeft')
	self.BaseClass.SetupDataTables(self)
end

function ENT:Initialize()
	self:DrawShadow(false)
	if CLIENT then return end

	self:SetModel('models/mcmodelpack/other_blocks/cake.mdl')
	self:UpdatePhysics()

	self:SetBlockID(800)
	self:UpdateData()
	self.DUPE_BLOCK_ID = 800

	self:SetNomLeft(4)
	self:SetUseType(SIMPLE_USE)
end

function ENT:CanChoke()
	return false
end

local Models = {
	'models/mcmodelpack/other_blocks/cake-quarter.mdl',
	'models/mcmodelpack/other_blocks/cake-half.mdl',
	'models/mcmodelpack/other_blocks/cake-sliced.mdl',
	'models/mcmodelpack/other_blocks/cake.mdl',
}

--NumNum
function ENT:TakeSlice()
	self:SetNomLeft(self:GetNomLeft() - 1)
	self.DUPE_SLICES = self:GetNomLeft()

	if Models[self:GetNomLeft()] then
		self:SetModel(Models[self:GetNomLeft()])
	end

	if self:GetNomLeft() <= 0 then
		self:Remove()
	end
end

function ENT:DrawLines()
	local pos = self:GetPos()
	local ang = self:GetAngles()

	mc.DrawLines(pos, ang, self:OBBMins(), self:OBBMaxs())
end

function ENT:Use(ply)
	local hp = ply:Health()
	local mhp = ply:GetMaxHealth()
	local delta = mhp - hp

	if delta <= 0 then return end
	ply:SetHealth(math.Clamp(hp + 25, 0, mhp))
	self:TakeSlice()
end

function ENT:InitializeBlockID()
	--Ignore things
end

scripted_ents.Register(ENT, 'dbot_mccake')

local ENT = {}
ENT.Type = 'anim'
ENT.Base = 'dbot_mcblock'
ENT.Author = 'DBot'
ENT.Category = 'MCSWEP2'
ENT.PrintName = 'TNT'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.BlastRadius = 256
ENT.MinDamage = 64
ENT.MaxDamage = 128
ENT.FuzeTime = 4
ENT.BlockID = 801
ENT.CustomWireOutputs = {'Ignited'}

function ENT:SetupDataTables()
	self:NetworkVar('Bool', 10, 'IsIgnited')
	self:NetworkVar('Float', 10, 'ExplodeAt')
	self.BaseClass.SetupDataTables(self)
end

function ENT:CanChoke()
	return false
end

function ENT:Initialize()
	self:DrawShadow(false)
	if CLIENT then return end

	self:SetBlockID(self.BlockID)
	self:UpdateData()
	self:UpdatePhysics()
	self.DUPE_BLOCK_ID = self.BlockID

	self:SetUseType(SIMPLE_USE)

	self:PostInitialize()

	self.Inputs = mc.SafeWireInputs(self, {'Ignite', 'UnIgnite'})
	mc.SafeTriggerOutput(self, 'Ignited', 0)
end

function ENT:TriggerInput(key, value)
	if key == 'Ignite' then
		self:MakeIgnite()
	elseif key == 'UnIgnite' then
		self:MakeUnignite()
	end
end

function ENT:PostInitialize()
	--Override
end

function ENT:MakeIgnite()
	if self:GetIsIgnited() then return end
	mc.SafeTriggerOutput(self, 'Ignited', 1)

	self:SetIsIgnited(true)
	self.phys:EnableMotion(true)
	self.phys:Wake()
	self.ExplodeAt = CurTime() + self.FuzeTime
	self:SetExplodeAt(self.ExplodeAt)
	self:EmitSound('minecraft/fuse.ogg')
end

function ENT:MakeUnignite()
	if not self:GetIsIgnited() then return end
	mc.SafeTriggerOutput(self, 'Ignited', 0)

	self:SetIsIgnited(false)
	self:EmitSound('minecraft/fizz.ogg')
end

function ENT:Explode()
	self.REMOVED = true

	util.BlastDamage(self, self:HaveOwner() and self:GetNWOwner() or self, self:GetPos() + Vector(0, 0, 5), self.BlastRadius, math.random(self.MinDamage, self.MaxDamage))
	self:EmitSound('minecraft/explode.ogg', 150)
	mc.Explosion(self:GetPos() + Vector(0, 0, 20))

	self:Remove()
end

local debugwtite = Material('models/debug/debugwhite')

function ENT:RealDraw()
	if self:GetIsIgnited() then
		local div = CurTime() % 1
		local ceil = div >= 0.5 and 1 or 0

		if ceil == 0 then
			render.SuppressEngineLighting(true)
			render.ModelMaterialOverride(debugwtite)
			render.ResetModelLighting(1, 1, 1)
		end

		local left = self:GetExplodeAt() - CurTime()

		if left <= 0.2 then
			local mult = (0.2 - left) * 3 + 1
			self:SetModelScale(mult)

			self:SetRenderOrigin()
			local pos = self:GetPos()
			self:SetRenderOrigin(pos + Vector(0, 0, -mult * 1.3))
		end

		self:DrawModel()

		render.SuppressEngineLighting(false)
	else
		self:DrawModel()
	end

	render.ModelMaterialOverride()
end

function ENT:Think()
	self.BaseClass.Think(self)

	if self.ExplodeAt then
		if self.ExplodeAt <= CurTime() then
			self:Explode()
		end
	end
end

function ENT:Use()
	if self.REMOVED then return end
	self:MakeIgnite()
end

function ENT:OnTakeDamage(dmg)
	if self.REMOVED then return end
	self:MakeIgnite()
end

function ENT:InitializeBlockID(id, ...)
	self.BaseClass.InitializeBlockID(self, self.BlockID, ...)
end

scripted_ents.Register(ENT, 'dbot_mctnt')

local ENT = {}
ENT.Type = 'anim'
ENT.Base = 'dbot_mcblock'
ENT.Author = 'DBot'
ENT.Category = 'MCSWEP2'
ENT.PrintName = 'Anvil'
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)
end

function ENT:UpdateSkin()
	local percent = self:HealthPercent()

	if percent < .4 then
		self:SetSkin(2)
	elseif percent > .4 and percent < .7 then
		self:SetSkin(1)
	else
		self:SetSkin(0)
	end
end

function ENT:StopFall()
	local stop = self.BaseClass.StopFall(self)
	if not stop then return end

	self:EmitSound('minecraft/anvil_land.ogg')

	local delta = self:GetFallStartZ() - self:GetFallEndZ()

	local dmg = delta / 10

	for k, ent in ipairs(ents.FindInSphere(self:GetPos(), mc.STEP)) do
		if ent == self then continue end
		ent:TakeDamage(dmg, self, self)
	end

	local world = Entity(0)
	self:TakeDamage(dmg, world, world)

	self:UpdateSkin()
end

function ENT:OnTakeDamage(dmg)
	self.BaseClass.OnTakeDamage(self, dmg)
	self:UpdateSkin()
end

function ENT:CanFall()
	return true
end

function ENT:CanBeRotated()
	return true
end

function ENT:CanFall()
	return true
end

function ENT:IsOpaque()
	return false
end

function ENT:FallSpeedMultipler()
	return 400
end

function ENT:DrawLines()
	mc.DrawLines(self:GetPos(), self:GetAngles(), self:OBBMins(), self:OBBMaxs())
end

function ENT:InitializeBlockID()
	self.BaseClass.InitializeBlockID(self, 807)
end

scripted_ents.Register(ENT, 'dbot_mcblock_anvil')

if CLIENT then
	language.Add('dbot_mctnt', 'TNT')
	language.Add('dbot_mcblock_anvil', 'Anvil')
	language.Add('dbot_mccake', 'Cake')
end

local WoodData = {material = self.MAT_WOOD, health = 40, flame = true}

self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/dirt.mdl', {health = 10, material = self.MAT_DIRT}, 'dirt')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/grass.mdl', {health = 10, material = self.MAT_GRASS}, 'grass')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/farmland.mdl', {health = 10, material = self.MAT_DIRT}, 'farmland')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/bookshelf.mdl', WoodData, 'bookshelf')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/brick.mdl', 'bricks')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/cactus.mdl', {material = self.MAT_CLOTH, health = 20}, 'cactus')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/workbench.mdl', WoodData, 'workbench')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/chest.mdl', {material = self.MAT_WOOD, health = 40, flame = true, rotate = true}, 'chest')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/stonecutter.mdl', 'stonecutter')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/stoneslabs.mdl', 'stoneslabs')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/jukebox.mdl', WoodData, 'jukebox')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/noteblock.mdl', WoodData, 'noteblock')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/wood.mdl', {material = self.MAT_WOOD, health = 40, flame = true, skins = self.SimpleSkins(0, 5)}, 'wood')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/planks.mdl', {material = self.MAT_WOOD, health = 40, flame = true, skins = self.SimpleSkins(0, 5)}, 'planks')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/furnace.mdl', {rotate = true}, 'furnace')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/netherbrick.mdl', 'netherbrick')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/netherrack.mdl', {health = 15}, 'netherrack')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/obsidian.mdl', {health = 750}, 'obsidian')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/ore-quartz.mdl', 'quartz')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/ore.mdl', {skins = self.SimpleSkins(0, 7)}, 'ore')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/ice.mdl', {health = 25, material = self.MAT_GLASS, skins = {0, 1}}, 'ice')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/endstone.mdl', {health = 200}, 'enderstone')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/clay-hardened.mdl', {health = 60, skins = self.SimpleSkins(0, 17)}, 'clay.hardened')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/clay.mdl', {health = 30, material = self.MAT_GRAVEL}, 'clay')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/cloth-new.mdl', {health = 25, material = self.MAT_CLOTH, skins = self.SimpleSkins(0, 15)}, 'cloth.new')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/cloth-old.mdl', {health = 25, material = self.MAT_CLOTH, skins = self.SimpleSkins(0, 15)}, 'cloth.old')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/dispencer.mdl', {skins = {0, 1}, rotate = true}, 'dispencer')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/giantmushroom-base.mdl', {health = 10, material = self.MAT_WOOD, flame = true}, 'mushroon')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/giantmushroom-head.mdl', {health = 10, material = self.MAT_WOOD, flame = true, skins = {0, 1}}, 'mushroom.head')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/glass.mdl', {health = 25, material = self.MAT_GLASS, skins = {0, 1}, canchoke = false}, 'glass')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/glowstone.mdl', {health = 25, material = self.MAT_GLASS, 'glowstone', glowmult = 3, glow = true, glowcolor = Color(255, 225, 65)}, 'glowstone')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/gravel.mdl', {health = 20, material = self.MAT_GRAVEL, physics = true}, 'gravel')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/hay.mdl', {health = 50, material = self.MAT_CLOTH}, 'hay')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/lamp.mdl', {health = 50, material = self.MAT_GLASS, skins = {0}, glowmult = 3, glow = true, glowcolor = Color(255, 225, 65)}, 'lamp.on')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/leaves.mdl', {health = 10, material = self.MAT_LEAVES, skins = self.SimpleSkins(0, 13), canchoke = false, opaque = false}, 'leaves')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/melon.mdl', WoodData, 'melon')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/pumpkin.mdl', {material = self.MAT_WOOD, health = 40, flame = true, skins = {0}, rotate = true}, 'pumpkin')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/pumpkin.mdl', {material = self.MAT_WOOD, health = 40, flame = true, skins = {1}, rotate = true, glowmult = 1, glow = true, glowcolor = Color(255, 225, 65)}, 'pumpkin.glow')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/quartz.mdl', {material = self.MAT_IRON, health = 150, skins = self.SimpleSkins(0, 2)}, 'quartz.block')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/reactor.mdl', {material = self.MAT_IRON, health = 150, skins = self.SimpleSkins(0, 2)}, 'reactor')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/sand.mdl', {material = self.MAT_SAND, health = 10, skins = self.SimpleSkins(0, 1), physics = true}, 'sand')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/sandstone.mdl', {health = 75, skins = self.SimpleSkins(0, 2)}, 'sandstone')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/snowblock.mdl', {material = self.MAT_SNOW, health = 40}, 'snowblock')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/solidblock.mdl', {material = self.MAT_IRON, health = 150, skins = self.SimpleSkins(0, 7)}, 'ironblock')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/soulsand.mdl', {material = self.MAT_SAND, health = 40}, 'soulsand')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/spawner.mdl', {material = self.MAT_IRON, health = 300}, 'spawner')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/sponge.mdl', {material = self.MAT_CLOTH, health = 40}, 'sponge')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/stonebrick.mdl', {skins = self.SimpleSkins(0, 3)}, 'stonebrick')
self.RegisterBlock(ID(), 'models/mcmodelpack/other_blocks/stairs-brick.mdl', {rotate = true, flip = true}, 'stairs.brick')
self.RegisterBlock(ID(), 'models/mcmodelpack/other_blocks/stairs-netherbrick.mdl', {rotate = true, flip = true}, 'stairs.netherbrick')
self.RegisterBlock(ID(), 'models/mcmodelpack/other_blocks/stairs-quartz.mdl', {rotate = true, flip = true}, 'stairs.quartz')
self.RegisterBlock(ID(), 'models/mcmodelpack/other_blocks/stairs-sandstone.mdl', {rotate = true, flip = true, health = 40}, 'stairs.sandstone')
self.RegisterBlock(ID(), 'models/mcmodelpack/other_blocks/stairs-stone.mdl', {rotate = true, flip = true}, 'stairs.cobblestone')
self.RegisterBlock(ID(), 'models/mcmodelpack/other_blocks/stairs-wood.mdl', {rotate = true, flip = true, material = self.MAT_WOOD, skins = self.SimpleSkins(0, 5), flame = true}, 'stairs.wood')
self.RegisterBlock(ID(), 'models/mcmodelpack/other_blocks/endportal.mdl', {destructable = false, canchoke = false}, 'enderportal')
self.RegisterBlock(ID(), 'models/mcmodelpack/other_blocks/endportal2.mdl', {destructable = false, canchoke = false}, 'enderportal2')
self.RegisterBlock(ID(), 'models/mcmodelpack/other_blocks/dragon_egg.mdl', {health = 1000, canchoke = false, opaque = false, physics = true}, 'dragonegg')
self.RegisterBlock(ID(), 'models/mcmodelpack/other_blocks/brewing_stand.mdl', {canchoke = false, opaque = false}, 'brewingstand')
self.RegisterBlock(ID(), 'models/mcmodelpack/other_blocks/cauldron.mdl', {canchoke = false}, 'cauldron')
self.RegisterBlock(ID(), 'models/mcmodelpack/other_blocks/ironbars.mdl', {material = self.MAT_IRON, health = 60, canchoke = false}, 'ironbars')
self.RegisterBlock(ID(), 'models/mcmodelpack/other_blocks/decoration.mdl', {material = self.MAT_LEAVES, health = 5, class = 'dbot_mcblock_decoration', skins = self.SimpleSkins(4, 26)}, 'decoration')
self.RegisterBlock(ID(), 'models/mcmodelpack/other_blocks/glasspane.mdl', {material = self.MAT_GLASS, health = 10, rotate = true, canchoke = false}, 'glasspanel')
self.RegisterBlock(ID(), 'models/mcmodelpack/other_blocks/ladder.mdl', {material = self.MAT_WOOD, health = 20, flame = true, rotate = true, rotateblock = true, opaque = false, canchoke = false, solid = false}, 'ladder')
self.RegisterBlock(ID(), 'models/mcmodelpack/blocks/lamp.mdl', {health = 50, material = self.MAT_GLASS, skins = {1}}, 'lamp.off')

--Destruct Events
self.RegisterEventHook(self.GetBlockByName('cobblestone'), 'OnDestruct', nil, self.EventCreate(self.GetBlockByName('gravel')))
self.RegisterEventHook(self.GetBlockByName('sandstone'), 'OnDestruct', nil, self.EventCreate(self.GetBlockByName('sand')))
self.RegisterEventHook(self.GetBlockByName('dispencer'), 'OnDestruct', nil, self.EventCreate(self.GetBlockByName('stone')))
self.RegisterEventHook(self.GetBlockByName('stonebrick'), 'OnDestruct', nil, self.EventCreate(self.GetBlockByName('stone')))
self.RegisterEventHook(self.GetBlockByName('furnace'), 'OnDestruct', nil, self.EventCreate(self.GetBlockByName('stone')))
self.RegisterEventHook(self.GetBlockByName('ore'), 'OnDestruct', nil, self.EventCreate(self.GetBlockByName('stone')))
self.RegisterEventHook(self.GetBlockByName('clay.hardened'), 'OnDestruct', nil, self.EventCreate(self.GetBlockByName('gravel')))
self.RegisterEventHook(self.GetBlockByName('quartz'), 'OnDestruct', nil, self.EventCreate(self.GetBlockByName('netherrack')))
self.RegisterEventHook(self.GetBlockByName('netherbrick'), 'OnDestruct', nil, self.EventCreate(self.GetBlockByName('netherrack')))
self.RegisterEventHook(self.GetBlockByName('soulsand'), 'OnDestruct', nil, self.EventCreate(self.GetBlockByName('sand')))

self.RegisterBlock(800, 'models/mcmodelpack/other_blocks/cake.mdl', {health = 30, material = self.MAT_CLOTH, class = 'dbot_mccake'}, 'cake')
self.RegisterBlock(801, 'models/mcmodelpack/blocks/tnt.mdl', {material = self.MAT_GRASS, class = 'dbot_mctnt'}, 'tnt')
self.RegisterBlock(802, 'models/mcmodelpack/fences/fence-post.mdl', {material = self.MAT_WOOD, class = 'dbot_mcblock_fence', health = 40, flame = true, skins = {0}}, 'fence.wood')
self.RegisterBlock(803, 'models/mcmodelpack/fences/fence-post.mdl', {class = 'dbot_mcblock_fence', skins = {1}}, 'fence.netherbrick')
self.RegisterBlock(804, 'models/mcmodelpack/fences/wall-post.mdl', {class = 'dbot_mcblock_fence', skins = {0, 1}}, 'fence.stone')
self.RegisterFenceModel(802, 'models/mcmodelpack/fences/fence-')
self.RegisterFenceModel(803, 'models/mcmodelpack/fences/fence-')
self.RegisterFenceModel(804, 'models/mcmodelpack/fences/wall-')

self.RegisterBlock(805, 'models/mcmodelpack/other_blocks/door-wood.mdl', {class = 'dbot_mcblock_door', health = 60, material = self.MAT_WOOD}, 'door.wood')
self.RegisterBlock(806, 'models/mcmodelpack/other_blocks/door-iron.mdl', {class = 'dbot_mcblock_door', health = 200, material = self.MAT_IRON}, 'door.iron')
self.RegisterBlock(807, 'models/mcmodelpack/entities/anvil.mdl', {class = 'dbot_mcblock_anvil', health = 200, material = self.MAT_IRON}, 'anvil')

self.RegisterBlock(808, 'models/mcmodelpack/other_blocks/decoration.mdl', {class = 'dbot_mcblock_sapling', health = 20, material = self.MAT_LEAVES, flame = true}, 'sapling.oak')
self.RegisterBlock(809, 'models/mcmodelpack/other_blocks/decoration.mdl', {class = 'dbot_mcblock_sapling', health = 20, material = self.MAT_LEAVES, skins = {2}, flame = true}, 'sapling.brich')
self.RegisterBlock(810, 'models/mcmodelpack/other_blocks/decoration.mdl', {class = 'dbot_mcblock_sapling', health = 20, material = self.MAT_LEAVES, skins = {1}, flame = true}, 'sapling.pine')
self.RegisterBlock(811, 'models/mcmodelpack/fences/fence-gate.mdl', {class = 'dbot_mcblock_fencegate', health = 40, material = self.MAT_WOOD, skins = {0}, flame = true}, 'fence.gate')
self.RegisterBlock(812, 'models/mcmodelpack/fences/fence-gate.mdl', {class = 'dbot_mcblock_fencegate', skins = {1}}, 'fence.gate')
self.RegisterFenceGateModel(811, 'models/mcmodelpack/fences/fence-gate')
self.RegisterFenceGateModel(812, 'models/mcmodelpack/fences/fence-gate')
self.RegisterBlock(813, 'models/mcmodelpack/other_blocks/decoration.mdl', {class = 'dbot_mcblock_sapling', health = 20, material = self.MAT_LEAVES, skins = {3}, flame = true}, 'sapling.jungle')

if SERVER then
	include('sv_blocks.lua')
	include('sv_trees.lua')
end
