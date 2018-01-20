
-- Copyright (C) 2017-2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local DLib = DLib
local math = math
local WOverlord = WOverlord
local hook = hook
local CurTime = CurTime
local RealTime = RealTime
local surface = surface
local ipairs = ipairs
local table = table
local FrameTime = FrameTime
local LocalPlayer = LocalPlayer
local meta = WOverlord.GetWeatherMeta('rain')
local isSnowing = false
local isWorking = false
local ScrW, ScrH = ScrW, ScrH
local IsValid = IsValid
local Angle = Angle
local ParticleEmitter = ParticleEmitter

if IsValid(WOverlord.RAIN_EMITTER) then
	WOverlord.RAIN_EMITTER:Finish()
	WOverlord.RAIN_EMITTER = nil
end

if IsValid(WOverlord.SNOW_EMITTER) then
	WOverlord.SNOW_EMITTER:Finish()
	WOverlord.SNOW_EMITTER = nil
end

local snowParticle = 'particle/snow'
local rainParticle = 'particle/water_drop'
local waterDrop = 'particle/warp_ripple3'
local snowID = surface.GetTextureID(snowParticle)
local rainID = surface.GetTextureID(rainParticle)
local waterDropID = surface.GetTextureID(waterDrop)

local snowParticles = {}
local rainParticles = {}

local windSpeed = 0
local windDirection = Vector(0, 0, 0)

local function HUDSnow()
	local ply = LocalPlayer()
	if not ply:IsValid() then return end

	if not ply:Alive() then
		if #snowParticles ~= 0 then
			snowParticles = {}
		end

		return
	end

	if #snowParticles == 0 then return end

	local time = RealTime()
	local toRemove

	surface.SetTexture(snowID)
	surface.SetDrawColor(255, 255, 255)

	for i, drop in ipairs(snowParticles) do
		if drop.lifetime < time then
			toRemove = toRemove or {}
			table.insert(toRemove, i)
		else
			surface.SetDrawColor(255, 255, 255, 255 - time:progression(drop.start, drop.lifetime) * 255)
			surface.DrawTexturedRect(drop.x, drop.y, drop.size, drop.size)
		end
	end

	if toRemove then
		table.removeValues(snowParticles, toRemove)
	end
end

local rainFadeStep = ScrH() * 0.09

local function HUDRain()
	local ply = LocalPlayer()
	if not ply:IsValid() then return end

	if not ply:Alive() then
		if #rainParticles ~= 0 then
			rainParticles = {}
		end

		return
	end

	local time = RealTime()
	local toRemove

	surface.SetTexture(waterDropID)
	surface.SetDrawColor(255, 255, 255)

	for i, drop in ipairs(rainParticles) do
		if drop.lifetime < time then
			toRemove = toRemove or {}
			table.insert(toRemove, i)
		else
			surface.SetDrawColor(255, 255, 255, 255 - time:progression(drop.start, drop.lifetime) * 255)
			surface.DrawTexturedRect(drop.x, drop.y + time:progression(drop.start, drop.lifetime) * rainFadeStep * (windSpeed * 3 + 1) * drop.fadeSpeed, drop.size, drop.size)
		end
	end

	if toRemove then
		table.removeValues(rainParticles, toRemove)
	end
end

local snowScore = 0
local minSize = math.floor(math.max(ScrW(), ScrH()) * 0.003)
local maxSize = math.floor(math.max(ScrW(), ScrH()) * 0.02)

local function ThinkSnow(state, date, delta)
	local ply = LocalPlayer()
	if not ply:IsValid() then return end
	if not ply:Alive() then return end
	local angles = ply:EyeAngles()

	local mult = (angles.p - 16) / 40

	if mult >= 0 then return end

	local pos = ply:GetPos()
	if not WOverlord.CheckOutdoorPoint(pos) then return end

	snowScore = snowScore - delta * mult * 6 * (windSpeed + 1)

	if snowScore < 1 then return end
	local score = math.floor(snowScore)
	snowScore = snowScore % 1

	local time = RealTime()

	for i = 1, score do
		local drop = {
			lifetime = time + math.random() * 2 + 1,
			x = math.random(0, ScrW()),
			y = math.random(0, ScrH()),
			size = math.random(minSize, maxSize),
			start = time,
		}

		table.insert(snowParticles, drop)
	end
end

local rainScore = 0

