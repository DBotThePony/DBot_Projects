
-- Copyright (C) 2016-2019 DBotThePony

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

local ENABLE = CreateConVar('tdeaths_enable', '1', FCVAR_ARCHIVE, 'Enable Death Messages')
local ENABLE_NPC = CreateConVar('tdeaths_enable_npc', '1', FCVAR_ARCHIVE, 'Enable Death Messages of NPCs')
local RANGE_DEFAULT = CreateConVar('tdeaths_range', '4000', FCVAR_ARCHIVE, 'Broadcast range of default death message')
local RANGE_NPC = CreateConVar('tdeaths_range', '1000', FCVAR_ARCHIVE, 'Broadcast range of npc vs npc death message')
local RANGE_PLAYER = CreateConVar('tdeaths_range_pvp', '2000', FCVAR_ARCHIVE, 'Broadcast range of deaths messages related to combat against real targets (Player, NPC)')

local RED = Color(215, 64, 64)

local function SayPVE(ply, attacker, weapon, pos, ...)
	if hook.Run('TDeaths_Notify', ply, attacker, weapon, pos, false) ~= false then
		DLib.chat.player(player.InRange(pos, RANGE_DEFAULT:GetInt()), RED, ...)
	end
end

local function SayEVE(ply, attacker, weapon, pos, ...)
	if hook.Run('TDeaths_Notify', ply, attacker, weapon, pos, false) ~= false then
		DLib.chat.player(player.InRange(pos, RANGE_NPC:GetInt()), RED, ...)
	end
end

local function SayPVP(ply, attacker, weapon, pos, ...)
	if hook.Run('TDeaths_Notify', ply, attacker, weapon, pos, true) ~= false then
		DLib.chat.player(player.InRange(pos, RANGE_PLAYER:GetInt()), RED, ...)
	end
end

local red = Color(190, 50, 50)

local Dict = {
	Fall = {
		'%s fell from a high place',
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
		'%s fell for too long',
	},

	Drowned = {
		"%s forgot to breathe",
		"%s is sleeping with the fish",
		"%s drowned",
		"%s's lungs got filled with liquid",
		"%s is shark food",
	},

	Fire = {
		'%s like to play with fire',
		'%s burned to a crisp',
		'%s burned to the death',
		'%s turned into an ach',
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
		"%s's game was overed",
		"%s lost any of his blood",
		"%s lost his life connection",
		"%s's mind was damaged",
		"%s got pulverizered",
		"%s's brain was turned into forcemeat",
	},

	Poison = {
		'%s was poisoned to the death',
		'%s\'s veins turned green',
		'%s blood were turned into water',
	},

	Acid = {
		'%s got digested',
		'%s was digested',
		'%s\'s vital organs were ruptured',
		'%s got splitted',
		'%s was oxidized',
		'%s likes to play in acid',
	},

	Suicide = {
		'%s took an easy way to quit',
		'%s don\'t want to live anymore',
		'%s wrecked his head',
		'%s had gone to hell',
		'%s like to shoot his own head',
		'%s feels upset and did a bad thing',
		'%s forgot to unbind kill button',
		'%s pointed his gun right next to his ear',
		'%s had very nasty hallucinations',
	},

	Prop = {
		'%s got smashed',
		'%s had their head removed',
		'All %s\'s bones got broken',
		'%s got crushed',
		'%s like to lift kilograms',
		'%s tried to throw locomotive',
		'%s got his head removed',
		'%s had their inners cut out',
	},

	Slash = {
		'%s got snapped in half',
		'%s was cut down the middle',
		'%s was chopped up',
		'%s turned into meat steak',
		'%s was butchered',
		'%s catched a cleaver using his own head',
		"%s's face was torn off",
		"%s was turned into a pile of flesh",
		"%s had their head removed",
		"%s was torn in half",
	},

	Electricity = {
		'%s was struck by lighting',
		'%s played and died because of electricity',
		'%s was shocked to death',
		'%s was zapped like a bee',
		'%s forgot to not to touch powered wires',
		'%s is pretty much dead now',
		'%s had their electrons moved',
		'%s forgot safety instructions',
		"%s got exposed to current",
		'%s got a heart attack because of voltage',
		'%s couldn\'t contain the watts',
	},

	Laser = {
		'%s got snapped in half',
		'%s overheated',
		'%s was perfectly cut in middle',
		'%s was splitted in half',
		'%s walked into a beam of light',
		'%s was cut down by a laser',
	},

	Disintegrated = {
		"%s was terminated",
		"%s's body was removed from this server",
		"%s is pretty much gone now",
		"%s was disintegrated",
		"%s decayed",
	},

	Explosion = {
		'%s\' organs is flying around',
		'%s got a grenade in his eye',
		'%s experienced quick energy expansion',
		"%s's meat was blown off their bones",
		'%s got impacted to second world',
		'%s got dismembered',
		'%s blew up',
		'It looks like they are gonna glue %s back together',
	},
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

local function GetWeapon(ent, weapon)
	if IsValid(weapon) and weapon:GetClass() ~= ent:GetClass() then
		return weapon:GetPrintNameDLib()
	end

	if ent.GetActiveWeapon and IsValid(ent:GetActiveWeapon()) then
		return ent:GetActiveWeapon():GetPrintNameDLib()
	end

	return ent:GetPrintNameDLib()
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
			say(format(targetDict, victim:GetPrintNameDLib()) .. string.format(' by %s\'s %s', attacker:GetPrintNameDLib(), rawWeapon:GetPrintNameDLib()))
		else
			say(format(Dict.Suicide, victim:GetPrintNameDLib()))
		end

		return
	end

	if isProp then
		if attackerIsAlive then
			say(format(Dict.Prop, victim:GetPrintNameDLib()) .. ' by ' .. attacker:GetPrintNameDLib())
		else
			say(format(Dict.Prop, victim:GetPrintNameDLib()))
		end

		return
	end

	local targetDict = DamageSpecific[guessDamage] or DamageSpecific[DMG_GENERIC]

	if valid then
		if validWeapon then
			say(format(targetDict, victim:GetPrintNameDLib()) .. string.format(' by %s\'s %s', attacker:GetPrintNameDLib(), guessWeapon:GetPrintNameDLib()))
		else
			say(format(targetDict, victim:GetPrintNameDLib()) .. string.format(' by %s', attacker:GetPrintNameDLib()))
		end
	else
		say(format(targetDict, victim:GetPrintNameDLib()))
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

	attacker = IsValid(attacker) and attacker or npc
	inflictor = IsValid(inflictor) and inflictor or attacker

	GenericDeath(npc, attacker, inflictor, npc.TDeaths_LatestDamage and table.sortedFind(npc.TDeaths_LatestDamage, damagePriority, DMG_GENERIC) or DMG_GENERIC, inflictor2)
end

local function EntityTakeDamage(self, dmginfo)
	self.TDeaths_LatestAttacker = dmginfo:GetAttacker()
	self.TDeaths_LatestInflictor = dmginfo:GetInflictor()
	self.TDeaths_LatestDamage = dmginfo:TypesArray()
end

hook.Add('DoPlayerDeath', 'TDeaths', DoPlayerDeath)
hook.Add('OnNPCKilled', 'TDeaths', OnNPCKilled)
hook.Add('EntityTakeDamage', 'TDeaths', EntityTakeDamage)
