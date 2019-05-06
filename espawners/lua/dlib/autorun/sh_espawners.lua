
--[[
Copyright (C) 2016-2019 DBotThePony


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

]]

local LIST = {}

function DSpawnPoints_CreateEntity(class, ENT2)
	if not class then return end
	local ENT = {}

	ENT.Base = 'dlib_espawner'
	ENT.Author = ENT2.Author or 'DBot'
	ENT.Category = ENT2.Category or 'Entity Spawners'
	ENT.Spawnable = ENT2.Spawnable
	ENT.AdminSpawnable = ENT2.AdminSpawnable
	ENT.AdminOnly = ENT2.AdminOnly
	ENT.CLASS = class
	ENT.TABLE = ENT2

	ENT.PrintName = (ENT2.PrintName or class) .. ' Spawner'

	scripted_ents.Register(ENT, 'dbot_es_' .. class)

	if ENT.Spawnable then
		local data = {}
		data.Author = ENT.Author
		data.Category = ENT2.Category or 'Other'
		data.ClassName = 'dbot_es_' .. class
		data.PrintName = ENT2.PrintName or class
		data.EClass = class
		data.AdminOnly = ENT.AdminOnly

		LIST['dbot_es_' .. class] = data
	end
end

local _, message = DLib.CMessage({}, 'EntitySpawnpoints')

function DSpawnPoints_PopulateEntities()
	message.Message('Generating entity spawnpoints...')

	local time = SysTime()
	for k, v in pairs(scripted_ents.GetList()) do
		if not v.t.IS_SPAWNER and not v.t.ClassName:find('spawner') and not v.t.ClassName:StartWith('dbot_es_') and v.t.Spawnable then
			DSpawnPoints_CreateEntity(v.t.ClassName, v.t)
		end
	end

	message.Message('Generating spawnpoints took ', string.format('%.3f ms', (SysTime() - time) * 1000))
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
