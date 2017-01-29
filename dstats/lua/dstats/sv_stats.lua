
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

local ENABLE_DAILY = CreateConVar('sv_dstats_s_daily', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable daily stats saving?')
local ENABLE_SESSION = CreateConVar('sv_dstats_s_session', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable session stats saving?')

DStats.stats = DStats.stats or {}
local self = DStats.stats
self.Query = DStats.Query
self.Link = DStats.LINK
self.STATS = self.STATS or {}
self.STATS_IDS = {}

local function N(ply)
	return ply.DStats.stats
end

local function ID(ply)
	return ply.DStats.PlyID
end

function self.StatID(id)
	return self.STATS_IDS[id]
end

function self.StatNameFromID(id)
	for k, v in pairs(self.STATS_IDS) do
		if v == id then return k end
	end
end

function self.Hook(id, func, p)
	hook.Add(id, 'DStats.stats.hooks', func, p)
end

function self.ForatToday()
	return os.date('%d_%m_%y', os.time())
end

function self.Load(ply, steamid)
	ply.DStats.stats = {}
	ply.DStats.stats.LOADED = false
	ply.DStats.stats.total = {}
	ply.DStats.stats.daily = {}
	ply.DStats.stats.session = {}
	
	ply.DStats.stats.cache = {}
	ply.DStats.stats.cache.total = {}
	ply.DStats.stats.cache.daily = {}
	ply.DStats.stats.cache.session = {}
	
	ply.DStats.stats.stamp = os.time()
	ply.DStats.stats.savein = CurTime() + 60
	
	self.Query('SELECT stat, svalue FROM dstats__default WHERE ply = ' .. SQLStr(steamid), function(data)
		ply.DStats.stats.LOADED = true
		
		for k, v in ipairs(self.STATS) do
			ply.DStats.stats.total[v[1]] = v[2]
		end
		
		for k, row in ipairs(data) do
			ply.DStats.stats.total[self.StatNameFromID(tonumber(row.stat))] = tonumber(row.svalue)
		end
	end)
	
	self.Query('SELECT stat, svalue FROM dstats__default_daily WHERE day = ' .. SQLStr(self.ForatToday()) .. ' AND ply = ' .. SQLStr(steamid), function(data)
		for k, v in ipairs(self.STATS) do
			ply.DStats.stats.daily[v[1]] = v[2]
		end
		
		for k, row in ipairs(data) do
			ply.DStats.stats.daily[self.StatNameFromID(tonumber(row.stat))] = tonumber(row.svalue)
		end
	end)
	
	for k, v in ipairs(self.STATS) do
		ply.DStats.stats.session[v[1]] = v[2]
	end
end

function self.Save(ply)
	if not ply.DStats.INIT then return end
	self.Link:Begin()
	
	local steamid = ID(ply)
	local format = {}
	local Reply = N(ply).cache
	
	for stat, value in pairs(Reply.total) do
		table.insert(format, {steamid, self.StatID(stat), math.ceil(value)})
	end
	
	if self.Link.IsMySQL then
		self.Link:Add(DMySQL3.Replace('dstats__default', {'ply', 'stat', 'svalue'}, unpack(format)))
	else --GMod SQLite is broken
		for k, v in ipairs(format) do
			self.Link:Add(DMySQL3.ReplaceEasy('dstats__default', {ply = v[1], stat = v[2], svalue = v[3]}))
		end
	end
	
	if ENABLE_DAILY:GetBool() then
		format = {}
		local day = self.ForatToday()
		
		for stat, value in pairs(Reply.daily) do
			table.insert(format, {steamid, self.StatID(stat), math.ceil(value), day})
		end
		
		if self.Link.IsMySQL then
			self.Link:Add(DMySQL3.Replace('dstats__default_daily', {'ply', 'stat', 'svalue', 'day'}, unpack(format)))
		else --GMod SQLite is broken
			for k, v in ipairs(format) do
				self.Link:Add(DMySQL3.ReplaceEasy('dstats__default_daily', {ply = v[1], stat = v[2], svalue = v[3], day = v[4]}))
			end
		end
	end
	
	if ENABLE_SESSION:GetBool() then
		local s = N(ply).stamp
		format = {}
		
		for stat, value in pairs(Reply.session) do
			table.insert(format, {steamid, self.StatID(stat), math.ceil(value), s})
		end
		
		if self.Link.IsMySQL then
			self.Link:Add(DMySQL3.Replace('dstats__default_daily', {'ply', 'stat', 'svalue', 'stamp'}, unpack(format)))
		else --GMod SQLite is broken
			for k, v in ipairs(format) do
				self.Link:Add(DMySQL3.ReplaceEasy('dstats__default_daily', {ply = v[1], stat = v[2], svalue = v[3], stamp = v[4]}))
			end
		end
	end
	
	self.Link:Commit()
	
	N(ply).cache = {
		total = {},
		daily = {},
		session = {},
	}
	
	N(ply).savein = CurTime() + 60
end

function self.SaveAll()
	for k, v in ipairs(player.GetAll()) do
		self.Save(v)
	end
end

function self.SaveTimer()
	local ctime = CurTime()
	
	for k, v in ipairs(player.GetAll()) do
		if not v.DStats then continue end
		if not N(v) then continue end
		if N(v).savein < ctime then
			self.Save(v)
		end
	end
end

function self.Default(id)
	for k, v in ipairs(self.STATS) do
		if v[1] == id then return v[2] end
	end
end

function self.GetStatTotal(ply, id)
	if not ply.DStats.INIT then return self.Default(id) end
	local i = N(ply)
	if not i then return self.Default(id) end
	return i.total[id]
end

function self.GetStatSession(ply, id)
	if not ply.DStats.INIT then return self.Default(id) end
	local i = N(ply)
	if not i then return self.Default(id) end
	return i.session[id]
end

function self.GetStatDaily(ply, id)
	if not ply.DStats.INIT then return self.Default(id) end
	local i = N(ply)
	if not i then return self.Default(id) end
	return i.daily[id]
end

function self.SetStatTotal(ply, id, val)
	if not ply.DStats.INIT then return end
	local i = N(ply)
	i.total[id] = val
	i.cache.total[id] = i.total[id]
end

function self.AddStatTotal(ply, id, val)
	if not ply.DStats.INIT then return end
	local i = N(ply)
	if not i then return end
	i.total[id] = i.total[id] + val
	i.cache.total[id] = i.total[id]
end

function self.SetStatDaily(ply, id, val)
	if not ply.DStats.INIT then return end
	local i = N(ply)
	if not i then return end
	i.daily[id] = val
	i.cache.daily[id] = i.daily[id]
end

function self.AddStatDaily(ply, id, val)
	if not ply.DStats.INIT then return end
	local i = N(ply)
	if not i then return end
	i.daily[id] = i.daily[id] + val
	i.cache.daily[id] = i.daily[id]
end

function self.SetStatSession(ply, id, val)
	if not ply.DStats.INIT then return end
	local i = N(ply)
	if not i then return end
	i.session[id] = val
	i.cache.session[id] = i.session[id]
end

function self.AddStatSession(ply, id, val)
	if not ply.DStats.INIT then return end
	local i = N(ply)
	if not i then return end
	i.session[id] = i.session[id] + val
	i.cache.session[id] = i.session[id]
end

function self.AddStat(ply, id, val)
	if not ply.DStats.INIT then return end
	val = val or 1
	local i = N(ply)
	if not i then return end
	i.total[id] = i.total[id] + val
	i.daily[id] = i.daily[id] + val
	i.session[id] = i.session[id] + val
	
	i.cache.total[id] = i.total[id]
	i.cache.daily[id] = i.daily[id]
	i.cache.session[id] = i.session[id]
end

function self.RegisterStat(id, default)
	for k, v in ipairs(self.STATS) do
		if v[1] == id then return end
	end
	
	table.insert(self.STATS, {id, default})
	
	for k, v in ipairs(player.GetAll()) do
		if not v.DStats then continue end
		local i = N(v)
		i.session[id] = default
		i.daily[id] = default
		i.total[id] = default
	end
end

function self.Init()
	self.Query('SELECT * FROM dstats__default_ids', function(data)
		for k, row in ipairs(data) do
			self.STATS_IDS[row.stat] = tonumber(row.id)
		end
		
		self.Link:Begin()
		
		for k, row in ipairs(self.STATS) do
			if self.STATS_IDS[row[1]] then continue end
			
			self.Link:Add('INSERT INTO dstats__default_ids (`stat`) VALUES (' .. SQLStr(row[1]) .. ')', function(data)
				self.Query('SELECT id FROM dstats__default_ids WHERE stat = ' .. SQLStr(row[1]), function(data)
					self.STATS_IDS[row[1]] = tonumber(data[1].id)
				end)
			end)
		end
		
		self.Link:Commit()
	end)
end

self.Tables = {
	[[
		CREATE TABLE IF NOT EXISTS `dstats__default`
		(
			`ply` INTEGER NOT NULL,
			`stat` INTEGER NOT NULL,
			`svalue` BIGINT NOT NULL,
			PRIMARY KEY (`ply`, `stat`)
		)
	]],[[
		CREATE TABLE IF NOT EXISTS `dstats__default_daily`
		(
			`ply` INTEGER NOT NULL,
			`stat` INTEGER NOT NULL,
			`day` VARCHAR(32) NOT NULL,
			`svalue` BIGINT NOT NULL,
			PRIMARY KEY (`ply`, `stat`)
		)
	]],[[
		CREATE TABLE IF NOT EXISTS `dstats__default_session`
		(
			`ply` INTEGER NOT NULL,
			`stat` INTEGER NOT NULL,
			`stamp` VARCHAR(32) NOT NULL,
			`svalue` BIGINT NOT NULL,
			PRIMARY KEY (`ply`, `stat`)
		)
	]],[[
		CREATE TABLE IF NOT EXISTS `dstats__default_ids`
		(
			`id` INTEGER NOT NULL PRIMARY KEY %s,
			`stat` VARCHAR(32) NOT NULL
		)
	]],
}

DStats.Hooks('stats', self)
timer.Create('DStats.stats.SaveTimer', 1, 0, self.SaveTimer)

include('sv_stats_default.lua')
