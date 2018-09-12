
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

local self = DFlashback
local CoverDelta = 0

net.Receive('DFlashback.RecordStatusChanges', function()
	local status = net.ReadBool()

	if status then
		self.Begin()
	else
		self.End()
	end
end)

net.Receive('DFlashback.ReplayStatusChanges', function()
	local status = net.ReadBool()

	if status then
		self.BeginRestore()
	else
		self.EndRestore()
	end
end)

surface.CreateFont('DFlashback.TextFont', {
	size = 72,
	font = 'Arial',
	weight = 800,
})

local nextChange = 0
local currentStatus = false
local radius = 25

local function DrawIsRecording()
	local x, y = ScrWL() - 250, 100

	surface.SetTextColor(255, 255, 255)
	surface.SetDrawColor(255, 0, 0)
	draw.NoTexture()

	surface.SetFont('DFlashback.TextFont')

	local text = 'Frame: ' .. (#self.Frames + 1)
	local W = surface.GetTextSize(text)

	surface.SetTextPos(x - W - 3, y)
	surface.DrawText(text)
	surface.SetTextPos(x, y)

	surface.DrawText('[   REC]')

	if nextChange < CurTimeL() then
		nextChange = CurTimeL() + 1
		currentStatus = not currentStatus
	end

	if currentStatus then
		x = x + 45
		y = y + 40

		local toDraw = {
			{x = x, y = y, u = 0.5, v = 0.5}
		}

		for i = 0, 90 do
			local a = math.rad(i / 90 * -360)

			table.insert(toDraw, {
				x = x + math.sin(a) * radius,
				y = y + math.cos(a) * radius,
				u = math.sin(a) / 2 + 0.5,
				v = math.cos(a) / 2 + 0.5
			})
		end

		surface.DrawPoly(toDraw)
	end
end

local function DrawIsReplaying()
	local x, y = ScrWL() - 375, 100

	surface.SetTextColor(255, 255, 255)
	surface.SetDrawColor(0, 255, 0)
	draw.NoTexture()

	surface.SetFont('DFlashback.TextFont')

	local text = 'Frame: ' .. (#self.Frames + 1)
	local W = surface.GetTextSize(text)

	surface.SetTextPos(x - W - 3, y)
	surface.DrawText(text)
	surface.SetTextPos(x, y)

	surface.DrawText('[   REPLAY]')

	if nextChange < CurTimeL() then
		nextChange = CurTimeL() + 0.4
		currentStatus = not currentStatus
	end

	if currentStatus then
		x = x + 25
		y = y + 10

		local toDraw = {
			{x = x, y = y + radius},
			{x = x + 20, y = y},
			{x = x + 20, y = y + radius + 20},
			{x = x + 40, y = y},
			{x = x + 40, y = y + radius * 2},
			{x = x + 20, y = y + radius - 20},
			{x = x + 20, y = y + radius * 2},
			{x = x, y = y + radius},
		}

		surface.DrawPoly(toDraw)
	end

	local Start = CoverDelta
	local End = ScrHL() - CoverDelta
	local Width = ScrWL()

	for i = 1, 20 do
		surface.SetDrawColor(255, 255, 255, math.random(3, 10))
		surface.DrawRect(0, math.random(Start, End), Width, math.random(1, 3))
	end
end

local LastDraw = 0

local function HUDPaint()
	if self.IsRecording then
		DrawIsRecording()
	end

	if self.IsRestoring then
		DrawIsReplaying()

		CoverDelta = Lerp(CurTimeL() - LastDraw, CoverDelta, 100)
	else
		CoverDelta = Lerp(CurTimeL() - LastDraw, CoverDelta, 0)
	end

	if CoverDelta > 1 then
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, ScrWL(), CoverDelta)
		surface.DrawRect(0, ScrHL() - CoverDelta, ScrWL(), CoverDelta)
	end

	LastDraw = CurTimeL()
end

hook.Add('HUDPaint', 'DFlashback.HUDPaint', HUDPaint)

self.ServerFPS = 66
self.ServerFPSTime = 0.05

net.Receive('DFlashback.SyncServerFPS', function()
	self.ServerFPS = net.ReadUInt(16)
	self.ServerFPSTime = 1 / self.ServerFPS
end)

net.Receive('DFlashback.RestoreSpeed', function()
	self.RestoreSpeed = net.ReadFloat()
end)

-- Ugh
net.Receive('DFlashback.SyncFrameAmount', function()
	if self.DISABLED then return end
	if not self.IsRecording and not self.IsRestoring then return end
	local amount = net.ReadUInt(16)

	local delta

	if self.IsRecording then
		delta = amount - #self.Frames
	else
		delta = #self.Frames - amount
	end

	self.IgnoreNextThink = true

	for i = 1, delta do
		if self.IsRecording then
			self.SkipCurrentFrame = true
		end

		self.OnThink()
	end

	self.IgnoreNextThink = false
end)

net.Receive('DFlashback.Notify', function()
	self.Message(unpack(net.ReadTable()))
end)
