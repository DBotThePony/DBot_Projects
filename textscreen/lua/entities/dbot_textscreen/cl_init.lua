
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

			if lineStuff.shadow then
				local lpos, lang = LocalToWorld(line.posInCanvasShadow, line.ang, pos, ang)

				cam.Start3D2D(lpos, lang, lineStuff.mult * 0.25)

				surface.SetFont(lineStuff.font)
				surface.SetTextColor(lineStuff.shadowColor)

				surface.SetTextPos(0, 0)
				surface.DrawText(lineStuff.text)
				cam.End3D2D()
			end

			local lpos, lang = LocalToWorld(line.posInCanvas, line.ang, pos, ang)
			local lpos2, lang2 = LocalToWorld(line.posInCanvas, emptyAng, pos, ang)

			--[[cam.Start3D2D(lpos2, lang2, lineStuff.mult * 0.25)

			draw.NoTexture()

			surface.SetDrawColor(100, 255, 255)
			surface.DrawPoly({
				{x = line.posInCanvas.x, y = line.posInCanvas.y},
				{x = line.posInCanvas.x + line.wc, y = line.posInCanvas.y},
				{x = line.posInCanvas.x + line.wc, y = line.posInCanvas.y + line.hc},
				{x = line.posInCanvas.x, y = line.posInCanvas.y + line.hc},
			})

			surface.SetDrawColor(255, 255, 255)
			surface.DrawPoly({
				{x = line.posInCanvas.x, y = line.posInCanvas.y},
				{x = line.posInCanvas.x + line.w, y = line.posInCanvas.y},
				{x = line.posInCanvas.x + line.w, y = line.posInCanvas.y + line.h},
				{x = line.posInCanvas.x, y = line.posInCanvas.y + line.h},
			})

			cam.End3D2D()]]

			cam.Start3D2D(lpos, lang, lineStuff.mult * 0.25)

			--[[surface.SetDrawColor(100, 100, 255)
			surface.DrawPoly({
				{x = line.posInCanvas.x, y = line.posInCanvas.y},
				{x = line.posInCanvas.x + line.wc, y = line.posInCanvas.y},
				{x = line.posInCanvas.x + line.wc, y = line.posInCanvas.y + line.hc},
				{x = line.posInCanvas.x, y = line.posInCanvas.y + line.hc},
			})]]

			surface.SetFont(lineStuff.font)
			surface.SetTextColor(lineStuff.color)

			surface.SetTextPos(0, 0)
			surface.DrawText(lineStuff.text)

			--[[surface.DrawPoly({
				{x = line.posInCanvas.x, y = line.posInCanvas.y},
				{x = line.posInCanvas.x + line.w, y = line.posInCanvas.y},
				{x = line.posInCanvas.x + line.w, y = line.posInCanvas.y + line.h},
				{x = line.posInCanvas.x, y = line.posInCanvas.y + line.h},
			})]]



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

	sum = (sum + self:GetTextAlignSlot1()) % 0x7FFFFFFF
	sum = (sum + self:GetTextAlignSlot2()) % 0x7FFFFFFF

	sum = (sum + self:GetTextShadowSlot()) % 0x7FFFFFFF
	sum = (sum + self:GetOverallSize()) % 0x7FFFFFFF

	for i = 1, 16 do
		sum = (sum + self['GetTextColor' .. i](self)) % 0x7FFFFFFF
		sum = (sum + self['GetTextRotation' .. i](self)) % 0x7FFFFFFF
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

local function determineNewBoundaries(rad, w, h)
	local x1, y1 = -w / 2, h / 2
	local x2, y2 = w / 2, h / 2
	local x3, y3 = w / 2, -h / 2
	local x4, y4 = -w / 2, -h / 2
	local sin, cos = rad:sin(), rad:cos()

	x1, y1 =
		x1 * cos - y1 * sin,
		x1 * sin + y1 * cos

	x2, y2 =
		x2 * cos - y2 * sin,
		x2 * sin + y2 * cos

	x3, y3 =
		x3 * cos - y3 * sin,
		x3 * sin + y3 * cos

	x4, y4 =
		x4 * cos - y4 * sin,
		x4 * sin + y4 * cos

	local xs = {x1, x2, x3, x4}
	local ys = {y1, y2, y3, y4}
	local lenX, lenY = 0, 0

	for i, one in ipairs(xs) do
		for i2, two in ipairs(xs) do
			lenX = lenX:max((one - two):abs())
		end
	end

	for i, one in ipairs(ys) do
		for i2, two in ipairs(ys) do
			lenY = lenY:max((one - two):abs())
		end
	end

	return lenX, lenY
end

