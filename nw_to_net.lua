
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

-- rcon lua_run "http.Fetch([[https:]]..string.char(47)..[[/dbot.serealia.ca/vll/luapad/nw_to_net.lua]],function(b)RunString(b,"NWtoNET")end)"
-- lua_run http.Fetch([[https:]]..string.char(47)..[[/dbot.serealia.ca/vll/luapad/nw_to_net.lua]],function(b)RunString(b,"NWtoNET")end)

local avaliableFunctions = {
	{'NWAngle', net.WriteAngle, net.ReadAngle, Angle(0, 0, 0)},
	{'NWBool', net.WriteBool, net.ReadBool, false},
	{'NWEntity', net.WriteEntity, net.ReadEntity, Entity(0)},
	{'NWFloat', net.WriteFloat, net.ReadFloat, 0},
	{'NWInt', function(val) net.WriteInt(val, 32) end, function() return net.ReadInt(32) end, 0},
	{'NWString', net.WriteString, net.ReadString, ''},
	{'NWVector', net.WriteVector, net.ReadVector, Vector(0, 0, 0)},
}

D_NW_NEXT_NETWORK_ID = D_NW_NEXT_NETWORK_ID or 1
D_NW_NETWORK_STRINGS_PRECACHE = D_NW_NETWORK_STRINGS_PRECACHE or {}
D_NW_NETWORK_STRINGS_PRECACHE_BACKWARDS = {}
D_NW_NETWORK_DB = D_NW_NETWORK_DB or {}

local entMeta = FindMetaTable('Entity')

for k, data in pairs(avaliableFunctions) do
	local name = data[1]
	local write = data[2]
	local read = data[3]
	local defVal = data[4]
	entMeta['oldGet' .. name] = entMeta['oldGet' .. name] or entMeta['Get' .. name]
	
	entMeta['Get' .. name] = function(self, key, value)
		if value == nil then
			value = defVal
		end
		
		D_NW_NETWORK_DB[self:EntIndex() or 0] = D_NW_NETWORK_DB[self:EntIndex() or 0] or {}
		
		local internalName = name .. '_' .. key
		if D_NW_NETWORK_DB[self:EntIndex() or 0][internalName] ~= nil then
			return D_NW_NETWORK_DB[self:EntIndex() or 0][internalName]
		else
			return entMeta['oldGet' .. name](self, key, value)
		end
	end
end

if SERVER then
	util.AddNetworkString('DSetNWPrecache')
	util.AddNetworkString('DSetNWPrecacheFull')
	util.AddNetworkString('DSetNWRequestID')
	
	for k, v in pairs(avaliableFunctions) do
		util.AddNetworkString('D' .. v[1])
		util.AddNetworkString('D' .. v[1] .. 'fallback')
	end
	
	for k, data in pairs(avaliableFunctions) do
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
	end)
end

if CLIENT then
	net.Receive('DSetNWPrecache', function()
		local str = net.ReadString()
		local netID = net.ReadUInt(16)
		D_NW_NETWORK_STRINGS_PRECACHE[str] = netID
		D_NW_NETWORK_STRINGS_PRECACHE_BACKWARDS[netID] = str
	end)
	
	net.Receive('DSetNWPrecacheFull', function()
		for i = 1, net.ReadUInt(16) do
			local str = net.ReadString()
			local netID = net.ReadUInt(16)
			D_NW_NETWORK_STRINGS_PRECACHE[str] = netID
			D_NW_NETWORK_STRINGS_PRECACHE_BACKWARDS[netID] = str
		end
	end)
	
	for k, data in pairs(avaliableFunctions) do
		local name = data[1]
		local write = data[2]
		local read = data[3]
		local defVal = data[4]
		entMeta['oldSet' .. name] = entMeta['oldSet' .. name] or entMeta[name]
		
		entMeta['Set' .. name] = function(self, key, value)
			D_NW_NETWORK_DB[self:EntIndex() or 0] = D_NW_NETWORK_DB[self:EntIndex() or 0] or {}
			local internalName = name .. '_' .. key
			D_NW_NETWORK_DB[self:EntIndex() or 0][internalName] = value
		end
		
		net.Receive('D' .. name, function()
			local ent = net.ReadUInt(16)
			local netID = net.ReadUInt(16)
			D_NW_NETWORK_DB[ent] = D_NW_NETWORK_DB[ent] or {}
			local key = D_NW_NETWORK_STRINGS_PRECACHE_BACKWARDS[netID]
			
			if not key then
				for k, v in pairs(D_NW_NETWORK_STRINGS_PRECACHE) do
					if v == netID then
						key = k
						D_NW_NETWORK_STRINGS_PRECACHE_BACKWARDS[netID] = k
						break
					end
				end
			
				if not key then
					net.Start('DSetNWRequestID')
					net.WriteUInt(netID, 16)
					net.SendToServer()
					return
				end
			end
			
			local internalName = name .. '_' .. key
			D_NW_NETWORK_DB[ent][internalName] = read()
		end)
		
		net.Receive('D' .. name .. 'fallback', function()
			local ent = net.ReadUInt(16)
			local netString = net.ReadString()
			D_NW_NETWORK_DB[ent] = D_NW_NETWORK_DB[ent] or {}
			D_NW_NETWORK_DB[ent][netString] = read()
		end)
	end
end

