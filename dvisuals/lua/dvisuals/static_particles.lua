
-- Enhanced Visuals for GMod
-- Copyright (C) 2018-2019 DBot

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

local render = render
local TEXFILTER = TEXFILTER

hook.Add('PostDrawHUD', 'DVisuals.RenderStaticParticles', function()
	local ply, lply = HUDCommons.SelectPlayer(), LocalPlayer()
	if ply == lply and ply:ShouldDrawLocalPlayer() and not DVisuals.ENABLE_THIRDPERSON() then return end

	render.PushFilterMag(TEXFILTER.POINT)
	render.PushFilterMin(TEXFILTER.POINT)

	for i, particleData in ipairs(particles) do
		particleData.mat:SetFloat('$alpha', particleData.color.a / 255)
		surface.SetDrawColor(particleData.color)
		surface.SetMaterial(particleData.mat)
		surface.DrawTexturedRectRotated(particleData.x, particleData.y, particleData.size, particleData.size, particleData.rotation)
	end

	render.PopFilterMag()
	render.PopFilterMin()
end, -9)

local LIMIT = CreateConVar('cl_ev_limit', '1', {FCVAR_ARCHIVE}, 'Limit maximal amount of static particles on screen')
local LIMIT_NUM = CreateConVar('cl_ev_limit_amount', '2000', {FCVAR_ARCHIVE}, 'Maximum particles')

function DVisuals.CreateParticle(mat, ttl, size, color)
	local time = RealTimeL()
	local w, h = ScrWL(), ScrHL()

	if LIMIT:GetBool() and #particles > LIMIT_NUM:GetInt() then
		table.remove(particles, 1)
	end

	table.insert(particles, {
		mat = mat,
		x = size / 2 + math.random(w - size / 2),
		y = size / 2 + math.random(h - size / 2),
		start = time,
		startfade = time + ttl * 0.75,
		endtime = time + ttl,
		color = Color(color or Color()),
		size = size,
		wash = true,
		rotation = math.random(360) - 180,
		alpha = color and color.a or 255,
	})
end

function DVisuals.CreateParticleOverrided(mat, ttl, size, overrides)
	local time = RealTimeL()
	local w, h = ScrWL(), ScrHL()

	if LIMIT:GetBool() and #particles > LIMIT_NUM:GetInt() then
		table.remove(particles, 1)
	end

	table.insert(particles, {
		mat = mat,
		x = overrides.x or (size / 2 + math.random(w - size / 2)),
		y = overrides.y or (size / 2 + math.random(h - size / 2)),
		start = overrides.start or time,
		startfade = overrides.startfade or time + ttl * 0.75,
		endtime = overrides.endtime or time + ttl,
		color = Color(overrides.color or Color()),
		size = size,
		wash = overrides.wash == true,
		rotation = overrides.rotation or (math.random(360) - 180),
		alpha = overrides.color and overrides.color.a or overrides.alpha or 255,
	})
end

hook.Add('Think', 'DVisuals.ThinkStaticParticles', function()
	local ply = HUDCommons.SelectPlayer()
	if not IsValid(ply) then return end

	local water = ply:WaterLevel() >= 3

	local toremove
	local time = RealTimeL()

	for i, particleData in ipairs(particles) do
		local fade = 1 - time:progression(particleData.startfade, particleData.endtime)

		if fade == 0 then
			toremove = toremove or {}
			table.insert(toremove, i)
		else
			particleData.color.a = particleData.alpha * fade

			if fade == 1 and water and particleData.wash then
				local delta = particleData.endtime - particleData.startfade
				particleData.startfade = RealTimeL()
				particleData.endtime = RealTimeL() + delta
			end
		end
	end

	if toremove then
		table.removeValues(particles, toremove)
	end
end)
