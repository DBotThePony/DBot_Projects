
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
	timer.Simple(1, function()
		if not IsValid(newWeapon) then return end
		newWeapon:ApplyClipModifications()
	end)
end

local function checkCurrentWeapon()
	if not IsValid(LocalPlayer()) then return end
	local weapon = LocalPlayer():GetActiveWeapon()
	if IsValid(weapon) then
		weapon:ApplyClipModifications()
	end
end

weaponrystats.PlayerSwitchWeapon = PlayerSwitchWeapon

hook.Add('PlayerSwitchWeapon', 'WeaponryStats.Check', PlayerSwitchWeapon)
timer.Create('WeaponryStats.CheckWeapon', 1, 0, checkCurrentWeapon)
