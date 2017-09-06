
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

local PICKUP_RANGE = CreateConVar('sv_dspawner_srange', '128', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Entity spawner spawn trigger range in Hu')
local RESET_TIMER = CreateConVar('sv_dspawner_stimer', '10', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Entity spawner reset timer in seconds')

local ENT = {}
ENT.Type = 'anim'
ENT.Author = 'DBot'
ENT.PrintName = 'Enitity Spawner Base'
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = 'models/items/item_item_crate.mdl'

function ENT:SetupDataTables()
	self:NetworkVar('String', 0, 'SWEPClass')
	self:NetworkVar('Bool', 0, 'IsSpawned')
end

function ENT:SpawnFunction(ply, tr, class)
	if not tr.Hit then return end
	
	local can = hook.Run('PlayerSpawnSENT', ply, self.CLASS)
	if can == false then return end
	
	local ent = ents.Create(class)
	ent:SetPos(tr.HitPos + tr.HitNormal)
	
	if not self.TABLE.eSpawnerInfo then
		local newEnt = ents.Create(self.CLASS)
		newEnt:SetPos(tr.HitPos)
		newEnt:Spawn()
		newEnt:Activate()
		
		local mdl = newEnt:GetModel()
		local skin = newEnt:GetSkin()
		local color = newEnt:GetColor()
		local material = newEnt:GetMaterial()
		local bg = newEnt:GetBodyGroups()
		
		self.TABLE.eSpawnerInfo = {}
		self.TABLE.eSpawnerInfo.mdl = mdl
		self.TABLE.eSpawnerInfo.skin = skin
		self.TABLE.eSpawnerInfo.color = color
		self.TABLE.eSpawnerInfo.material = material
		self.TABLE.eSpawnerInfo.bg = bg
		self.TABLE.eSpawnerInfo.bginfo = {}
		
		if bg then
			for k, v in pairs(bg) do
				self.TABLE.eSpawnerInfo.bginfo[v.id] = newEnt:GetBodygroup(v.id)
			end
		end
		
		newEnt:Remove()
	end
	
	local mdl = self.TABLE.eSpawnerInfo.mdl
	local skin = self.TABLE.eSpawnerInfo.skin
	local color = self.TABLE.eSpawnerInfo.color
	local material = self.TABLE.eSpawnerInfo.material
	
	if mdl then
		ent.Model = mdl
		ent:SetModel(mdl)
	else
		ent:SetModel(ent.Model)
	end
	
	if skin then
		ent:SetSkin(skin)
	end
	
	for k, v in pairs(self.TABLE.eSpawnerInfo.bginfo) do
		ent:SetBodygroup(k, v)
	end
	
	ent:Spawn()
	ent:Activate()
	
	return ent
end

local MINS, MAXS = Vector(-10, -10, 0), Vector(10, 10, 10)

function ENT:Initialize()
	-- self:SetModel(self.Model)
	self:PhysicsInit(SOLID_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(false)
	
	self.NextRespawn = 0
	self:SetIsSpawned(true)
	
	self.CurrentClip = 0
	
	if CLIENT then
		self:ClientsideEntity()
		self.CurrAngle = Angle()
		return
	end
end

function ENT:ClientsideEntity()
	if IsValid(self.CModel) then self.CModel:Remove() end
	local ent = ClientsideModel(self:GetModel())
	self.CModel = ent
	ent:SetPos(self:GetPos())
	ent:Spawn()
	ent:Activate()
	ent:SetNoDraw(true)
	
	if IsValid(self.CModel2) then self.CModel2:Remove() end
	
	local ent1 = ent
	local ent = ClientsideModel(self:GetModel())
	local ent2 = ent
	self.CModel2 = ent
	ent:SetPos(self:GetPos())
	ent:Spawn()
	ent:Activate()
	ent:SetNoDraw(true)
	
	local bg = self:GetBodyGroups()
	
	ent1:SetSkin(self:GetSkin() or 0)
	ent1:SetColor(self:GetColor())
	ent1:SetMaterial(self:GetMaterial() or '')
	
	ent2:SetSkin(self:GetSkin() or 0)
	ent2:SetColor(self:GetColor())
	ent2:SetMaterial(self:GetMaterial() or '')
	
	if bg then
		for k, v in pairs(bg) do
			ent1:SetBodygroup(v.id, self:GetBodygroup(v.id))
		end
		
		for k, v in pairs(bg) do
			ent2:SetBodygroup(v.id, self:GetBodygroup(v.id))
		end
	end
end

function ENT:DoSpawn(ply)
	if ply.EntSpawnerCooldown and ply.EntSpawnerCooldown > CurTime() then return false end
	local try = hook.Run('PlayerSpawnSENT', ply, self.CLASS)
	if try == false then return false end
	
	if not ply:CheckLimit('sents') then
		ply.EntSpawnerCooldown = CurTime() + 10
		return false
	end
	
	local sfunc = self.TABLE.SpawnFunction
	local ent
	local hpos = self:GetPos() + Vector(0, 0, 40)
	
	if sfunc then
		local fakeTrace = {
			Hit = true,
			HitPos = hpos,
			StartPos = hpos,
			EndPos = hpos,
			HitWorld = true,
			HitSky = false,
			PhysicsBone = 0,
			HitNoDraw = false,
			HitNonWorld = false,
			HitTexture = '',
			HitGroup = HITGROUP_GENERIC,
			MatType = MAT_GRASS, -- heh
			HitNormal = Vector(0, 0, 1),
			Entity = game.GetWorld()
		}
		
		ent = sfunc(self.TABLE, ply, fakeTrace, self.CLASS)
		if not ent then return end
	else
		ent = ents.Create(self.CLASS)
	end
	
	ent:SetPos(hpos)
	ent:Spawn()
	
	ent:PhysWake()
	
	hook.Run('PlayerSpawnedSENT', ply, ent)
	
	ent:Activate()
	
	DoPropSpawnedEffect(ent)
	
	self.LastEntity = ent
	self.LastPly = ply
	
	self.NextRespawn = CurTime() + RESET_TIMER:GetFloat()
	self:SetIsSpawned(false)
	
	undo.Create('SENT')
	undo.AddEntity(ent)
	undo.SetPlayer(ply)
	
	if ent.PrintName then
		undo.SetCustomUndoText('Undone ' .. ent.PrintName)
	end
	
	undo.Finish()
	
	return true
end

function ENT:BringBack()
	self:SetIsSpawned(true)
end

function ENT:Think()
	if CLIENT then return end
	
	if self:GetIsSpawned() then
		local lpos = self:GetPos()
		local dist = PICKUP_RANGE:GetInt()
		
		for k, v in ipairs(player.GetAll()) do
			if v:GetPos():Distance(lpos) > dist then continue end
			if self:DoSpawn(v) then break end
		end
	else
		if self.NextRespawn < CurTime() then
			self:BringBack()
		end
	end
end

local debugwtite = Material('models/debug/debugwhite')
local glow = Color(0, 255, 255)

function ENT:Draw()
	if not IsValid(self.CModel) then self:ClientsideEntity() end
	if not IsValid(self.CModel2) then self:ClientsideEntity() end
	
	local mdl = self:GetModel()
	self.CModel:SetModel(mdl)
	self.CModel2:SetModel(mdl)
	
	local ang = self.CurrAngle
	local pos = self:GetPos()
	
	ang.y = ang.y + FrameTime() * 33
	pos.z = pos.z + math.sin(CurTime() * 2) * 10 + 20
	
	ang:Normalize()
	
	self.CModel:SetAngles(ang)
	self.CModel2:SetAngles(ang)
	self.CModel:SetPos(pos)
	self.CModel2:SetPos(pos)
	
	if self:GetIsSpawned() then
		self.CModel:DrawModel()
		-- God how i hate this part
		-- GMod functions have documented the best
		self.CurrentClip = self.CurrentClip + FrameTime() * 33
		if self.CurrentClip > 150 then
			self.CurrentClip = -150
		end
		
		local Vec = ang:Forward()
		
		local First = pos + Vec * self.CurrentClip
		local Second = pos + Vec * self.CurrentClip + Vec * 5
		local dot1 = Vec:Dot(First)
		local dot2 = (-Vec):Dot(Second)
		
		render.SuppressEngineLighting(true)
		render.ModelMaterialOverride(debugwtite)
		render.SetColorModulation(0, 1, 1)
		render.ResetModelLighting(1, 1, 1)

		local old = render.EnableClipping(true)
		render.PushCustomClipPlane(Vec, dot1)
		render.PushCustomClipPlane(-Vec, dot2)
		
		self.CModel2:DrawModel()
		
		render.PopCustomClipPlane()
		render.PopCustomClipPlane()
		render.EnableClipping(old)
		
		render.SetColorModulation(1, 1, 1)
		render.ModelMaterialOverride()
		render.SuppressEngineLighting(false)
	end
	
	self.CurrAngle = ang
end

function ENT:OnRemove()
	if CLIENT and IsValid(self.CModel) then
		self.CModel:Remove()
	end
	
	if CLIENT and IsValid(self.CModel2) then
		self.CModel2:Remove()
	end
end

scripted_ents.Register(ENT, 'dbot_espawner_base')

local LIST = {}

function DSpawnPoints_CreateEntity(class, ENT2)
	if not class then return end
	local ENT = {}
	
	ENT.Base = 'dbot_espawner_base'
	ENT.Author = ENT2.Author or 'DBot'
	ENT.Category = ENT2.Category or 'Entity Spawners'
	ENT.Spawnable = ENT2.Spawnable
	ENT.AdminSpawnable = ENT2.AdminSpawnable
	ENT.AdminOnly = ENT2.AdminOnly
	ENT.CLASS = class
	ENT.TABLE = ENT2
	
	--Defining PrintName clientside only is dump thing
	ENT.PrintName = (ENT2.PrintName or class) .. ' Spawner'
	
	scripted_ents.Register(ENT, 'dbot_espawner_' .. class)
	
	if ENT.Spawnable then
		local data = {}
		data.Author = ENT.Author
		data.Category = ENT2.Category or 'Other' --Heh
		data.ClassName = 'dbot_espawner_' .. class
		data.PrintName = ENT2.PrintName or class
		data.EClass = class
		data.AdminOnly = ENT.AdminOnly
		
		LIST['dbot_espawner_' .. class] = data
	end
end

function DSpawnPoints_PopulateEntities()
	for k, v in pairs(scripted_ents.GetList()) do
		if v.t.ClassName:sub(1, 14) ~= 'dbot_wspawner_' and v.t.ClassName:sub(1, 14) ~= 'dbot_espawner_' then
			DSpawnPoints_CreateEntity(v.t.ClassName, v.t)
		end
	end
end

local HL2 = {}
HL2.Author = 'VALVe'
HL2.Category = 'Half-Life 2'
HL2.Spawnable = true
HL2.AdminSpawnable = true
HL2.AdminOnly = false

local function ADD_ITEM(name, class, model)
	local HL2 = table.Copy(HL2)
	HL2.PrintName = name
	HL2.WorldModel = model
	DSpawnPoints_CreateEntity(class, HL2)
end

-- Ammo
ADD_ITEM('AR2 Ammo', 'item_ammo_ar2')
ADD_ITEM('AR2 Ammo (Large)', 'item_ammo_ar2_large')

ADD_ITEM('Pistol Ammo', 'item_ammo_pistol')
ADD_ITEM('Pistol Ammo (Large)', 'item_ammo_pistol_large')

ADD_ITEM('357 Ammo', 'item_ammo_357')
ADD_ITEM('357 Ammo (Large)', 'item_ammo_357_large')

ADD_ITEM('SMG Ammo', 'item_ammo_smg1')
ADD_ITEM('SMG Ammo (Large)', 'item_ammo_smg1_large')

ADD_ITEM('SMG Grenade', 'item_ammo_smg1_grenade')
ADD_ITEM('Crossbow Bolts', 'item_ammo_crossbow')
ADD_ITEM('Shotgun Ammo', 'item_box_buckshot')
ADD_ITEM('AR2 Orb', 'item_ammo_ar2_altfire')
ADD_ITEM('RPG Rocket', 'item_rpg_round')

-- Items
ADD_ITEM('Suit Battery', 'item_battery')
ADD_ITEM('Health Kit', 'item_healthkit')
ADD_ITEM('Health Vial', 'item_healthvial')
ADD_ITEM('Suit Charger', 'item_suitcharger')
ADD_ITEM('Health Charger', 'item_healthcharger')
ADD_ITEM('Suit', 'item_suit')

ADD_ITEM('Thumper', 'prop_thumper')
ADD_ITEM('Combine Mine', 'combine_mine')
ADD_ITEM('Zombine Grenade', 'npc_grenade_frag')
ADD_ITEM('Helicopter Grenade', 'grenade_helicopter')

timer.Simple(0, DSpawnPoints_PopulateEntities)

if CLIENT then
	local function CreateMenu()
		local ctrl = vgui.Create('SpawnmenuContentPanel')
		ctrl:CallPopulateHook('PopulateEntitySpawnpoints')
		return ctrl
	end

	--Populate as usual
	local function PopulateMenu(canvas, tree, node)
		local Categorised = {}

		local SpawnableEntities = LIST
		for k, v in pairs(SpawnableEntities) do
			v.SpawnName = k
			v.Category = v.Category or 'Other'
			Categorised[v.Category] = Categorised[v.Category] or {}
			table.insert(Categorised[v.Category], v)
		end

		for CategoryName, v in SortedPairs(Categorised) do
			local node = tree:AddNode(CategoryName, 'icon16/bricks.png')

			node.DoPopulate = function(self)
				if self.PropPanel then return end
				
				self.PropPanel = vgui.Create('ContentContainer', canvas)
				self.PropPanel:SetVisible(false)
				self.PropPanel:SetTriggerSpawnlistChange(false)

				for k, ent in SortedPairsByMemberValue(v, 'PrintName') do
					spawnmenu.CreateContentIcon('entity', self.PropPanel, {
						nicename	= ent.PrintName or ent.ClassName,
						spawnname	= ent.SpawnName,
						material	= 'entities/' .. ent.EClass .. '.png',
						admin		= ent.AdminOnly
					})
				end
			end
			
			node.DoClick = function(self)
				self:DoPopulate()
				canvas:SwitchPanel(self.PropPanel)
			end
		end

		local FirstNode = tree:Root():GetChildNode(0)
		if IsValid(FirstNode) then
			FirstNode:InternalDoClick()
		end
	end
	
	hook.Add('PopulateEntitySpawnpoints', 'PopulateEntitySpawnpoints', PopulateMenu)
	spawnmenu.AddCreationTab('Entity Spawnpoints', CreateMenu, 'icon16/bricks.png', 40)
end
