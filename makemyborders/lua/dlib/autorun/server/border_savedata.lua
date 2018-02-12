
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

local DLib = DLib
local LINK = DLib.DMySQL3.Connect('func_border')
local borders = func_border_data_ref
local DROP = false

for name, config in pairs(borders) do
	if DROP then
		LINK:Query('DROP TABLE func_' .. name, print, print)
	end

	local build = [[
		CREATE TABLE IF NOT EXISTS func_]] .. name .. [[ (
			"id" INTEGER NOT NULL,
			"gamemap" VARCHAR(255) NOT NULL,
			"posx" float NOT NULL DEFAULT '0',
			"posy" float NOT NULL DEFAULT '0',
			"posz" float NOT NULL DEFAULT '0',
			"minsx" float NOT NULL DEFAULT '0',
			"minsy" float NOT NULL DEFAULT '0',
			"minsz" float NOT NULL DEFAULT '0',
			"maxsx" float NOT NULL DEFAULT '0',
			"maxsy" float NOT NULL DEFAULT '0',
			"maxsz" float NOT NULL DEFAULT '0',
			"yaw" float NOT NULL DEFAULT '0', ]]

	for i, valueData in ipairs(config) do
		build = build .. '"' .. valueData[1] .. '" ' .. valueData[2] .. ' NOT NULL DEFAULT \'' .. valueData[3] .. '\', '
	end

	build = build .. [[
		PRIMARY KEY ("id", "gamemap") )
	]]

	LINK:Query(build, function() end, error)
end

local INIT = false
local SAVEDATA = {}

function func_border_getSaveData()
	return SAVEDATA
end

local function init()
	INIT = false

	local queries = 0
	local map = SQLStr(game.GetMap())

	for name, config in pairs(borders) do
		queries = queries + 1

		local function success(data)
			queries = queries - 1
			SAVEDATA[name] = data

			if queries <= 0 then
				for n, ndata in pairs(SAVEDATA) do
					hook.Run('func_border_Initialize', n, ndata)
				end
			end
		end

		LINK:Query('SELECT * FROM func_' .. name .. ' WHERE "gamemap" = ' .. map, success, error)
	end
end

if AreEntitiesAvaliable() then
	init()
else
	hook.Add('InitPostEntity', 'func_border_spawn', init)
end

local function placeBorder(classname, row)
	local pos = Vector(tonumber(row.posx), tonumber(row.posy), tonumber(row.posz))
	local mins = Vector(tonumber(row.minsx), tonumber(row.minsy), tonumber(row.minsz))
	local maxs = Vector(tonumber(row.maxsx), tonumber(row.maxsy), tonumber(row.maxsz))
	local ang = Angle(0, tonumber(row.yaw), 0)

	local ent = ents.Create('func_' .. classname)
	ent.__SPAWN_BY_INITIALIZE = true
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetCollisionMins(mins)
	ent:SetCollisionMaxs(maxs)
	ent.__SPAWN_ID = row.id
	ent.__SPAWN_DATA = row

	local loadData = borders[classname]

	for i2, valueData in ipairs(loadData) do
		local func = ent['Set' .. valueData[1]]

		if func and row[valueData[1]] ~= nil then
			if valueData[2]:lower() == 'boolean' then
				func(ent, tobool(row[valueData[1]]))
			elseif valueData[2]:lower():startsWith('varchar') then
				func(ent, row[valueData[1]])
			else
				local num = tonumber(row[valueData[1]])

				if num then
					func(ent)
				else
					ProtectedCall(function() error('Unable to cast numeric type - ' .. valueData[1] .. ' for ' .. classname .. '!') end)
				end
			end
		end
	end

	ent:Spawn()
	ent:Activate()
	return ent
end

local function placeBorders(classname, sqldata)
	for i, ent in ipairs(ents.FindByClass('func_' .. classname)) do
		if IsValid(ent) and ent.__SPAWN_BY_INITIALIZE then
			ent:Remove()
		end
	end

	for i, row in ipairs(sqldata) do
		placeBorder(classname, row)
	end
end

hook.Add('func_border_Initialize', 'func_border_init', placeBorders, 10)

function func_border_write(borderEntity, callback)
	assert(IsValid(borderEntity), 'Invalid border entity!')
	assert(borderEntity:GetClass():startsWith('func_'), 'Entity is not even a func logical entity!')
	local grabID = borderEntity:GetClass():sub(6):lower()
	local data = assert(borders[grabID], 'Entity is not a valid known border!')
	local savedata = assert(SAVEDATA[grabID], 'No save entries were even loaded for ' .. grabID .. '! This is either a bug or problem with database! Operation can not continue')
	local id, find
	local isNew = true
	local map = SQLStr(game.GetMap())

	if borderEntity.__SPAWN_BY_INITIALIZE then
		id = borderEntity.__SPAWN_ID

		for i, save in ipairs(savedata) do
			if save.id == id then
				find = save
				break
			end
		end

		if not find then
			error('border.__SPAWN_ID is present, but no SAVEDATA entry? wtf?! Looks like bad API usage or something')
		end

		isNew = false
	else
		id = 0

		for i, row in ipairs(savedata) do
			if row.id > id then
				id = row.id
			end
		end

		id = id + 1
	end

	local pos = borderEntity:GetPos()
	local yaw = (borderEntity:GetRealAngle() or borderEntity:GetAngles()).y
	local x = pos.x
	local y = pos.y
	local z = pos.z
	local mins = borderEntity:GetCollisionMins()
	local maxs = borderEntity:GetCollisionMaxs()
	local minsx = mins.x
	local minsy = mins.y
	local minsz = mins.z
	local maxsx = maxs.x
	local maxsy = maxs.y
	local maxsz = maxs.z

	local newSavedata = {
		id = tostring(id),
		map = game.GetMap(),
		posx = tostring(x),
		posy = tostring(y),
		posz = tostring(z),
		minsx = tostring(minsx),
		minsy = tostring(minsy),
		minsz = tostring(minsz),
		maxsx = tostring(maxsx),
		maxsy = tostring(maxsy),
		maxsz = tostring(maxsz),
		yaw = tostring(yaw),
	}

	for k, valueData in ipairs(data) do
		local func = assert(borderEntity['Get' .. valueData[1]], 'Function ' .. valueData[1] .. ' is not found in ' .. tostring(borderEntity) .. ', saving can not continue.')
		newSavedata[valueData[1]] = tostring(func(borderEntity))
	end

	LINK:Query(('DELETE FROM func_%s WHERE "gamemap" = %s AND "id" = %i'):format(grabID, map, id), function()
		local buildQuery = 'INSERT INTO func_' .. grabID .. ' VALUES (' ..
			("'%i', %s, '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f'"):format(id, map, x, y, z, minsx, minsy, minsz, maxsx, maxsy, maxsz, yaw)

		for k, valueData in ipairs(data) do
			buildQuery = buildQuery .. ', ' .. SQLStr(tostring(borderEntity['Get' .. valueData[1]](borderEntity)))
		end

		buildQuery = buildQuery .. ')'
		LINK:Query(buildQuery, callback, error)
	end)

	borderEntity:Remove()
	placeBorder(grabID, newSavedata)

	if isNew then
		table.insert(savedata, newSavedata)
	else
		table.Merge(find, newSavedata)
	end

	return newSavedata
end

local function PostCleanupMap()
	timer.Simple(0.3, function()
		for n, ndata in pairs(SAVEDATA) do
			hook.Run('func_border_Initialize', n, ndata)
		end
	end)
end

hook.Add('PostCleanupMap', 'func_borders_place', PostCleanupMap)
