
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

local particles = {}

for i = 0, 3 do
	local mat = Material('enchancedvisuals/splat/splatter/splatter' .. i .. '.png')

	table.insert(particles, mat)
end

for i, mat in ipairs(particles) do
	if mat:IsError() then return end
end

local Color = Color
local math = math

return {
	particles = particles,
	minspeed = 75,
	maxspeed = 3000,
	multiplier = 2,
	sizeMultiplier = 3,
	fadeTimerMultiplier = 0.6,
	vehicles = true,
	fall = true,
	walk = true,
	blowoff = false,
	blowoffWalk = false,
	bullet = true,
	vehicleMultiplier = 4,
	grabColor = function() return Color(120 + math.random(70), 30, 10) end,
	materials = {MAT_BLOODYFLESH}
}, {
	particles = particles,
	minspeed = 75,
	maxspeed = 3000,
	multiplier = 2,
	sizeMultiplier = 3,
	fadeTimerMultiplier = 0.6,
	vehicles = true,
	fall = true,
	walk = true,
	blowoff = false,
	blowoffWalk = false,
	bullet = true,
	vehicleMultiplier = 4,
	grabColor = function() return Color(140 + math.random(40), 70 + math.random(50), 20) end,
	materials = {MAT_ALIENFLESH}
}
