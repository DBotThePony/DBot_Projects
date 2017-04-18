
--
-- Copyright (C) 2017 DBot
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 

-- the day it got removed
umsg = {}

util.AddNetworkString('DSetNWPrecache')
util.AddNetworkString('DSetNWPrecacheFull')
util.AddNetworkString('DSetNWRequestID')
util.AddNetworkString('DSetNWRemove')

util.AddNetworkString('DNetUMSG')
util.AddNetworkString('DNetUMSGFallback')
util.AddNetworkString('DNetUMSGPrecache')
util.AddNetworkString('DNetUMSGPrecacheFull')
util.AddNetworkString('DNetUMSGDestinationReached')
util.AddNetworkString('DNetUMSGDestinationReachedFull')

for k, v in pairs(SETNW_AVALIABLE_FUNCTIONS) do
	util.AddNetworkString('D' .. v[1])
	util.AddNetworkString('D' .. v[1] .. 'fallback')
end

local entMeta = FindMetaTable('Entity')

for k, data in pairs(SETNW_AVALIABLE_FUNCTIONS) do
	local name = data[1]
	local write = data[2]
	local read = data[3]
	local defVal = data[4]
	entMeta['oldSet' .. name] = entMeta['oldSet' .. name] or entMeta['Set' .. name]
	
	entMeta['Set' .. name] = function(self, key, value)
		if value == nil then
			value = defVal
		end
		
		if not D_NW_NETWORK_STRINGS_PRECACHE[key] then
			D_NW_NETWORK_STRINGS_PRECACHE[key] = D_NW_NEXT_NETWORK_ID
			D_NW_NEXT_NETWORK_ID = D_NW_NEXT_NETWORK_ID + 1
			
			net.Start('DSetNWPrecache')
			net.WriteString(key)
			net.WriteUInt(D_NW_NETWORK_STRINGS_PRECACHE[key], 16)
			net.Broadcast()
			
			net.Start('D' .. name .. 'fallback')
			net.WriteUInt(self:EntIndex() or 0, 16)
			net.WriteString(key)
			write(value)
			net.Broadcast()
		end
		
		local internalName = name .. '_' .. key
		D_NW_NETWORK_DB[self:EntIndex() or 0] = D_NW_NETWORK_DB[self:EntIndex() or 0] or {}
		
		if D_NW_NETWORK_DB[self:EntIndex() or 0][internalName] ~= value then
			net.Start('D' .. name)
			net.WriteUInt(self:EntIndex() or 0, 16)
			net.WriteUInt(D_NW_NETWORK_STRINGS_PRECACHE[key], 16)
			write(value)
			net.Broadcast()
			D_NW_NETWORK_DB[self:EntIndex() or 0][internalName] = value
		end
	end
end

net.Receive('DSetNWRequestID', function(len, ply)
	local id = net.ReadUInt(16)
	local key
	
	for k, v in pairs(D_NW_NETWORK_STRINGS_PRECACHE) do
		if v == id then
			key = k
			break
		end
	end
	
	if key then
		net.Start('DSetNWPrecache')
		net.WriteString(key)
		net.WriteUInt(id, 16)
		net.Send(ply)
	end
end)

hook.Add('PlayerInitialSpawn', 'DNWReplace', function(ply)
	timer.Simple(10, function()
		net.Start('DSetNWPrecacheFull')
		net.WriteUInt(table.Count(D_NW_NETWORK_STRINGS_PRECACHE), 16)
		
		for k, v in pairs(D_NW_NETWORK_STRINGS_PRECACHE) do
			net.WriteString(k)
			net.WriteUInt(v, 16)
		end
		
		net.Send(ply)
	end)
	
	timer.Simple(5, function()
		net.Start('DNetUMSGPrecacheFull')
		net.WriteUInt(table.Count(D_UMSG_NETWORK_STRINGS_PRECACHE), 16)
		
		for k, v in pairs(D_UMSG_NETWORK_STRINGS_PRECACHE) do
			net.WriteString(k)
			net.WriteUInt(v, 16)
		end
		
		net.Send(ply)
	end)
end)

hook.Add('EntityRemoved', 'DNWClear', function(ent)
	net.Start('DSetNWRemove')
	net.WriteUInt(ent:EntIndex() or 0, 16)
	D_NW_NETWORK_DB[ent:EntIndex() or 0] = nil
	net.Broadcast()
end)

function umsg.PoolString(strName)
	if D_UMSG_NETWORK_STRINGS_PRECACHE[strName] then return end
	D_UMSG_NETWORK_STRINGS_PRECACHE[strName] = D_UMSG_NEXT_NETWORK_ID
	D_UMSG_NEXT_NETWORK_ID = D_UMSG_NEXT_NETWORK_ID + 1
	D_UMSG_NETWORK_STRINGS_PRECACHE_BACKWARDS[D_UMSG_NETWORK_STRINGS_PRECACHE[strName]] = strName
	
	net.Start('DNetUMSGPrecache')
	net.WriteString(strName)
	net.WriteUInt(D_UMSG_NETWORK_STRINGS_PRECACHE[strName], 16)
	net.Broadcast()
end

net.Receive('DNetUMSGDestinationReached', function(len, ply)
	local id = net.ReadUInt(16)
	local strName = D_UMSG_NETWORK_STRINGS_PRECACHE_BACKWARDS[id]
	if not strName then return end
	ply.DUMSG = ply.DUMSG or {}
	ply.DUMSG[strName] = strName
end)

