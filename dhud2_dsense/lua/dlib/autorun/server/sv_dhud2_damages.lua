
-- Copyright (C) 2016-2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

util.AddNetworkString('DHUD2.DamagePlayer')

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
