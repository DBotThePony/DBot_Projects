
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


local AddCSLuaFile_, include_ = AddCSLuaFile, include

local function AddCSLuaFile(fil)
	AddCSLuaFile_('dlib/autorun/weaponrystats/' .. fil)
end

local function include(fil)
	return include_('dlib/autorun/weaponrystats/' .. fil)
end

if SERVER then
	AddCSLuaFile('sh_modifications.lua')
	AddCSLuaFile('sh_types.lua')
	AddCSLuaFile('sh_util.lua')
	AddCSLuaFile('sh_logic.lua')
	AddCSLuaFile('cl_hud.lua')
	AddCSLuaFile('cl_util.lua')
	AddCSLuaFile('cl_hooks.lua')
else
	DLib.RegisterAddonName('Weaponry Stats')
end

weaponrystats = {}
weaponrystats.modifications = include('sh_modifications.lua')
weaponrystats.types = include('sh_types.lua')

weaponrystats.ENABLED = CreateConVar('sv_wpstats_enabled', '1', {FCVAR_REPLICATED}, 'Enable Weaponry Stats')

weaponrystats.blacklisted = DLib.HashSet()
local hashset = weaponrystats.blacklisted

_G.PhysBullets = {
	AddClassToBlacklist = function(val)
		return hashset:add(val)
	end,

	RemoveClassFromBlacklist = function(val)
		return hashset:remove(val)
	end,

	IsClassBlacklisted = function(val)
		return hashset:has(val)
	end,

	GetClassBlacklistTable = function()
		return hashset:copyHash()
	end,
}

local getModifiers = DLib.Loader.loadPureSHTop('dlib/autorun/weaponrystats_custom')
local getTypes = DLib.Loader.loadPureSHTop('dlib/autorun/weaponrystats_custom/types')

for i, fileData in ipairs(getModifiers) do
	local filename, modifiers = fileData[1], fileData[2]

	if type(modifiers) == 'table' then
		table.Merge(weaponrystats.modifications, modifiers)
	end
end

for i, fileData in ipairs(getTypes) do
	local filename, types = fileData[1], fileData[2]

	if type(types) == 'table' then
		table.Merge(weaponrystats.types, types)
	end
end

include('sh_util.lua')
include('sh_logic.lua')

if CLIENT then
	include('cl_util.lua')
	include('cl_hud.lua')
	include('cl_hooks.lua')
end

weaponrystats.modifications_hash = {}
weaponrystats.types_hash = {}
weaponrystats.modifications_array = {}
weaponrystats.types_array = {}

local function checkValue(value)
	value.damage = value.damage or 1
	value.force = value.force or 1
	value.clip = value.clip or 1
	value.scatter = value.scatter or 1
	value.scatterAdd = value.scatterAdd or Vector(0, 0, 0)
	value.dist = value.dist or 1
	value.num = value.num or 1
	value.numAdd = value.numAdd or 0
	value.randomMin = value.randomMin or 1
	value.randomMax = value.randomMax or 1
	value.bullet = value.bullet or 'dbot_physbullet'

	value.bulletSpeed = value.bulletSpeed or 1
	value.bulletRicochet = value.bulletRicochet or 1
	value.bulletPenetration = value.bulletPenetration or 1
end

for key, value in pairs(weaponrystats.modifications) do
	checkValue(value)
	local crc = util.CRC(key)
	weaponrystats.modifications_hash[crc] = value
	value.crc = crc
	value.uid = weaponrystats.uidToNumber(crc)
	table.insert(weaponrystats.modifications_array, key)
end

for key, value in pairs(weaponrystats.types) do
	checkValue(value)
	local crc = util.CRC(key)
	weaponrystats.types_hash[crc] = value
	value.crc = crc
	value.uid = weaponrystats.uidToNumber(crc)
	table.insert(weaponrystats.types_array, key)
end

table.sort(weaponrystats.types_array, function(a, b)
	return weaponrystats.types[a].order < weaponrystats.types[b].order
end)

table.sort(weaponrystats.modifications_array, function(a, b)
	return weaponrystats.modifications[a].order < weaponrystats.modifications[b].order
end)

if SERVER then
	include('sv_util.lua')
	include('sv_loadsave.lua')
	include('sv_hooks.lua')
	include('sv_logic.lua')
end

--weaponrystats = nil
