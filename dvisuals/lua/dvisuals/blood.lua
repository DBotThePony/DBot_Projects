
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
local HUDCommons = DLib.HUDCommons
local ScrWL = ScrWL
local ScrHL = ScrHL
local ScreenSize = ScreenSize
local Quintic = Quintic

local slashparticles = {}
local pierceparticles = {}
local impactparticles = {}

for i = 0, 4 do
	table.insert(slashparticles, CreateMaterial('enchancedvisuals/splat/slash/slash' .. i, 'UnlitGeneric', {
		['$basetexture'] = 'enchancedvisuals/splat/slash/slash' .. i,
		['$translucent'] = '1',
		['$alpha'] = '1',
		['$nolod'] = '1',
		['$nofog'] = '1',
		['$color'] = '[1 1 1]',
		['$color2'] = '[1 1 1]',
	}))
end

for i = 0, 2 do
	table.insert(pierceparticles, CreateMaterial('enchancedvisuals/splat/pierce/pierce' .. i, 'UnlitGeneric', {
		['$basetexture'] = 'enchancedvisuals/splat/pierce/pierce' .. i,
		['$translucent'] = '1',
		['$alpha'] = '1',
		['$nolod'] = '1',
		['$nofog'] = '1',
		['$color'] = '[1 1 1]',
		['$color2'] = '[1 1 1]',
	}))
end

for i = 0, 2 do
	table.insert(impactparticles, CreateMaterial('enchancedvisuals/splat/impact/impact' .. i, 'UnlitGeneric', {
		['$basetexture'] = 'enchancedvisuals/splat/impact/impact' .. i,
		['$translucent'] = '1',
		['$alpha'] = '1',
		['$nolod'] = '1',
		['$nofog'] = '1',
		['$color'] = '[1 1 1]',
		['$color2'] = '[1 1 1]',
	}))
end

local bloodColorGen = {
	[BLOOD_COLOR_RED] = function(alpha)
		return Color(math.random(55) + 160, 20, 50, alpha)
	end,

	[BLOOD_COLOR_ZOMBIE] = function(alpha)
		return Color(math.random(40) + 150, 80 + math.random(70), 50, alpha)
	end,

	[BLOOD_COLOR_GREEN] = function(alpha)
		return Color(math.random(40) + 150, 80 + math.random(70), 50, alpha)
	end,

	[BLOOD_COLOR_ANTLION_WORKER] = function(alpha)
		return Color(20, math.random(55) + 200, 30, alpha)
	end,

	[BLOOD_COLOR_YELLOW] = function(alpha)
		return Color(200 + math.random(35), 185 + math.random(22), 77 + math.random(20), alpha)
	end,

	[BLOOD_COLOR_ANTLION] = function(alpha)
		return Color(170 + math.random(35), 160 + math.random(22), 77 + math.random(20), alpha)
	end,
}

local function makeSomeBlood(colorID, alpha)
	local func = bloodColorGen[colorID] or bloodColorGen[BLOOD_COLOR_RED]
	return func(alpha)
end

net.receive('DVisuals.Slash', function()
	if not DVisuals.ENABLE_BLOOD() then return end
	if not DVisuals.ENABLE_BLOOD_SLASH() then return end

	local score = net.ReadUInt(8)
	local yaw = net.ReadInt(8)
	local bloodColor = net.ReadUInt(4)
	local w, h = ScrWL(), ScrHL()

	local mult = (score / 8):clamp(1, 8)
	local currentX = (yaw + 90) / 180 * w
	local randY = math.random(h * 0.8) + h * 0.1
	local scatterWidth = (ScreenSize(60) + ScreenSize(120):random()) * mult
	local scatterHeight = (ScreenSize(20) + ScreenSize(15):random()) * mult
	local ttl = math.random(score:sqrt()) + 7

	--print(scatterWidth, scatterHeight, currentX, yaw)

	for i = 1, (score:sqrt() * 5):max(4) do
		local scatterX = math.random(scatterWidth)
		local maxScatterY = Quintic(scatterX:progression(0, scatterWidth, scatterWidth / 2))
		--print(scatterX, scatterWidth, maxScatterY)

		DVisuals.CreateParticleOverrided(table.frandom(slashparticles), ttl, (score / 2):random() * ScreenSize(6) + ScreenSize(3), {
			x = currentX + scatterX - scatterWidth / 2,
			y = randY + (math.random(scatterHeight) - scatterHeight / 2) * maxScatterY,
			color = makeSomeBlood(bloodColor, 255)
		})
	end
end)

