
--[[
Copyright (C) 2016-2017 DBot

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

local ENABLE = CreateConVar('dhud_numbers', '1', FCVAR_ARCHIVE, 'Draw hit numbers')
DHUD2.AddConVar('dhud_numbers', 'Draw hit numbers', ENABLE)

DHUD2.Damage = DHUD2.Damage or {}
local Damage = DHUD2.Damage
Damage.History = Damage.History or {}
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

local DisableAt = 0

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

local function NetPlayer()
	if not ENABLE:GetBool() then return end
	local dmg = net.ReadFloat()
	local typeRead = readArray()
	local pos = ReadVector()
	local target = Entity(net.ReadUInt(8))
	if target ~= DHUD2.SelectPlayer() then return end
	local scrambleAplifier = #typeRead * 4
	dmg = math.floor(dmg * 100) / 100

	for i, type in ipairs(typeRead) do
		local dtype = Types[type]

		DHUD2.DamageShift = true
		DHUD2.DamageShiftData = {}
		DisableAt = CurTime() + 0.2

		local ctime = CurTime()
		local tolive = math.Clamp(dmg / 10, 3, 12)
		local col = Damage.Colors[dtype] or color_white
		local scale = math.Clamp(dmg / 10, 0.5, 2)

		local data = {
			pos = pos + VectorRand() * scrambleAplifier,
			dmg = dmg,
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

local function Net()
	if not ENABLE:GetBool() then return end
	local pos = ReadVector()
	local dmg = net.ReadFloat()
	local typeRead = readArray()
	local entityThatDamaged = net.ReadEntity()
	local scrambleAplifier = #typeRead * 4
	dmg = math.floor(dmg * 100) / 100

	for i, type in ipairs(typeRead) do
		local dtype = Types[type]
		local ctime = CurTime()
		local tolive = math.Clamp(dmg / 25, 3, 12)
		local col = Damage.Colors[dtype] or color_white
		local data = {
			pos = pos + VectorRand() * scrambleAplifier,
			dmg = dmg,
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

		if IsValid(entityThatDamaged) and LocalPlayer():ShouldDrawLocalPlayer() then
			local mins, maxs = entityThatDamaged:WorldSpaceAABB()

			if DHUD2.pointInsideBox(DHUD2.EyePos, mins, maxs) or DHUD2.EyePos:Distance(entityThatDamaged:GetPos()) < 10 then
				table.insert(Damage.PHistory, table.Copy(data))
			end
		end

		table.insert(Damage.History, data)
	end
end

surface.CreateFont('DHUD2.DamageNumber', {
	font = 'Roboto',
	size = 72,
	weight = 800,
})

for i = 1, 4 do
	surface.CreateFont('DHUD2.DamageNumber' .. i, {
		font = 'Roboto',
		size = 18 + i * 4,
		weight = 500,
	})
end

local function PostDrawTranslucentRenderables(a, b)
	if a or b then return end
	if not ENABLE:GetBool() then return end

	local ply = DHUD2.SelectPlayer()
	local lpos = EyePos()
	local langle = EyeAngles()

	for k, data in pairs(Damage.History) do
		local pos = data.pos
		local dmg = data.dmg

		local delta = (lpos - pos)
		local dang = delta:Angle()
		dang:RotateAroundAxis(dang:Right(), -90)
		dang:RotateAroundAxis(dang:Up(), 90)

		local add = Vector(-data.size / 2, data.shift + data.size, 0)
		add:Rotate(dang)

		cam.Start3D2D(pos + add, dang, data.size / 100)
		draw.DrawText('-' .. data.dmg, 'DHUD2.DamageNumber', 0, 0, data.color)
		cam.End3D2D()
	end
end

local node = DLib.node()

local function Draw()
	local lpos = DHUD2.EyePos
	local lyaw = DHUD2.EyeAngles.y
	local srcw, scrh = ScrW(), ScrH()

	surface.SetDrawColor(255, 255, 255)
	draw.NoTexture()
	node.clear()

	for k, v in pairs(Damage.PHistory) do
		local ang = (v.pos - lpos):Angle()
		local yaw = ang.y + 90
		local turn = math.rad(lyaw - yaw)

		local cos, sin = math.cos(turn), math.sin(turn)

		local x, y = srcw / 2 + cos * 200, scrh / 2 + sin * 200

		local gen = {
			{x = x + 7.5 * sin * v.scale, y = y - 7.5 * cos * v.scale},
			{x = x + 50 * cos * v.scale, y = y + 50 * sin * v.scale},
			{x = x - 7.5 * sin * v.scale, y = y + 7.5 * cos * v.scale},
		}

		local selectFont = math.floor(v.scale * 2)
		surface.SetFont('DHUD2.DamageNumber' .. selectFont)

		surface.SetTextColor(v.color.r, v.color.g, v.color.b, v.color.a)
		surface.SetDrawColor(v.color.r, v.color.g, v.color.b, v.color.a)
		surface.DrawPoly(gen)

		local w, h = surface.GetTextSize(v.dmg)

		local x1, y1 = node.findNearestAlt(x - (w / 2 + 4) * cos - w / 2 + 3, y - (h / 2) * sin - h / 2, selectFont, h / 24)
		surface.SetTextPos(x1, y1)
		surface.DrawText(v.dmg)
	end
end

local function Tick()
	if not ENABLE:GetBool() then return end
	local ctime = CurTime()

	for k, data in pairs(Damage.History) do
		if data.finish < ctime then
			Damage.History[k] = nil
			goto CONTINUE
		end

		data.size = math.max(data.size - FrameTime() * (50 + data.ssize / 5), 10)

		if data.size == 10 then
			data.shift = data.shift + FrameTime() * 40
		end

		data.cfade = math.Clamp(1 - (CurTime() - data.fade), 0, 1)
		data.color.a = data.cfade * 255
		::CONTINUE::
	end

	for k, data in pairs(Damage.PHistory) do
		if data.finish < ctime then
			Damage.PHistory[k] = nil
			goto CONTINUE
		end

		data.cfade = math.Clamp(1 - (CurTime() - data.fade), 0, 1)
		data.color.a = data.cfade * 255
		::CONTINUE::
	end
end

net.Receive('DHUD2.Damage', Net)
net.Receive('DHUD2.DamagePlayer', NetPlayer)
hook.Add('PostDrawTranslucentRenderables', 'DHUD2.DrawDamage', PostDrawTranslucentRenderables)
hook.Add('Think', 'DHUD2.DamageGlitch', function()
	if DisableAt < CurTime() then
		DHUD2.DamageShift = false
		DHUD2.DamageShiftData = {}
	end
end)
DHUD2.VarHook('damage', Tick)
DHUD2.DrawHook('damage_display', Draw)
