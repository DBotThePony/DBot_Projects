
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

_G.DVisuals = _G.DVisuals or {}
local DVisuals = DVisuals

local function CreateShared(thing, cvarname, default, desscription)
	if SERVER then
		local enabled = CreateConVar('sv_' .. cvarname, default, {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, desscription)
		CreateConVar('sv_' .. cvarname .. '_ov', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Allow clientside override of this setting')

		DVisuals[thing] = function()
			return enabled:GetBool()
		end

		DVisuals[thing .. '_SV'] = enabled

		return function()
			return enabled:GetBool()
		end, nil, enabled
	else
		local enabled_sv = CreateConVar('sv_' .. cvarname, default, {FCVAR_REPLICATED, FCVAR_NOTIFY}, desscription)
		local enabled_sv_override = CreateConVar('sv_' .. cvarname .. '_ov', default, {FCVAR_REPLICATED, FCVAR_NOTIFY}, desscription)
		local enabled_cl = CreateConVar('cl_' .. cvarname, default, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, desscription)

		DVisuals[thing] = function()
			if enabled_sv_override:GetBool() then
				return enabled_sv:GetBool() and enabled_cl:GetBool()
			else
				return enabled_sv:GetBool()
			end
		end

		DVisuals[thing .. '_SV'] = enabled_sv
		DVisuals[thing .. '_CL'] = enabled_cl

		return function()
			if enabled_sv_override:GetBool() then
				return enabled_sv:GetBool() and enabled_cl:GetBool()
			else
				return enabled_sv:GetBool()
			end
		end, enabled_cl, enabled_sv, enabled_sv_override
	end
end

CreateShared('ENABLE_EXPLOSIONS', 'ev_explosions', '1', 'Whenever enable explosion damage aftershock')
CreateShared('ENABLE_WATER', 'ev_water', '1', 'Whenever enable water effect')
CreateShared('ENABLE_PARTICLES', 'ev_particles', '1', 'Whenever enable any particles')
CreateShared('ENABLE_FIRE', 'ev_fires', '1', 'Whenever enable fire/heat effects')
CreateShared('ENABLE_FROZEN', 'ev_frost', '1', 'Whenever enable frozen/freeze (not really) effects')

if SERVER then
	AddCSLuaFile('DVisuals/explosion.lua')
	AddCSLuaFile('DVisuals/particles.lua')
	AddCSLuaFile('DVisuals/static_particles.lua')
	AddCSLuaFile('DVisuals/sand.lua')
	AddCSLuaFile('DVisuals/water.lua')
	AddCSLuaFile('DVisuals/fire.lua')
	include('DVisuals/sv_damage.lua')
	return
end

include('DVisuals/static_particles.lua')
include('DVisuals/explosion.lua')
include('DVisuals/water.lua')
include('DVisuals/particles.lua')
include('DVisuals/fire.lua')
