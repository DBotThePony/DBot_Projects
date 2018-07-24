
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

include('shared.lua')

local LocalPlayer = LocalPlayer
local util = util
local table = table
local ColorBE = ColorBE
local CRC = util.CRC

local surface = surface
local LocalToWorld = LocalToWorld
local Vector = Vector
local cam = cam

ENT.RenderGroup = RENDERGROUP_BOTH

local NORMAL_SIZE = 24

local debugprint = print:Compose(debug.traceback)
local emptyAng = Angle(0, 90, 0)

function ENT:DrawLines(pos, ang)
	for i, lineData in ipairs(self.Lines) do
		for i2, line in ipairs(lineData.draw) do
			local lineStuff = lineData.data[i2]

			local xInCanvas = -self.TotalHeight / 2 + line.y
			local yInCanvas = -self.TotalWidth / 2 + line.x

			local posInCanvas = Vector(xInCanvas, yInCanvas, 20) * 0.25
			local lpos, lang = LocalToWorld(posInCanvas, emptyAng, pos, ang)

			cam.Start3D2D(lpos, lang, lineStuff.mult * 0.25)
			surface.SetFont(lineStuff.font)
			surface.SetTextColor(lineStuff.color)

			surface.SetTextPos(0, 0)
			surface.DrawText(lineStuff.text)
			cam.End3D2D()
		end
	end
end

function ENT:DrawTranslucent()
	if not self.Lines then return end

	local pos, ang = self:GetPos(), self:GetAngles()

	self:DrawLines(pos, ang)

	if self:GetDoubleDraw() then
		ang:RotateAroundAxis(ang:Right(), 180)
		ang:RotateAroundAxis(ang:Up(), 180)
		self:DrawLines(pos, ang)
	end
end

function ENT:Draw()
	if self.ShouldDrawWorldModel then
		self:DrawModel()
	end
end

function ENT:HashsumState()
	local sum

	sum = CRC(self:GetTextSlot1()):tonumber()
	sum = (sum + CRC(self:GetTextSlot2()):tonumber()) % 0x7FFFFFFF
	sum = (sum + CRC(self:GetTextSlot3()):tonumber()) % 0x7FFFFFFF
	sum = (sum + CRC(self:GetTextSlot4()):tonumber()) % 0x7FFFFFFF

	sum = (sum + self:GetTextFontSlot1()) % 0x7FFFFFFF
	sum = (sum + self:GetTextFontSlot2()) % 0x7FFFFFFF
	sum = (sum + self:GetTextFontSlot3()) % 0x7FFFFFFF
	sum = (sum + self:GetTextFontSlot4()) % 0x7FFFFFFF

	sum = (sum + self:GetTextSizeSlot1()) % 0x7FFFFFFF
	sum = (sum + self:GetTextSizeSlot2()) % 0x7FFFFFFF
	sum = (sum + self:GetTextSizeSlot3()) % 0x7FFFFFFF
	sum = (sum + self:GetTextSizeSlot4()) % 0x7FFFFFFF

	for i = 1, 16 do
		sum = (sum + self['GetTextColor' .. i](self)) % 0x7FFFFFFF
	end

	return sum
end

function ENT:CheckForChanges()
	local sum = self:HashsumState()

	if sum ~= self.LastState then
		self:ParseNWValues()
		self.LastState = sum
		return true, sum
	end

	return false, sum
end

local function fonts(int)
	return int:rshift(24):band(255), int:rshift(16):band(255), int:rshift(8):band(255), int:band(255)
end

local function alignInt(int)
	return
		int:rshift(28):band(15),
		int:rshift(24):band(15),
		int:rshift(20):band(15),
		int:rshift(16):band(15),
		int:rshift(12):band(15),
		int:rshift(8):band(15),
		int:rshift(4):band(15),
		int:band(15)
end

