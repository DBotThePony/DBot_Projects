
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

net.Receive('DSetNWPrecache', function()
	local str = net.ReadString()
	local netID = net.ReadUInt(16)
	D_NW_NETWORK_STRINGS_PRECACHE[str] = netID
	D_NW_NETWORK_STRINGS_PRECACHE_BACKWARDS[netID] = str
end)

net.Receive('DNetUMSGPrecache', function()
	local str = net.ReadString()
	local netID = net.ReadUInt(16)
	D_UMSG_NETWORK_STRINGS_PRECACHE[str] = netID
	D_UMSG_NETWORK_STRINGS_PRECACHE_BACKWARDS[netID] = str
	
	net.Start('DNetUMSGDestinationReached')
	net.WriteUInt(netID, 16)
	net.SendToServer()
end)

local UMSGObjectMeta = {
	ReadBool = function(self)
		local read = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		return (tonumber(read) or 0) > 0
	end,
	
	ReadChar = function(self)
		local dir = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local read1 = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local num1 = tonumber(read1) or 0
		
		if dir == 0 then
			return -num1
		else
			return num1
		end
	end,
	
	ReadUChar = function(self)
		local read1 = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local num1 = tonumber(read1) or 0
		return num1
	end,
	
	ReadLong = function(self)
		local dir = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local read1 = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local read2 = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local read3 = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local read4 = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local num1 = tonumber(read1) or 0
		local num2 = tonumber(read2) or 0
		local num3 = tonumber(read3) or 0
		local num4 = tonumber(read4) or 0
		
		if dir == 0 then
			return -num1 - num2 * 256 - num3 * 256 * 256 - num4 * 256 * 256 * 256
		else
			return num1 + num2 * 256 + num3 * 256 * 256 + num4 * 256 * 256 * 256
		end
	end,
	
	ReadULong = function(self)
		local read1 = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local read2 = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local read3 = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local read4 = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local num1 = tonumber(read1) or 0
		local num2 = tonumber(read2) or 0
		local num3 = tonumber(read3) or 0
		local num4 = tonumber(read4) or 0
		
		return num1 + num2 * 256 + num3 * 256 * 256 + num4 * 256 * 256 * 256
	end,
	
	ReadShort = function(self)
		local dir = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local readOne = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local readTwo = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local num1 = tonumber(readOne) or 0
		local num2 = tonumber(readTwo) or 0
		
		if dir == 0 then
			return -num1 - num2 * 256
		else
			return num1 + num2 * 256
		end
	end,
	
	ReadUShort = function(self)
		local readOne = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local readTwo = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local num1 = tonumber(readOne) or 0
		local num2 = tonumber(readTwo) or 0
		
		return num1 + num2 * 256
	end,
	
	ReadEntity = function(self)
		local num = self:ReadUShort()
		local ent = Entity(num)
		if IsValid(ent) then
			return ent
		else
			return Entity(0)
		end
	end,
	
	ReadFloat = function(self)
		local dir = string.byte(self.read, self.readPos, self.readPos + 1)
		self.readPos = self.readPos + 1
		
		local first = self:ReadULong()
		local second = self:ReadULong()
		
		-- loal lazy
		if dir == 0 then
			return -tonumber(first .. '.' .. second) or 0
		else
			return tonumber(first .. '.' .. second) or 0
		end
	end,
	
	ReadString = function(self)
		local str = ''
		
		while true do
			local read = self:ReadUChar()
			if read == 0 then break end
			str = str .. string.char(read)
		end
		
		return str
	end,
	
	Reset = function(self)
		self.readPos = 1
	end
}

function UMSGObjectMeta.ReadAngle(self)
	return Angle(self:ReadFloat(), self:ReadFloat(), self:ReadFloat())
end

function UMSGObjectMeta.ReadVector(self)
	return Vector(self:ReadFloat(), self:ReadFloat(), self:ReadFloat())
end

function UMSGObjectMeta.ReadVectorNormal(self)
	return Vector(self:ReadShort(), self:ReadShort(), self:ReadShort()) / 10000
end

local function CreateUMSGObject()
	local object = setmetatable({}, {__index = UMSGObjectMeta})
	local readData = net.ReadData(267)
	object.read = readData
	object.readPos = 1
	-- We are reading in 256 digit system
	return object
end

net.Receive('DNetUMSG', function()
	local netID = net.ReadUInt(16)
	local key = D_UMSG_NETWORK_STRINGS_PRECACHE_BACKWARDS[netID]
	
	if key then
		usermessage.IncomingMessage(key, CreateUMSGObject())
	end
end)

net.Receive('DNetUMSGFallback', function()
	local key = net.ReadString()
	local netID = net.ReadUInt(16)
	
	D_UMSG_NETWORK_STRINGS_PRECACHE[key] = netID
	D_UMSG_NETWORK_STRINGS_PRECACHE_BACKWARDS[netID] = key
	
	usermessage.IncomingMessage(key, CreateUMSGObject())
	
	net.Start('DNetUMSGDestinationReached')
	net.WriteUInt(netID, 16)
	net.SendToServer()
end)

net.Receive('DSetNWRemove', function()
	D_NW_NETWORK_DB[net.ReadUInt(16)] = nil
end)

net.Receive('DSetNWPrecacheFull', function()
	for i = 1, net.ReadUInt(16) do
		local str = net.ReadString()
		local netID = net.ReadUInt(16)
		D_NW_NETWORK_STRINGS_PRECACHE[str] = netID
		D_NW_NETWORK_STRINGS_PRECACHE_BACKWARDS[netID] = str
	end
end)

net.Receive('DNetUMSGPrecacheFull', function()
	local netIDs = {}
	for i = 1, net.ReadUInt(16) do
		local str = net.ReadString()
		local netID = net.ReadUInt(16)
		table.insert(netIDs, netID)
		D_NW_NETWORK_STRINGS_PRECACHE[str] = netID
		D_NW_NETWORK_STRINGS_PRECACHE_BACKWARDS[netID] = str
	end
	
	net.Start('DNetUMSGDestinationReachedFull')
	net.WriteUInt(#netIDs, 16)
	for i, v in pairs(netIDs) do
		net.WriteUInt(v, 16)
	end
	net.SendToServer()
end)

local entMeta = FindMetaTable('Entity')

for k, data in pairs(SETNW_AVALIABLE_FUNCTIONS) do
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