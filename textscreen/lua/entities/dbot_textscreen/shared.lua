
-- Copyright (C) 2018-2019 DBot

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


ENT.Type = 'anim'
ENT.PrintName = 'Text Screen'
ENT.Author = 'DBot'
ENT.Spawnable = true
ENT.AdminSpawnable = true

local NORMAL_SIZE = 24
local sizeConst = NORMAL_SIZE + NORMAL_SIZE:lshift(8) + NORMAL_SIZE:lshift(16) + NORMAL_SIZE:lshift(24)

local SERVER = SERVER

function ENT:SetupDataTables()
	self:NetworkVar('Bool', 0, 'IsPersistent')
	self:NetworkVar('Bool', 1, 'AlwaysDraw')
	self:NetworkVar('Bool', 2, 'NeverDraw')
	self:NetworkVar('Bool', 3, 'IsMovable')
	self:NetworkVar('Bool', 4, 'DoubleDraw')

	for i = 0, 3 do
		self:NetworkVar('String', i, 'TextSlot' .. (i + 1))
		if SERVER then self['SetTextSlot' .. (i + 1)](self, '') end
	end

	self:NetworkVar('Int', 0, 'TextFontSlot1')
	self:NetworkVar('Int', 1, 'TextFontSlot2')
	self:NetworkVar('Int', 2, 'TextFontSlot3')
	self:NetworkVar('Int', 3, 'TextFontSlot4')

	for i = 1, 16 do
		self:NetworkVar('Int', 3 + i, 'TextColor' .. i)
		self:NetworkVar('Float', i, 'TextRotation' .. i)

		if SERVER then
			self['SetTextColor' .. i](self, 0xFFFFFFFF)
			self['SetTextRotation' .. i](self, 0)
		end
	end

	self:NetworkVar('Int', 20, 'TextSizeSlot1')
	self:NetworkVar('Int', 21, 'TextSizeSlot2')
	self:NetworkVar('Int', 22, 'TextSizeSlot3')
	self:NetworkVar('Int', 23, 'TextSizeSlot4')

	self:NetworkVar('Int', 24, 'TextAlignSlot1')
	self:NetworkVar('Int', 25, 'TextAlignSlot2')

	self:NetworkVar('Int', 26, 'TextShadowSlot')

	self:NetworkVar('Float', 0, 'OverallSize')

	if SERVER then
		self:SetTextFontSlot1(0)
		self:SetTextFontSlot2(0)
		self:SetTextFontSlot3(0)
		self:SetTextFontSlot4(0)

		self:SetTextSizeSlot1(sizeConst)
		self:SetTextSizeSlot2(sizeConst)
		self:SetTextSizeSlot3(sizeConst)
		self:SetTextSizeSlot4(sizeConst)

		self:SetTextAlignSlot1(0)
		self:SetTextAlignSlot2(0)

		self:SetTextShadowSlot(0)
		self:SetOverallSize(10)

		self:SetNeverDraw(false)
		self:SetAlwaysDraw(false)
		self:SetIsPersistent(false)
		self:SetIsMovable(false)
		self:SetDoubleDraw(true)

		self:NetworkVarNotify('IsMovable', self.UpdatePhysics)
	end
end

local cloneFuncs = {
	'TextAlignSlot1', 'TextAlignSlot2', 'TextShadowSlot', 'OverallSize',
	'IsMovable', 'NeverDraw', 'AlwaysDraw', 'DoubleDraw'
}

for i = 1, 4 do
	table.insert(cloneFuncs, 'TextSlot' .. i)
	table.insert(cloneFuncs, 'TextSizeSlot' .. i)
	table.insert(cloneFuncs, 'TextFontSlot' .. i)
end

for i = 1, 16 do
	table.insert(cloneFuncs, 'TextColor' .. i)
	table.insert(cloneFuncs, 'TextRotation' .. i)
end

function ENT:CloneInto(ent)
	for i, funcname in ipairs(cloneFuncs) do
		ent['Set' .. funcname](ent, self['Get' .. funcname](self))
	end
end

for i = 1, 16 do
	ENT['SetColor' .. i] = function(self, color)
		self['SetTextColor' .. i](self, color:ToNumber(true))
	end

	ENT['GetColor' .. i] = function(self)
		return ColorBE(self['GetTextColor' .. i](self), true)
	end

	ENT['SetTextColorEasy' .. i] = function(self, color)
		self['SetTextColor' .. i](self, color:ToNumber(true))
	end

	local textSlotPos = 1 + ((i - 1) / 4):floor()
	local textAlignPos = 1 + ((i - 1) / 8):floor()
	local perBit = 4 - i % 4
	local perBitAlign = 8 - i % 8
	local fontmask = (0xFF):lshift(perBit * 8):bnot()
	local alignMask = (0xF):lshift(perBitAlign * 4):bnot()

	ENT['SetTextSize' .. i] = function(self, newID)
		local oldID = self['GetTextSizeSlot' .. textSlotPos](self)
		self['SetTextSizeSlot' .. textSlotPos](self, oldID:band(fontmask):bor(newID:band(0xFF):lshift(perBit * 8)))
	end

	ENT['GetTextSize' .. i] = function(self)
		return self['GetTextSizeSlot' .. textSlotPos](self):rshift(perBit * 8):band(0xFF)
	end

	ENT['SetFontID' .. i] = function(self, newID)
		local oldID = self['GetTextFontSlot' .. textSlotPos](self)
		self['SetTextFontSlot' .. textSlotPos](self, oldID:band(fontmask):bor(newID:band(0xFF):lshift(perBit * 8)))
	end

	ENT['GetFontID' .. i] = function(self)
		return self['GetTextFontSlot' .. textSlotPos](self):rshift(perBit * 8):band(0xFF)
	end

	ENT['SetAlign' .. i] = function(self, newID)
		local oldID = self['GetTextAlignSlot' .. textAlignPos](self)
		self['SetTextAlignSlot' .. textAlignPos](self, oldID:band(alignMask):bor(newID:band(0xF):lshift(perBitAlign * 4)))
	end

	ENT['GetAlign' .. i] = function(self)
		return self['GetTextAlignSlot' .. textAlignPos](self):rshift(perBitAlign * 4):band(0xF)
	end

	ENT['GetShadow' .. i] = function(self)
		return self:GetTextShadowSlot():rshift(i - 1):band(1) == 1
	end

	ENT['SetShadow' .. i] = function(self, status)
		local oldMask = self:GetTextShadowSlot()

		if status then
			self:SetTextShadowSlot(oldMask:bor((1):lshift(i - 1)))
		else
			self:SetTextShadowSlot(oldMask:band((1):lshift(i - 1):bnot()))
		end
	end
end

function ENT:Initialize()
	self:SetModel('models/props_phx/construct/metal_plate1x2.mdl')

	if SERVER then
		self:InitializeSV()
	else
		self:InitializeCL()
	end

	self:DrawShadow(false)
end