local function ThinkRain(state, date, delta)
	local ply = LocalPlayer()
	if not ply:IsValid() then return end
	if not ply:Alive() then return end
	local angles = ply:EyeAngles()

	local mult = (angles.p - 16) / 20

	if mult >= 0 then return end

	local pos = ply:GetPos()
	if not WOverlord.CheckOutdoorPoint(pos) then return end

	rainScore = rainScore - delta * mult * 12 * (windSpeed + 1)
	if rainScore < 1 then return end
	local score = math.floor(rainScore)
	rainScore = rainScore % 1

	local time = RealTime()

	for i = 1, score do
		local drop = {
			lifetime = time + math.random() * 3 + 1,
			x = math.random(-40, ScrW() + 40),
			y = math.random(-200, ScrH()),
			size = math.random(minSize, maxSize * 2),
			start = time,
			fadeSpeed = math.random() * 4
		}

		table.insert(rainParticles, drop)
	end
end

local lastSkyPosition = Vector(0, 0, 0)
local rainAngle = Angle(0, 0, -90)

local function RainDropCollide(self, hitPos, hitNormal)
	self:SetDieTime(0)
end

local function SnowDropCollide(self, hitPos, hitNormal)
	self:SetDieTime(0)
end

local function EffectsRain(state, date, delta)
	local scoreMin = math.max(1, delta * 66 * 10):floor()
	local scoreMax = math.max(2, delta * 66 * 40):floor()
	local rnd = math.random(scoreMin, scoreMax)

	for i = 1, rnd do
		local pos = lastSkyPosition + Vector((math.random() - 0.5) * 1000, (math.random() - 0.5) * 1000, 0) - windDirection * 3
		local particle = WOverlord.RAIN_EMITTER:Add(rainParticle, pos)

		particle:SetCollide(true)
		particle:SetDieTime(5)
		particle:SetAngles(rainAngle)
		particle:SetStartAlpha(200)

		particle:SetVelocity(windDirection * 3 + Vector(0, 0, -1000))

		particle:SetStartSize(4)
		particle:SetEndSize(4)
		particle:SetCollideCallback(RainDropCollide)
		particle:SetColor(255, 255, 255)
	end
end

local snowSizeMult = 3
local localVelocity = Vector()

local function EffectsSnow(state, date, delta)
	local scoreMin = math.max(1, delta * 66 * 10):floor()
	local scoreMax = math.max(2, delta * 66 * 40):floor()
	local rnd = math.random(scoreMin, scoreMax)

	for i = 1, rnd do
		local pos = lastSkyPosition + Vector((math.random() - 0.5) * 1000, (math.random() - 0.5) * 1000, 0) - windDirection * 3 + localVelocity
		local particle = WOverlord.SNOW_EMITTER:Add(snowParticle, pos)

		particle:SetCollide(true)
		particle:SetDieTime(20)
		particle:SetAngles(rainAngle)
		particle:SetStartAlpha(200)

		particle:SetVelocity(windDirection + Vector(0, 0, -200))

		particle:SetStartSize(math.random() * snowSizeMult)
		particle:SetEndSize(1)
		particle:SetCollideCallback(SnowDropCollide)
		particle:SetColor(255, 255, 255)
	end
end

-- local lastLocalPos

function meta:ThinkClient(date, delta)
	if self:IsDryRun() then return end

	windDirection = date:GetWindDirection()

	local ply = LocalPlayer()
	local pos = ply:GetPos()

	if not IsValid(WOverlord.RAIN_EMITTER) then
		WOverlord.RAIN_EMITTER = ParticleEmitter(pos, true)
	end

	if not IsValid(WOverlord.SNOW_EMITTER) then
		WOverlord.SNOW_EMITTER = ParticleEmitter(pos, false)
	end

	WOverlord.RAIN_EMITTER:SetPos(pos)
	WOverlord.SNOW_EMITTER:SetPos(pos)

	-- lastLocalPos = lastLocalPos or pos
	-- local diff = pos - lastLocalPos
	-- localVelocity = diff * 6
	-- lastLocalPos = pos

	localVelocity = ply:GetVelocity()

	local sky = WOverlord.GetSkyPositionNear(pos)

	if sky then
		lastSkyPosition = sky
	end

	local dist = pos:Distance(sky) < 3000

	rainAngle = windDirection:Angle()
	rainAngle.r = -90

	isWorking = true
	local temperature = date:GetTemperature()
	snowSizeMult = temperature * -0.1 + 1
	isSnowing = temperature < 0.1
	windSpeed = date:GetWindSpeedSI():GetMetres()

	if isSnowing then
		ThinkSnow(self, date, delta)

		if dist then
			EffectsSnow(self, date, delta)
		end
	else
		ThinkRain(self, date, delta)

		if dist then
			EffectsRain(self, date, delta)
		end
	end

	hook.Run(meta.UpdateClientHookID, self, date, delta)
	return true
end

function meta:Stop()
	if self:IsDryRun() then return end
	isWorking = false
end

hook.Add('HUDPaint', 'WeatherOverlord_RainOverlay', function()
	if isSnowing then
		HUDSnow()
	else
		HUDRain()
	end
end)
