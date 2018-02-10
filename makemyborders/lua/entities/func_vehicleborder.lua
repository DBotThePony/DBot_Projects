
-- Copyright (C) 2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

if SERVER then
	AddCSLuaFile()
end

local type = type
local hook = hook

ENT.Type = 'anim'
ENT.Author = 'DBotThePony'
ENT.PrintName = 'Vehicle Border'
ENT.Base = 'func_border'

function ENT:AllowObjectPass(objectIn, ifNothing)
	local typeIn = type(objectIn)

	if typeIn == 'string' then
		return true
	end

	if typeIn == 'number' then
		objectIn = Entity(objectIn)
		typeIn = type(objectIn)
	end

	if objectIn == NULL then
		return true
	end

	if typeIn == 'Vehicle' then
		return false
	end

	return true
end
