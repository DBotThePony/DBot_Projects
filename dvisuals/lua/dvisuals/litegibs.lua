
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
local FrameTime = FrameTime
local CurTimeL = CurTimeL
local ScreenSize = ScreenSize

local gibStepDistance = 32
local gibStepVelocity = 40

local splatter = {}

for i = 0, 3 do
	local mat = Material('enchancedvisuals/splat/splatter/splatter' .. i .. '.png')

	table.insert(splatter, mat)
end

hook.Add('PlayerFootstep', 'DVisuals.LiteGibs', function(ply, pos)
	if not DVisuals.ENABLE_BLOOD() then return end
	if not DVisuals.ENABLE_BLOOD_LITEGIBS() then return end
	if not LiteGibs then return end
	local lply = HUDCommons.SelectPlayer()
	if not lply:IsValid() then return end
	if lply ~= ply then return end

	for i, data in ipairs(LiteGibs.Gibs) do
		local gib = data[2]

		if IsValid(gib) and gib:GetPos():Distance(pos) < gibStepDistance then
			for i = 1, math.random(4) do
				DVisuals.CreateParticle(table.frandom(splatter), math.random(7) + 2, ScreenSize(40) + ScreenSize(30):random(), Color(math.random(55) + 160, 20, 50))
			end
		end
	end

	for i, data in ipairs(LiteGibs.RagdollGibs) do
		for i2, gib in pairs(data[2]) do
			if IsValid(gib) then
				for physid = 0, gib:GetPhysicsObjectCount() - 1 do
					local phys = gib:GetPhysicsObjectNum(physid)

					if IsValid(phys) and phys:GetPos():Distance(pos) < gibStepDistance then
						for i = 1, math.random(4) do
							DVisuals.CreateParticle(table.frandom(splatter), math.random(10) + 3, ScreenSize(40) + ScreenSize(30):random(), Color(math.random(55) + 160, 20, 50))
						end
					end
				end
			end
		end
	end
end, -1)
