
-- Copyright (c) 2018 DBot

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

local IsValid = IsValid
local CHAN_WEAPON = CHAN_WEAPON

local function EntityEmitSound(data)
	local ent = data.Entity
	local chan = data.Channel
	if chan ~= CHAN_WEAPON then return end
	if not ent:IsNPC() and not ent:IsPlayer() and not ent:IsWeapon() then return end

	local weapon

	if ent:IsNPC() or ent:IsPlayer() then
		weapon = ent:GetActiveWeapon()

		if not IsValid(weapon) then return end
	else
		weapon = ent
	end

	if weapon.IsTFA and weapon:IsTFA() then return end

	local clip1 = weapon:Clip1()
	local maxclip1 = weapon:GetMaxClip1()

	if maxclip1 <= 0 or maxclip1 >= 70 then return end

	local mult = clip1 / maxclip1
	if mult >= 0.35 then return end

	data.Pitch = data.Pitch * (1 + (1 / mult) * 0.27)

	return true
end

hook.Add('EntityEmitSound', 'AdjuctPitchOfEmptyMagazine', EntityEmitSound)
