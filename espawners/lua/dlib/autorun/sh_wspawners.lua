
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

local LIST = {}

function DSpawnPoints_Create(class, SWEP)
	if not class then return end
	local ENT = {}

	ENT.Base = 'dlib_wspawner'
	ENT.Author = SWEP.Author or 'DBot'
	ENT.Category = SWEP.Category or 'WSpawners'
	ENT.Spawnable = SWEP.Spawnable
	ENT.AdminSpawnable = SWEP.AdminSpawnable
	ENT.AdminOnly = SWEP.AdminOnly
	ENT.CLASS = class
	ENT.DefaultModel = SWEP.WorldModel ~= '' and SWEP.WorldModel or 'models/items/item_item_crate.mdl'
	ENT.TABLE = SWEP

	--Defining PrintName clientside only is dump thing
	ENT.PrintName = (SWEP.PrintName or class) .. ' Spawner'

	scripted_ents.Register(ENT, 'dbot_es_' .. class)

	if ENT.Spawnable then
		local data = {}
		data.Author = ENT.Author
		data.Category = SWEP.Category or 'Other' --Heh
		data.ClassName = 'dbot_es_' .. class
		data.PrintName = SWEP.PrintName or class
		data.WPClass = class
		data.AdminOnly = ENT.AdminOnly

		LIST['dbot_es_' .. class] = data
	end
end

local _, message = DLib.CMessage({}, 'WeaponSpawnpoints')

function DSpawnPoints_Populate()
	message.Message('Generating weapon spawnpoints...')

	local time = SysTime()
	for k, v in pairs(weapons.GetList()) do
		if v.ClassName and v.Spawnable then
			DSpawnPoints_Create(v.ClassName, v)
		end
	end

	message.Message('Generating spawnpoints took ', string.format('%.2f ms', (SysTime() - time) * 1000))
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

if CLIENT then
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

	hook.Add('PopulateWeaponsSpawnpoints', 'PopulateWeaponsSpawnpoints', PopulateMenu)
	spawnmenu.AddCreationTab('Weapons Spawnpoints', CreateMenu, 'icon16/gun.png', 40)
end