function ENT:ParseNWValues()
	local textraw = self:GetTextSlot1() .. self:GetTextSlot2() .. self:GetTextSlot3() .. self:GetTextSlot4()
	local text = textraw:split('\n')
	local font = {}
	local color = {}
	local size = {}
	local align = {alignInt(self:GetTextAlignSlot1())}

	table.append(align, {alignInt(self:GetTextAlignSlot2())})

	for i = 1, 4 do
		local a, b, c, d = fonts(self['GetTextFontSlot' .. i](self))
		table.insert(font, TEXT_SCREEN_AVALIABLE_FONTS[a + 1] or TEXT_SCREEN_AVALIABLE_FONTS[1])
		table.insert(font, TEXT_SCREEN_AVALIABLE_FONTS[b + 1] or TEXT_SCREEN_AVALIABLE_FONTS[1])
		table.insert(font, TEXT_SCREEN_AVALIABLE_FONTS[c + 1] or TEXT_SCREEN_AVALIABLE_FONTS[1])
		table.insert(font, TEXT_SCREEN_AVALIABLE_FONTS[d + 1] or TEXT_SCREEN_AVALIABLE_FONTS[1])
	end

	for i = 1, 4 do
		local a, b, c, d = fonts(self['GetTextSizeSlot' .. i](self))
		table.insert(size, a:clamp(12, 128))
		table.insert(size, b:clamp(12, 128))
		table.insert(size, c:clamp(12, 128))
		table.insert(size, d:clamp(12, 128))
	end

	for i = 1, 16 do
		table.insert(color, ColorBE(self['GetTextColor' .. i](self), true))
	end

	self.Lines = {}
	local lines = 0

	for i = 1, math.min(#text, 16) do
		local separated = text[i]:split('\2')

		local lineTable = {
			data = {},
			draw = {}
		}

		for i2, str in ipairs(separated) do
			if lines == 16 then break end
			local line = lines + 1
			lines = lines + 1

			local data = {
				text = str,
				font = font[line].id,
				color = color[line],
				size = size[line],
				mult = (size[line] / NORMAL_SIZE) * (font[line].mult or 1),
				alignFlags = align[line],

				align = {
					left = align[line]:band(TEXT_SCREEN_ALIGN_LEFT) == TEXT_SCREEN_ALIGN_LEFT,
					right = align[line]:band(TEXT_SCREEN_ALIGN_RIGHT) == TEXT_SCREEN_ALIGN_RIGHT,
					top = align[line]:band(TEXT_SCREEN_ALIGN_TOP) == TEXT_SCREEN_ALIGN_TOP,
					bottom = align[line]:band(TEXT_SCREEN_ALIGN_BOTTOM) == TEXT_SCREEN_ALIGN_BOTTOM,
				}
			}

			data.align.centerHr = not data.align.left and not data.align.right
			data.align.centerVr = not data.align.top and not data.align.bottom

			table.insert(lineTable.data, data)
		end

		lineTable.alignFlags = lineTable.data[1].alignFlags
		lineTable.align = lineTable.data[1].align

		table.insert(self.Lines, lineTable)

		if lines == 16 then break end
	end

	self.TotalWidth = 0
	self.TotalHeight = 0

	for line, lineData in ipairs(self.Lines) do
		local drawdata = lineData.draw
		local lW, lH = 0, 0

		-- pass one - determine line bounds
		for i, data in ipairs(lineData.data) do
			surface.SetFont(data.font)
			local w, h = surface.GetTextSize(data.text .. ' ')

			lW = lW + w * data.mult
			lH = lH:max(h * data.mult)
		end

		self.TotalWidth = self.TotalWidth:max(lW)
		self.TotalHeight = self.TotalHeight + lH

		-- pass two - determine in line positions
		for i, data in ipairs(lineData.data) do
			surface.SetFont(data.font)
			local w, h = surface.GetTextSize(data.text)
			local w2, h2 = surface.GetTextSize(' ')
			w, h = w * data.mult, h * data.mult
			w2, h2 = w2 * data.mult, h2 * data.mult

			local delta = lH - h
			local ypos = delta / 2

			if lineData.align.top then
				ypos = 0
			elseif lineData.align.bottom then
				ypos = delta
			end

			drawdata[i] = {
				w = w,
				h = h,
				spacing = w2,
				str = data.text,
				x = 0,
				y = ypos
			}
		end

		lineData.lW = lW
		lineData.lH = lH
	end

	-- phase three - align all lines at Y
	local totalY = 0

	for line, lineData in ipairs(self.Lines) do
		local drawdata = lineData.draw
		local lW, lH = lineData.lW, lineData.lH

		local currentX = 0

		-- phase four - determine starting X and align all strings in line
		if lineData.align.right then
			currentX = self.TotalWidth - lW
		elseif not lineData.align.left then
			currentX = self.TotalWidth / 2 - lW / 2
		end

		for i, data in ipairs(lineData.data) do
			drawdata[i].x = currentX
			drawdata[i].y = drawdata[i].y + totalY
			currentX = currentX + drawdata[i].w + drawdata[i].spacing
		end

		totalY = totalY + lH * 1.05
	end
end

function ENT:InitializeCL()
	self.ShouldDrawWorldModel = false
	self:CheckForChanges()
end

function ENT:Think()
	self:CheckForChanges()
	self:SetNextClientThink(CurTimeL() + 1)

	local ply = DLib.HUDCommons.SelectPlayer()

	if IsValid(ply) then
		self.ShouldDrawWorldModel = self:GetAlwaysDraw() or
			not self:GetNeverDraw() and
			(ply:GetActiveWeaponClass() == 'weapon_physgun' or ply:GetActiveWeaponClass() == 'gmod_tool')

	end

	return true
end
