
-- Copyright (C) 2017-2019 DBotThePony

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


local weaponrystats = weaponrystats

local function PlayerSwitchWeapon(self, oldWeapon, newWeapon)
	weaponrystats.iterateWeapon(self, newWeapon)
	weaponrystats.networkWeapon(newWeapon)
	newWeapon:ApplyClipModifications()
end

weaponrystats.PlayerSwitchWeapon = PlayerSwitchWeapon

hook.Add('PlayerSwitchWeapon', 'WeaponryStats.Check', PlayerSwitchWeapon)

local function findPlayer(name)
	if not name then return end
	local num = tonumber(name)

	if num then
		local ply = Player(num)
		if IsValid(ply) then return ply end
	else
		name = name:lower()
		local ply

		for i, ply2 in ipairs(player.GetAll()) do
			if ply2:Nick():lower():find(name) then
				if ply then return end
				ply = ply2
			end
		end

		return ply
	end
end

concommand.Add('weaponrystats_reset', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return weaponrystats.NotifyConsole(ply, 'No access!') end
	local plyFind = findPlayer(table.concat(args or {}, ' '))
	if not plyFind then return weaponrystats.NotifyConsole(ply, 'Invalid UniqueID/Nickname') end

	local steamid = SQLStr(plyFind:SteamID())
	sql.Query('DELETE FROM weaponrystats WHERE steamid = ' .. steamid)
	weaponrystats.iterateWeapons(plyFind)
	weaponrystats.NotifyConsole(ply, plyFind, ' was cleared from database')
	weaponrystats.Message(ply, ' cleared data of ', plyFind)
end)

concommand.Add('weaponrystats_resetall', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return weaponrystats.NotifyConsole(ply, 'No access!') end

	sql.Query('DELETE FROM weaponrystats')

	for i, ply in ipairs(player.GetAll()) do
		local weapons = ply:GetWeapons()
		if weapons then
			for i, weapon in ipairs(weapons) do
				weapon.weaponrystats = nil
			end
		end

		weaponrystats.PlayerInitialSpawn(ply)
		weaponrystats.PlayerLoadout(ply)
	end

	weaponrystats.NotifyConsole(ply, 'Cleared the database!')
	weaponrystats.Message(ply, ' Cleared the database!')
end)
