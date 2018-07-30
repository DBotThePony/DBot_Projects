
-- Copyright (C) 2016-2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

DLib.RegisterAddonName('DHUD/2')

local ENABLED = CreateConVar('cl_dhud2_dsense', '1', {FCVAR_ARCHIVE}, 'Enable damage sense')
local ENABLED_NUMBERS = CreateConVar('cl_dhud2_dsense_numbers', '1', {FCVAR_ARCHIVE}, 'Show numbers representing damage')

local net = net
local table = table
local pairs = pairs
local ipairs = ipairs
local LocalPlayer = LocalPlayer
local IsValid = IsValid
local Vector = Vector
local draw = draw
local surface = surface
local EyePos = EyePos
local EyeAngles = EyeAngles
local DHUD2 = {}
local CurTimeL = CurTimeL
local DLib = DLib
local math = math

local Damage = {}
Damage.PHistory = Damage.PHistory or {}

local Types = {
	DMG_GENERIC,
	DMG_CRUSH,
	DMG_BULLET,
	DMG_SLASH,
	DMG_BURN,
	DMG_VEHICLE,
	DMG_FALL,
	DMG_BLAST,
	DMG_CLUB,
	DMG_SHOCK,
	DMG_SONIC,
	DMG_ENERGYBEAM,
	DMG_NEVERGIB,
	DMG_ALWAYSGIB,
	DMG_DROWN,
	DMG_PARALYZE,
	DMG_NERVEGAS,
	DMG_POISON,
	DMG_ACID,
	DMG_AIRBOAT,
	DMG_BLAST_SURFACE,
	DMG_BUCKSHOT,
	DMG_DIRECT,
	DMG_DISSOLVE,
	DMG_DROWNRECOVER,
	DMG_PHYSGUN,
	DMG_PLASMA,
	DMG_PREVENT_PHYSICS_FORCE,
	DMG_RADIATION,
	DMG_REMOVENORAGDOLL,
	DMG_SLOWBURN,
}

Damage.Types = Types
Damage.Colors = {
	[DMG_GENERIC] = color_white,
	[DMG_CRUSH] = Color(255, 210, 60),
	[DMG_CLUB] = Color(255, 210, 60),
	[DMG_BULLET] = Color(154, 199, 245),
	[DMG_SLASH] = Color(255, 165, 165),
	[DMG_BURN] = Color(255, 64, 64),
	[DMG_SLOWBURN] = Color(255, 64, 64),
	[DMG_VEHICLE] = Color(255, 210, 60),
	[DMG_FALL] = Color(250, 55, 255),
	[DMG_BLAST] = Color(255, 170, 64),
	[DMG_SHOCK] = Color(64, 198, 255),
	[DMG_SONIC] = Color(64, 198, 255),
	[DMG_ENERGYBEAM] = Color(255, 255, 60),
	[DMG_DROWN] = Color(64, 128, 255),
	[DMG_PARALYZE] = Color(115, 255, 60),
	[DMG_NERVEGAS] = Color(115, 255, 60),
	[DMG_POISON] = Color(115, 255, 60),
	[DMG_ACID] = Color(0, 200, 50),
	[DMG_RADIATION] = Color(0, 200, 50),
	[DMG_AIRBOAT] = Color(192, 220, 216),
	[DMG_BLAST_SURFACE] = Color(255, 170, 64),
	[DMG_DIRECT] = Color(0, 0, 0),
	[DMG_DISSOLVE] = Color(175, 36, 255),
	[DMG_DROWNRECOVER] = Color(64, 128, 255),
	[DMG_PHYSGUN] = Color(255, 210, 60),
	[DMG_PLASMA] = Color(131, 155, 255),
}

Damage.Colors[DMG_BUCKSHOT] = Damage.Colors[DMG_BULLET]

local function ReadVector()
	return Vector(net.ReadFloat(), net.ReadFloat(), net.ReadFloat())
end

