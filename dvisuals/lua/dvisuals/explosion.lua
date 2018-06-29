
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
	local mat = CreateMaterial('enchancedvisuals/splat/dust/dust' .. i, 'UnlitGeneric', {
		['$basetexture'] = 'enchancedvisuals/splat/dust/dust' .. i,
		['$translucent'] = '1',
		['$alpha'] = '1',
		['$nolod'] = '1',
		['$nofog'] = '1',
	})

	table.insert(dust, mat)
end

local particles = {}
local TEXFILTER = TEXFILTER
local render = render

hook.Add('PostDrawHUD', 'DVisuals.ExplosionsParticles', function()
	if not DVisuals.ENABLE_EXPLOSIONS() then return end
	local ply, lply = HUDCommons.SelectPlayer(), LocalPlayer()
	if ply == lply and ply:ShouldDrawLocalPlayer() then return end

	render.PushFilterMag(TEXFILTER.POINT)
	render.PushFilterMin(TEXFILTER.POINT)

	for i, particleData in ipairs(particles) do
		surface.SetDrawColor(particleData.color)
		particleData.mat:SetFloat('$alpha', particleData.color.a / 255)
		particleData.mat:SetVector('$color', particleData.color:ToVector())
		particleData.mat:SetVector('$color2', particleData.color:ToVector())
		surface.SetMaterial(particleData.mat)
		surface.DrawTexturedRectRotated(particleData.x, particleData.y, particleData.size, particleData.size, particleData.rotation)
	end

	render.PopFilterMag()
	render.PopFilterMin()
end, -9)

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

	if IsValid(DVisuals.RingingSound) then
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
	end

	if not explosionActive then return end

	if explosionEnd < time then
		explosionActive = false
		return
	end

	explosionSpread = Lerp(RealFrameTime() * 12, explosionSpread, math.random() * 2 - 1)
end)

local INPLAY = false
local ringing = Sound('enhancedvisuals/ringing.wav')

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

hook.Add('Think', 'DVisuals.ThinkExplosionParticles', function()
	if not DVisuals.ENABLE_EXPLOSIONS() then return end

	local toremove
	local time = RealTimeL()

	for i, particleData in ipairs(particles) do
		local fade = 1 - time:progression(particleData.startfade, particleData.endtime)

		if fade == 0 then
			toremove = toremove or {}
			table.insert(toremove, i)
		else
			particleData.color.a = 255 * fade
		end
	end

	if toremove then
		table.removeValues(particles, toremove)
	end
end)

local function nurandom(max)
	return math.random(max / 2) - max / 2
end

local function createParticle()
	local time = RealTimeL()
	local ttl = math.random(20) + 10
	local size = ScreenSize(80) + nurandom(ScreenSize(120))
	local w, h = ScrWL(), ScrHL()

	table.insert(particles, {
		mat = table.frandom(dust),
		x = size / 2 + math.random(w - size / 2),
		y = size / 2 + math.random(h - size / 2),
		start = time,
		startfade = time + ttl * 0.75,
		endtime = time + ttl,
		color = Color(),
		size = size,
		rotation = math.random(360) - 180,
	})
end

net.receive('DVisuals.Explosions', function()
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

	INPLAY = true
	DVisuals.RingingSound = CreateSound(LocalPlayer(), ringing)
	DVisuals.RingingSound:ChangeVolume(1)
	DVisuals.RingingSound:SetSoundLevel(0)
	DVisuals.RingingSound:Play()
	INPLAY = false

	LocalPlayer():SetDSP(16, true)
end)

hook.Add('HUDShouldDraw', 'DVisuals.Explosions', function(strName)
	if not DVisuals.ENABLE_EXPLOSIONS() then return end
	if strName == 'CHudDamageIndicator' then return false end -- ??
end)
