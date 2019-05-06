
--[[
Copyright (C) 2016-2019 DBotThePony


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

]]

AddCSLuaFile('dhud/cl_init.lua')
AddCSLuaFile('dhud/cl_default.lua')
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

-- sometimes vector breaks
local function WriteVector(vec)
	net.WriteFloat(vec.x)
	net.WriteFloat(vec.y)
	net.WriteFloat(vec.z)
end

local function writeArray(damageTypesIn)
	net.WriteUInt(#damageTypesIn, 8)
	for i, dmgtype in ipairs(damageTypesIn) do
		net.WriteUInt(TypesR[dmgtype] or 1, 8)
	end
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

	local myDamage = dmg:GetDamageType()
	local damageTypesIn = {}

	for i, dmgtype in ipairs(Types) do
		if bit.band(myDamage, dmgtype) ~= 0 then
			myDamage = myDamage - dmgtype
			table.insert(damageTypesIn, dmgtype)
			if myDamage == 0 then break end
		end
	end

	if #damageTypesIn == 0 then
		table.insert(damageTypesIn, DMG_GENERIC)
	end

	local scrambleAplifier = #damageTypesIn * 4
	local damageAplifier = 1 / #damageTypesIn
	local incomingDamage = dmg:GetDamage() * damageAplifier

	net.Start('DHUD2.Damage', true)
	WriteVector(report + VectorRand() * scrambleAplifier)
	net.WriteFloat(incomingDamage)
	writeArray(damageTypesIn)
	net.WriteEntity(ent)
	net.Broadcast()

	if ent:IsPlayer() and IsValid(fattacker) and not table.HasValue(DisplayBlacklist, dmgtype) then
		net.Start('DHUD2.DamagePlayer', true)
		net.WriteFloat(incomingDamage)
		writeArray(damageTypesIn)
		WriteVector(fattacker:GetPos())
		net.WriteUInt(ent:EntIndex(), 8)
		net.Broadcast()
	elseif ent:IsVehicle() and IsValid(ent:GetDriver()) and IsValid(fattacker) and ent:GetDriver():IsPlayer() then
		net.Start('DHUD2.DamagePlayer', true)
		net.WriteFloat(incomingDamage)
		writeArray(damageTypesIn)
		WriteVector(fattacker:GetPos())
		net.WriteUInt(ent:GetDriver():EntIndex(), 8)
		net.Broadcast()
	else
		local ply = GetObservedTo(ent)

		if IsValid(ply) and IsValid(fattacker) then
			net.Start('DHUD2.DamagePlayer', true)
			net.WriteFloat(incomingDamage)
			writeArray(damageTypesIn)
			WriteVector(fattacker:GetPos())
			net.WriteUInt(ply:EntIndex(), 8)
			net.Broadcast()
		end
	end
end

hook.Add('EntityTakeDamage', 'DHUD2.DamageDisplay', EntityTakeDamage)
