
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
local render = render
local CurTimeL = CurTimeL
local ScrWL = ScrWL
local ScrHL = ScrHL
local Lerp = Lerp
local IsValid = IsValid
local HUDCommons = DLib.HUDCommons

local drawWaterEffect = false
local waterStart = 0
local waterEnd = 0

local blurmat = CreateMaterial('DVisuals_WaterRefract', 'Refract', {
	['$alpha'] = '1',
	['$alphatest'] = '1',
	['$normalmap'] = 'effects/flat_normal',
	['$refractamount'] = '0.1',
	['$vertexalpha'] = '1',
	['$vertexcolor'] = '1',
	['$translucent'] = '1',
	['$forcerefract'] = '1',
	['$bluramount'] = '16',
	['$nofog'] = '1'
})

hook.Add('HUDPaintBackground', 'DVisuals.Water', function()
	if not DVisuals.ENABLE_WATER() then return end
	if not drawWaterEffect then return end
	local w, h = ScrWL(), ScrHL()

	surface.SetMaterial(blurmat)
	local progression = CurTimeL():progression(waterStart, waterEnd)
	local passes = 40 * (1 - progression)

	for i = 1, passes:ceil() do
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(0, 0, w, h)
	end
end)

local Quintic = Quintic
local lastInWater = false
local LocalPlayer = LocalPlayer

hook.Add('Think', 'DVisuals.Water', function(strName)
	if not DVisuals.ENABLE_WATER() then return end

	local time = CurTimeL()

	if drawWaterEffect then
		drawWaterEffect = waterEnd > time
	end

	local ply = HUDCommons.SelectPlayer()
	if not IsValid(ply) then return end
	local targetEntity = DVisuals.FindVehicle(ply)

	local water = targetEntity:WaterLevel() >= 3

	if lastInWater ~= water then
		lastInWater = water

		waterStart = time
		waterEnd = time + (water and 1.25 or 0.8)
		drawWaterEffect = true
	end
end)