local function readArray()
	local reply = {}

	for i = 1, net.ReadUInt(8) do
		table.insert(reply, net.ReadUInt(8))
	end

	return reply
end

for i = 1, 4 do
	surface.CreateFont('DHUD2.DamageNumber' .. i, {
		font = 'Roboto',
		size = 18 + i * 4,
		weight = 500,
	})
end

local function NetPlayer()
	if not ENABLED:GetBool() then return end
	local dmg = net.ReadFloat()
	local typeRead = readArray()
	local pos = ReadVector()
	local target = Entity(net.ReadUInt(8))
	if target ~= DLib.HUDCommons.SelectPlayer() then return end
	local scrambleAplifier = #typeRead * 4
	dmg = math.floor(dmg * 100) / 100

	for i, type in ipairs(typeRead) do
		local dtype = Types[type]
		DisableAt = CurTimeL() + 0.2

		local ctime = CurTimeL()
		local tolive = math.Clamp(dmg / 10, 3, 12)
		local col = Damage.Colors[dtype] or color_white
		local scale = math.Clamp(dmg / 10, 0.5, 2)

		local data = {
			pos = pos + VectorRand() * scrambleAplifier,
			dmg = dmg,
			dmgt = '-' .. dmg,
			start = ctime,
			finish = ctime + tolive,
			fade = ctime + tolive - 1,
			color = Color(col.r, col.g, col.b, col.a),
			dtype = dtype,
			cfade = 1,
			scale = scale
		}

		table.insert(Damage.PHistory, data)
	end
end

local node = DLib.node()

local function Draw()
	if not ENABLED:GetBool() then return end
	local lpos = EyePos()
	local lyaw = EyeAngles().y
	local srcw, ScrHL = ScrWL(), ScrHL()

	surface.SetDrawColor(255, 255, 255)
	draw.NoTexture()
	node.clear()

	for k, v in ipairs(Damage.PHistory) do
		local ang = (v.pos - lpos):Angle()
		local yaw = ang.y + 90
		local turn = math.rad(lyaw - yaw)

		local cos, sin = math.cos(turn), math.sin(turn)

		local x, y = srcw / 2 + cos * 200, ScrHL / 2 + sin * 200

		local gen = {
			{x = x + 7.5 * sin * v.scale, y = y - 7.5 * cos * v.scale},
			{x = x + 50 * cos * v.scale, y = y + 50 * sin * v.scale},
			{x = x - 7.5 * sin * v.scale, y = y + 7.5 * cos * v.scale},
		}

		if ENABLED_NUMBERS:GetBool() then
			local selectFont = math.floor(v.scale * 2)
			surface.SetFont('DHUD2.DamageNumber' .. selectFont)

			surface.SetTextColor(v.color.r, v.color.g, v.color.b, v.color.a)
			surface.SetDrawColor(v.color.r, v.color.g, v.color.b, v.color.a)
			surface.DrawPoly(gen)

			local w, h = surface.GetTextSize(v.dmg)

			local x1, y1 = node.findNearestAlt(x - (w / 2 + 4) * cos - w / 2 + 3, y - (h / 2) * sin - h / 2, selectFont, h / 24)
			surface.SetTextPos(x1, y1)
			surface.DrawText(v.dmg)
		else
			surface.SetDrawColor(v.color.r, v.color.g, v.color.b, v.color.a)
			surface.DrawPoly(gen)
		end
	end
end

local function Tick()
	if not ENABLED:GetBool() then return end
	local ctime = CurTimeL()

	for k, data in ipairs(Damage.PHistory) do
		if data.finish < ctime then
			table.remove(Damage.PHistory, k)
		end

		data.cfade = math.Clamp(1 - (CurTimeL() - data.fade), 0, 1)
		data.color.a = data.cfade * 255
	end
end

hook.Add('Think', 'DHUD2.DamageThinkS', Tick)
hook.Add('HUDPaint', 'DHUD2.DamageDrawS', Draw)
net.Receive('DHUD2.DamagePlayer', NetPlayer)
