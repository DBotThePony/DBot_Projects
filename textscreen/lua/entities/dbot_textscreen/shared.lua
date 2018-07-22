
-- Copyright (C) 2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

ENT.Type = 'anim'
ENT.PrintName = 'Text Screen'
ENT.Author = 'DBot'
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self:NetworkVar('Bool', 0, 'IsPersistent')
	self:NetworkVar('Bool', 1, 'AlwaysDraw')
	self:NetworkVar('Bool', 2, 'NeverDraw')
	self:NetworkVar('Bool', 3, 'IsMovable')

	for i = 0, 3 do
		self:NetworkVar('String', i, 'TextSlot' .. (i + 1))
		self['SetTextSlot' .. (i + 1)](self, '')
	end

	self:NetworkVar('Int', 0, 'TextFontSlot1')
	self:NetworkVar('Int', 1, 'TextFontSlot2')
	self:NetworkVar('Int', 2, 'TextFontSlot3')
	self:NetworkVar('Int', 3, 'TextFontSlot4')

	for i = 0, 15 do
		self:NetworkVar('Int', 4 + i, 'TextColor' .. (i + 1))
		self['SetTextColor' .. (i + 1)](self, 0xFFFFFFFF)
	end

	self:NetworkVar('Int', 20, 'TextSizeSlot1')
	self:NetworkVar('Int', 21, 'TextSizeSlot2')
	self:NetworkVar('Int', 22, 'TextSizeSlot3')
	self:NetworkVar('Int', 23, 'TextSizeSlot4')

	self:NetworkVar('Int', 24, 'TextAlignSlot1')
	self:NetworkVar('Int', 25, 'TextAlignSlot2')

	self:SetTextFontSlot1(0)
	self:SetTextFontSlot2(0)
	self:SetTextFontSlot3(0)
	self:SetTextFontSlot4(0)

	self:SetTextSizeSlot1(0)
	self:SetTextSizeSlot2(0)
	self:SetTextSizeSlot3(0)
	self:SetTextSizeSlot4(0)

	self:SetTextAlignSlot1(0)
	self:SetTextAlignSlot2(0)

	self:SetNeverDraw(false)
	self:SetAlwaysDraw(false)
	self:SetIsPersistent(false)
	self:SetIsMovable(false)

	if SERVER then
		self:NetworkVarNotify('IsMovable', self.UpdatePhysics)
	end
end

function ENT:Initialize()
	self:SetModel('models/props_phx/construct/metal_plate1x2.mdl')
	
	if SERVER then
		self:InitializeSV()
	else
		self:InitializeCL()
	end
end

