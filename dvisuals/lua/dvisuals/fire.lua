
-- Enhanced Visuals for GMod
-- Copyright (C) 2018 DBot

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local DVisuals = DVisuals
local type = type
local table = table
local math = math
local ipairs = ipairs
local Color = Color
local RealTimeL = RealTimeL
local RealFrameTime = RealFrameTime
local HUDCommons = DLib.HUDCommons
local ScrWL = ScrWL
local ScrHL = ScrHL

local particles = {}
local fireparticles = {
	CreateMaterial('enchancedvisuals/splat/fire/fire0', 'UnlitGeneric', {
		['$basetexture'] = 'enchancedvisuals/splat/fire/fire0',
		['$translucent'] = '1',
		['$alpha'] = '1',
		['$nolod'] = '1',
		['$nofog'] = '1',
		['$color'] = '[1 0.75 0.38]',
		['$color2'] = '[1 0.75 0.38]',
	}), CreateMaterial('enchancedvisuals/splat/fire/fire1', 'UnlitGeneric', {
		['$basetexture'] = 'enchancedvisuals/splat/fire/fire1',
		['$translucent'] = '1',
		['$alpha'] = '1',
		['$nolod'] = '1',
		['$nofog'] = '1',
		['$color'] = '[1 0.75 0.38]',
		['$color2'] = '[1 0.75 0.38]',
	})
}

local snowparticles = {}

for i = 0, 3 do
	table.insert(snowparticles, CreateMaterial('enchancedvisuals/splat/snow/snow' .. i, 'UnlitGeneric', {
		['$basetexture'] = 'enchancedvisuals/splat/snow/snow' .. i,
		['$translucent'] = '1',
		['$alpha'] = '1',
		['$nolod'] = '1',
		['$nofog'] = '1',
		['$color'] = '[1 1 1]',
		['$color2'] = '[1 1 1]',
	}))
end

local fires = CreateMaterial('enchancedvisuals/overlay/heat/heat0', 'UnlitGeneric', {
	['$basetexture'] = 'enchancedvisuals/overlay/heat/heat0',
	['$translucent'] = '1',
	['$alpha'] = '1',
	['$nolod'] = '1',
	['$nofog'] = '1',
})

local freeze = CreateMaterial('enchancedvisuals/overlay/freeze/freeze0', 'UnlitGeneric', {
	['$basetexture'] = 'enchancedvisuals/overlay/freeze/freeze0',
	['$translucent'] = '1',
	['$alpha'] = '1',
	['$nolod'] = '1',
	['$nofog'] = '1',
})

local firesOverlayStrength = 0
local frozenOverlayStrength = 0

hook.Add('PostDrawHUD', 'DVisuals.RenderFireOverlay', function()
	if not DVisuals.ENABLE_FIRE() then return end

	if firesOverlayStrength ~= 0 then
		fires:SetFloat('$alpha', firesOverlayStrength)
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(fires)
		surface.DrawTexturedRect(0, 0, ScrWL(), ScrHL())
	end

	if frozenOverlayStrength ~= 0 then
		freeze:SetFloat('$alpha', frozenOverlayStrength)
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(freeze)
		surface.DrawTexturedRect(0, 0, ScrWL(), ScrHL())
	end
end, 9)

local nextOnFire = 0

local function nurandom(max)
	return math.random(max / 2) - max / 2
end

local function createParticle()
	local ttl = math.random(4) + 1
	local size = ScreenSize(40) + nurandom(ScreenSize(60))

	DVisuals.CreateParticle(table.frandom(fireparticles), ttl, size, Color(math.random(55) + 200, math.random(30) + 170, math.random(80) + 60))
end

local function createFrostParticle()
	local ttl = math.random(8) + 2
	local size = ScreenSize(30) + nurandom(ScreenSize(20))

	DVisuals.CreateParticle(table.frandom(snowparticles), ttl, size, Color())
end

hook.Add('Think', 'DVisuals.ThinkFireParticles', function()
	if not DVisuals.ENABLE_FIRE() then return end
	local ply = HUDCommons.SelectPlayer()
	if not IsValid(ply) then return end

	local time = RealTimeL()
	local onfire = ply:IsOnFire()

	if onfire and nextOnFire < time then
		nextOnFire = RealTimeL() + math.random() / 2

		for i = 1, math.random(7) + 1 do
			createParticle()
		end
	end

	if onfire then
		firesOverlayStrength = (firesOverlayStrength + RealFrameTime() / 8):min(1)
	else
		firesOverlayStrength = (firesOverlayStrength - RealFrameTime() / 8):max(0)
	end

	frozenOverlayStrength = (frozenOverlayStrength - RealFrameTime() / 8):max(0)
end)

net.receive('DVisuals.Fires', function()
	local score = net.ReadUInt(4)

	for i = 1, score do
		createParticle()
	end

	firesOverlayStrength = (firesOverlayStrength + score / 32):clamp(0, 1)
end)

net.receive('DVisuals.Frost', function()
	local score = net.ReadUInt(8)

	for i = 1, score do
		createFrostParticle()
	end

	frozenOverlayStrength = (frozenOverlayStrength + score / 32):clamp(0, 1)
end)
