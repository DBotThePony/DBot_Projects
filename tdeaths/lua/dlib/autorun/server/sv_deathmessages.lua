
-- Copyright (C) 2016-2017 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local ENABLE = CreateConVar('tdeaths_enable', '1', FCVAR_ARCHIVE, 'Enable Death Messages')
local ENABLE_NPC = CreateConVar('tdeaths_enable_npc', '1', FCVAR_ARCHIVE, 'Enable Death Messages of NPCs')
local RANGE_DEFAULT = CreateConVar('tdeaths_range', '4000', FCVAR_ARCHIVE, 'Broadcast range of default death message')
local RANGE_NPC = CreateConVar('tdeaths_range', '1000', FCVAR_ARCHIVE, 'Broadcast range of npc vs npc death message')
local RANGE_PLAYER = CreateConVar('tdeaths_range_pvp', '2000', FCVAR_ARCHIVE, 'Broadcast range of deaths messages related to combat against real targets (Player, NPC)')

local RED = Color(215, 64, 64)

local function SayPVE(ply, attacker, weapon, pos, ...)
	if hook.Run('TDeaths_Notify', ply, attacker, weapon, pos, false) ~= false then
		DLib.chat.player(player.inRange(pos, RANGE_DEFAULT:GetInt()), RED, ...)
	end
end

local function SayEVE(ply, attacker, weapon, pos, ...)
	if hook.Run('TDeaths_Notify', ply, attacker, weapon, pos, false) ~= false then
		DLib.chat.player(player.inRange(pos, RANGE_NPC:GetInt()), RED, ...)
	end
end

local function SayPVP(ply, attacker, weapon, pos, ...)
	if hook.Run('TDeaths_Notify', ply, attacker, weapon, pos, true) ~= false then
		DLib.chat.player(player.inRange(pos, RANGE_PLAYER:GetInt()), RED, ...)
	end
end

local red = Color(190, 50, 50)

local Dict = {
	Fall = {
		'%s fell from high place',
		'%s hit the ground too hard',
		"%s fell to their death",
		"%s didn't bounce",
		"%s fell victim of gravity",
		"%s faceplanted the ground",
		"%s left a small crater",
		'%s likes to be smashed',
		'%s forgot to open his parachute',
		'%s forgot to open his wings',
		'%s became an angel',
		'%s was falling too long',
	},

	Drowned = {
		"%s forgot to breathe",
		"%s is sleeping with the fishes",
		"%s drowned",
		"%s became a seapony",
		"%s's lungs is filled with wrong liquid",
		"%s is shark food",
	},

	Fire = {
		'%s likes to play with fire',
		'%s burned to the crisp',
		'%s burned to the death',
		'%s became an ach',
		'%s was cooked alive',
	},

	Default = {
		"%s was slain",
		"%s was eviscerated",
		"%s was murdered",
		"%s's face was torn off",
		"%s's entrails were ripped out",
		"%s was destroyed",
		"%s's skull was crushed",
		"%s got massacred",
		"%s got impaled",
		"%s was torn in half",
		"%s was decapitated",
		"%s let their arms get torn off",
		"%s watched their innards become outards",
		"%s was brutally dissected",
		"%s's extremities were detached",
		"%s's body was mangled",
		"%s's vital organs were ruptured",
		"%s was turned into a pile of flesh",
		"%s's body was removed from this server",
		"%s was terminated",
		"%s got snapped in half",
		"%s was cut down the middle",
		"%s was chopped up",
		"%s's plead for death was answered",
		"%s's meat was ripped off the bone",
		"%s's flailing about was finally stopped",
		"%s had their head removed",
		"%s got a bullet in his head",
		"%s become a useless body",
		"%s gone to paradise",
		"%s's life was finished",
		"%s gone from this world",
		"%s's game was overed",
		"%s lost any of his blood",
		"%s lost his life connection",
		"%s's mind was damaged",
		"%s got pulverizered",
		"%s's brain was turned into forcemeat",
	},

	Poison = {
		'%s was poisoned to the death',
		'%s\'s veins was poisoned',
		'%s blood were turned into water',
	},

	Acid = {
		'%s disappeared',
		'%s was digested',
		'%s\'s vital organs were ruptured',
		'%s got splitted',
		'%s got disintegrated by acid',
		'%s got disassembled',
		'%s was oxidized',
		'%s tried to swin in acid',
	},

	Suicide = {
		'%s don\'t like his life',
		'%s don\'t wants to live anymore',
		'%s wrecks his head',
		'%s hads gone to hell',
		'%s likes to shoot his own head',
		'%s feels upset and done suicide',
		'%s forgot to unbind kill button',
		'%s swinged his sword and his head torn off his body',
		'%s used suicide revolver',
		'%s had very nasty hallucinations',
	},

	Prop = {
		'%s got smashed',
		'%s had their head removed',
		'All %s\'s bones got broken',
		'%s is crunching',
		'%s likes to play with heavy things',
		'%s tried to throw locomotive',
		'%s\'s head was removed by throwned prop',
		'%s got a thing stuck in his body',
	},

	Slash = {
		'%s got snapped in half',
		'%s was cut down the middle',
		'%s was chopped up',
		'%s was butchered by a knife',
		'%s turned into meat steak',
		'%s was butchered',
		'%s catched a cleaver by his head',
		"%s's face was torn off",
		"%s was turned into a pile of flesh",
		"%s had their head removed",
		"%s was torn in half",
		"%s got pulverizered",
	},

	Electricity = {
		'%s was hit by lighting',
		'%s played and died because of electricity',
		'%s got shocked to the death',
		'%s was zapped like a bee',
		'%s was cooked by electricity',
		'%s became a live battery',
		'%s was charged by electrons',
		'%s got plus and minus polarity',
		'%s loves to play with electricity',
		"%s didn't wear gloves while working with electricity",
		'%s got a heart attack because of electricity',
		'%s\'s heart got wrong electricity',
		'%s got cooked',
	},

	Laser = {
		'%s got snapped in half',
		'%s received much heat and melted',
		'%s was melted',
		'%s was perfectly cut',
		'%s\'s body got splitted',
		'%s fell at open laser',
		'%s was cut by a laser',
	},

	Disintegrated = {
		"%s gone from this world",
		"%s was terminated",
		"%s's body was removed from this server",
		"%s disappeared",
		"%s was disintegrated",
		"%s's body was divided into atoms",
		"%s's atmos disintegrated",
	},

	Explosion = {
		'%s was blown up',
		'%s\' organs is flying around',
		'%s got a grenade in his eye',
		'%s catched a rocket in wrong way',
		'%s was butchered',
		"%s's meat was ripped off the bone",
		'%s got impacted to second world',
		'%s got dismembered',
		'%s explodes',
		'BOOM! Wee now can see %s\'s meat around',
	},
}

