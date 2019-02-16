
-- Copyright (C) 2016-2019 DBot

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
