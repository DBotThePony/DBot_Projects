
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

local fires = CreateMaterial('enchancedvisuals/overlay/heat/heat0', 'UnlitGeneric', {
	['$basetexture'] = 'enchancedvisuals/overlay/heat/heat0',
	['$translucent'] = '1',
	['$alpha'] = '1',
	['$nolod'] = '1',
	['$nofog'] = '1',
})

local firesOverlayStrength = 0

hook.Add('PostDrawHUD', 'DVisuals.RenderFireParticles', function()
	if not DVisuals.ENABLE_FIRE() then return end
	local ply, lply = HUDCommons.SelectPlayer(), LocalPlayer()

	if ply == lply and ply:ShouldDrawLocalPlayer() then return end

	for i, particleData in ipairs(particles) do
		surface.SetDrawColor(particleData.color)
		particleData.mat:SetFloat('$alpha', particleData.color.a / 255)
		particleData.mat:SetVector('$color', particleData.color:ToVector())
		particleData.mat:SetVector('$color2', particleData.color:ToVector())
		surface.SetMaterial(particleData.mat)
		surface.DrawTexturedRectRotated(particleData.x, particleData.y, particleData.size, particleData.size, particleData.rotation)
	end
end, -3)

hook.Add('PostDrawHUD', 'DVisuals.RenderFireOverlay', function()
	if not DVisuals.ENABLE_FIRE() then return end
	if firesOverlayStrength == 0 then return end
	fires:SetFloat('$alpha', firesOverlayStrength)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(fires)
	surface.DrawTexturedRect(0, 0, ScrWL(), ScrHL())
end, 9)

local nextOnFire = 0

local function nurandom(max)
	return math.random(max / 2) - max / 2
end

local function createParticle()
	local time = RealTimeL()
	local ttl = math.random(4) + 1
	local size = ScreenSize(40) + nurandom(ScreenSize(60))
	local w, h = ScrWL(), ScrHL()

	table.insert(particles, {
		mat = table.frandom(fireparticles),
		x = size / 2 + math.random(w - size / 2),
		y = size / 2 + math.random(h - size / 2),
		start = time,
		startfade = time + ttl * 0.75,
		endtime = time + ttl,
		color = Color(math.random(55) + 200, math.random(30) + 170, math.random(80) + 60),
		size = size,
		rotation = math.random(360) - 180,
	})
end

hook.Add('Think', 'DVisuals.ThinkFireParticles', function()
	if not DVisuals.ENABLE_FIRE() then return end
	local ply = HUDCommons.SelectPlayer()
	if not IsValid(ply) then return end

	local toremove
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

	for i, particleData in ipairs(particles) do
		local fade = 1 - time:progression(particleData.startfade, particleData.endtime)

		if fade == 0 then
			toremove = toremove or {}
			table.insert(toremove, i)
		else
			particleData.color.a = 255 * fade
		end
	end

	if toremove then
		table.removeValues(particles, toremove)
	end
end)