local Names = {
	worldspawn = 'WORLD',
}

local DamageSpecific = {
	[DMG_BLAST] = Dict.Explosion,

	[DMG_SLASH] = Dict.Slash,
	[DMG_ENERGYBEAM] = Dict.Laser,
	[DMG_DISSOLVE] = Dict.Disintegrated,
	[DMG_SHOCK] = Dict.Electricity,

	[DMG_GENERIC] = Dict.Default, -- Generic
	[DMG_BULLET] = Dict.Default, -- Generic
	[DMG_BUCKSHOT] = Dict.Default, -- Generic
	[DMG_DIRECT] = Dict.Default, -- Generic

	[DMG_CRUSH] = Dict.Prop,
	[DMG_PHYSGUN] = Dict.Prop,
	[DMG_BURN] = Dict.Fire,
	[DMG_SLOWBURN] = Dict.Fire,
	[DMG_DROWN] = Dict.Drowned,
	[DMG_DROWNRECOVER] = Dict.Drowned,
	[DMG_FALL] = Dict.Fall,
	[DMG_PARALYZE] = Dict.Poison,
	[DMG_NERVEGAS] = Dict.Poison,
	[DMG_POISON] = Dict.Poison,
	[DMG_ACID] = Dict.Acid,
	[DMG_RADIATION] = Dict.Acid,
}

DamageSpecific[DMG_BLAST_SURFACE] = DamageSpecific[DMG_BLAST]
DamageSpecific[DMG_PLASMA] = DamageSpecific[DMG_ENERGYBEAM]
DamageSpecific[DMG_CLUB] = DamageSpecific[DMG_SLASH]

local function GetName(ent)
	local get = DLib.string.niceName(ent)
	return Names[get] or get
end

local function GetWeapon(ent, weapon)
	if IsValid(weapon) and weapon:GetClass() ~= ent:GetClass() then
		return GetName(weapon)
	end

	if ent.GetActiveWeapon and IsValid(ent:GetActiveWeapon()) then
		return GetName(ent:GetActiveWeapon())
	end

	return GetName(ent)
end

local function format(tableIn, ...)
	return string.format(table.frandom(tableIn), ...)
end