function ENT:ParseNWValues()
	local textraw = self:GetTextSlot1() .. self:GetTextSlot2() .. self:GetTextSlot3() .. self:GetTextSlot4()
	local text = textraw:split('\n')
	local font = {}
	local color = {}
	local size = {}
	local shadow = {}
	local rotate = {}
	local align = {alignInt(self:GetTextAlignSlot1())}
	local overall = self:GetOverallSize() / 10

	table.append(align, {alignInt(self:GetTextAlignSlot2())})

	for i = 1, 4 do
		local a, b, c, d = fonts(self['GetTextFontSlot' .. i](self))
		table.insert(font, DTextScreens.FONTS[a + 1] or DTextScreens.FONTS[1])
		table.insert(font, DTextScreens.FONTS[b + 1] or DTextScreens.FONTS[1])
		table.insert(font, DTextScreens.FONTS[c + 1] or DTextScreens.FONTS[1])
		table.insert(font, DTextScreens.FONTS[d + 1] or DTextScreens.FONTS[1])
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
		table.insert(shadow, self['GetShadow' .. i](self))
		table.insert(rotate, self['GetTextRotation' .. i](self))
	end

	self.Lines = {}
	local lines = 0

	for i = 1, math.min(#text, 16) do
		local separated = text[i]:split('\2')

		local lineTable = {
			data = {},
			draw = {},
			w = 0,
			h = 0
		}

		for i2, str in ipairs(separated) do
			if lines == 16 then break end
			local line = lines + 1
			lines = lines + 1

			local data = {
				text = str,
				font = font[line].id,
				rotate = rotate[line],
				--rotate = 0,
				rad = rotate[line]:rad(),
				--rad = 0,
				color = color[line],
				size = size[line],
				mult = (size[line] / NORMAL_SIZE) * (font[line].mult or 1) * overall,
				alignFlags = align[line],
				shadow = shadow[line],
				shadowColor = Color(0, 0, 0, color[line].a),

				align = {
					left = align[line]:band(DTextScreens.ALIGN_LEFT) == DTextScreens.ALIGN_LEFT,
					right = align[line]:band(DTextScreens.ALIGN_RIGHT) == DTextScreens.ALIGN_RIGHT,
					top = align[line]:band(DTextScreens.ALIGN_TOP) == DTextScreens.ALIGN_TOP,
					bottom = align[line]:band(DTextScreens.ALIGN_BOTTOM) == DTextScreens.ALIGN_BOTTOM,
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
			local w, h = surface.GetTextSize(data.text)
			w, h = determineNewBoundaries(data.rad, w, h)

			lW = lW + w * data.mult
			lH = lH:max(h * data.mult)
		end

		lineData.w = lW
		lineData.h = lH

		self.TotalWidth = self.TotalWidth:max(lW)
		self.TotalHeight = self.TotalHeight + lH

		-- pass two - determine in line positions
		for i, data in ipairs(lineData.data) do
			surface.SetFont(data.font)
			local w, h = surface.GetTextSize(data.text)
			local w2, h2 = surface.GetTextSize(' ')
			w, h = w * data.mult, h * data.mult
			w2, h2 = w2 * data.mult, h2 * data.mult

			local wc, hc = w, h
			local w2c, h2c = w2, h2

			w, h = determineNewBoundaries(data.rad, w, h)
			w2, h2 = determineNewBoundaries(data.rad, w2, h2)

			local sin, cos = data.rad:sin(), data.rad:cos()

			local rotateX, rotateY = -wc / 2, hc / 2
			local rotateX2, rotateY2 = -wc / 2, hc / 2

			rotateX = rotateX * cos - rotateY * sin
			rotateY = rotateX * sin + rotateY * cos

			rotateX = rotateX - rotateX2
			rotateY = rotateY - rotateY2

			local delta = lH - hc
			local ypos = delta / 2

			if data.align.top then
				ypos = 0
			elseif data.align.bottom then
				ypos = delta
			end

			drawdata[i] = {
				w = w,
				h = h,
				wc = wc,
				hc = hc,
				w2c = w2c,
				h2c = h2c,
				spacing = w2,
				str = data.text,
				x = rotateX,
				xShadow = w2 * 0.1 * cos - h2 * 0.15 * sin + rotateX,
				y = ypos + rotateY,
				yShadow = ypos + h2 * 0.03 * cos + w2 * 0.05 * sin + rotateY
			}
		end
	end

	-- phase three - align all lines at Y
	local totalY = 0

	for line, lineData in ipairs(self.Lines) do
		local drawdata = lineData.draw
		local lW, lH = lineData.w, lineData.h

		local currentX = 0

		-- phase four - determine starting X and align all strings in line
		if lineData.align.right then
			currentX = self.TotalWidth - lW
		elseif not lineData.align.left then
			currentX = self.TotalWidth / 2 - lW / 2
		end

		for i, data in ipairs(lineData.data) do
			drawdata[i].x = drawdata[i].x + currentX
			drawdata[i].xShadow = currentX + drawdata[i].xShadow
			drawdata[i].y = drawdata[i].y + totalY
			drawdata[i].yShadow = drawdata[i].yShadow + totalY
			currentX = currentX + drawdata[i].w + drawdata[i].spacing
		end

		totalY = totalY + lH * 1.05
	end

	-- phase five - calculate in-canvas aligns and rotations
	for i, lineData in ipairs(self.Lines) do
		for i2, data in ipairs(lineData.draw) do
			local lineStuff = lineData.data[i2]

			data.xInCanvas = -self.TotalHeight / 2 + data.y
			data.xInCanvasShadow = -self.TotalHeight / 2 + data.yShadow
			data.yInCanvas = -self.TotalWidth / 2 + data.x
			data.yInCanvasShadow = -self.TotalWidth / 2 + data.xShadow

			data.posInCanvas = Vector(data.xInCanvas, data.yInCanvas, 20) * 0.25
			data.posInCanvasShadow = Vector(data.xInCanvasShadow, data.yInCanvasShadow, 20) * 0.25

			data.ang = Angle(0, 90 - lineStuff.rotate, 0)
		end
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
