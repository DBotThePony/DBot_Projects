
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

local LIST = {}

local PICKUP_RANGE = CreateConVar('sv_dspawner_range', '80', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Weapon spawner pickup range in Hu')
local RESET_TIMER = CreateConVar('sv_dspawner_timer', '10', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Weapon spawner reset timer in seconds')

local ENT = {}
ENT.Type = 'anim'
ENT.Author = 'DBot'
ENT.PrintName = 'Weapon Spawner Base'
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar('String', 0, 'SWEPClass')
	self:NetworkVar('Bool', 0, 'IsSpawned')
end

function ENT:SpawnFunction(ply, tr, class)
	if not tr.Hit then return end
	
	local can = hook.Run('PlayerSpawnSWEP', ply, self.CLASS, self.TABLE)
	if can == false then return end
	
	local ent = ents.Create(class)
	ent:SetPos(tr.HitPos + tr.HitNormal)
	ent:Spawn()
	ent:Activate()
	
	return ent
end

local MINS, MAXS = Vector(-10, -10, 0), Vector(10, 10, 10)

function ENT:Initialize()
	self:SetModel(self.Model)
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
	local ent = ClientsideModel(self.Model)
	self.CModel = ent
	ent:SetPos(self:GetPos())
	ent:Spawn()
	ent:Activate()
	ent:SetNoDraw(true)
	
	if IsValid(self.CModel2) then self.CModel2:Remove() end
	local ent = ClientsideModel(self.Model)
	self.CModel2 = ent
	ent:SetPos(self:GetPos())
	ent:Spawn()
	ent:Activate()
	ent:SetNoDraw(true)
end

function ENT:Pickup(ply)
	if IsValid(self.LastGun) and not IsValid(self.LastGun:GetOwner()) then return end
	--Spawn entity on player, so PlayerCanPickupWeapon is getting called
	local ent = ents.Create(self.CLASS)
	ent:SetPos(ply:EyePos())
	ent:Spawn()
	
	self.LastGun = ent
	self.LastPly = ply
	
	self.NextRespawn = CurTime() + RESET_TIMER:GetFloat()
	self:SetIsSpawned(false)
end

function ENT:BringBack()
	self:SetIsSpawned(true)
end

function ENT:Think()
	if CLIENT then return end
	
	if self:GetIsSpawned() then
		local lpos = self:GetPos()
		local dist = PICKUP_RANGE:GetInt()
		
		for k, v in pairs(player.GetAll()) do
			if v:GetPos():Distance(lpos) > dist then continue end
			self:Pickup(v)
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
		--God how i hate this part
		--GMod functions have documented the best
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

scripted_ents.Register(ENT, 'dbot_wspawner_base')

function DSpawnPoints_Create(class, SWEP)
	local ENT = {}
	
	ENT.Base = 'dbot_wspawner_base'
	ENT.Author = SWEP.Author or 'DBot'
	ENT.Category = SWEP.Category or 'WSpawners'
	ENT.Spawnable = SWEP.Spawnable
	ENT.AdminSpawnable = SWEP.AdminSpawnable
	ENT.AdminOnly = SWEP.AdminOnly
	ENT.CLASS = class
	ENT.Model = SWEP.WorldModel ~= '' and SWEP.WorldModel or 'models/items/item_item_crate.mdl'
	ENT.TABLE = SWEP
	
	--Defining PrintName clientside only is dump thing
	ENT.PrintName = (SWEP.PrintName or class) .. ' Spawner'
	
	scripted_ents.Register(ENT, 'dbot_wspawner_' .. class)
	
	if ENT.Spawnable then
		local data = {}
		data.Author = ENT.Author
		data.Category = SWEP.Category or 'Other' --Heh
		data.ClassName = 'dbot_wspawner_' .. class
		data.PrintName = SWEP.PrintName or class
		data.WPClass = class
		data.AdminOnly = ENT.AdminOnly
		
		LIST['dbot_wspawner_' .. class] = data
	end
end

function DSpawnPoints_Populate()
	for k, v in pairs(weapons.GetList()) do
		DSpawnPoints_Create(v.ClassName, v)
	end
end

local HL2 = {}
HL2.Author = 'VALVe'
HL2.Category = 'Half-Life 2'
HL2.Spawnable = true
HL2.AdminSpawnable = true
HL2.AdminOnly = false

--Add weapons as it added in game_hl2.lua
local function ADD_WEAPON(name, class, model)
	local HL2 = table.Copy(HL2)
	HL2.PrintName = name
	HL2.WorldModel = model
	DSpawnPoints_Create(class, HL2)
end

ADD_WEAPON('357', 'weapon_357', 'models/weapons/w_357.mdl')
ADD_WEAPON('AR2', 'weapon_ar2', 'models/weapons/w_irifle.mdl')
ADD_WEAPON('Bug Bait', 'weapon_bugbait', 'models/weapons/w_bugbait.mdl')
ADD_WEAPON('Crossbow', 'weapon_crossbow', 'models/weapons/w_crossbow.mdl')
ADD_WEAPON('Crowbar', 'weapon_crowbar', 'models/weapons/w_crowbar.mdl')
ADD_WEAPON('Gravity Gun', 'weapon_physcannon', 'models/weapons/w_physics.mdl')
ADD_WEAPON('Frag Grenade', 'weapon_frag', 'models/weapons/w_grenade.mdl')
ADD_WEAPON('Pistol', 'weapon_pistol', 'models/weapons/w_pistol.mdl')
ADD_WEAPON('RPG Launcher', 'weapon_rpg', 'models/weapons/w_rocket_launcher.mdl')
ADD_WEAPON('Shotgun', 'weapon_shotgun', 'models/weapons/w_shotgun.mdl')
ADD_WEAPON('SLAM', 'weapon_slam')
ADD_WEAPON('SMG', 'weapon_smg1', 'models/weapons/w_smg1.mdl')
ADD_WEAPON('Stunstick', 'weapon_stunstick', 'models/weapons/w_stunbaton.mdl')

timer.Simple(0, DSpawnPoints_Populate)

local function CreateMenu()
	local ctrl = vgui.Create('SpawnmenuContentPanel')
	ctrl:CallPopulateHook('PopulateWeaponsSpawnpoints')
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
		local node = tree:AddNode(CategoryName, 'icon16/gun.png')

		node.DoPopulate = function(self)
			if self.PropPanel then return end
			
			self.PropPanel = vgui.Create('ContentContainer', canvas)
			self.PropPanel:SetVisible(false)
			self.PropPanel:SetTriggerSpawnlistChange(false)

			for k, ent in SortedPairsByMemberValue(v, 'PrintName') do
				spawnmenu.CreateContentIcon('entity', self.PropPanel, {
					nicename	= ent.PrintName or ent.ClassName,
					spawnname	= ent.SpawnName,
					material	= 'entities/' .. ent.WPClass .. '.png',
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

if CLIENT then
	hook.Add('PopulateWeaponsSpawnpoints', 'PopulateWeaponsSpawnpoints', PopulateMenu)
	spawnmenu.AddCreationTab('Weapons Spawnpoints', CreateMenu, 'icon16/gun.png', 10)
end