local damagePriority = {
	DMG_DISSOLVE,
	DMG_PLASMA,
	DMG_FALL,
	DMG_SHOCK,
	DMG_SONIC,
	DMG_ENERGYBEAM,
	DMG_ENERGYBEAM,
	DMG_RADIATION,
	DMG_DROWN,
	DMG_BURN,
	DMG_BURN,
	DMG_PARALYZE,
	DMG_NERVEGAS,
	DMG_NERVEGAS,
	DMG_ACID,
	DMG_NERVEGAS,
	DMG_POISON,
	DMG_CRUSH,
	DMG_VEHICLE,
	DMG_BLAST,
	DMG_CLUB,
	DMG_SLASH,
	DMG_BURN,
	DMG_BUCKSHOT,
	DMG_BULLET,
	DMG_AIRBOAT,
	DMG_DIRECT,
	DMG_PHYSGUN,
	DMG_SLOWBURN
}

local function GenericDeath(victim, attacker, guessWeapon, guessDamage, rawWeapon)
	if not ENABLE:GetBool() then return end

	local say2 = type(victim) == 'Player' and type(attacker) == 'Player' and SayPVP or
		(type(victim) == 'NPC' or type(victim) == 'NextBot') and (type(attacker) == 'NPC' or type(attacker) == 'NextBot') and SayEVE or SayPVE

	local valid, validWeapon, validWeaponRaw = IsValid(attacker), IsValid(guessWeapon) and guessWeapon ~= attacker, IsValid(rawWeapon) and rawWeapon ~= attacker
	local isProp = type(attacker) == 'Entity' and attacker:GetClass():find('prop_')
	local attackerIsAlive = type(attacker) == 'Player' or type(attacker) == 'NPC' or type(attacker) == 'NextBot'
	local pos = IsValid(victim) and victim:GetPos() or IsValid(attacker) and attacker:GetPos() or Vector(0, 0, 0)

	local function say(...)
		return say2(victim, attacker, guessWeapon, pos, ...)
	end

	if victim == attacker then
		local targetDict = DamageSpecific[guessDamage] or DamageSpecific[DMG_GENERIC]

		if validWeaponRaw then
			say(format(targetDict, GetName(victim)) .. string.format(' by %s\'s %s', GetName(attacker), GetName(rawWeapon)))
		else
			say(format(Dict.Suicide, GetName(victim)))
		end

		return
	end

	if isProp then
		if attackerIsAlive then
			say(format(Dict.Prop, GetName(victim)) .. ' by ' .. GetName(attacker))
		else
			say(format(Dict.Prop, GetName(victim)))
		end

		return
	end

	local targetDict = DamageSpecific[guessDamage] or DamageSpecific[DMG_GENERIC]

	if valid then
		if validWeapon then
			say(format(targetDict, GetName(victim)) .. string.format(' by %s\'s %s', GetName(attacker), GetName(guessWeapon)))
		else
			say(format(targetDict, GetName(victim)) .. string.format(' by %s', GetName(attacker)))
		end
	else
		say(format(targetDict, GetName(victim)))
	end
end

local function DoPlayerDeath(ply, attacker, dmginfo)
	local weapon, attacker, inflictor = DLib.combat.findWeaponAlt(dmginfo)
	GenericDeath(ply, attacker, weapon, table.sortedFind(dmginfo:TypesArray(), damagePriority, DMG_GENERIC), dmginfo:GetInflictor())
end

local function OnNPCKilled(npc, attacker, inflictor)
	if not ENABLE_NPC:GetBool() then return end
	if npc == attacker then return end
	local inflictor2 = inflictor

	inflictor = inflictor ~= attacker and
		inflictor or
		attacker.GetActiveWeapon and
		attacker:GetActiveWeapon():IsValid() and
		attacker:GetActiveWeapon() or
		inflictor

	GenericDeath(npc, attacker, inflictor, npc.TDeaths_LatestDamage and table.sortedFind(npc.TDeaths_LatestDamage, damagePriority, DMG_GENERIC) or DMG_GENERIC, inflictor2)
end

local function EntityTakeDamage(self, dmginfo)
	self.TDeaths_LatestAttacker = dmginfo:GetAttacker()
	self.TDeaths_LatestInflictor = dmginfo:GetInflictor()
	self.TDeaths_LatestDamage = dmginfo:TypesArray()
end

timer.Simple(0, function()
	for k, v in pairs(list.Get('NPC')) do
		if v.Name then
			Names[k] = v.Name
		end
	end
end)

hook.Add('DoPlayerDeath', 'TDeaths', DoPlayerDeath)
hook.Add('OnNPCKilled', 'TDeaths', OnNPCKilled)
hook.Add('EntityTakeDamage', 'TDeaths', EntityTakeDamage)