net.Receive('DNetUMSGDestinationReachedFull', function(len, ply)
	ply.DUMSG = ply.DUMSG or {}
	
	for i = 1, net.ReadUInt(16) do
		local id = net.ReadUInt(16)
		local strName = D_UMSG_NETWORK_STRINGS_PRECACHE_BACKWARDS[id]
		if not strName then continue end
		ply.DUMSG[strName] = strName
	end
end)

local CURRENT_USERMESSAGES

function umsg.Start(strName, players)
	players = players or player.GetAll()
	
	if type(players) == 'CRecipientFilter' then
		players = players:GetPlayers()
	elseif type(players) == 'Player' then
		players = {players}
	end
	
	if CURRENT_USERMESSAGES then
		print('UMSG ERROR: Starting new usermessage without finishing old one!')
		print('NEW:')
		print(strName)
		print(debug.traceback())
		print('OLD:')
		print(CURRENT_USERMESSAGES.name)
		print(CURRENT_USERMESSAGES.trace)
	end
	
	CURRENT_USERMESSAGES = {}
	CURRENT_USERMESSAGES.trace = debug.traceback()
	CURRENT_USERMESSAGES.name = strName
	CURRENT_USERMESSAGES.players = players
	
	local preached = D_UMSG_NETWORK_STRINGS_PRECACHE[strName] ~= nil
	
	if not preached then
		umsg.PoolString(strName)
	end
	
	local hitPlayers = {}
	local missPlayers = {}
	
	for i, ply in pairs(players) do
		ply.DUMSG = ply.DUMSG or {}
		
		if ply.DUMSG[strName] then
			table.insert(hitPlayers, ply)
		else
			table.insert(missPlayers, ply)
		end
	end
	
	CURRENT_USERMESSAGES.hitPlayers = hitPlayers
	CURRENT_USERMESSAGES.missPlayers = missPlayers
	CURRENT_USERMESSAGES.writeTable = {}
	CURRENT_USERMESSAGES.writeBits = 0
	CURRENT_USERMESSAGES.id = D_UMSG_NETWORK_STRINGS_PRECACHE[strName]
end

local writeFuncs = {
	Bool = function(val) net.WriteUInt(val and 1 or 0, 8) end, -- Because we have no Buffer() object like node.js has, we have to write byte-by-byte messages, and we are unable to write bits
	Char = function(val) net.WriteUInt(val > 0 and 1 or 0, 8) net.WriteUInt(math.abs(val), 8) end,
	Long = function(val) net.WriteUInt(val > 0 and 1 or 0, 8) net.WriteUInt(math.abs(val), 32) end,
	Short = function(val) net.WriteUInt(val > 0 and 1 or 0, 8) net.WriteUInt(math.abs(val), 16) end,
	UShort = function(val) net.WriteUInt(val, 16) end,
	
	Float = function(val)
		net.WriteUInt(val > 0 and 1 or 0, 8)
		
		val = math.abs(val)
		local first = math.floor(val)
		local dig = val - first
		dig = tostring(dig)
		dig = tonumber(dig:sub(3)) or 0
		
		net.WriteUInt(first, 32)
		net.WriteUInt(dig, 32)
	end,
	
	String = net.WriteString,
}

function writeFuncs.Entity(val)
	writeFuncs.UShort(val:EntIndex() or 0)
end

function writeFuncs.Vector(val)
	writeFuncs.Float(val.x)
	writeFuncs.Float(val.y)
	writeFuncs.Float(val.z)
end

function writeFuncs.Angle(val)
	writeFuncs.Float(val.p)
	writeFuncs.Float(val.y)
	writeFuncs.Float(val.r)
end

function writeFuncs.VectorNormal(val)
	local x, y, z = val.x, val.y, val.z
	
	writeFuncs.Short(x * 10000)
	writeFuncs.Short(y * 10000)
	writeFuncs.Short(z * 10000)
end

for name, send in pairs(writeFuncs) do
	umsg[name] = function(val)
		if not CURRENT_USERMESSAGES then
			print('UMSG ERROR: There is no any ongoing messages!')
			print(debug.traceback())
			return
		end
		
		table.insert(CURRENT_USERMESSAGES.writeTable, function() send(val) end)
	end
end

function umsg.End()
	if not CURRENT_USERMESSAGES then
		print('UMSG ERROR: There is no any ongoing messages!')
		print(debug.traceback())
		return
	end
	
	local hitPlayers = CURRENT_USERMESSAGES.hitPlayers
	local missPlayers = CURRENT_USERMESSAGES.missPlayers
	
	if #hitPlayers ~= 0 then
		net.Start('DNetUMSG')
		net.WriteUInt(CURRENT_USERMESSAGES.id, 16)
		
		for i, func in pairs(CURRENT_USERMESSAGES.writeTable) do
			func()
		end
		
		net.Send(hitPlayers)
	end
	
	if #missPlayers ~= 0 then
		net.Start('DNetUMSGFallback')
		net.WriteString(CURRENT_USERMESSAGES.name, 16)
		net.WriteUInt(CURRENT_USERMESSAGES.id, 16)
		
		for i, func in pairs(CURRENT_USERMESSAGES.writeTable) do
			func()
		end
		
		net.Send(missPlayers)
	end
	
	CURRENT_USERMESSAGES = nil
end
