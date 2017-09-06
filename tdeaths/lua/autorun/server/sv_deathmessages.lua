
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

--Death messages!
--Was maded and still used on our PonyRP server, so there is pony thematic messages

local ENABLE = CreateConVar('sv_death_enable', '1', FCVAR_ARCHIVE, 'Enable Death Messages')
local RANGE_DEFAULT = CreateConVar('sv_death_range', '2000', FCVAR_ARCHIVE, 'Broadcast range of default death message')
local RANGE_PLAYER = CreateConVar('sv_death_range_player', '750', FCVAR_ARCHIVE, 'Broadcast range of deaths messages related to combat against real targets (Player, NPC)')

util.AddNetworkString('DBot.TerrariaDeath')

local Meta = {
	lastattacker = '',
	lastattackerN = 0,
}

local function Check(ply)
	if not IsValid(ply) then return end
	ply.DMesses = ply.DMesses or {}
	ply.DMesses.custom = ply.DMesses.custom or {}
	ply.DMesses.dmg = ply.DMesses.dmg or {}
	
	local I = ply.DMesses
	
	for k, v in pairs(Meta) do
		I[k] = I[k] or v
	end
end

local function Find(pos, radius)
	local t = {}
	
	for k, v in pairs(player.GetAll()) do
		if v:GetPos():Distance(pos) > radius then continue end
		if DVars and not DVars.ClientVar(v, 'misc_deathmessage', true) then continue end
		table.insert(t, v)
	end
	
	return t
end

local function Say(ply, attacker, weapon, pos, ...)
	local can = hook.Run('TDeaths_Notify', ply, attacker, weapon, pos, false)
	if can == false then return end
	
	net.Start('DBot.TerrariaDeath')
	net.WriteTable({...}) 
	net.Send(Find(pos, RANGE_DEFAULT:GetInt()))
end

local function Say2(ply, attacker, weapon, pos, ...)
	local can = hook.Run('TDeaths_Notify', ply, attacker, weapon, pos, true)
	if can == false then return end
	
	net.Start('DBot.TerrariaDeath')
	net.WriteTable({...}) 
	net.Send(Find(pos, RANGE_PLAYER:GetInt()))
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
	
	[DMG_GENERIC] = Dict.Default, --Generic
	[DMG_BULLET] = Dict.Default, --Generic
	[DMG_BUCKSHOT] = Dict.Default, --Generic
	[DMG_DIRECT] = Dict.Default, --Generic
	
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

timer.Simple(0, function()
	for k, v in pairs(list.Get('NPC')) do
		if v.Name then
			Names[k] = v.Name
		end
	end
	
	for k, v in pairs(list.Get('Weapon')) do
		if v.PrintName then
			Names[k] = v.PrintName
		end
	end
end)

local function GetName(ent)
	if not IsValid(ent) then return '' end
	if ent.Nick then return ent:Nick() end
	if ent.PrintName and ent.PrintName ~= '' then return ent.PrintName end
	if ent.GetPrintName then return ent:GetPrintName() end
	return Names[ent:GetClass()] or ent:GetClass()
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

local function HandleDeath(ply, attacker, weapon)
	if not IsValid(ply) then return end
	Check(ply)
	local I = ply.DMesses
	if not I then return end --Invalid entity
	
	local func = ply:IsPlayer() and Say2 or Say
	
	local cTime = CurTime()

	if IsValid(weapon) and weapon:IsPlayer() then
		attacker = weapon
	end
	
	if not IsValid(attacker) and IsValid(weapon) then
		attacker = weapon
	end
	
	if attacker == ply then
		func(ply, attacker, weapon, ply:GetPos(), red, string.format(table.Random(Dict.Suicide), GetName(ply)))
		return
	end

	local AttackerName = GetName(attacker)
	local WeaponName = GetWeapon(attacker, weapon)
	
	I.dmg[DMG_CRUSH] = I.dmg[DMG_CRUSH] or 0
	
	if I.dmg[DMG_CRUSH] > cTime then
		func(ply, attacker, weapon, ply:GetPos(), red, string.format(table.Random(Dict.Prop), GetName(ply)))
		return
	end
	
	local phrase = table.Random(Dict.Default)
	
	local ValidType
	local Last = 0
	
	for k, v in pairs(I.dmg) do
		if v > cTime and v > Last then
			Last = v
			ValidType = k
		end
	end
	
	if ValidType then
		phrase = table.Random(DamageSpecific[ValidType])
	end
	
	if not (attacker:IsPlayer() or attacker:IsNPC()) then
		if IsValid(attacker) then
			func(ply, attacker, weapon, ply:GetPos(), red, string.format(phrase .. ' by %s', GetName(ply), AttackerName))
		elseif WeaponName ~= '' then
			func(ply, attacker, weapon, ply:GetPos(), red, string.format(phrase .. ' by %s', GetName(ply), WeaponName))
		else
			func(ply, attacker, weapon, ply:GetPos(), red, string.format(phrase, GetName(ply)))
		end
	else
		if WeaponName ~= '' then
			func(ply, attacker, weapon, ply:GetPos(), red, string.format(phrase .. ' by %s\'s %s', GetName(ply), AttackerName, WeaponName))
		else
			func(ply, attacker, weapon, ply:GetPos(), red, string.format(phrase .. ' by %s', GetName(ply), AttackerName))
		end
	end
end

local function EntityTakeDamage(ply, dmg)
	if not IsValid(ply) then return end
	if not ENABLE:GetBool() then return end
	Check(ply)
	local I = ply.DMesses
	if not I then return end --Invalid entity
	
	local attacker = dmg:GetAttacker()
	if not IsValid(attacker) then return end
	
	local weapon = dmg:GetInflictor()
	local class = attacker:GetClass()
	local dmgType = dmg:GetDamageType()
	
	if DamageSpecific[dmgType] then
		I.dmg[dmgType] = CurTime() + 0.2
	end
	
	I.lastattacker = GetName(attacker)
	I.lastattackerN = CurTime() + 0.2
end

local function PlayerDeath(ply, attacker, weapon)
	--Run on next frame
	if not ENABLE:GetBool() then return end
	
	local can = hook.Run('TDeaths_PlayerDeath', ply, attacker, weapon)
	if can == false then return end
	
	timer.Simple(0, function()
		HandleDeath(ply, attacker, weapon)
	end)
end

local SHOULD_NPC = CreateConVar('sv_npcdeathmessage', '0', FCVAR_ARCHIVE, 'Should display NPC death as regular death')
local function OnNPCKilled(ent, attacker, weapon)
	--Run on next frame
	if not ENABLE:GetBool() then return end
	if not SHOULD_NPC:GetBool() then return end
	
	local can = hook.Run('TDeaths_OnNPCKilled', ent, attacker, weapon)
	if can == false then return end
	
	timer.Simple(0, function()
		HandleDeath(ent, attacker, weapon)
	end)
end

hook.Add('PlayerDeath', 'DBot.TerrariaDeath', PlayerDeath)
hook.Add('OnNPCKilled', 'DBot.TerrariaDeath', OnNPCKilled)
hook.Add('EntityTakeDamage', 'DBot.TerrariaDeath', EntityTakeDamage)
