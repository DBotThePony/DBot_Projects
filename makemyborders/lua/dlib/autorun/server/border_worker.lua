
-- Copyright (C) 2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local messages = DLib.chat.generateWithMessages({}, 'Borders')
local borders = func_border_data_ref

CAMI.RegisterPrivilege({
	Name = 'func_border_view',
	MinAccess = 'admin',
	Description = 'Access to viewing world borders list'
})

CAMI.RegisterPrivilege({
	Name = 'func_border_edit',
	MinAccess = 'superadmin',
	Description = 'Access to edit world borders list'
})

net.pool('func_border_request')
net.pool('func_border_edit')
net.pool('func_border_delete')

net.receive('func_border_request', function()
	if not IsValid(ply) then return end

	CAMI.PlayerHasAccess(ply, 'func_border_view', function(allowed, reason)
		if not IsValid(ply) then return end

		if not allowed then
			messages.chatPlayer(ply, 'No access! ' .. (reason or ''))
			net.start('func_border_request')
			net.WriteUInt(1, 8)
			net.Send(ply)
			return
		end

		local savedata = func_border_getSaveData()

		if not savedata or table.Count(savedata) == 0 then
			net.start('func_border_request')
			net.WriteUInt(2, 8)
			net.Send(ply)
		end

		net.start('func_border_request')
		net.WriteUInt(0, 8)

		for border, borderData in pairs(savedata) do
			net.WriteString(border)
			net.WriteUInt(#borderData, 16)

			for i, row in ipairs(borderData) do
				local id = tonumber(row.id)
				local pos = Vector(tonumber(row.posx), tonumber(row.posy), tonumber(row.posz))
				local mins = Vector(tonumber(row.minsx), tonumber(row.minsy), tonumber(row.minsz))
				local maxs = Vector(tonumber(row.maxsx), tonumber(row.maxsy), tonumber(row.maxsz))
				local yaw = tonumber(row.yaw)

				net.WriteUInt(id, 32)
				net.WriteVectorDouble(pos)
				net.WriteVectorDouble(mins)
				net.WriteVectorDouble(maxs)
				net.WriteDouble(yaw)

				net.WriteUInt(tonumber(row.lastmodified), 64)
				net.WriteString(row.modifiedby)
				net.WriteString(row.modifiedid)
				net.WriteString(row.createdby)
				net.WriteString(row.createdid)

				local vars = borders[border]

				for i2, var in ipairs(vars) do
					var.nwwrite(var.fix(row[var[1]]))
				end
			end
		end

		net.WriteUInt(0, 8)
		net.CompressOngoing()
		net.Send(ply)
	end)
end)

net.receive('func_border_edit', function(len, ply)
	if not IsValid(ply) then return end

	CAMI.PlayerHasAccess(ply, 'func_border_edit', function(allowed, reason)
		if not IsValid(ply) then return end

		if not allowed then
			messages.chatPlayer(ply, 'No access! ' .. (reason or ''))
			return
		end

		local isNew = net.ReadBool()
		local classID = net.ReadString():lower()
		local border = borders[classID]
		local id, ent, pos, yaw, mins, maxs

		if not border then
			messages.chatPlayer(ply, 'Unknown border classname! ' .. border)
			return
		end

		if isNew then
			ent = ents.Create('func_' .. classID)
		else
			id = net.ReadUInt(32)

			for i, entFind in ipairs(ents.FindByClass('func_' .. classID)) do
				if IsValid(entFind) and entFind.__SPAWN_BY_INITIALIZE and entFind.__SPAWN_ID == id then
					ent = entFind
					break
				end
			end

			if not IsValid(ent) then
				messages.chatPlayer(ply, 'Border with ID ' .. id .. ' does not exist on map! wtf?')
				return
			end
		end

		pos = net.ReadVectorDouble()
		mins = net.ReadVectorDouble()
		maxs = net.ReadVectorDouble()
		yaw = net.ReadDouble()

		ent:SetPos(pos)
		ent:SetCollisionMins(mins)
		ent:SetCollisionMaxs(maxs)
		ent:SetAngles(Angle(0, yaw, 0))

		for i, var in ipairs(border) do
			ent['Set' .. var[1]](ent, var.nwread())
		end

		if isNew then
			ent:Spawn()
			ent:Activate()
		end

		func_border_write(ent, function()
			messages.chatPlayer(ply, 'Operation successfull')
		end)
	end)
end)
