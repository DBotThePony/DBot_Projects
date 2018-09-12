
-- Copyright (C) 2016-2018 DBot

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


DLib.RegisterAddonName('DHUD/2')

local ENABLED = CreateConVar('cl_dhud2_dnumbers', '1', {FCVAR_ARCHIVE}, 'Enable damage numbers')

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
Damage.History = Damage.History or {}

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

local function Net()
	if not ENABLED:GetBool() then return end
	local pos = ReadVector()
	local dmg = net.ReadFloat()
	local typeRead = readArray()
	local entityThatDamaged = net.ReadEntity()
	local scrambleAplifier = #typeRead * 4
	dmg = math.floor(dmg * 100) / 100

	for i, type in ipairs(typeRead) do
		local dtype = Types[type]
		local ctime = CurTimeL()
		local tolive = math.Clamp(dmg / 25, 3, 12)
		local col = Damage.Colors[dtype] or color_white
		local data = {
			pos = pos + VectorRand() * scrambleAplifier,
			dmg = dmg,
			dmgt = '-' .. dmg,
			start = ctime,
			finish = ctime + tolive,
			shift = 0,
			size = math.Clamp(dmg, 10, 175),
			fade = ctime + tolive - 1,
			color = Color(col.r, col.g, col.b, col.a),
			dtype = dtype,
			cfade = 1,
			scale = math.Clamp(dmg / 10, 0.5, 2)
		}

		data.ssize = data.size
		table.insert(Damage.History, data)
	end
end

surface.CreateFont('DHUD2.DamageNumber', {
	font = 'PT Mono',
	size = 72,
	weight = 800,
})

local function PostDrawTranslucentRenderables(a, b)
	if a or b then return end
	if not ENABLED:GetBool() then return end

	local ply = DLib.HUDCommons.SelectPlayer()
	local lpos = EyePos()
	local langle = EyeAngles()

	surface.SetFont('DHUD2.DamageNumber')
	surface.SetTextPos(0, 0)

	for k, data in ipairs(Damage.History) do
		local pos = data.pos
		local dmg = data.dmg

		local delta = (lpos - pos)
		local dang = delta:Angle()
		dang:RotateAroundAxis(dang:Right(), -90)
		dang:RotateAroundAxis(dang:Up(), 90)

		local add = Vector(-data.size / 2, data.shift + data.size, 0)
		add:Rotate(dang)

		cam.Start3D2D(pos + add, dang, data.size / 100)
		surface.SetTextColor(data.color)
		surface.SetTextPos(0, 0)
		surface.DrawText(data.dmgt)
		cam.End3D2D()
	end
end

local function Tick()
	if not ENABLED:GetBool() then return end
	local ctime = CurTimeL()

	for k, data in ipairs(Damage.History) do
		if data.finish < ctime then
			table.remove(Damage.History, k)
		end

		data.size = math.max(data.size - FrameTime() * (50 + data.ssize / 5), 10)

		if data.size == 10 then
			data.shift = data.shift + FrameTime() * 40
		end

		data.cfade = math.Clamp(1 - (CurTimeL() - data.fade), 0, 1)
		data.color.a = data.cfade * 255
	end
end

hook.Add('Think', 'DHUD2.DamageThink', Tick)
hook.Add('PostDrawTranslucentRenderables', 'DHUD2.DamageDraw', PostDrawTranslucentRenderables)
net.Receive('DHUD2.Damage', Net)
