
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

AddCSLuaFile('shared.lua')
include('shared.lua')
AddCSLuaFile('cl_init.lua')

local hook = hook
local WOverlord = WOverlord
local ipairs = ipairs
local table = table
local ents = ents
local ProtectedCall = ProtectedCall
local math = math
local IsValid = IsValid
local pairs = pairs
local player = player
local string = string
local MOVETYPE_WALK = MOVETYPE_WALK
local util = util
local Entity = Entity
local GRID_SIZE = WOverlord.GRID_SIZE
local HEIGHT_SCALE = WOverlord.HEIGHT_SCALE
local checkWide = 8

WOverlord.WEATHER_EFFECT_POINTS_POSITIONS_LOCKED = {}
local LOCKED = WOverlord.WEATHER_EFFECT_POINTS_POSITIONS_LOCKED
local POSITIONS = WOverlord.WEATHER_EFFECT_POINTS_POSITIONS

for i, point in ipairs(ents.FindByClass('env_wo_point')) do
	point:Remove()
end

function ENT:Initialize()
	self:InitializeShared()
end

local checkedPositions = {}

local function hash(x, y, z)
	return string.format('%i_%i_%i', x, y, z)
end

local worldspawn

local function update()
	worldspawn = IsValid(worldspawn) and worldspawn or Entity(0)

	for i, ply in ipairs(player.GetAll()) do
		if ply:Alive() and ply:OnGround() and ply:GetMoveType() == MOVETYPE_WALK then
			local pos = ply:GetPos()
			local x = math.floor(pos.x / GRID_SIZE)
			local y = math.floor(pos.y / GRID_SIZE)
			local z = math.floor((pos.z + 10) / HEIGHT_SCALE)
			local zOriginal = pos.z

			local deltaZ = z * HEIGHT_SCALE - pos.z

			if deltaZ < 786 then
				z = z + 1
			end

			local checked = hash(x, y, z)

			if not checkedPositions[checked] then
				checkedPositions[checked] = true

				for xExp = -checkWide, checkWide do
					for yExp = -checkWide, checkWide do
						local X, Y = x + xExp, y + yExp
						local hashed = hash(X, Y, z)

						if not LOCKED[hashed] then
							LOCKED[hashed] = true
							local rx, ry, rz = X * GRID_SIZE, Y * GRID_SIZE, z * HEIGHT_SCALE

							local trData = {
								start = Vector(rx, ry, zOriginal + 10),
								endpos = Vector(rx, ry, z),
								mask = MASK_BLOCKLOS
							}

							local shouldBeNULLOrSky = util.TraceLine(trData)

							if not shouldBeNULLOrSky.Hit or shouldBeNULLOrSky.HitSky then
								trData = {
									start = Vector(rx, ry, zOriginal + 10),
									endpos = Vector(rx, ry, zOriginal - 786),
									mask = MASK_BLOCKLOS
								}

								local shouldBeWorldSpawn = util.TraceLine(trData)

								if shouldBeWorldSpawn.Entity == worldspawn then
									local ent = ents.Create('env_wo_point')
									ent:SetPos(Vector(rx, ry, rz))
									ent:Spawn()
									ent:Activate()

									POSITIONS[hashed] = ent
								end
							end
						end
					end
				end
			end
		end
	end
end

timer.Create('WeatherOverlord_PlaceWeatherNodes', 0.5, 0, function()
	ProtectedCall(update)
end)