net.receive('DVisuals.SlashOther', function()
	if not DVisuals.ENABLE_BLOOD() then return end
	if not DVisuals.ENABLE_BLOOD_SLASH() then return end

	local score = net.ReadUInt(8)
	local yaw = net.ReadInt(8)
	local bloodColor = net.ReadUInt(4)
	local w, h = ScrWL(), ScrHL()

	local mult = (score / 8):clamp(1, 6)
	local currentX = (yaw + 90) / 180 * w
	local randY = math.random(h * 0.8) + h * 0.1
	local scatterWidth = (ScreenSize(30) + ScreenSize(120):random()) * mult
	local scatterHeight = (ScreenSize(20) + ScreenSize(20):random()) * mult
	local ttl = math.random((score / 4):sqrt()) + 2

	--print(scatterWidth, scatterHeight, currentX, yaw)

	for i = 1, (score:sqrt() * 5):max(4) do
		local scatterX = math.random(scatterWidth)
		local maxScatterY = Quintic(scatterX:progression(0, scatterWidth, scatterWidth / 2))
		--print(scatterX, scatterWidth, maxScatterY)

		DVisuals.CreateParticleOverrided(table.frandom(slashparticles), ttl, (score / 2):random() * ScreenSize(5) + ScreenSize(3), {
			x = currentX + scatterX - scatterWidth / 2,
			y = randY + (math.random(scatterHeight) - scatterHeight / 2) * maxScatterY,
			color = makeSomeBlood(bloodColor, 150)
		})
	end
end)

net.receive('DVisuals.Generic', function()
	if not DVisuals.ENABLE_BLOOD() then return end

	local score = net.ReadUInt(8)
	local bloodColor = net.ReadUInt(4)

	for i = 1, score / 2 do
		if math.random(score / 3 + 1) < score then
			DVisuals.CreateParticle(table.frandom(pierceparticles), math.random(20) + 5, ScreenSize(40) + ScreenSize(30):random(), makeSomeBlood(bloodColor, 255))
		else
			break
		end
	end
end)

net.receive('DVisuals.GenericOther', function()
	if not DVisuals.ENABLE_BLOOD() then return end

	local score = net.ReadUInt(8)
	local bloodColor = net.ReadUInt(4)

	for i = 1, score do
		if math.random(score / 3 + 1) < score then
			DVisuals.CreateParticle(table.frandom(pierceparticles), math.random(10) + 3, ScreenSize(40) + ScreenSize(30):random(), makeSomeBlood(bloodColor, 160))
		else
			break
		end
	end
end)

net.receive('DVisuals.Fall', function()
	if not DVisuals.ENABLE_BLOOD() then return end
	if not DVisuals.ENABLE_FALLDAMAGE() then return end

	local speed = net.ReadUInt(16)

	for i = 1, speed / 100 do
		DVisuals.CreateParticle(table.frandom(impactparticles), math.random(20) + 10, ScreenSize(30) + ScreenSize(50):random(), Color(math.random(80) + 60, 20, 10))
	end

	for i = 1, speed / 60 do
		DVisuals.CreateParticle(table.frandom(slashparticles), math.random(30) + 5, ScreenSize(80) + ScreenSize(60):random(), Color(math.random(70) + 120, 20, 10))
	end
end)
