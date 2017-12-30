
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

local ENT = {}
ENT.Type = 'anim'
ENT.Author = 'DBot'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PrintName = 'Dropped Weapons Crate'

function ENT:SetupDataTables()
	self:NetworkVar('Float', 0, 'HP')
	self:NetworkVar('Float', 1, 'MaxHP')
end

function ENT:Initialize()
	self:SetModel('models/Items/item_item_crate.mdl')
	if CLIENT then return end

	self.Contents = self.Contents or {}
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:PhysWake()

	if not self:GetHP() then
		self:SetHP(50)
		self:SetMaxHP(50)
	end
end

function ENT:AddGun(class)
	self.Contents[class] = self.Contents[class] or {}

	local w = self.Contents[class]
	w.Clip1 = w.Clip1 or 0
	w.Clip2 = w.Clip2 or 0

	w.Ammo1 = w.Ammo1 or 0
	w.Ammo2 = w.Ammo2 or 0
	w.AmmoID1 = w.AmmoID1 or ''
	w.AmmoID2 = w.AmmoID2 or ''

	w.Model = w.Model or ''

	return w
end

function ENT:ReleaseContents()
	local lpos = self:GetPos()
	local lang = self:GetAngles()
	local up = Vector(0, 0, 1)

	local spawnpos = lpos + up * 30
	for class, data in pairs(self.Contents) do
		 local weapon = ents.Create('spawned_weapon')
		 weapon:SetWeaponClass(class)
		 weapon:SetModel(data.Model)

		 weapon.clip1 = data.Clip1
		 weapon.clip2 = data.Clip2
		 weapon.nodupe = true

		 weapon.ammoadd = data.Ammo1

		 weapon:SetPos(spawnpos)
		 weapon:Spawn()
		 weapon:Activate()

		 local phys = weapon:GetPhysicsObject()

		 if IsValid(phys) then
			phys:Sleep()
		 end

		 spawnpos = spawnpos + up * 10
	end

	SafeRemoveEntity(self)
end

function ENT:OnTakeDamage(dmg)
	local hp = self:GetHP()

	hp = hp - dmg:GetDamage()

	if hp <= 0 then
		self:ReleaseContents()
	end

	self:SetHP(hp)
end

function ENT:Use(ply)
	if ply:GetPos():Distance(self:GetPos()) > 150 then return end -- uh uh, wire user
	self:ReleaseContents()
end

scripted_ents.Register(ENT, 'dbot_wcrate')

timer.Simple(0, function()
	DarkRP.declareChatCommand{
		command = 'dropweapons',
		description = 'Drops all weapons that you can drop',
		delay = 1.5
	}
end)
