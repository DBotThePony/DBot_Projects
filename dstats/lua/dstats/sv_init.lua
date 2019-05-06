
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

local self = DStats
self.InitHooks = self.InitHooks or {}
self.LoadHooks = self.LoadHooks or {}
self.SaveHooks = self.SaveHooks or {}
self.Tables = {}

if not DMySQL3 then
	include('autorun/server/sv_dmysql3.lua')
end

local LINK = DMySQL3.Connect('dstats')
self.LINK = LINK

function self.Query(str, callback)
	LINK:Query(str, callback, function(e)
		print('Next Query Failed:')
		print(str)
		print('SQL Error: ' .. e)
	end)
end

function self.GetLink()
	return self.LINK
end

function self.IsMySQL()
	return self.LINK.IsMySQL
end

function self.LoadHook(id, func)
	self.LoadHooks[id] = func
end

function self.InitHook(id, func)
	self.InitHooks[id] = func
end

function self.SaveHook(id, func)
	self.SaveHooks[id] = func
end

function self.PlyID(ply)
	return ply.DStats.PlyID
end

function self.Hooks(id, tab)
	self.InitHook(id, tab.Init)
	self.LoadHook(id, tab.Load)
	self.SaveHook(id, tab.Save)

	if tab.Tables then
		for k, v in ipairs(tab.Tables) do
			table.insert(self.Tables, v)
		end
	end
end

function self.Load(ply, steamid)
	ply.DStats = {}
	ply.DStats.PlyID = 0
	ply.DStats.INIT = false

	self.Query('SELECT ply FROM dstats__playerinfo WHERE steamid = ' .. SQLStr(steamid), function(data)
		if not data[1] then
			--Gud SQLite is so Gud
			self.Query('INSERT INTO dstats__playerinfo (`steamid`) VALUES (' .. SQLStr(steamid) .. ')', function(data)
				self.Query('SELECT ply FROM dstats__playerinfo WHERE steamid = ' .. SQLStr(steamid), function(data)
					ply.DStats.INIT = true
					ply.DStats.PlyID = tonumber(data[1].ply)
					for k, v in pairs(self.LoadHooks) do
						v(ply, steamid)
					end
				end)
			end)
		else
			ply.DStats.INIT = true
			ply.DStats.PlyID = tonumber(data[1].ply)
			for k, v in pairs(self.LoadHooks) do
				v(ply, steamid)
			end
		end
	end)
end

function self.Save(ply)
	local steamid = ply:SteamID()
	for k, v in pairs(self.SaveHooks) do
		v(ply, steamid)
	end
end

function self.SaveAll(ply)
	for k, v in ipairs(player.GetAll()) do
		self.Save(v)
	end
end

function self.Init()
	local AUTO = self.IsMySQL() and 'AUTO_INCREMENT' or 'AUTOINCREMENT'

	for k, v in ipairs(self.Tables) do
		self.Query(string.format(v, AUTO))
	end

	for k, v in pairs(self.InitHooks) do
		v()
	end

	for k, v in ipairs(player.GetAll()) do
		self.Load(v, v:SteamID())
	end
end

table.insert(self.Tables, [[
	CREATE TABLE IF NOT EXISTS `dstats__playerinfo`
	(
		`ply` INTEGER NOT NULL PRIMARY KEY %s,
		`steamid` VARCHAR(32) NOT NULL
	)
]])

include('sv_stats.lua')
include('sv_weapons.lua')
include('sv_npc.lua')

timer.Simple(1, self.Init)
hook.Add('PlayerInitialSpawn', 'DStats.hooks', self.Load)
hook.Add('PlayerDisconnected', 'DStats.hooks', self.Save)
