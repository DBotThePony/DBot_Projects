
--
-- Copyright (C) 2017-2018 DBot
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

SETNW_AVALIABLE_FUNCTIONS = {
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

D_UMSG_NEXT_NETWORK_ID = D_UMSG_NEXT_NETWORK_ID or 1
D_UMSG_NETWORK_STRINGS_PRECACHE = D_UMSG_NETWORK_STRINGS_PRECACHE or {}
D_UMSG_NETWORK_STRINGS_PRECACHE_BACKWARDS = D_UMSG_NETWORK_STRINGS_PRECACHE_BACKWARDS or {}

local entMeta = FindMetaTable('Entity')

for k, data in pairs(SETNW_AVALIABLE_FUNCTIONS) do
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