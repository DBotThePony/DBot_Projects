
-- Copyright (C) 2017-2018 DBot

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

local ALLOW_BLINK = CreateConVar('cl_weaponrystats_blinking', '1', {FCVAR_ARCHIVE}, 'Labels of current weapon are blinking')

local GET_POSITION = DLib.HUDCommons.DefinePosition('weaponrystats', 0.7, 15)

surface.CreateFont('WPS.DisplayName', {
	font = 'Exo 2',
	size = 24,
	weight = 500
})

surface.CreateFont('WPS.DisplayName2', {
	font = 'Exo 2',
	size = 17,
	weight = 500
})

surface.CreateFont('WPS.DisplayStats', {
	font = 'PT Sans',
	size = 18,
	weight = 500
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

local alpha = 255

local function doDrawText(text, x, y, color)
	surface.SetTextColor(0, 0, 0, alpha)
	surface.SetTextPos(x + 1, y + 1)
	surface.DrawText(text)

	surface.SetTextColor(color)
	surface.SetTextPos(x, y)
	surface.DrawText(text)
end

local lastWeapon
local lastChange = 0

local function HUDPaint()
	if not weaponrystats.ENABLED:GetBool() then return end
	local ply = LocalPlayer()
	if not ply:IsValid() then return end
	if ply:InVehicle() and not ply:GetAllowWeaponsInVehicle() then return end
	local weapon = ply:GetActiveWeapon()
	if not IsValid(weapon) then return end
	local modif, wtype = weapon:GetWeaponModification(), weapon:GetWeaponType()
	if not modif and not wtype then return end
	local name = weapon:GetPrintName()
	local x, y = GET_POSITION()
	local currentQuality = 0

	local time = RealTimeL()

	if weapon ~= lastWeapon then
		lastChange = RealTimeL() + 4
		lastWeapon = weapon
	end

	if lastChange < time then return end

	local sin = 0
	alpha = (1 - time:progression(lastChange - 1, lastChange)) * 255
	local STATS_COLOR = Color(255, 255, 255, alpha)

	if ALLOW_BLINK:GetBool() then
		sin = math.sin(RealTimeL() * 10) * 20
		STATS_COLOR = Color(230 + sin, 230 + sin, 230 + sin, alpha)
	end

	local speed = 1
	local force = 1
	local damage = 1
	local clip = 1
	local scatter = 1
	local scatterAdd = Vector(0, 0, 0)
	local num = 1
	local numAdd = 0
	local dist = 1
	local randomMin = 1
	local randomMax = 1
	local bulletSpeed = 1
	local bulletRicochet = 1
	local bulletPenetration = 1
	local additional = false
	local add = 0
	local dps = weapon:GetNWInt('wps_dps')

	if string.sub(name, 1, 1) == '#' then
		name = language.GetPhrase(string.sub(name, 2))
	end

	if modif then
		name = modif.name .. ' ' .. name
		currentQuality = currentQuality + (modif.quality or 0)
		speed = speed * modif.speed
		force = force * modif.force
		damage = damage * modif.damage
		clip = clip * modif.clip
		scatter = scatter * modif.scatter
		num = num * modif.num
		dist = dist * modif.dist
		bulletSpeed = bulletSpeed * modif.bulletSpeed
		bulletRicochet = bulletRicochet * modif.bulletRicochet
		bulletPenetration = bulletPenetration * modif.bulletPenetration
		randomMin = randomMin * modif.randomMin
		randomMax = randomMax * modif.randomMax
		scatterAdd = scatterAdd + modif.scatterAdd
		numAdd = numAdd + modif.numAdd
	end

	if wtype then
		name = name .. ' of ' .. wtype.name
		currentQuality = currentQuality + (wtype.quality or 0)
		speed = speed * wtype.speed
		force = damage * wtype.force
		clip = clip * wtype.clip
		scatter = scatter * wtype.scatter
		num = num * wtype.num
		dist = dist * wtype.dist
		randomMin = randomMin * wtype.randomMin
		randomMax = randomMax * wtype.randomMax
		bulletSpeed = bulletSpeed * wtype.bulletSpeed
		bulletRicochet = bulletRicochet * wtype.bulletRicochet
		bulletPenetration = bulletPenetration * wtype.bulletPenetration
		scatterAdd = scatterAdd + wtype.scatterAdd
		numAdd = numAdd + wtype.numAdd

		if wtype.isAdditional then
			add = wtype.damage
			additional = true
		else
			damage = damage * wtype.damage
		end
	end

	local currentQualityColor = math.Clamp(currentQuality + 2, 1, #qualityColors)
	surface.SetFont('WPS.DisplayName')

	local r, g, b = qualityColors[currentQualityColor].r, qualityColors[currentQualityColor].g, qualityColors[currentQualityColor].b
	local colorQuality = Color(math.Clamp(r + sin, 0, 255), math.Clamp(g + sin, 0, 255), math.Clamp(b + sin, 0, 255), alpha)
	doDrawText(name, x, y, colorQuality)

	surface.SetFont('WPS.DisplayName2')
	y = y + 19

	doDrawText(string.format('Level %i weapon', currentQuality), x, y, colorQuality)
	y = y + 16

	doDrawText(string.format('%i damage per second', dps), x, y, STATS_COLOR)
	y = y + 19

	x = x + 7

	surface.SetFont('WPS.DisplayStats')

	if additional then
		doDrawText(string.format('%+i%% damage (+%i%% additional damage)', damage * 100 - 100, add * 100), x, y, STATS_COLOR)
		y = y + 15
	else
		if damage ~= 1 then
			doDrawText(string.format('%+i%% damage', damage * 100 - 100), x, y, STATS_COLOR)
			y = y + 15
		end
	end

	if speed ~= 1 then
		doDrawText(string.format('%+i%% attack speed', speed * 100 - 100), x, y, STATS_COLOR)
		y = y + 15
	end

	if force ~= 1 then
		doDrawText(string.format('%+i%% knockback', force * 100 - 100), x, y, STATS_COLOR)
		y = y + 15
	end

	if clip ~= 1 then
		doDrawText(string.format('%+i%% clip size', clip * 100 - 100), x, y, STATS_COLOR)
		y = y + 15
	end

	if scatterAdd:Length() == 0 then
		if scatter ~= 1 then
			doDrawText(string.format('%+i%% bullet scatter', scatter * 100 - 100), x, y, STATS_COLOR)
			y = y + 15
		end
	else
		doDrawText(string.format('%+i%% bullet scatter (+%i extra)', scatter * 100 - 100, scatterAdd:Length() * 1000), x, y, STATS_COLOR)
		y = y + 15
	end

	if numAdd == 0 then
		if num ~= 1 then
			doDrawText(string.format('%+i%% bullets amount', num * 100 - 100), x, y, STATS_COLOR)
			y = y + 15
		end
	else
		doDrawText(string.format('%+i%% bullets amount (+%i extra bullets)', num * 100 - 100, numAdd), x, y, STATS_COLOR)
		y = y + 15
	end

	if dist ~= 1 then
		doDrawText(string.format('%+i%% bullet travel distance', dist * 100 - 100), x, y, STATS_COLOR)
		y = y + 15
	end

	if bulletSpeed ~= 1 then
		doDrawText(string.format('%+i%% bullet travel speed', bulletSpeed * 100 - 100), x, y, STATS_COLOR)
		y = y + 15
	end

	if bulletRicochet ~= 1 then
		doDrawText(string.format('%+i%% bullet ricochet force', bulletRicochet * 100 - 100), x, y, STATS_COLOR)
		y = y + 15
	end

	if bulletPenetration ~= 1 then
		doDrawText(string.format('%+i%% bullet penetration force', bulletPenetration * 100 - 100), x, y, STATS_COLOR)
		y = y + 15
	end
end

weaponrystats.HUDPaint = HUDPaint

hook.Add('HUDPaint', 'WeaponryStats.HUD', HUDPaint)

hook.Add('StartCommand', 'WeaponryStats.HUD', function(ply, cmd)
	if cmd:KeyDown(IN_RELOAD) then
		lastChange = RealTimeL() + 4
	end
end)
