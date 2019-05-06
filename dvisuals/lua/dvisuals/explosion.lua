
-- Enhanced Visuals for GMod
-- Copyright (C) 2018-2019 DBotThePony

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
local RealFrameTime = RealFrameTime
local Lerp = Lerp
local IsValid = IsValid
local math = math
local HUDCommons = DLib.HUDCommons

--local EXPLOSION_DIVIDER = CreateConVar('')

local explosionStart = 0
local explosionEnd = 0
local explosionDeaf = 0
local explosionActive = false
local explosionSpread = 0
local strongDeaf = false

local blurmat = CreateMaterial('DVisuals_ExplosionRefract9', 'Refract', {
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

local rtmat = CreateMaterial('DVisuals_ExplosionRT', 'UnlitGeneric', {
	['$alpha'] = '1',
	['$translucent'] = '1',
	['$nolod'] = '1',
	['$basetexture'] = '_rt_FullFrameFB',
	['$nofog'] = '1'
})

local dust = {}

for i = 0, 2 do
	local mat = Material('enchancedvisuals/splat/dust/dust' .. i .. '.png')

	table.insert(dust, mat)
end

hook.Add('PostDrawHUD', 'DVisuals.Explosions', function()
	if not DVisuals.ENABLE_EXPLOSIONS() then return end
	if not explosionActive then return end
	local w, h = ScrWL(), ScrHL()

	surface.SetMaterial(blurmat)
	local progression = CurTimeL():progression(explosionStart, explosionEnd)
	local passes = 40 * (1 - progression) + 10 * explosionSpread

	for i = 1, passes:ceil() do
		render.UpdateScreenEffectTexture()

		surface.DrawTexturedRect(0, 0, w, h)
	end
end, 10)

local Quintic = Quintic

hook.Add('Think', 'DVisuals.Explosions', function()
	if not DVisuals.ENABLE_EXPLOSIONS() then return end

	local time = CurTimeL()

	--[[if IsValid(DVisuals.RingingSound) then
		local strengthOfEffect = 1 - time:progression(explosionStart, explosionDeaf)

		if strengthOfEffect == 0 then
			DVisuals.RingingSound:Stop()
			strongDeaf = false
			return
		end

		local volume = strengthOfEffect:sqrt()

		if not strongDeaf then
			volume = Quintic(volume) * 0.7
		end

		DVisuals.RingingSound:ChangeVolume(volume:clamp(0, 1) - math.random() * 0.1)
		LocalPlayer():SetDSP(0, true)
	end]]

	if not explosionActive then return end

	if explosionEnd < time then
		explosionActive = false
		LocalPlayer():SetDSP(0)
		return
	end

	explosionSpread = Lerp(RealFrameTime() * 12, explosionSpread, math.random() * 2 - 1)
	LocalPlayer():SetDSP(0)
	LocalPlayer():SetDSP(37)
end)

local INPLAY = false
--local ringing = Sound('enhancedvisuals/ringing.wav')

hook.Add('SurfaceEmitSound', 'DVisuals.Explosions', function(path)
	if not DVisuals.ENABLE_EXPLOSIONS() then return end
	local progression = CurTimeL():progression(explosionStart, explosionDeaf)
	if progression == 1 then return end

	LocalPlayer():EmitSound(path)

	return false
end)

hook.Add('EntityEmitSound', 'DVisuals.Explosions', function(data)
	if not DVisuals.ENABLE_EXPLOSIONS() then return end
	if INPLAY then return end
	if data.SoundName == ringing then return end
	if data.OriginalSoundName == ringing then return end

	local delta = explosionEnd - explosionStart
	local deltaDeaf = explosionDeaf - explosionStart
	local progression = CurTimeL():progression(explosionStart, explosionDeaf)
	if progression == 1 then return end

	if delta > 1 and progression < 0.2 then
		return false
	end

	if progression < 0.2 then
		data.Volume = data.Volume * Quintic(progression:sqrt())
	else
		data.Volume = data.Volume * Quintic((progression - 0.2) * 1.6):clamp(0, 1)
	end

	data.DSP = 16
	return true
end)

local CreateSound = CreateSound
local LocalPlayer = LocalPlayer
local SNDLVL_NONE = SNDLVL_NONE

local function nurandom(max)
	return math.random(max / 2) - max / 2
end

local function createParticle()
	local ttl = math.random(20) + 10
	local size = ScreenSize(80) + nurandom(ScreenSize(120))

	DVisuals.CreateParticle(table.frandom(dust), ttl, size)
end

net.receive('DVisuals.Explosions', function()
	if not DVisuals.ENABLE_EXPLOSIONS() then return end
	local score = net.ReadUInt(4) / 3
	local time = CurTimeL()

	for i = 1, score * 3 do
		if math.random() > 0.1 then
			createParticle()
		else
			break
		end
	end

	if explosionEnd < time + score then
		explosionStart = time
		explosionEnd = time + score
		explosionDeaf = time + score * 3
	else
		local delta = explosionEnd - explosionStart

		if delta / 2 < score then
			explosionStart = time
			explosionEnd = explosionEnd + delta / 4
			explosionDeaf = explosionDeaf + delta / 3
		end

		explosionEnd = explosionEnd + score
		explosionDeaf = explosionDeaf + score * 5
	end

	if not strongDeaf then
		strongDeaf = (explosionDeaf - explosionStart) > 4
	end

	RunConsoleCommand('stopsound')

	if not explosionActive then
		explosionActive = true
	end

	--[[INPLAY = true
	DVisuals.RingingSound = CreateSound(LocalPlayer(), ringing)
	DVisuals.RingingSound:ChangeVolume(1)
	DVisuals.RingingSound:SetSoundLevel(0)
	DVisuals.RingingSound:Play()
	INPLAY = false]]

	LocalPlayer():SetDSP(16, true)
end)

hook.Add('HUDShouldDraw', 'DVisuals.Explosions', function(strName)
	if not DVisuals.ENABLE_EXPLOSIONS() then return end
	if strName == 'CHudDamageIndicator' then return false end -- ??
end)
