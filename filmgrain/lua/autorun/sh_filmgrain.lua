
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

if SERVER then
	return
end

local ENABLE = CreateConVar('cl_grain_enable', '1', {FCVAR_ARCHIVE}, 'Enable film grain')
local ENABLE_LINES = CreateConVar('cl_grain_lines', '0', {FCVAR_ARCHIVE}, 'Enable film grain lines')
local CURRENT_ALPHA = CreateConVar('cl_grain_alpha', '12', {FCVAR_ARCHIVE}, 'Alpha channel of grain. 1-255')
local LINES_COUNT = CreateConVar('cl_grain_lines_count', '12', {FCVAR_ARCHIVE}, 'Amount of lines')

if not file.Exists('materials/dbot/grain.png', 'GAME') then
	print('Film grain texture not found, skipping this addon')
	return
end

local MATERIAL = Material('dbot/grain.png')
local STEP = 128

local CurrentLines = {}

local function RebuildLines()
	local w, h = ScrW(), ScrH()

	for i = 1, LINES_COUNT:GetInt() do
		table.insert(CurrentLines, {pos = math.random(100, w - 100), size = math.random(1, 3), speed = math.random(1, 3), dir = math.random(1, 2) == 1, change = 0})
	end
end

cvars.AddChangeCallback('cl_grain_lines', RebuildLines, 'Grain')
RebuildLines()

local LastCall

local function PostDrawHUD()
	if not ENABLE:GetBool() then return end
	if not system.HasFocus() then return end -- Performance

	LastCall = LastCall or CurTime()

	surface.SetDrawColor(255, 255, 255, 3)

	if ENABLE_LINES:GetBool() then
		local ctime = CurTime()
		local w, h = ScrW(), ScrH()

		for k, data in ipairs(CurrentLines) do
			local change = data.speed * (ctime - LastCall) * .1

			if not data.dir then
				change = -change
			end

			data.pos = math.Clamp(data.pos + change, -40, w + 40)

			if data.change < ctime then
				data.dir = math.random(1, 2) == 1
				data.speed = math.random(1, 3)
				data.change = ctime + math.random(100, 1000) / 100
			end

			surface.DrawRect(data.pos, 0, data.size, h)
		end
	end

	surface.SetMaterial(MATERIAL)
	surface.SetDrawColor(255, 255, 255, math.Clamp(CURRENT_ALPHA:GetInt(), 1, 255))

	local ShiftX = math.random(-100, 100)
	local ShiftY = math.random(-100, 100)

	for X = -200, ScrW() + 200, STEP do
		for Y = -200, ScrH() + 200, STEP do
			surface.DrawTexturedRectRotated(X + ShiftX,Y + ShiftY, 128, 128, math.random(-2,2) * 90)
		end
	end
end

hook.Add('PostDrawHUD', 'DBot_FilmGrain', PostDrawHUD, 2)
