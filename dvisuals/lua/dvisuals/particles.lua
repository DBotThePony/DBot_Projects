
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
local HUDCommons = DLib.HUDCommons
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

	particleData.blowoffRotateMultiplier = particleData.blowoffRotateMultiplier or 1
	particleData.blowoffRotateScatter = particleData.blowoffRotateScatter or 1

	particleData.blowoffWalkMultiplier = particleData.blowoffWalkMultiplier or particleData.blowoffRotateMultiplier
	particleData.blowoffWalkScatter = particleData.blowoffWalkScatter or particleData.blowoffRotateScatter

	if particleData.vehicles == nil then
		particleData.vehicles = false
	end

	if particleData.blowoff == nil then
		particleData.blowoff = true
	end

	if particleData.blowoffWalk == nil then
		particleData.blowoffWalk = true
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
	local ply, lply = HUDCommons.SelectPlayer(), LocalPlayer()

	if ply == lply and ply:ShouldDrawLocalPlayer() then return end

	for i, particleData in ipairs(particles) do
		surface.SetDrawColor(particleData.color)
		particleData.mat:SetFloat('$alpha', particleData.color.a / 255)
		surface.SetMaterial(particleData.mat)
		surface.DrawTexturedRectRotated(particleData.x, particleData.y, particleData.size, particleData.size, particleData.rotation)
	end
end)

local lastAngle = Angle()
local LerpAngle = LerpAngle
local RealFrameTime = RealFrameTime
local ScreenSize = ScreenSize
local ScrWL = ScrWL
local ScrHL = ScrHL
local Quintic = Quintic
local SOLID_NONE = SOLID_NONE

local function findVehicle(ply)
	if not ply:InVehicle() or ply:GetVehicle():GetSolid() == SOLID_NONE then
		return ply
	end

	local vehicle = ply:GetVehicle()
	local parent = vehicle:GetParent()

	-- cyclic parenting will cause crash
	for i = 1, 4 do
		if not IsValid(parent) then
			break
		end

		vehicle = parent
		parent = vehicle:GetParent()
	end

	return vehicle
end

DVisuals.FindVehicle = findVehicle

hook.Add('Think', 'DVisuals.ThinkParticles', function()
	local ply = HUDCommons.SelectPlayer()
	if not IsValid(ply) then return end
	local ang = ply:EyeAnglesFixed()
	local targetEntity = findVehicle(ply)
	local vehicle = targetEntity ~= ply

	local diffPitch = ang.p:angleDifference(lastAngle.p) / 120
	local diffYaw = ang.y:angleDifference(lastAngle.y) / 120
	lastAngle = LerpAngle(RealFrameTime() * 10, lastAngle, ang)
	local w, h = ScrWL(), ScrHL()
	local w2, h2 = w / 2, h / 2
	local velocity = ((targetEntity:GetVelocity():Length() - 300):max(0):sqrt() / 400) * RealFrameTime() * 66

	local toremove
	local time = RealTimeL()

	for i, particleData in ipairs(particles) do
		local fade = 1 - time:progression(particleData.startfade, particleData.endtime)

		if fade == 0 then
			toremove = toremove or {}
			table.insert(toremove, i)
		else
			particleData.color.a = 255 * fade

			if particleData.matData.blowoff then
				particleData.x = particleData.x + diffYaw * ScreenSize(2) * particleData.matData.blowoffRotateMultiplier * particleData.rotateScatter
				particleData.y = particleData.y - diffPitch * ScreenSize(2) * particleData.matData.blowoffRotateMultiplier * particleData.rotateScatter
			end

			if particleData.matData.blowoffWalk then
				local value = ScreenSize(9) * velocity * particleData.matData.blowoffWalkMultiplier * particleData.walkScatter

				if particleData.x > w2 then
					particleData.x = particleData.x + value * Quintic((particleData.x - w2) / w2)
				else
					particleData.x = particleData.x - value * Quintic((w2 - particleData.x) / w2)
				end

				if particleData.y > h2 then
					particleData.y = particleData.y + value * Quintic((particleData.y - h2) / h2)
				else
					particleData.y = particleData.y - value * Quintic((h2 - particleData.y) / h2)
				end
			end

			if particleData.x + particleData.size < 0 or particleData.x - particleData.size > w then
				toremove = toremove or {}
				table.insert(toremove, i)
			elseif particleData.y + particleData.size < 0 or particleData.y - particleData.size > h then
				toremove = toremove or {}
				table.insert(toremove, i)
			end
		end
	end

	if toremove then
		table.removeValues(particles, toremove)
	end
end)

local lastOnGround = true
local lastVelocity = Vector()
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
	local rotateScatter = math.random(ScreenSize(6)) * matData.blowoffRotateScatter + 1
	local walkScatter = math.random(ScreenSize(6)) * matData.blowoffWalkScatter + 1

	table.insert(particles, {
		mat = table.frandom(matData.particles),
		x = size / 2 + math.random(w - size / 2),
		y = size / 2 + math.random(h - size / 2),
		start = time,
		startfade = time + ttl * 0.75,
		endtime = time + ttl,
		color = Color(),
		size = size,
		rotateScatter = rotateScatter,
		walkScatter = walkScatter,
		rotation = math.random(360) - 180,
		matData = matData
	})
	--print('create')
end

local lastThink = 0

hook.Add('Think', 'DVisuals.CreateParticles', function()
	local ply = HUDCommons.SelectPlayer()
	if not IsValid(ply) then return end
	local ground = ply:OnGround()
	local time = RealTimeL()
	local targetEntity

	local tr

	if not ply:InVehicle() or ply:GetVehicle():GetSolid() == SOLID_NONE then
		targetEntity = ply

		tr = util.TraceLine({
			start = ply:GetPos() + Vector(0, 0, 15),
			endpos = ply:GetPos() - Vector(0, 0, 30),
			mask = MASK_BLOCKLOS
		})
	else
		local vehicle = findVehicle(ply)
		targetEntity = vehicle

		local mins, maxs, center = vehicle:OBBMins(), vehicle:OBBMaxs(), vehicle:OBBCenter()
		local ang = vehicle:GetAngles()
		mins:Rotate(ang)
		maxs:Rotate(ang)
		center:Rotate(ang)
		local pos = vehicle:GetPos()

		tr = util.TraceLine({
			start = pos + center,
			endpos = pos - center,
			mask = MASK_BLOCKLOS,
			mins = mins,
			maxs = maxs,
		})
	end

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

	if targetEntity == ply and not lastOnGround and ground and matData.fall then
		local force = lastVelocity:Length():min(matData.maxspeed)

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
	lastVelocity = targetEntity:GetVelocity()

	if not ground then return end
	if lastThink > time then return end
	lastThink = time + 0.4
	local chance = lastVelocity:Length():min(matData.maxspeed)

	if chance >= matData.minspeed then
		local roll = chance + 500
		local mult = targetEntity == ply and matData.vehicleMultiplier or matData.multiplier

		if targetEntity ~= ply then
			roll = roll - 300
		end

		for i = 1, mult * 3 do
			if math.random() < chance / roll then
				createParticle(matData)
			elseif targetEntity == ply then
				break
			end
		end
	end
end)
