
-- Copyright (C) 2017 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local weaponrystats = weaponrystats

local function PlayerSwitchWeapon(self, oldWeapon, newWeapon)
	weaponrystats.iterateWeapon(self, newWeapon)
	weaponrystats.networkWeapon(newWeapon)
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
