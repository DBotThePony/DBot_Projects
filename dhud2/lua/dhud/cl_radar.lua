
--Radar

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

DHUD2.DefinePosition('radar', ScrWL() / 2, 40)

local RADAR_WIDTH = 500

local Positions = {}
local PositionsPly = {}

local function Draw()
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('radar') then return end

	local x, y = DHUD2.GetPosition('radar')
	DLib.HUDCommons.DrawCustomMatrix(x, y)
	x, y = 0, 0
	DHUD2.DrawBox(x - RADAR_WIDTH / 2 + DHUD2.GetDamageShift(), y + DHUD2.GetDamageShift(), RADAR_WIDTH, 10, DHUD2.GetColor('bg'))
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

		DHUD2.SimpleText(data.meters .. ' m', nil, lx + DHUD2.GetDamageShift(), y + 13 + shiftY + DHUD2.GetDamageShift(), data.textColor)

		if data.isply then
			PositionsPly[mySector] = (PositionsPly[mySector] or -1) + 1
			local shiftY = PositionsPly[mySector] * 10

			DHUD2.SimpleText(data.nick, nil, lx + DHUD2.GetDamageShift(), y - 20 - shiftY + DHUD2.GetDamageShift(), data.textColor)
		end
	end

	DLib.HUDCommons.PopDrawMatrix()
end

DHUD2.DrawHook('default_radar', Draw)
hook.Add('Tick', 'DHUD2.UpdateRadar', Update)
