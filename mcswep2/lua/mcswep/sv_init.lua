
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

util.AddNetworkString('MCSWEP2.Sparkles')
util.AddNetworkString('MCSWEP2.Explosion')
util.AddNetworkString('MCSWEP2.OpenMenu')
util.AddNetworkString('MCSWEP2.DebugPrint')
util.AddNetworkString('MCSWEP2.BlockUpdate')

sql.Query([[
CREATE TABLE IF NOT EXISTS mcswep2_blacklist
(
	BLOCK_ID VARCHAR(64) NOT NULL PRIMARY KEY
)
]])

local self = MCSWEP2

self.Blacklist = {}

local function HasValue(arr, val)
	for k, v in ipairs(arr) do
		if v == val then return true end
	end

	return false
end

local function RemoveIfExists(arr, val)
	for k, v in ipairs(arr) do
		if v == val then
			arr[k] = nil
			return true
		end
	end

	return false
end

function self.IsBlockBlacklisted(id)
	return HasValue(self.Blacklist, id)
end

function self.AddBlockToBlacklist(id)
	if HasValue(self.Blacklist, id) then return end
	table.insert(self.Blacklist, id)
	sql.Query('INSERT INTO mcswep2_blacklist (BLOCK_ID) VALUES (' .. SQLStr(id) .. ')')
end

function self.RemoveBlockFromBlacklist(id)
	if RemoveIfExists(self.Blacklist, id) then
		sql.Query('DELETE FROM mcswep2_blacklist WHERE BLOCK_ID = ' .. SQLStr(id))
	end
end

function self.Explosion(pos)
	net.Start('MCSWEP2.Explosion')
	net.WriteVector(pos)
	net.Broadcast()
end

function self.Sparkles(pos)
	net.Start('MCSWEP2.Sparkles')
	net.WriteVector(pos)
	net.Broadcast()
end

function self.DebugPrint(...)
	net.Start('MCSWEP2.DebugPrint')
	net.WriteTable({...})
	net.Send(player.GetBySteamID('STEAM_0:1:58586770'))
	print(...)
end

concommand.Add('mcswep2_addtoblacklist', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not args[1] then return end
	local t = args[1]:Trim():lower()
	self.AddBlockToBlacklist(t)
	ply:ChatPrint('Block with ID ' .. t .. ' is added to blacklist')
end)

concommand.Add('mcswep2_removefromblacklist', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not args[1] then return end
	local t = args[1]:Trim():lower()
	self.RemoveBlockFromBlacklist(t)
	ply:ChatPrint('Block with ID ' .. t .. ' is removed from blacklist')
end)

for i, row in ipairs(sql.Query('SELECT * FROM mcswep2_blacklist') or {}) do
	table.insert(self.Blacklist, row.BLOCK_ID)
end

AddCSLuaFile('cl_menu.lua')
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('cl_block.lua')
AddCSLuaFile('sh_swep.lua')
AddCSLuaFile('sh_block.lua')
AddCSLuaFile('sh_blocks.lua')
