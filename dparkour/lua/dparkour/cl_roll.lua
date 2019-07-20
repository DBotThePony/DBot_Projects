
-- Copyright (C) 2018-2019 DBotThePony

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

local DParkour = DParkour
local DLib = DLib
local hook = hook
local CurTimeL = CurTimeL
local Angle = Angle

local function CalcView(self, origin, angles, fov, znear, zfar)
	local data = self._parkour
	if not data or not data.rolling then return end

	local roll = RealTime():progression(data.roll_start, data.roll_end)

	local ang = Angle((roll * 360 + 90):normalizeAngle(), self:GetDParkourRollAng().y, 0)

	return {
		origin = origin,
		angles = ang,
		fov = fov,
		znear = znear,
		zfar = zfar,
	}
end

local function CalcViewSinglePlayer(self, origin, angles, fov, znear, zfar)
	if not ply:GetDParkourRolling() then end
	local roll = CurTime():progression(ply:GetDParkourRollStart(), ply:GetDParkourRollEnd())

	local ang = Angle((roll * 360 + 90):normalizeAngle(), self:GetDParkourRollAng().y, 0)

	return {
		origin = origin,
		angles = ang,
		fov = fov,
		znear = znear,
		zfar = zfar,
	}
end

local function PreDrawViewModel(vm, ply, weapon)
	if not vm then return end
	if ply:GetDParkourRolling() then return true end
end

if not game.SinglePlayer() then
	hook.Add('CalcView', 'DParkour.Rolling', CalcView, -2)
else
	hook.Add('CalcView', 'DParkour.Rolling', CalcViewSinglePlayer, -2)
end

hook.Add('PreDrawViewModel', 'DParkour.Rolling', PreDrawViewModel, 4)
