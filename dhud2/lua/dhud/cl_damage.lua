
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

local ENABLE = CreateConVar('dhud_numbers', '1', FCVAR_ARCHIVE, 'Draw hit numbers')
DHUD2.AddConVar('dhud_numbers', 'Draw hit numbers', ENABLE)

DHUD2.Damage = DHUD2.Damage or {}
local Damage = DHUD2.Damage
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
	[DMG_BULLET] = Color(230, 230, 230),
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
	[DMG_BUCKSHOT] = Color(230, 230, 230),
	[DMG_DIRECT] = color_white,
	[DMG_DISSOLVE] = Color(175, 36, 255),
	[DMG_DROWNRECOVER] = Color(64, 128, 255),
	[DMG_PHYSGUN] = Color(255, 210, 60),
	[DMG_PLASMA] = Color(131, 155, 255),
}

--[[
Damage.DrawFuncs = {
	[DMG_BULLET] = function(w, h)
		local x, y = w + 3, h / 3
		local h = h / 3
		
		surface.DrawPoly{
			{x = x + 20, y = y},
			{x = x + 80, y = y},
			{x = x + 80, y = y + h},
			{x = x + 20, y = y + h},
			{x = x, y = y + h / 2},
		}
	end,
	
	[DMG_CRUSH] = function(w, h)
		local x, y = w + 3, 10
		local div = h / 3 - 7
		
		for i = 0, 2 do
			surface.DrawRect(x, y + div * i, x + 20 - i * 20, div - 8)
		end
	end,
	
	[DMG_BLAST] = function(w, h)
		local x, y = w + 3, 0
		surface.DrawPoly{
			{x = x, y = 22},
			{x = x + 14, y = 19},
			{x = x + 11, y = 5},
			{x = x + 25, y = 12},
			{x = x + 32, y = 0},
			{x = x + 38, y = 11},
			{x = x + 50, y = 5},
			{x = x + 48, y = 18},
			{x = x + 62, y = 21},
			{x = x + 52, y = 32},
			{x = x + 62, y = 41},
			{x = x + 48, y = 43},
			{x = x + 51, y = 58},
			{x = x + 38, y = 52},
			{x = x + 32, y = 64},
			{x = x + 25, y = 52},
			{x = x + 12, y = 58},
			{x = x + 14, y = 45},
			{x = x + 0, y = 42},
			{x = x + 10, y = 32},
		}
	end,
}]]

--Damage.DrawFuncs[DMG_BUCKSHOT] = Damage.DrawFuncs[DMG_BULLET]
--Damage.DrawFuncs[DMG_CLUB] = Damage.DrawFuncs[DMG_CRUSH]

local function Net()
	if not ENABLE:GetBool() then return end
	local pos = Vector(net.ReadFloat(), net.ReadFloat(), net.ReadFloat())
	local dmg = net.ReadFloat()
	local type = net.ReadUInt(8)
	local dtype = Types[type]
	
	dmg = math.floor(dmg * 100) / 100
	
	local ctime = CurTime()
	
	local tolive = math.Clamp(dmg / 25, 3, 12)
	
	local col = Damage.Colors[dtype] or color_white
	
	local data = {
		pos = pos,
		dmg = dmg,
		start = ctime,
		finish = ctime + tolive,
		shift = 0,
		size = math.Clamp(dmg, 10, 175),
		fade = ctime + tolive - 1,
		color = Color(col.r, col.g, col.b, col.a),
		dtype = dtype,
		cfade = 1,
	}
	
	data.ssize = data.size
	
	table.insert(Damage.History, data)
end

surface.CreateFont('DHUD2.DamageNumber', {
	font = 'Roboto',
	size = 72,
	weight = 800,
})

local function PostDrawTranslucentRenderables(a, b)
	if a or b then return end
	if not ENABLE:GetBool() then return end
	
	local ply = LocalPlayer()
	local lpos = EyePos()
	local langle = EyeAngles()
	
	--draw.NoTexture()
	
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
		
		--[[if Damage.DrawFuncs[data.dtype] then
			local w, h = surface.GetTextSize('-' .. data.dmg)
			surface.SetDrawColor(data.color)
			Damage.DrawFuncs[data.dtype](w, h)
		end]]

		cam.End3D2D()
	end
end

local function Tick()
	if not ENABLE:GetBool() then return end
	local ctime = CurTime()
	
	for k, data in pairs(Damage.History) do
		if data.finish < ctime then
			Damage.History[k] = nil
			continue
		end
		
		data.size = math.max(data.size - FrameTime() * (50 + data.ssize / 5), 10)
		
		if data.size == 10 then
			data.shift = data.shift + FrameTime() * 40
		end
		
		data.cfade = math.Clamp(1 - (CurTime() - data.fade), 0, 1)
		data.color.a = data.cfade * 255
	end
end

net.Receive('DHUD2.Damage', Net)
hook.Add('PostDrawTranslucentRenderables', 'DHUD2.DrawDamage', PostDrawTranslucentRenderables)
DHUD2.VarHook('damage', Tick)
