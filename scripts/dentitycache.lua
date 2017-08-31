
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

-- Enables examples from wiki to all entities
-- Experemental, but improves fps

ents.GetAllOld = ents.GetAllOld or ents.GetAll
ents.FindByClassOld = ents.FindByClassOld or ents.FindByClass
local KnownEntities = {}
local KnownEntitiesByClass = {}
local KnownPlayers = {}
local GET_CLASS = FindMetaTable('Entity').GetClass
player.GetAllOld = player.GetAllOld or player.GetAll

local function update()
	KnownEntities = ents.GetAllOld()
	KnownEntitiesByClass = {}
	KnownPlayers = {}
	local nextID = 1
	
	for k, v in ipairs(KnownEntities) do
		local getClass = GET_CLASS(v)
		KnownEntitiesByClass[nextID] = {v, getClass}
		nextID = nextID + 1
		
		if getClass == 'player' then
			table.insert(KnownPlayers, v)
		end
	end
end

update()

function ents.GetAll()
	return KnownEntities
end

function player.GetAll()
	return KnownPlayers
end

function ents.FindByClass(byStr)
	local matchedStart, matchedEnd = string.find(byStr, '*', 1, false)
	if matchedStart then
		local matchFor = string.sub(byStr, 1, matchedStart)
		local reply = {}
		local nextID = 1
		for k, v in ipairs(KnownEntitiesByClass) do
			if string.sub(v[2], 1, matchedStart) == byStr then
				reply[nextID] = v[1]
				nextID = nextID + 1
			end
		end
		return reply
	else
		local reply = {}
		local nextID = 1
		for k, v in ipairs(KnownEntitiesByClass) do
			if v[2] == byStr then
				reply[nextID] = v[1]
				nextID = nextID + 1
			end
		end
		return reply
	end
end

hook.Add('EntityRemoved', 'DEntityCache', function(ent2)
	for i, ent in ipairs(KnownEntities) do
		if ent == ent2 then
			table.remove(KnownEntities, i)
			break
		end
	end
	
	for i, ent in ipairs(KnownEntitiesByClass) do
		if ent[1] == ent2 then
			table.remove(KnownEntitiesByClass, i)
			break
		end
	end
	
	timer.Create('DEntityCache.Update', 0, 1, update)
end)

hook.Add('OnEntityCreated', 'DEntityCache', function(ent2)
	table.insert(KnownEntities, ent2)
	table.insert(KnownEntitiesByClass, {ent2, GET_CLASS(ent2)})
	timer.Create('DEntityCache.Update', 0, 1, update)
end)
