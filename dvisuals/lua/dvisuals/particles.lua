
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
local assert = assert
local type = type
local table = table
local math = math
local ipairs = ipairs
local Color = Color
local sand = include('sand.lua')

local registered = {}

local function registerParticle(particleData)
	assert(type(particleData) == 'table', 'Invalid particleData type')
	assert(type(particleData.particles) == 'table', 'particleData.particles is not a table')
	assert(type(particleData.materials) == 'table', 'particleData.materials is not a table')

	particleData.minspeed = particleData.minspeed or 0
	particleData.maxspeed = particleData.maxspeed or 1000
	particleData.multiplier = particleData.multiplier or 1
	particleData.sizeMultiplier = particleData.sizeMultiplier or 1
	particleData.sizeScatter = particleData.sizeScatter or 1
	particleData.vehicleMultiplier = particleData.vehicleMultiplier or 4
	particleData.fadeTimerMultiplier = particleData.fadeTimerMultiplier or 1

	if particleData.vehicles == nil then
		particleData.vehicles = false
	end

	if particleData.walk == nil then
		particleData.walk = false
	end

	if particleData.explosion == nil then
		particleData.explosion = true
	end

	if particleData.bullet == nil then
		particleData.bullet = false
	end

	if particleData.fall == nil then
		particleData.fall = true
	end

	table.insert(registered, particleData)
	return true
end

if sand then
	registerParticle(sand)
end

hook.Run('RegisterVisualParticles', registerParticle)

local particles = {}
local LocalPlayer = LocalPlayer
local IsValid = IsValid
local RealTimeL = RealTimeL
local surface = surface

hook.Add('PostDrawHUD', 'DVisuals.RenderParticles', function()
	for i, particleData in ipairs(particles) do
		surface.SetDrawColor(particleData.color)
		particleData.mat:SetFloat('$alpha', particleData.color.a / 255)
		surface.SetMaterial(particleData.mat)
		surface.DrawTexturedRectRotated(particleData.x, particleData.y, particleData.size, particleData.size, particleData.rotation)
	end
end)

hook.Add('Think', 'DVisuals.ThinkParticles', function()
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

local lastOnGround = true
local lastVelocity = Vector()
local ScreenSize = ScreenSize
local ScrWL = ScrWL
local ScrHL = ScrHL
local MASK_BLOCKLOS = MASK_BLOCKLOS
local util = util

local function nurandom(max)
	return math.random(max / 2) - max / 2
end

local function createParticle(matData)
	local time = RealTimeL()
	local ttl = matData.fadeTimerMultiplier * (math.random(18) + 3)
	local size = matData.sizeMultiplier * ScreenSize(16) + nurandom(ScreenSize(20) * matData.sizeScatter)
	local w, h = ScrWL(), ScrHL()

	table.insert(particles, {
		mat = table.frandom(matData.particles),
		x = size / 2 + math.random(w - size / 2),
		y = size / 2 + math.random(h - size / 2),
		start = time,
		startfade = time + ttl * 0.75,
		endtime = time + ttl,
		color = Color(),
		size = size,
		rotation = math.random(360) - 180,
		matData = matData
	})
	--print('create')
end

local lastThink = 0

hook.Add('Think', 'DVisuals.CreateParticles', function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local ground = ply:OnGround()
	local time = RealTimeL()

	local tr = util.TraceLine({
		start = ply:GetPos() + Vector(0, 0, 15),
		endpos = ply:GetPos() - Vector(0, 0, 30),
		mask = MASK_BLOCKLOS
	})

	local mat = tr.MatType or MAT_GRASS
	if not mat then return end
	local matData

	for i, registeredData in ipairs(registered) do
		for i2, matIn in ipairs(registeredData.materials) do
			if matIn == mat then
				matData = registeredData
				break
			end
		end
	end

	if not matData then return end

	if not lastOnGround and ground and matData.fall then
		local force = lastVelocity:Length():min(matData.maxspeed)
		--print(force)

		if force >= matData.minspeed then
			local chance = force:pow(2)
			local roll = chance + 14000

			for i = 1, matData.multiplier * 10 do
				if math.random() < chance / roll then
					createParticle(matData)
				else
					break
				end
			end
		end
	end

	lastOnGround = ground
	lastVelocity = ply:GetVelocity()

	if not ground then return end
	if lastThink > time then return end
	lastThink = time + 0.4
	local chance = lastVelocity:Length():min(matData.maxspeed)

	if chance >= matData.minspeed then
		local roll = chance + 500

		for i = 1, matData.multiplier * 3 do
			if math.random() < chance / roll then
				createParticle(matData)
			else
				break
			end
		end
	end
end)
