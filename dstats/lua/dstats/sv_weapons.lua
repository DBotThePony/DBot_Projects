
--[[
Copyright (C) 2016-2018 DBot


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

DStats.weapons = DStats.weapons or {}
local self = DStats.weapons
self.Query = DStats.Query
self.Link = DStats.LINK
self.CHECKING = {}
self.IDS = self.IDS or {}
self.KILLS = self.KILLS or {}
self.KILLS_BUFFER = self.KILLS_BUFFER or {}

local function N(ply)
	return ply.DStats.weapons
end

local function ID(ply)
	return ply.DStats.PlyID
end

function self.CheckClass(class)
	if not self.INIT then return end
	if self.IDS[class] then return end
	if self.CHECKING[class] then return end --Prevent duplicates

	self.CHECKING[class] = true

	self.Query('INSERT INTO dstats__weapons_id (class) VALUES (' .. SQLStr(class) .. ')', function(data)
		self.Query('SELECT id FROM dstats__weapons_id WHERE class = ' .. SQLStr(class), function(data)
			self.CHECKING[class] = nil
			self.IDS[class] = tonumber(data[1].id)
		end)
	end)
end

function self.WeaponExists(class)
	self.CheckClass(class)
	return self.IDS[class] ~= nil
end

function self.ClassID(class)
	self.CheckClass(class)
	return self.IDS[class] or -1
end

function self.ClassFromID(id)
	for k, v in pairs(self.IDS) do
		if v == id then return k end
	end
end

DStats.CheckWeapon = self.CheckClass
DStats.WeaponID = self.ClassID
DStats.WeaponClassFromID = self.ClassFromID

function self.Load(ply)
	ply.DStats.weapons = {}
	local i = ply.DStats.weapons
	i.INIT = false
	i.Classes = {}
	i.Classes.NPC = {}
	i.Classes.PLY = {}
	i.ClassesBuffer = {}
	i.ClassesBuffer.NPC = {}
	i.ClassesBuffer.PLY = {}

	self.Query('SELECT * FROM dstats__weapons_ply WHERE ply = ' .. ID(ply), function(data)
		for k, row in ipairs(data) do
			i.Classes.PLY[self.ClassFromID(tonumber(row.class))] = tonumber(row.svalue)
		end

		i.INIT = true
	end)

	self.Query('SELECT * FROM dstats__weapons_ply_npc WHERE ply = ' .. ID(ply), function(data)
		for k, row in ipairs(data) do
			i.Classes.NPC[self.ClassFromID(tonumber(row.class))] = tonumber(row.svalue)
		end

		i.INIT = true
	end)
end

function self.Save(ply)
	if not N(ply) then return end
	local Reply = N(ply).ClassesBuffer

	self.Link:Begin()

	local id = ID(ply)

	local format = {}

	for class, svalue in pairs(Reply.PLY) do
		table.insert(format, {id, self.ClassID(class), svalue})
	end

	if self.Link.IsMySQL then
		self.Link:Add(DMySQL3.Replace('dstats__npc_ply', {'ply', 'class', 'svalue'}, unpack(format)))
	else --GMod SQLite is broken
		for k, v in ipairs(format) do
			self.Link:Add(DMySQL3.ReplaceEasy('dstats__npc_ply', {ply = v[1], class = v[2], svalue = v[3]}))
		end
	end

	format = {}

	for class, svalue in pairs(Reply.NPC) do
		table.insert(format, {id, self.ClassID(class), svalue})
	end

	if self.Link.IsMySQL then
		self.Link:Add(DMySQL3.Replace('dstats__weapons_ply_npc', {'ply', 'class', 'svalue'}, unpack(format)))
	else --GMod SQLite is broken
		for k, v in ipairs(format) do
			self.Link:Add(DMySQL3.ReplaceEasy('dstats__weapons_ply_npc', {ply = v[1], class = v[2], svalue = v[3]}))
		end
	end

	self.Link:Commit()

	Reply.NPC = {}
	Reply.PLY = {}
end

function self.SaveWeapons()
	self.Link:Begin()

	local format = {}

	for class, data in pairs(self.KILLS_BUFFER) do
		table.insert(format, {self.ClassID(class), data.svalue, data.pkills, data.nkills})
	end

	if self.Link.IsMySQL then
		self.Link:Add(DMySQL3.Replace('dstats__weapons', {'class', 'svalue', 'pkills', 'nkills'}, unpack(format)))
	else --GMod SQLite is broken
		for k, v in ipairs(format) do
			self.Link:Add(DMySQL3.ReplaceEasy('dstats__weapons', {class = v[1], svalue = v[2], pkills = v[3], nkills = v[4]}))
		end
	end

	self.Link:Commit()
	self.KILLS_BUFFER = {}
end

function self.SaveAll()
	for k, v in ipairs(player.GetAll()) do
		self.Save(v)
	end

	self.SaveWeapons()
end

function self.SaveTimer()
	for k, v in ipairs(player.GetAll()) do
		if not v.DStats then continue end
		if not N(v) then continue end
		if not N(v).INIT then continue end
		self.Save(v)
	end

	self.SaveWeapons()
end

function self.Init()
	self.INIT = false

	self.Query('SELECT * FROM dstats__weapons_id', function(data)
		self.INIT = true

		for k, row in ipairs(data) do
			self.IDS[row.class] = tonumber(row.id)
		end

		hook.Run('DStats_WeaponsLoaded')

		self.Query('SELECT * FROM dstats__weapons', function(data)
			for k, row in ipairs(data) do
				local class = self.ClassFromID(tonumber(row.class))

				self.KILLS[class] = {}
				self.KILLS[class].svalue = tonumber(row.svalue)
				self.KILLS[class].pkills = tonumber(row.pkills)
				self.KILLS[class].nkills = tonumber(row.nkills)
			end
		end)
	end)
end

function self.TriggerKill(attacker, weapon, victim)
	if IsValid(attacker) and attacker:IsPlayer() and attacker == weapon then
		local get = attacker:GetActiveWeapon()
		weapon = IsValid(get) and get or weapon
	end

	if attacker == weapon then return end
	if not IsValid(weapon) then return end

	local class = weapon:GetClass()
	self.CheckClass(class)

	local npcKill = IsValid(victim) and victim:IsNPC()
	local plyKill = IsValid(victim) and victim:IsPlayer()

	if IsValid(attacker) and attacker:IsPlayer() then
		local ply = attacker
		local i = N(ply)
		local Def = i.Classes
		local Buffer = i.ClassesBuffer

		if npcKill then
			Def.NPC[class] = (Def.NPC[class] or 0) + 1
			Buffer.NPC[class] = Def.NPC[class]
		elseif plyKill then
			Def.PLY[class] = (Def.PLY[class] or 0) + 1
			Buffer.PLY[class] = Def.PLY[class]
		end
	end

	self.KILLS[class] = self.KILLS[class] or {}
	self.KILLS[class].svalue = self.KILLS[class].svalue or 0
	self.KILLS[class].pkills = self.KILLS[class].pkills or 0
	self.KILLS[class].nkills = self.KILLS[class].nkills or 0

	self.KILLS[class].svalue = self.KILLS[class].svalue + 1

	if npcKill then
		self.KILLS[class].nkills = self.KILLS[class].nkills + 1
	end

	if plyKill then
		self.KILLS[class].pkills = self.KILLS[class].pkills + 1
	end

	self.KILLS_BUFFER[class] = self.KILLS[class]
end

local function PlayerDeath(ply, weapon, attacker)
	self.TriggerKill(attacker, weapon, ply)
end

local function OnNPCKilled(npc, attacker, weapon)
	self.TriggerKill(attacker, weapon, npc)
end

self.Tables = {
	[[
		CREATE TABLE IF NOT EXISTS `dstats__weapons_ply`
		(
			`ply` INTEGER NOT NULL,
			`class` INTEGER NOT NULL,
			`svalue` BIGINT NOT NULL,
			PRIMARY KEY (`ply`, `class`)
		)
	]],[[
		CREATE TABLE IF NOT EXISTS `dstats__weapons_ply_npc`
		(
			`ply` INTEGER NOT NULL,
			`class` INTEGER NOT NULL,
			`svalue` BIGINT NOT NULL,
			PRIMARY KEY (`ply`, `class`)
		)
	]],[[
		CREATE TABLE IF NOT EXISTS `dstats__weapons`
		(
			`class` INTEGER NOT NULL,
			`svalue` BIGINT NOT NULL,
			`pkills` BIGINT NOT NULL,
			`nkills` BIGINT NOT NULL,
			PRIMARY KEY (`class`)
		)
	]],[[
		CREATE TABLE IF NOT EXISTS `dstats__weapons_id`
		(
			`id` INTEGER NOT NULL PRIMARY KEY %s,
			`class` VARCHAR(32) NOT NULL
		)
	]],
}

hook.Add('PlayerDeath', 'DStats.weapons.hooks', PlayerDeath)
hook.Add('OnNPCKilled', 'DStats.weapons.hooks', OnNPCKilled)

timer.Create('DStats.weapons.SaveTimer', 10, 0, self.SaveTimer)
DStats.Hooks('weapons', self)
