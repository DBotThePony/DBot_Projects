
-- The Unlicense (no Copyright) DBotThePony
-- do whatever you want, including removal of this notice

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
	if mult >= 0.4 then return end
	if mult == 0 then return end

	data.Pitch = data.Pitch * (1 + 0.02 / mult)

	return true
end

hook.Add('EntityEmitSound', 'AdjuctPitchOfEmptyMagazine', EntityEmitSound)
