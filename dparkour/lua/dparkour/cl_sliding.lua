
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

local CurTimeL = CurTimeL
local RealFrameTime = RealFrameTime
local tilt = 0
local Lerp = Lerp

local function CalcView(self, origin, angles, fov, znear, zfar)
	if not self:GetDParkourSliding() then
		tilt = Lerp(RealFrameTime() * 4, tilt, 0)
		if tilt:abs() <= 0.01 then return end
	end

	if self:GetDParkourSliding() then
		local ang = self:GetDParkourSlideVelStart():Angle()
		ang.p = 0
		ang.r = 0
		--print(ang)

		if ang.y:angleDifference(angles.y) >= 0 then
			tilt = Lerp(RealFrameTime() * 4, tilt, 1)
		else
			tilt = Lerp(RealFrameTime() * 4, tilt, -1)
		end
	end

	angles.r = angles.r + tilt * 30

	return {
		origin = origin,
		angles = angles,
		fov = fov,
		znear = znear,
		zfar = zfar,
	}
end

hook.Add('CalcView', 'DParkour.TiltSlide', CalcView, 1)
