
-- Copyright (C) 2016-2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

util.AddNetworkString('DBot_DuckOMeter')
sql.Query('CREATE TABLE IF NOT EXISTS dbot_duckometr_sv (steamid varchar(32) not null primary key, cval integer not null)')

hook.Add('PlayerInitialSpawn', 'DBot_DuckOMeter', function(ply)
	local data = sql.Query('SELECT cval FROM dbot_duckometr_sv WHERE steamid = "' .. ply:SteamID() .. '"') or {}

	ply.CurrentDucksCollected = data[1] and data[1].cval or 0
end)

concommand.Add('sv_duck_reset', function(ply, cmd, args)
	ply.CurrentDucksCollected = 0
	sql.Query('DELETE FROM dbot_duckometr_sv WHERE steamid = "' .. ply:SteamID() .. '"')
	print('Duck count reseted serverside for you!')
end)

concommand.Add('sv_duck_reset_all', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then
		ply:ChatPrint('Merasmus not trusting you ducks! Must be a superadmin!')
		return
	end

	for i, ply2 in ipairs(player.GetAll()) do
		ply2.CurrentDucksCollected = 0
	end

	sql.Query('DELETE FROM dbot_duckometr_sv')
	print('Duck count reseted serverside for EVERYONE! Merasmus cries!')

	if IsValid(ply) then
		ply:ChatPrint('Duck count reseted serverside for EVERYONE! Merasmus cries!')
	end
end)
