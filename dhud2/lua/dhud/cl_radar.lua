
--Radar

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


local ENABLE = CreateConVar('dhud_radar', '1', FCVAR_ARCHIVE, 'Enable radar')
DHUD2.AddConVar('dhud_radar', 'Enable radar', ENABLE)

local MAX_DIST = 1000
local MAX_KNOWN_DISTANCE = 500

local ENTS = {}

timer.Create('DHUD2.UpdateRadar', 1, 0, function()
	if not ENABLE:GetBool() then return end
	if not IsValid(DHUD2.SelectPlayer()) then return end
	if not DHUD2.ServerConVar('radar') then return end
	
	ENTS = ents.GetAll()
	local ply = DHUD2.SelectPlayer()
	local pos = EyePos()
	
	for k, v in pairs(ENTS) do
		if v == ply or (not v:IsNPC() and not v:IsPlayer()) or v:GetPos():Distance(pos) > MAX_DIST then
			ENTS[k] = nil
		end
	end
end)

DHUD2.CreateColor('radar_ply', 'Player on top Radar', 120, 255, 255, 255)
DHUD2.CreateColor('radar_npc', 'NPCs on top Radar', 200, 200, 200, 255)
DHUD2.CreateColor('radar_npc_dist', 'NPCs distance top Radar', 255, 255, 255, 255)

local ToDraw = {}
local HU_IN_METER = 40

local function Update()
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('radar') then return end
	
	ToDraw = {}
	local ply = DHUD2.SelectPlayer()
	if not IsValid(ply) then return end
	local lpos = EyePos()
	local ang = EyeAngles()
	local leyes = lpos
	
	local pColor = DHUD2.GetColor('radar_ply')
	local nColor = DHUD2.GetColor('radar_npc')
	local dColor = DHUD2.GetColor('radar_npc_dist')
	
	for k, ent in pairs(ENTS) do
		if not IsValid(ent) then continue end
		local pos = ent:GetPos()
		local dist = pos:Distance(lpos)
		if dist > MAX_DIST then continue end
		
		local known = dist <= MAX_KNOWN_DISTANCE
		local delta = pos - lpos
		local dang = delta:Angle()
		local diffYaw = math.AngleDifference(dang.y, ang.y)
		local diff = -diffYaw / 45
		
		if diff > 1 or diff < -1 then continue end
		
		local isPlayer = ent:IsPlayer()
		
		local data = {}
		data.dist = math.floor(dist)
		data.known = known
		data.pos = pos
		data.diff = diff
		
		if known then
			data.meters = math.floor(dist / HU_IN_METER * 10) / 10
		else
			data.meters = math.floor(dist / HU_IN_METER / 5) * 5
		end
		
		data.isply = isPlayer
		if isPlayer then
			data.nick = ent:Nick()
			data.color = pColor
			data.textColor = team.GetColor(ent:Team())
		else
			data.color = nColor
			data.textColor = dColor
		end
		
		table.insert(ToDraw, data)
	end
end

DHUD2.DefinePosition('radar', ScrW() / 2, 40)

local RADAR_WIDTH = 500

local Positions = {}
local PositionsPly = {}

local function Draw()
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('radar') then return end
	
	local x, y = DHUD2.GetPosition('radar')
	DHUD2.DrawBox(x - RADAR_WIDTH / 2, y, RADAR_WIDTH, 10, DHUD2.GetColor('bg'))
	Positions = {}
	PositionsPly = {}
	
	surface.SetFont('DHUD2.Default')
	
	for k, data in pairs(ToDraw) do
		local shift = data.diff * RADAR_WIDTH / 2
		local lx = x + shift
		DHUD2.DrawBox(lx, y, 10, 10, data.color)
		
		local mySector = math.ceil(shift / math.floor(RADAR_WIDTH / 4))
		Positions[mySector] = (Positions[mySector] or -1) + 1
		local shiftY = Positions[mySector] * 10
		
		DHUD2.SimpleText(data.meters .. ' m', nil, lx, y + 13 + shiftY, data.textColor)
		
		if data.isply then
			PositionsPly[mySector] = (PositionsPly[mySector] or -1) + 1
			local shiftY = PositionsPly[mySector] * 10
			
			DHUD2.SimpleText(data.nick, nil, lx, y - 20 - shiftY, data.textColor)
		end
	end
end

DHUD2.DrawHook('default_radar', Draw)
hook.Add('Tick', 'DHUD2.UpdateRadar', Update)
