
--[[
Copyright (C) 2016-2017 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

AddCSLuaFile('dhud/cl_init.lua')
AddCSLuaFile('dhud/cl_default.lua')
AddCSLuaFile('dhud/cl_highlight.lua')
AddCSLuaFile('dhud/cl_playerinfo.lua')
AddCSLuaFile('dhud/cl_radar.lua')
AddCSLuaFile('dhud/cl_playericon.lua')
AddCSLuaFile('dhud/cl_minimap.lua')
AddCSLuaFile('dhud/cl_view.lua')
AddCSLuaFile('dhud/cl_crosshair.lua')
AddCSLuaFile('dhud/cl_history.lua')
AddCSLuaFile('dhud/cl_freecam.lua')
AddCSLuaFile('dhud/cl_killfeed.lua')
AddCSLuaFile('dhud/cl_speedmeter.lua')
AddCSLuaFile('dhud/cl_damage.lua')
AddCSLuaFile('dhud/cl_darkrp.lua')
AddCSLuaFile('dhud/cl_voice.lua')

util.AddNetworkString('DHUD2.Damage')
util.AddNetworkString('DHUD2.DamagePlayer')

DHUD2.SVars = DHUD2.SVars or {}

function DHUD2.ConVarChanged(var, old, new)
	SetGlobalString(var, new)
end

function DHUD2.RebroadcastCVars()
	for k, v in pairs(DHUD2.SVars) do
		SetGlobalString('dhud_sv_' .. k, v:GetString())
	end
end

timer.Create('DHUD2.RebroadcastCVars', 30, 0, DHUD2.RebroadcastCVars)

hook.Add('PlayerInitialSpawn', 'DHUD2.PlayerInitialSpawn', function()
	timer.Simple(5, DHUD2.RebroadcastCVars)
end)

concommand.Add('dhud_setvar', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	
	if not args[1] then return end
	if not args[2] then return end
	
	RunConsoleCommand('dhud_sv_' .. args[1], args[2])
end)

local zero = Vector(0, 0, 0)

local Types = {
	DMG_GENERIC,
	DMG_CRUSH,
	DMG_BULLET,
	DMG_SLASH,
	DMG_BURN,
	DMG_VEHICLE,
	DMG_FALL,
	DMG_BLAST,
	DMG_CLUB,
	DMG_SHOCK,
	DMG_SONIC,
	DMG_ENERGYBEAM,
	DMG_NEVERGIB,
	DMG_ALWAYSGIB,
	DMG_DROWN,
	DMG_PARALYZE,
	DMG_NERVEGAS,
	DMG_POISON,
	DMG_ACID,
	DMG_AIRBOAT,
	DMG_BLAST_SURFACE,
	DMG_BUCKSHOT,
	DMG_DIRECT,
	DMG_DISSOLVE,
	DMG_DROWNRECOVER,
	DMG_PHYSGUN,
	DMG_PLASMA,
	DMG_PREVENT_PHYSICS_FORCE,
	DMG_RADIATION,
	DMG_REMOVENORAGDOLL,
	DMG_SLOWBURN,
}

local TypesR = {}

for k, v in ipairs(Types) do
	TypesR[v] = k
end

TypesR[4098] = 3 --Bullet

local DisplayBlacklist = {
	DMG_FALL,
	DMG_DROWN,
	DMG_ACID,
	DMG_POISON,
	DMG_NERVEGAS,
}

local function GetObservedTo(ent)
	for k, v in ipairs(player.GetAll()) do
		if v:GetObserverTarget() == ent then
			return v
		end
		
		if v:InVehicle() then
			local veh = v:GetVehicle()
			
			if veh:GetParent() == ent then
				return v
			end
			
			for k, v2 in pairs(veh:GetChildren()) do
				if v2 == ent then
					return v
				end
			end
		end
	end
end

--Because sometimes WriteVector breaks, and i am lazy to report a bug
--(because i don't know WHY it breaks, so...)
local function WriteVector(vec)
	net.WriteFloat(vec.x)
	net.WriteFloat(vec.y)
	net.WriteFloat(vec.z)
end

local function EntityTakeDamage(ent, dmg)
	if not DHUD2.ServerConVar('damage') then return end
	if not IsValid(ent) then return end
	
	if dmg:GetDamage() < .1 then return end
	
	local attacker = dmg:GetAttacker()
	local inflictor = dmg:GetAttacker()
	
	local fattacker = IsValid(inflictor) and inflictor or attacker
	
	local report = dmg:GetReportedPosition()
	
	if report == zero then
		report = ent:GetPos() + VectorRand() * math.random(5, 25)
		report.z = report.z + (ent:OBBMaxs().z - ent:OBBMins().z)
	end
	
	net.Start('DHUD2.Damage', true)
	net.WriteFloat(report.x)
	net.WriteFloat(report.y)
	net.WriteFloat(report.z)
	net.WriteFloat(dmg:GetDamage())
	net.WriteUInt(TypesR[dmg:GetDamageType()] or 1, 8)
	net.WriteEntity(ent)
	net.Broadcast()
	
	if ent:IsPlayer() and IsValid(fattacker) and not table.HasValue(DisplayBlacklist, dmg:GetDamageType()) then
		net.Start('DHUD2.DamagePlayer', true)
		net.WriteFloat(dmg:GetDamage())
		net.WriteUInt(TypesR[dmg:GetDamageType()] or 1, 8)
		WriteVector(fattacker:GetPos())
		net.WriteUInt(ent:EntIndex(), 8)
		net.Broadcast()
	elseif ent:IsVehicle() and IsValid(ent:GetDriver()) and IsValid(fattacker) and ent:GetDriver():IsPlayer() then
		net.Start('DHUD2.DamagePlayer', true)
		net.WriteFloat(dmg:GetDamage())
		net.WriteUInt(TypesR[dmg:GetDamageType()] or 1, 8)
		WriteVector(fattacker:GetPos())
		net.WriteUInt(ent:GetDriver():EntIndex(), 8)
		net.Broadcast()
	else
		local ply = GetObservedTo(ent)
		
		if IsValid(ply) and IsValid(fattacker) then
			net.Start('DHUD2.DamagePlayer', true)
			net.WriteFloat(dmg:GetDamage())
			net.WriteUInt(TypesR[dmg:GetDamageType()] or 1, 8)
			WriteVector(fattacker:GetPos())
			net.WriteUInt(ply:EntIndex(), 8)
			net.Broadcast()
		end
	end
end

hook.Add('EntityTakeDamage', 'DHUD2.DamageDisplay', EntityTakeDamage)
