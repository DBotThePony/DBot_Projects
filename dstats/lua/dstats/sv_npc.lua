
--[[
Copyright (C) 2016 DBot

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

DStats.npc = DStats.npc or {}
local self = DStats.npc
self.Query = DStats.Query
self.Link = DStats.LINK
self.NPC_IDS = self.NPC_IDS or {}
self.NPCS = self.NPCS or {}
self.NPCS_BUFFER = self.NPCS_BUFFER or {}
self.NPC_CHECKING = self.NPC_CHECKING or {}
self.WEAPONS = self.WEAPONS or {}
self.WEAPONS_BUFFER = self.WEAPONS_BUFFER or {}

--External functions
self.CheckWeapon = DStats.weapons.CheckClass
self.WeaponExists = DStats.weapons.WeaponExists
self.WeaponClassID = DStats.weapons.ClassID
self.WeaponClassFromID = DStats.weapons.ClassFromID

local function N(ply)
	return ply.DStats.npc
end

local function N_N(ply, class)
	self.CheckNPC(class)
	
	N(ply).NPCs[class] = N(ply).NPCs[class] or {
		kills = 0,
		deaths = 0,
	}
	
	return N(ply).NPCs[class]
end

local function ID(ply)
	return ply.DStats.PlyID
end

local AUTO = DStats.IsMySQL() and 'AUTO_INCREMENT' or 'AUTOINCREMENT'

function self.CheckNPC(class)
	if not self.INIT then return end
	if self.NPC_IDS[class] then return end
	if self.NPC_CHECKING[class] then return end --Prevent duplicates
	
	self.NPC_CHECKING[class] = true
	
	self.Query('INSERT INTO dstats__npc_id (npc) VALUES (' .. SQLStr(class) .. ')', function(data)
		self.Query('SELECT id FROM dstats__npc_id WHERE npc = ' .. SQLStr(class), function(data)
			self.NPC_CHECKING[class] = nil
			self.NPC_IDS[class] = tonumber(data[1].id)
		end)
	end)
end

function self.NPCExists(class)
	self.CheckNPC(class)
	return self.NPC_IDS[class] ~= nil
end

function self.NPCID(class)
	self.CheckNPC(class)
	return self.NPC_IDS[class] or -1
end

DStats.NPCID = self.NPCID

function self.ClassFromID(id)
	for k, v in pairs(self.NPC_IDS) do
		if v == id then return k end
	end
end

function self.AddKill(ent1, ent2, weapon)
	local e1ply, e2ply = ent1:IsPlayer(), ent2:IsPlayer()
	
	if e2ply and e1ply then return end --PvP
	
	if ent1 == weapon then
		weapon = IsValid(ent1:GetActiveWeapon()) and ent1:GetActiveWeapon() or weapon
	end
	
	local isValidWeapon = IsValid(weapon)
	local wclass
	
	if isValidWeapon then
		wclass = weapon:GetClass()
	end
	
	if wclass then
		self.CheckWeapon(wclass)
	end
	
	if e2ply or e1ply then --PvE
		local ply, npc
		local isKill = e1ply

		if e1ply then
			ply = ent1
			npc = ent2
		end
		
		if e2ply then
			ply = ent2
			npc = ent1
		end
		
		local class = npc:GetClass()
		self.CheckNPC(class)
		local Data = N(ply)
		local Def = Data.NPCs
		local Buffer = Data.NPCsBuffer
		
		local Defw = Data.Weapons
		local Bufferw = Data.WeaponsBuffer
		
		Def[class] = Def[class] or {}
		Def[class].kills = Def[class].kills or 0
		Def[class].deaths = Def[class].deaths or 0
		
		if isKill then
			Def[class].kills = Def[class].kills + 1
			
			if wclass then
				self.CheckWeapon(wclass)
				Defw[class] = Defw[class] or {}
				Defw[class][wclass] = (Defw[class][wclass] or 0) + 1
				
				Bufferw[class] = Bufferw[class] or {}
				Bufferw[class][wclass] = Defw[class][wclass]
			end
		else
			Def[class].deaths = Def[class].deaths + 1
		end
		
		Buffer[class] = Def[class]
		return
	end
	
	--EvE or NPC vs NPC
	
	local class1 = ent1:GetClass()
	local class2 = ent2:GetClass()
	
	self.CheckNPC(class1)
	self.CheckNPC(class2)
	
	self.NPCS[class1] = self.NPCS[class1] or {}
	self.NPCS[class1][class2] = (self.NPCS[class1][class2] or 0) + 1
	
	self.NPCS_BUFFER[class1] = self.NPCS_BUFFER[class1] or {}
	self.NPCS_BUFFER[class1][class2] = self.NPCS[class1][class2]
	
	--Table in table that was already in table and that table is in another table
	if wclass then
		self.WEAPONS[class1] = self.WEAPONS[class1] or {}
		self.WEAPONS[class1][class2] = self.WEAPONS[class1][class2] or {}
		self.WEAPONS[class1][class2][wclass] = (self.WEAPONS[class1][class2][wclass] or 0) + 1
		
		self.WEAPONS_BUFFER[class1] = self.WEAPONS_BUFFER[class1] or {}
		self.WEAPONS_BUFFER[class1][class2] = self.WEAPONS_BUFFER[class1][class2] or {}
		self.WEAPONS_BUFFER[class1][class2][wclass] = self.WEAPONS[class1][class2][wclass]
	end
end

function self.Load(ply)
	ply.DStats.npc = {}
	local i = ply.DStats.npc
	i.INIT = false
	i.NPCs = {}
	i.NPCsBuffer = {}
	i.Weapons = {}
	i.WeaponsBuffer = {}
	
	self.Query('SELECT npc, kills, deaths FROM dstats__npc_ply WHERE ply = ' .. ID(ply), function(data)
		for k, row in ipairs(data) do
			i.NPCs[self.ClassFromID(tonumber(row.npc))] = {
				kills = tonumber(row.kills),
				deaths = tonumber(row.deaths),
			}
		end
		
		i.INIT = true
	end)
	
	self.Query('SELECT npc, weapon, svalue FROM dstats__npc_ply_weapon WHERE ply = ' .. ID(ply), function(data)
		for k, row in ipairs(data) do
			local npc = self.ClassFromID(tonumber(row.npc))
			local weapon = self.WeaponClassFromID(tonumber(row.weapon))
			local kills = tonumber(row.svalue)
			
			i.Weapons[npc] = i.Weapons[npc] or {}
			i.Weapons[npc][weapon] = kills
		end
		
		i.INIT = true
	end)
end

function self.Save(ply)
	if not N(ply) then return end
	local Reply = N(ply).NPCsBuffer
	
	self.Link:Begin()
	
	local id = ID(ply)
	
	local format = {}
	
	for class, data in pairs(Reply) do
		table.insert(format, {id, self.NPCID(class), data.kills, data.deaths})
	end
	
	if self.Link.IsMySQL then
		self.Link:Add(DMySQL3.Replace('dstats__npc_ply', {'ply', 'npc', 'kills', 'deaths'}, unpack(format)))
	else --GMod SQLite is broken
		for k, v in ipairs(format) do
			self.Link:Add(DMySQL3.ReplaceEasy('dstats__npc_ply', {ply = v[1], npc = v[2], kills = v[3], deaths = v[4]}))
		end
	end
	
	format = {}
	
	for class, data in pairs(N(ply).WeaponsBuffer) do
		for wclass, kills in pairs(data) do
			table.insert(format, {id, self.NPCID(class), self.WeaponClassID(wclass), kills})
		end
	end
	
	if self.Link.IsMySQL then
		self.Link:Add(DMySQL3.Replace('dstats__npc_ply_weapon', {'ply', 'npc', 'weapon', 'svalue'}, unpack(format)))
	else --GMod SQLite is broken
		for k, v in ipairs(format) do
			self.Link:Add(DMySQL3.ReplaceEasy('dstats__npc_ply_weapon', {ply = v[1], npc = v[2], weapon = v[3], svalue = v[4]}))
		end
	end

	self.Link:Commit()
	
	N(ply).NPCsBuffer = {}
	N(ply).WeaponsBuffer = {}
end

function self.SaveNPCs()
	self.Link:Begin()
	
	local format = {}
	
	for class1, data in pairs(self.NPCS_BUFFER) do
		local id = self.NPCID(class1)
		
		for class2, kills in pairs(data) do
			table.insert(format, {id, self.NPCID(class2), kills})
		end
	end
	
	if self.Link.IsMySQL then
		self.Link:Add(DMySQL3.Replace('dstats__npc_npc', {'npc1', 'npc2', 'kills'}, unpack(format)))
	else --GMod SQLite is broken
		for k, v in ipairs(format) do
			self.Link:Add(DMySQL3.ReplaceEasy('dstats__npc_npc', {npc1 = v[1], npc2 = v[2], kills = v[3]}))
		end
	end
	
	format = {}
	
	for class1, data in pairs(self.WEAPONS_BUFFER) do
		local id = self.NPCID(class1)
		
		for class2, data2 in pairs(data) do
			local id2 = self.NPCID(class2)
			
			for wclass, kills in pairs(data2) do
				table.insert(format, {id, id2, self.WeaponClassID(wclass), kills})
			end
		end
	end
	
	if self.Link.IsMySQL then
		self.Link:Add(DMySQL3.Replace('dstats__npc_npc_weapon_d', {'npc1', 'npc2', 'weapon', 'svalue'}, unpack(format)))
	else --GMod SQLite is broken
		for k, v in ipairs(format) do
			self.Link:Add(DMySQL3.ReplaceEasy('dstats__npc_npc_weapon_d', {npc1 = v[1], npc2 = v[2], weapon = v[3], svalue = v[4]}))
		end
	end
	
	format = {}
	
	for class1, data in pairs(self.WEAPONS) do
		local Wep = {}
		
		for class2, data2 in pairs(data) do
			for wclass, kills in pairs(data2) do
				Wep[wclass] = (Wep[wclass] or 0) + kills
			end
		end
		
		for wclass, kills in pairs(Wep) do
			table.insert(format, {self.NPCID(class1), self.WeaponClassID(wclass), kills})
		end
	end
	
	if self.Link.IsMySQL then
		self.Link:Add(DMySQL3.Replace('dstats__npc_npc_weapon', {'npc', 'weapon', 'svalue'}, unpack(format)))
	else --GMod SQLite is broken
		for k, v in ipairs(format) do
			self.Link:Add(DMySQL3.ReplaceEasy('dstats__npc_npc_weapon', {npc = v[1], weapon = v[2], svalue = v[3]}))
		end
	end
	
	self.Link:Commit()
	
	self.NPCS_BUFFER = {}
	self.WEAPONS_BUFFER = {}
end

function self.SaveAll()
	for k, v in ipairs(player.GetAll()) do
		self.Save(v)
	end
	
	self.SaveNPCs()
end

function self.SaveTimer()
	for k, v in ipairs(player.GetAll()) do
		if not v.DStats then continue end
		if not N(v) then continue end
		if not N(v).INIT then continue end
		self.Save(v)
	end
	
	self.SaveNPCs()
end

timer.Create('DStats.npc.SaveTimer', 10, 0, self.SaveTimer)

local function LoadWeaponD()
	self.Query('SELECT * FROM dstats__npc_npc_weapon_d', function(data)
		for k, row in ipairs(data) do
			local class1 = self.ClassFromID(tonumber(row.npc1))
			local class2 = self.ClassFromID(tonumber(row.npc2))
			local wclass = self.WeaponClassFromID(tonumber(row.weapon))
			local kills = tonumber(row.svalue)
			
			self.WEAPONS[class1] = self.WEAPONS[class1] or {}
			self.WEAPONS[class1][class2] = self.WEAPONS[class1][class2] or {}
			self.WEAPONS[class1][class2][wclass] = (self.WEAPONS[class1][class2][wclass] or 0) + 1
		end
	end)
end

function self.Init()
	self.INIT = false
	
	self.Query('SELECT * FROM dstats__npc_id', function(data)
		self.INIT = true
		
		for k, row in ipairs(data) do
			self.NPC_IDS[row.npc] = tonumber(row.id)
		end
		
		self.Query('SELECT * FROM dstats__npc_npc', function(data)
			for k, row in ipairs(data) do
				local class1 = self.ClassFromID(tonumber(row.npc1))
				local class2 = self.ClassFromID(tonumber(row.npc2))
				
				self.NPCS[class1] = self.NPCS[class1] or {}
				self.NPCS[class1][class2] = tonumber(row.kills)
			end
		end)
		
		--Wait before weapons IDs gets loaded
		if DStats.weapons.INIT then
			LoadWeaponD()
		else
			hook.Add('DStats_WeaponsLoaded', 'DStats.npc.hooks', LoadWeaponD)
		end
	end)
end

local function PlayerDeath(ply, weapon, attacker)
	self.AddKill(attacker, ply, weapon)
end

local function OnNPCKilled(npc, attacker, weapon)
	self.AddKill(attacker, npc, weapon)
end

self.Tables = {
	[[
		CREATE TABLE IF NOT EXISTS `dstats__npc_ply`
		(
			`ply` INTEGER NOT NULL,
			`npc` INTEGER NOT NULL,
			`kills` BIGINT NOT NULL,
			`deaths` BIGINT NOT NULL,
			PRIMARY KEY (`ply`, `npc`)
		)
	]],[[
		CREATE TABLE IF NOT EXISTS `dstats__npc_ply_weapon`
		(
			`ply` INTEGER NOT NULL,
			`npc` INTEGER NOT NULL,
			`weapon` INTEGER NOT NULL,
			`svalue` BIGINT NOT NULL,
			PRIMARY KEY (`ply`, `npc`, `weapon`)
		)
	]],[[
		CREATE TABLE IF NOT EXISTS `dstats__npc_npc`
		(
			`npc1` INTEGER NOT NULL,
			`npc2` INTEGER NOT NULL,
			`kills` BIGINT NOT NULL,
			PRIMARY KEY (`npc1`, `npc2`)
		)
	]],[[
		CREATE TABLE IF NOT EXISTS `dstats__npc_npc_weapon`
		(
			`npc` INTEGER NOT NULL,
			`weapon` INTEGER NOT NULL,
			`svalue` BIGINT NOT NULL,
			PRIMARY KEY (`npc`, `weapon`)
		)
	]],[[
		CREATE TABLE IF NOT EXISTS `dstats__npc_npc_weapon_d`
		(
			`npc1` INTEGER NOT NULL,
			`npc2` INTEGER NOT NULL,
			`weapon` INTEGER NOT NULL,
			`svalue` BIGINT NOT NULL,
			PRIMARY KEY (`npc1`, `npc2`, `weapon`)
		)
	]],[[
		CREATE TABLE IF NOT EXISTS `dstats__npc_id`
		(
			`id` INTEGER NOT NULL PRIMARY KEY %s,
			`npc` VARCHAR(32) NOT NULL
		)
	]],
}

hook.Add('PlayerDeath', 'DStats.npc.hooks', PlayerDeath)
hook.Add('OnNPCKilled', 'DStats.npc.hooks', OnNPCKilled)

DStats.Hooks('npc', self)
