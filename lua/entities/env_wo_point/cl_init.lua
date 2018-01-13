
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

if true then return end

include('shared.lua')

local TRANSMIT_ALWAYS = TRANSMIT_ALWAYS
local hook = hook
local WOverlord = WOverlord
local ipairs = ipairs
local table = table
local LocalPlayer = LocalPlayer
local ProtectedCall = ProtectedCall
local math = math
local IsValid = IsValid
local CreateParticleSystem = CreateParticleSystem
local pairs = pairs
local GRID_SIZE = WOverlord.GRID_SIZE
local HEIGHT_SCALE = WOverlord.HEIGHT_SCALE

local startParticles = {}

function WOverlord.AddWeatherParticles(effect)
	if SERVER then return end
	startParticles[effect] = effect

	for i, point in ipairs(WOverlord.WEATHER_EFFECT_POINTS) do
		point:AddParticleEffect(effect)
	end
end

function WOverlord.AddWeatherParticlesSingle(effect)
	for i, point in ipairs(WOverlord.WEATHER_EFFECT_POINTS) do
		point:AddParticleEffectSingle(effect)
	end
end

function WOverlord.RemoveWeatherParticles(effect)
	if SERVER then return end
	startParticles[effect] = nil

	for i, point in ipairs(WOverlord.WEATHER_EFFECT_POINTS) do
		point:RemoveParticleEffect(effect)
	end
end

function WOverlord.RemoveWeatherParticlesAll(effect)
	for i, point in ipairs(WOverlord.WEATHER_EFFECT_POINTS) do
		point:RemoveParticleEffectAll(effect)
	end
end

function WOverlord.RemoveWeatherParticlesPartial(effect, amount)
	for i, point in ipairs(WOverlord.WEATHER_EFFECT_POINTS) do
		point:RemoveParticleEffectPartial(effect, amount)
	end
end

function ENT:Initialize()
	self:InitializeShared()

	self.ActiveEffects = {}
	self.ActiveEffectsMultiple = {}

	for _, effect in pairs(startParticles) do
		self:AddParticleEffect(effect)
	end
end

function ENT:AddParticleEffect(effect)
	if SERVER then return end
	if IsValid(self.ActiveEffects[effect]) then return self.ActiveEffects[effect] end
	self.ActiveEffects[effect] = CreateParticleSystem(self, effect, PATTACH_ABSORIGIN_FOLLOW)
	return self.ActiveEffects[effect]
end

function ENT:AddParticleEffectSingle(effect)
	if SERVER then return end
	self.ActiveEffectsMultiple[effect] = self.ActiveEffectsMultiple[effect] or {}
	local system = CreateParticleSystem(self, effect, PATTACH_ABSORIGIN_FOLLOW)
	table.insert(self.ActiveEffectsMultiple[effect], system)
	return system
end

function ENT:RemoveParticleEffect(effect)
	if SERVER then return end
	if not IsValid(self.ActiveEffects[effect]) then return end
	self.ActiveEffects[effect]:StopEmission()
end

function ENT:RemoveParticleEffectAll(effect)
	if SERVER then return end
	if not self.ActiveEffectsMultiple[effect] then return end

	for i, effect in ipairs(self.ActiveEffectsMultiple[effect]) do
		effect:StopEmission()
	end

	self.ActiveEffectsMultiple[effect] = {}
end

function ENT:RemoveParticleEffectPartial(effect, amount)
	if SERVER then return end
	if not self.ActiveEffectsMultiple[effect] or #self.ActiveEffectsMultiple[effect] == 0 then return end
	local target = self.ActiveEffectsMultiple[effect]

	for i = 1, amount do
		local value = target[#target]
		if not value then return end
		value:StopEmission()
		target[#target] = nil
	end
end

local function update()
	local date = WOverlord.GetCurrentDateAccurate()
	local wind = date:GetWindDirection()
	local angle = wind:Angle()
	angle.r = 0
	local mult = math.Clamp(math.sqrt(wind:Length()) / 200, 0, 1)
	angle.p = 90 * mult

	for i, point in ipairs(WOverlord.WEATHER_EFFECT_POINTS) do
		point:SetRenderAngles(angle)
	end
end

timer.Create('WeatherOverlord_UpdateWeatherPoints', 1, 0, function()
	ProtectedCall(update)
end)