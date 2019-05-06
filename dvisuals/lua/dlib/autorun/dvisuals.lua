
-- Enhanced Visuals for GMod
-- Copyright (C) 2018-2019 DBotThePony

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

if CLIENT then
	DVisuals.ClientCVars = {}
end

local function CreateShared(thing, cvarname, default, description)
	if SERVER then
		local enabled = CreateConVar('sv_' .. cvarname, default, {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, description)
		CreateConVar('sv_' .. cvarname .. '_ov', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Allow clientside override of this setting')

		if thing == 'ENABLE' then
			DVisuals[thing] = function()
				return enabled:GetBool()
			end
		else
			DVisuals[thing] = function()
				return DVisuals.ENABLE() and enabled:GetBool()
			end
		end

		DVisuals[thing .. '_SV'] = enabled

		return DVisuals[thing], nil, enabled
	else
		local enabled_sv = CreateConVar('sv_' .. cvarname, default, {FCVAR_REPLICATED, FCVAR_NOTIFY}, description)
		local enabled_sv_override = CreateConVar('sv_' .. cvarname .. '_ov', default, {FCVAR_REPLICATED, FCVAR_NOTIFY}, description)
		local enabled_cl = CreateConVar('cl_' .. cvarname, default, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, description)

		if thing == 'ENABLE' then
			DVisuals[thing] = function()
				if enabled_sv_override:GetBool() then
					return enabled_sv:GetBool() and enabled_cl:GetBool()
				else
					return enabled_sv:GetBool()
				end
			end
		else
			DVisuals[thing] = function()
				if not DVisuals.ENABLE() then return false end

				if enabled_sv_override:GetBool() then
					return enabled_sv:GetBool() and enabled_cl:GetBool()
				else
					return enabled_sv:GetBool()
				end
			end
		end

		DVisuals[thing .. '_SV'] = enabled_sv
		DVisuals[thing .. '_CL'] = enabled_cl
		DVisuals[thing .. '_SV_OV'] = enabled_sv_override

		--print(string.format("gui.dvisuals.cvar.%s = '%s'", enabled_cl:GetName(), description))

		table.insert(DVisuals.ClientCVars, {enabled_cl, 'gui.dvisuals.cvar.' .. enabled_cl:GetName()})

		return DVisuals[thing], enabled_cl, enabled_sv, enabled_sv_override
	end
end

CreateShared('ENABLE', 'ev_enabled', '1', 'Main power switch')
CreateShared('ENABLE_EXPLOSIONS', 'ev_explosions', '1', 'Whenever enable explosion damage aftershock')
CreateShared('ENABLE_WATER', 'ev_water', '1', 'Whenever enable water effect')
CreateShared('ENABLE_PARTICLES', 'ev_particles', '1', 'Whenever enable any particles')
CreateShared('ENABLE_FIRE', 'ev_fires', '1', 'Whenever enable fire/heat effects')
CreateShared('ENABLE_FROZEN', 'ev_frost', '1', 'Whenever enable frozen/freeze (not really) effects')
CreateShared('ENABLE_THIRDPERSON', 'ev_thirdperson', '0', 'Draw effects while in third person mode')

CreateShared('ENABLE_FALLDAMAGE', 'ev_fall', '1', 'Enable fall effects')
CreateShared('ENABLE_BLOOD', 'ev_blood', '1', 'Enable blood effects in general')
CreateShared('ENABLE_BLOOD_LITEGIBS', 'ev_blood_litegibs', '1', 'Enable litegibs support')
CreateShared('ENABLE_BLOOD_RECEIVED', 'ev_blood_receive', '1', 'Enable blood effects when taking damage from others')
CreateShared('ENABLE_BLOOD_SLASH', 'ev_slash', '1', 'Enable slash blood effects')
CreateShared('ENABLE_BLOOD_DEALT', 'ev_blood_dealt', '1', 'Enable blood effects when hurting others on close distance')
CreateShared('ENABLE_FALL', 'ev_fall', '1', 'Enable fall effects in general')
CreateShared('ENABLE_FALL_SHAKE', 'ev_fall_shake', '1', 'Enable a bit shaking after fall')

CreateShared('ENABLE_LOWHEALTH', 'ev_lowhealth', '1', 'Enable low health visuals')

if SERVER then
	AddCSLuaFile('DVisuals/explosion.lua')
	AddCSLuaFile('DVisuals/particles.lua')
	AddCSLuaFile('DVisuals/static_particles.lua')
	AddCSLuaFile('DVisuals/sand.lua')
	AddCSLuaFile('DVisuals/water.lua')
	AddCSLuaFile('DVisuals/fire.lua')
	AddCSLuaFile('DVisuals/blood.lua')
	AddCSLuaFile('DVisuals/bloody.lua')
	AddCSLuaFile('DVisuals/snow.lua')
	AddCSLuaFile('DVisuals/fall.lua')
	AddCSLuaFile('DVisuals/heartbeat.lua')
	AddCSLuaFile('DVisuals/litegibs.lua')
	AddCSLuaFile('DVisuals/menus.lua')
	include('DVisuals/sv_damage.lua')
	return
end

DLib.RegisterAddonName('DVisuals')

include('DVisuals/static_particles.lua')
include('DVisuals/explosion.lua')
include('DVisuals/water.lua')
include('DVisuals/particles.lua')
include('DVisuals/fire.lua')
include('DVisuals/blood.lua')
include('DVisuals/fall.lua')
include('DVisuals/heartbeat.lua')
include('DVisuals/litegibs.lua')
include('DVisuals/menus.lua')
