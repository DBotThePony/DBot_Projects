
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

surface.CreateFont('WPS.DisplayName', {
	font = 'Roboto',
	size = 18,
	weight = 400
})

surface.CreateFont('WPS.DisplayStats', {
	font = 'Roboto',
	size = 14,
	weight = 400
})

local qualityColors = {
	Color(141, 141, 141),
	Color(255, 255, 255),
	Color(41, 78, 200),
	Color(35, 162, 68),
	Color(254, 199, 134),
	Color(239, 122, 122),
	Color(246, 156, 241),
	Color(173, 82, 231),
	Color(0, 255, 60),
	Color(255, 241, 15),
	Color(0, 255, 246),
	Color(255, 0, 0),
	Color(108, 0, 255),
}

local function doDrawText(text, x, y, color)
	surface.SetTextColor(0, 0, 0)
	surface.SetTextPos(x + 1, y + 1)
	surface.DrawText(text)

	surface.SetTextColor(color)
	surface.SetTextPos(x, y)
	surface.DrawText(text)
end

local STATS_COLOR = Color(255, 255, 255)

local function HUDPaint()
	local weapon = LocalPlayer():GetActiveWeapon()
	if not IsValid(weapon) then return end
	local modif, wtype = weapon:GetWeaponModification(), weapon:GetWeaponType()
	if not modif and not wtype then return end
	local name = weapon:GetPrintName()
	local x, y = ScrW() * 0.7, 15
	local currentQuality = 0

	local speed = 1
	local force = 1
	local damage = 1
	local additional = false
	local add = 0

	if string.sub(name, 1, 1) == '#' then
		name = language.GetPhrase(string.sub(name, 2))
	end

	if modif then
		name = modif.name .. ' ' .. name
		currentQuality = currentQuality + (modif.quality or 0)
		speed = speed * modif.speed
		force = force * modif.force
		damage = damage * modif.damage
	end

	if wtype then
		name = name .. ' of ' .. wtype.name
		currentQuality = currentQuality + (wtype.quality or 0)
		speed = speed * wtype.speed
		force = damage * wtype.force

		if wtype.isAdditional then
			add = wtype.damage
			additional = true
		else
			damage = damage * wtype.damage
		end
	end

	currentQuality = math.Clamp(currentQuality + 2, 1, #qualityColors)
	surface.SetFont('WPS.DisplayName')

	doDrawText(name, x, y, qualityColors[currentQuality])

	y = y + 17

	surface.SetFont('WPS.DisplayStats')

	doDrawText(string.format('Level %i weapon', currentQuality - 2), x, y, qualityColors[currentQuality])
	y = y + 19

	if additional then
		doDrawText(string.format('%i%% damage (+%i%% additional damage)', damage * 100, add * 100), x, y, STATS_COLOR)
		y = y + 15
	else
		doDrawText(string.format('%i%% damage', damage * 100), x, y, STATS_COLOR)
		y = y + 15
	end

	doDrawText(string.format('%i%% attack speed', speed * 100), x, y, STATS_COLOR)
	y = y + 15
	doDrawText(string.format('%i%% knockback', force * 100), x, y, STATS_COLOR)
	y = y + 15
end

weaponrystats.HUDPaint = HUDPaint

hook.Add('HUDPaint', 'WeaponryStats.HUD', HUDPaint)
