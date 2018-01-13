
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

ENT.Type = 'point'
ENT.DisableDuplicator = true

local TRANSMIT_ALWAYS = TRANSMIT_ALWAYS
local hook = hook
local WOverlord = WOverlord
local ipairs = ipairs
local table = table
local math = math
local IsValid = IsValid
local SERVER = SERVER
local CLIENT = CLIENT
local pairs = pairs
local string = string
WOverlord.GRID_SIZE = 512
WOverlord.HEIGHT_SCALE = 2048
local GRID_SIZE = WOverlord.GRID_SIZE
local HEIGHT_SCALE = WOverlord.HEIGHT_SCALE

WOverlord.WEATHER_EFFECT_POINTS = {}
WOverlord.WEATHER_EFFECT_POINTS_POSITIONS = {}

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:InitializeShared()
	table.insert(WOverlord.WEATHER_EFFECT_POINTS, self)
end

function ENT:StorePosition()
	local pos = self:GetPos()
	local x = math.floor(pos.x / GRID_SIZE)
	local y = math.floor(pos.y / GRID_SIZE)
	local z = math.floor(pos.z / HEIGHT_SCALE)
	local deltaZ = z * HEIGHT_SCALE - pos.z

	if deltaZ < 786 then
		z = z + 1
	end

	local hash = string.format('%i_%i_%i', x, y, z)
	WOverlord.WEATHER_EFFECT_POINTS_POSITIONS[hash] = self
	return hash
end

function ENT:Think()
	return hook.Run('env_wo_point_think', self)
end
