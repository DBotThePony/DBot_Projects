
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

local render = render
local TEXFILTER = TEXFILTER

hook.Add('PostDrawHUD', 'DVisuals.RenderStaticParticles', function()
	local ply, lply = HUDCommons.SelectPlayer(), LocalPlayer()
	if ply == lply and ply:ShouldDrawLocalPlayer() then return end

	render.PushFilterMag(TEXFILTER.POINT)
	render.PushFilterMin(TEXFILTER.POINT)

	for i, particleData in ipairs(particles) do
		surface.SetDrawColor(particleData.color)
		particleData.mat:SetFloat('$alpha', particleData.color.a / 255)
		particleData.mat:SetVector('$color', particleData.color:ToVector())
		particleData.mat:SetVector('$color2', particleData.color:ToVector())
		surface.SetMaterial(particleData.mat)
		surface.DrawTexturedRectRotated(particleData.x, particleData.y, particleData.size, particleData.size, particleData.rotation)
	end

	render.PopFilterMag()
	render.PopFilterMin()
end, -9)

function DVisuals.CreateParticle(mat, ttl, size, color)
	local time = RealTimeL()
	local w, h = ScrWL(), ScrHL()

	table.insert(particles, {
		mat = mat,
		x = size / 2 + math.random(w - size / 2),
		y = size / 2 + math.random(h - size / 2),
		start = time,
		startfade = time + ttl * 0.75,
		endtime = time + ttl,
		color = color or Color(),
		size = size,
		rotation = math.random(360) - 180,
	})
end

hook.Add('Think', 'DVisuals.ThinkStaticParticles', function()
	local ply = HUDCommons.SelectPlayer()
	if not IsValid(ply) then return end

	local toremove
	local time = RealTimeL()

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
