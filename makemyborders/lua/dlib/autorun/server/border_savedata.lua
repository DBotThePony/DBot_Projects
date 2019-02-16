
-- Copyright (C) 2018-2019 DBot

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


local DLib = DLib
local LINK = DLib.DMySQL3.Connect('func_border')
local borders = func_border_data_ref
local DROP = false
local INIT = false
local SAVEDATA = {}

local ready = 0
local init

for name, config in pairs(borders) do
	ready = ready + 1

	if DROP then
		LINK:Query('DROP TABLE func_' .. name, print, print)
	end
end

function func_border_getSaveData()
	return SAVEDATA
end

function init()
	INIT = false

	local queries = 0
	local map = SQLStr(game.GetMap())

	for name, config in pairs(borders) do
		queries = queries + 1

		local function success(data)
			queries = queries - 1
			SAVEDATA[name] = data

			if queries <= 0 then
				INIT = true

				for n, ndata in pairs(SAVEDATA) do
					hook.Run('func_border_Initialize', n, ndata)
				end
			end
		end

		LINK:Query('SELECT * FROM func_' .. name .. ' WHERE `gamemap` = ' .. map, success, error)
	end
end

for name, config in pairs(borders) do
	local build = [[
		CREATE TABLE IF NOT EXISTS func_]] .. name .. [[ (
			`id` integer NOT NULL,
			`gamemap` varchar(255) NOT NULL,
			`posx` float NOT NULL DEFAULT '0',
			`posy` float NOT NULL DEFAULT '0',
			`posz` float NOT NULL DEFAULT '0',
			`minsx` float NOT NULL DEFAULT '0',
			`minsy` float NOT NULL DEFAULT '0',
			`minsz` float NOT NULL DEFAULT '0',
			`maxsx` float NOT NULL DEFAULT '0',
			`maxsy` float NOT NULL DEFAULT '0',
			`maxsz` float NOT NULL DEFAULT '0',
			`yaw` float NOT NULL DEFAULT '0',
			]]

	for i, valueData in ipairs(config) do
		build = build .. ' `' .. valueData[1] .. '` ' .. valueData[2] .. ' NOT NULL DEFAULT \'' .. valueData[3] .. '\', '
	end

	build = build .. [[
		PRIMARY KEY (`id`, `gamemap`) )
	]]

	LINK:Query(build, function()
		LINK:GatherTableColumns('func_' .. name, function(columns)
			local knownColumns = {}
			local needsUpdate = 0

			for i, configEntry in ipairs(config) do
				knownColumns[configEntry[1]] = {false, configEntry}
				needsUpdate = needsUpdate + 1
			end

			for i, row in ipairs(columns) do
				if knownColumns[row.field] and knownColumns[row.field][1] == false then
					knownColumns[row.field][2] = true
					needsUpdate = needsUpdate - 1
				end
			end

			if needsUpdate == 0 then
				ready = ready - 1

				if ready == 0 then
					if AreEntitiesAvaliable() then
						init()
					else
						hook.Add('InitPostEntity', 'func_border_spawn', init)
					end
				end
			else
				local function finish()
					ready = ready - 1

					if ready == 0 then
						if AreEntitiesAvaliable() then
							init()
						else
							hook.Add('InitPostEntity', 'func_border_spawn', init)
						end
					end
				end

				local function err(traceback, data)
					error('ERROR ON UPDATING BORDER DATABASE! FATAL: ' .. data)
				end

				LINK:Begin(true)

				for row, status in pairs(knownColumns) do
					if status[1] == false then
						local configEntry = status[2]
						LINK:Add('ALTER TABLE func_' .. name .. ' ADD COLUMN `' .. row .. '` ' .. configEntry[2] .. ' NOT NULL DEFAULT \'' .. valueData[3] .. '\'', nil, err)
					end
				end

				LINK:Commit(finish)
			end
		end)
	end, error)
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
	ent.__SPAWN_ID = tonumber(row.id)
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

function func_border_remove(borderEntity, callback, errCallback)
	assert(IsValid(borderEntity), 'Invalid border entity!')
	assert(borderEntity:GetClass():startsWith('func_'), 'Entity is not even a func logical entity!')
	local grabID = borderEntity:GetClass():sub(6):lower()
	assert(borders[grabID], 'Entity is not a valid known border!')
	local savedata = assert(SAVEDATA[grabID], 'No save entries were even loaded for ' .. grabID .. '! This is either a bug or problem with database! Operation can not continue')
	local map = SQLStr(game.GetMap())
	local id = assert(borderEntity.__SPAWN_ID, 'Border has no ID!')

	LINK:Query('DELETE FROM func_' .. grabID .. ' WHERE `gamemap` = ' .. map .. ' AND `id` = ' .. id, function(...)
		if callback then
			callback(...)
		end

		table.removeByMember(savedata, 'id', tostring(id))
	end, errCallback or error)
end

function func_border_write(borderEntity, callback, errCallback)
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
			local rid = tonumber(row.id)
			if rid > id then
				id = rid
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

	LINK:Query(('DELETE FROM func_%s WHERE `gamemap` = %s AND `id` = %i'):format(grabID, map, id), function()
		local buildQuery = 'INSERT INTO func_' .. grabID .. ' VALUES (' ..
			("'%i', %s, '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f'"):format(id, map, x, y, z, minsx, minsy, minsz, maxsx, maxsy, maxsz, yaw)

		for k, valueData in ipairs(data) do
			buildQuery = buildQuery .. ', ' .. SQLStr(tostring(borderEntity['Get' .. valueData[1]](borderEntity)))
		end

		buildQuery = buildQuery .. ')'
		LINK:Query(buildQuery, callback, errCallback or error)
	end, errCallback or error)

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
