
--[[
Copyright (C) 2016-2018 DBot


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
