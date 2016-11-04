
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

local IsFlashingBack = false
local FrameCount = 0
local IsRecording = false

net.Receive('DFlashback.RecordStatusChanges', function()
	IsRecording = net.ReadBool()
end)

net.Receive('DFlashback.ReplayStatusChanges', function()
	IsFlashingBack = net.ReadBool()
end)

net.Receive('DFlashback.UpdateFrameCount', function()
	FrameCount = net.ReadUInt(16)
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
	local x, y = ScrW() - 250, 100
	
	surface.SetTextColor(255, 255, 255)
	surface.SetDrawColor(255, 0, 0)
	draw.NoTexture()
	
	surface.SetFont('DFlashback.TextFont')
	
	local text = 'Frame: ' .. (FrameCount + 1)
	local W = surface.GetTextSize(text)
	
	surface.SetTextPos(x - W - 3, y)
	surface.DrawText(text)
	surface.SetTextPos(x, y)
	
	surface.DrawText('[   REC]')
	
	if nextChange < CurTime() then
		nextChange = CurTime() + 1
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
	local x, y = ScrW() - 375, 100
	
	surface.SetTextColor(255, 255, 255)
	surface.SetDrawColor(0, 255, 0)
	draw.NoTexture()
	
	surface.SetFont('DFlashback.TextFont')
	
	local text = 'Frame: ' .. (FrameCount + 1)
	local W = surface.GetTextSize(text)
	
	surface.SetTextPos(x - W - 3, y)
	surface.DrawText(text)
	surface.SetTextPos(x, y)
	
	surface.DrawText('[   REPLAY]')
	
	if nextChange < CurTime() then
		nextChange = CurTime() + 0.4
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
end

local function HUDPaint()
	if IsRecording then
		DrawIsRecording()
	end
	
	if IsFlashingBack then
		DrawIsReplaying()
	end
end

hook.Add('HUDPaint', 'DFlashback.HUDPaint', HUDPaint)
