
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

		DVisuals[thing] = function()
			return enabled:GetBool()
		end

		DVisuals[thing .. '_SV'] = enabled

		return function()
			return enabled:GetBool()
		end, nil, enabled
	else
		local enabled_sv = CreateConVar('sv_' .. cvarname, default, {FCVAR_REPLICATED, FCVAR_NOTIFY}, desscription)
		local enabled_cl = CreateConVar('cl_' .. cvarname, default, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, desscription)

		DVisuals[thing] = function()
			return enabled_sv:GetBool() and enabled_cl:GetBool()
		end

		DVisuals[thing .. '_SV'] = enabled_sv
		DVisuals[thing .. '_CL'] = enabled_cl

		return function()
			return enabled_sv:GetBool() and enabled_cl:GetBool()
		end, enabled_cl, enabled_sv
	end
end

CreateShared('ENABLE_EXPLOSIONS', 'ev_explosions', '1', {FCVAR_ARCHIVE}, 'Whenever enable explosion damage aftershock')

if SERVER then
	AddCSLuaFile('DVisuals/explosion.lua')
	AddCSLuaFile('DVisuals/particles.lua')
	AddCSLuaFile('DVisuals/sand.lua')
	include('DVisuals/sv_explosion.lua')
	return
end

include('DVisuals/explosion.lua')
include('DVisuals/particles.lua')
