
-- Copyright (C) 2016-2018 DBot

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


util.AddNetworkString('DHUD2.Damage')
local ENABLED = CreateConVar('sv_dhud2_dnumbers', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable damage numbers')

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
	if not ENABLED:GetBool() then return end
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
end

hook.Add('EntityTakeDamage', 'DHUD2.DamageDisplay', EntityTakeDamage)
