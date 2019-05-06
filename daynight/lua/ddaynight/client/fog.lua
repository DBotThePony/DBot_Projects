
-- Copyright (C) 2017-2019 DBotThePony

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

local DLib = DLib
local DDayNight = DDayNight
local hook = hook
local CurTimeL = CurTimeL
local self = DDayNight
local math = math
local render = render
local MATERIAL_FOG_LINEAR = MATERIAL_FOG_LINEAR
local TOKEN = 0x72ff2a8d

local function SetupFog(scale)
	local progression = self.DATE_OBJECT:GetDayProgression()
	local night = self.DATE_OBJECT:GetNightMultiplier()
	if night >= 0.75 then return end
	if progression > 0.1 then return end
	if self.DATE_OBJECT:RandomDay(0, 100, TOKEN) > 80 * (0.5 + 0.5 * self.DATE_OBJECT:GetTemperature():progression(-15, 25, 15)) then return end

	local fogProgression

	if night > 0 then
		fogProgression = 1 - night * 2
	else
		fogProgression = 1 - progression * 10
	end

	local start = 800 * (1 - (fogProgression * 2):min(1)) * self.DATE_OBJECT:RandomDay(500, 1400, TOKEN + 3) / 1000
	local endpos = (4000 - 3000 * fogProgression) * self.DATE_OBJECT:RandomDay(700, 1400, TOKEN + 4) / 1000
	local mthick = self.DATE_OBJECT:RandomDay(300, 900, TOKEN + 6) / 1000

	local thickness = mthick

	if fogProgression < 0.5 then
		thickness = mthick * (fogProgression * 2)
	end

	scale = scale or 1

	render.FogColor(200, 200, 200)
	render.FogMode(MATERIAL_FOG_LINEAR)

	render.FogMaxDensity(thickness)

	render.FogEnd(endpos)
	render.FogStart(start)

	return true
end

hook.Add('SetupSkyboxFog', 'DDayNight.Foggy', SetupFog)
hook.Add('SetupWorldFog', 'DDayNight.Foggy', SetupFog)