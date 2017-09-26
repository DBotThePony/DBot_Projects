
-- Copyright (C) 2017 DBot

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
	AddCSLuaFile('autorun/weaponrystats/sh_modifications.lua')
	AddCSLuaFile('autorun/weaponrystats/sh_types.lua')
	AddCSLuaFile('autorun/weaponrystats/sh_util.lua')
	AddCSLuaFile('autorun/weaponrystats/sh_logic.lua')
	AddCSLuaFile('autorun/weaponrystats/cl_hud.lua')
	AddCSLuaFile('autorun/weaponrystats/cl_util.lua')
end

weaponrystats = {}
weaponrystats.modifications = include('autorun/weaponrystats/sh_modifications.lua')
weaponrystats.types = include('autorun/weaponrystats/sh_types.lua')
include('autorun/weaponrystats/sh_util.lua')
include('autorun/weaponrystats/sh_logic.lua')

if CLIENT then
	include('autorun/weaponrystats/cl_util.lua')
	include('autorun/weaponrystats/cl_hud.lua')
end

weaponrystats.modifications_hash = {}
weaponrystats.types_hash = {}
weaponrystats.modifications_array = {}
weaponrystats.types_array = {}

for key, value in pairs(weaponrystats.modifications) do
	local crc = util.CRC(key)
	weaponrystats.modifications_hash[crc] = value
	value.crc = crc
	value.uid = weaponrystats.uidToNumber(crc)
	table.insert(weaponrystats.modifications_array, key)
end

for key, value in pairs(weaponrystats.types) do
	local crc = util.CRC(key)
	weaponrystats.types_hash[crc] = value
	value.crc = crc
	value.uid = weaponrystats.uidToNumber(crc)
	table.insert(weaponrystats.types_array, key)
end

if SERVER then
	include('autorun/weaponrystats/sv_util.lua')
	include('autorun/weaponrystats/sv_loadsave.lua')
	include('autorun/weaponrystats/sv_hooks.lua')
	include('autorun/weaponrystats/sv_logic.lua')
end

--weaponrystats = nil
