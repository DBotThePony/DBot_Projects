
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
local Quintic = Quintic

local LocalPlayer = LocalPlayer
local strength = 0
local targetstrength = 0
local FrameTime = FrameTime
local CurTimeL = CurTimeL
local RealFrameTime = RealFrameTime
local Lerp = Lerp

net.receive('DVisuals.Fall', function()
	if not DVisuals.ENABLE_FALL() then return end

	local speed = net.ReadUInt(16)
	DVisuals.FallBloodHanlder(speed)

	if DVisuals.ENABLE_FALL_SHAKE() and speed > 600 then
		strength = strength + speed / 400
	end
end)

hook.Add('Think', 'DVisuals.Fall', function()
	local ply = LocalPlayer()
	if not ply:IsValid() or not ply:Alive() then
		strength = 0
		return
	end

	strength = (strength - FrameTime() * 0.7):max(0)
	targetstrength = Lerp(RealFrameTime() * 10, targetstrength, strength)
end)

hook.Add('CalcView', 'DVisuals.Fall', function(ply, origin, angles, fov, znear, zfar)
	if targetstrength <= 0.02 then return end
	if not DVisuals.ENABLE_THIRDPERSON() and ply:ShouldDrawLocalPlayer() then return end

	local value = targetstrength:min(1.2)

	local sin = math.sin(CurTimeL() * 3) * value
	local cos = math.cos(CurTimeL() * 4) * value
	local cos2 = math.cos(CurTimeL() * 6) * value

	return {
		origin = origin + angles:Forward() * Vector(sin * 2, cos2 * 2, cos * 3),
		angles = angles + Angle(sin * 6, cos * 2, 0),
		fov = fov,
		znear = znear,
		zfar = zfar,
	}
end, 2)
