
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


local DLib = DLib
local HUDCommons = DLib.HUDCommons
local surface = surface
local draw = draw
local RealTimeL = RealTimeL
local CurTimeL = CurTimeL
local hook = hook
local IsValid = IsValid
local LocalPlayer = LocalPlayer
local ScrWL = ScrWL
local ScrHL = ScrHL

DLib.RegisterAddonName('Freakman HUD')

local ENABLE = CreateConVar('cl_freakman_hud', '1', {FCVAR_ARCHIVE}, 'Enable Gordon Freakman HUD')
local ENABLE2 = CreateConVar('sv_freakman_hud', '1', {FCVAR_REPLICATED}, 'Enable Gordon Freakman HUD')

local pattern = HUDCommons.Pattern(true, 'GordonFreakman_SANITY', 24, -1.5, 1.5)
local pattern2 = HUDCommons.Pattern(true, 'GordonFreakman_ALT', 24, -1.5, 1.5)
local patternAmmo1 = HUDCommons.Pattern(true, 'GordonFreakman_AMMO1', 24, -1.5, 1.5)
local patternAmmo2 = HUDCommons.Pattern(true, 'GordonFreakman_AMMO2', 24, -1.5, 1.5)
local patternArmor = HUDCommons.Pattern(true, 'GordonFreakman_ARMOR', 24, -1.5, 1.5)

local rainbow = DLib.Rainbow(64, 0.4, 2, true, 0.5)
local rainbow2 = DLib.Rainbow(80, 0.25, 2, true, 0.5)
local rainbowAmmo1 = DLib.Rainbow(100, 0.3, 2, true, 0.5)
local rainbowAmmo2 = DLib.Rainbow(150, 0.4, 2, true, 0.5)
local rainbowArmor = DLib.Rainbow(60, 0.3, 2, true, 0.5)

local BACKGROUND_COLOR = Color(0, 0, 0, 150)
local TEXT_COLOR = Color(228, 230, 68)
local TEXT_COLOR_ALPHA = Color(228, 230, 68)

local HEALTH_WIDTH = 210
local AMMO_WIDTH = 300
local AMMO2_WIDTH = 130
local HEALTH_HEIGHT = 75

surface.CreateFont('Freakman_HudNumbers', {
	font = 'HalfLife2',
	size = 64,
	weight = 500
})

surface.CreateFont('Freakman_HudNumbersGlow', {
	font = 'HalfLife2',
	size = 64,
	weight = 500,
	scanlines = 4,
	blursize = 8
})

surface.CreateFont('Freakman_HudNumbers_SMALL', {
	font = 'HalfLife2',
	size = 32,
	weight = 500
})

surface.CreateFont('Freakman_HudNumbersGlow_SMALL', {
	font = 'HalfLife2',
	size = 32,
	weight = 500,
	scanlines = 4,
	blursize = 8
})

local FONT_NUMBERS = 'Freakman_HudNumbers'
local FONT_NUMBERSS_SMALL = 'Freakman_HudNumbers_SMALL'
local FONT = 'HudHintTextLarge'
local FONT_NUMBERS_GLOWING = 'Freakman_HudNumbersGlow'
local FONT_NUMBERS_GLOWING_SMALL = 'Freakman_HudNumbersGlow_SMALL'

local FIRST_THINK = false

local HEALTH = 0
local LAST_HEALTH_CHANGE = 0

local ARMOR = 0
local LAST_ARMOR_CHANGE = 0
local AWEAPON

local CLIP1 = 0
local CLIP2 = 0
local CLIP1_MAX = 0
local CLIP2_MAX = 0
local AMMO1 = 0
local AMMO2 = 0

local CLIP1_CHANGE = 0
local CLIP2_CHANGE = 0
local CLIP1_MAX_CHANGE = 0
local CLIP2_MAX_CHANGE = 0
local AMMO1_CHANGE = 0
local AMMO2_CHANGE = 0

local function HUDPaint()
	if not ENABLE:GetBool() then return end
	if not ENABLE2:GetBool() then return end
	if not FIRST_THINK then return end

	pattern:Next()

	local x, y = 40, ScrHL() - 30 - HEALTH_HEIGHT

	draw.RoundedBox(8, x, y, HEALTH_WIDTH, HEALTH_HEIGHT, BACKGROUND_COLOR)

	x = x + 19
	y = y + HEALTH_HEIGHT - 30

	HUDCommons.SimpleText('SANITY', FONT, x, y, TEXT_COLOR)

	x = x + 75
	y = y - 45

	pattern:SimpleText(HEALTH, FONT_NUMBERS, x, y, rainbow:Next())

	local time = RealTimeL()

	if LAST_HEALTH_CHANGE > time then
		TEXT_COLOR_ALPHA.a = (LAST_HEALTH_CHANGE - time) / 2 * 255
		pattern:SimpleText(HEALTH, FONT_NUMBERS_GLOWING, x, y, TEXT_COLOR_ALPHA)
	end

	if ARMOR > 0 then
		patternArmor:Next()

		y = ScrHL() - 30 - HEALTH_HEIGHT
		x = 80 + HEALTH_WIDTH

		draw.RoundedBox(8, x, y, HEALTH_WIDTH * 1.1, HEALTH_HEIGHT, BACKGROUND_COLOR)

		x = x + 19
		y = y + HEALTH_HEIGHT - 30

		HUDCommons.SimpleText('HARDNESS', FONT, x, y, TEXT_COLOR)

		x = x + 100
		y = y - 45

		patternArmor:SimpleText(ARMOR, FONT_NUMBERS, x, y, rainbowArmor:Next())

		if LAST_ARMOR_CHANGE > time then
			TEXT_COLOR_ALPHA.a = (LAST_ARMOR_CHANGE - time) / 2 * 255
			pattern:SimpleText(ARMOR, FONT_NUMBERS_GLOWING, x, y, TEXT_COLOR_ALPHA)
		end
	end

	x, y = ScrWL() - 40, ScrHL() - 30 - HEALTH_HEIGHT

	if CLIP2_MAX > 0 or CLIP2 > 0 or AMMO2 > 0 then
		local touse = math.max(CLIP2, AMMO2)
		pattern:Next()

		x = x - AMMO2_WIDTH

		draw.RoundedBox(8, x, y, AMMO2_WIDTH, HEALTH_HEIGHT, BACKGROUND_COLOR)
		HUDCommons.SimpleText('MUZZ', FONT, x + 20, y + 50, TEXT_COLOR)
		HUDCommons.DrawWeaponSecondaryAmmoIcon(AWEAPON, x + 20, y, TEXT_COLOR)

		pattern:SimpleText(touse, FONT_NUMBERS, x + 80, y + 4, rainbow2:Next())

		if AMMO2_CHANGE > time then
			TEXT_COLOR_ALPHA.a = (AMMO2_CHANGE - time) / 2 * 255
			pattern:SimpleText(AMMO2, FONT_NUMBERS_GLOWING, x + 80, y + 4, TEXT_COLOR_ALPHA)
		end

		x = x - 40
	end

	x = x - AMMO_WIDTH

	if CLIP1_MAX > 0 or CLIP1 > 0 or AMMO1 > 0 then
		patternAmmo1:Next()
		patternAmmo2:Next()

		draw.RoundedBox(8, x, y, AMMO_WIDTH, HEALTH_HEIGHT, BACKGROUND_COLOR)

		HUDCommons.SimpleText('AMMO', FONT, x + 20, y + 45, TEXT_COLOR)

		if CLIP1_MAX > 0 then
			patternAmmo1:SimpleText(CLIP1, FONT_NUMBERS, x + 90, y + 4, rainbowAmmo1:Next())
			patternAmmo2:SimpleText(AMMO1, FONT_NUMBERSS_SMALL, x + 220, y + 34, rainbowAmmo2:Next())

			if CLIP1_CHANGE > time then
				TEXT_COLOR_ALPHA.a = (CLIP1_CHANGE - time) / 2 * 255
				pattern:SimpleText(CLIP1, FONT_NUMBERS_GLOWING, x + 90, y + 4, TEXT_COLOR_ALPHA)
			end

			if AMMO1_CHANGE > time then
				TEXT_COLOR_ALPHA.a = (AMMO1_CHANGE - time) / 2 * 255
				pattern:SimpleText(AMMO1, FONT_NUMBERS_GLOWING_SMALL, x + 220, y + 34, TEXT_COLOR_ALPHA)
			end
		else
			patternAmmo1:SimpleText(AMMO1, FONT_NUMBERS, x + 90, y + 4, rainbowAmmo1:Next())
			patternAmmo2:SimpleText('-', FONT_NUMBERSS_SMALL, x + 220, y + 34, rainbowAmmo2:Next())

			if AMMO1_CHANGE > time then
				TEXT_COLOR_ALPHA.a = (AMMO1_CHANGE - time) / 2 * 255
				pattern:SimpleText(AMMO1, FONT_NUMBERS_GLOWING, x + 90, y + 4, TEXT_COLOR_ALPHA)
			end
		end

		HUDCommons.DrawWeaponAmmoIcon(AWEAPON, x + 20, y, TEXT_COLOR)
	end
end

local function Tick()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	FIRST_THINK = true

	local newhp = ply:Health()
	local weapon = ply:GetActiveWeapon()
	local _ARMOR = ply:Armor()

	if HEALTH ~= newhp then
		LAST_HEALTH_CHANGE = RealTimeL() + 2
	end

	if ARMOR ~= _ARMOR then
		LAST_ARMOR_CHANGE = RealTimeL() + 2
	end

	HEALTH = newhp
	ARMOR = _ARMOR

	AWEAPON = weapon

	if IsValid(weapon) then
		local _CLIP1 = weapon:Clip1()
		local _CLIP2 = weapon:Clip2()
		local _CLIP1_MAX = weapon:GetMaxClip1()
		local _CLIP2_MAX = weapon:GetMaxClip2()

		local _AMMO1 = ply:GetAmmoCount(weapon:GetPrimaryAmmoType())
		local _AMMO2 = ply:GetAmmoCount(weapon:GetSecondaryAmmoType())

		if CLIP1 ~= _CLIP1 then
			CLIP1_CHANGE = RealTimeL() + 2
		end

		if CLIP2 ~= _CLIP2 then
			CLIP2_CHANGE = RealTimeL() + 2
		end

		if CLIP1_MAX ~= _CLIP1_MAX then
			CLIP1_MAX_CHANGE = RealTimeL() + 2
		end

		if CLIP2_MAX ~= _CLIP2_MAX then
			CLIP2_MAX_CHANGE = RealTimeL() + 2
		end

		if CLIP2_MAX ~= _CLIP2_MAX then
			CLIP2_MAX_CHANGE = RealTimeL() + 2
		end

		if AMMO1 ~= _AMMO1 then
			AMMO1_CHANGE = RealTimeL() + 2
		end

		if AMMO2 ~= _AMMO2 then
			AMMO2_CHANGE = RealTimeL() + 2
		end

		CLIP1 = _CLIP1
		CLIP2 = _CLIP2
		CLIP1_MAX = _CLIP1_MAX
		CLIP2_MAX = _CLIP2_MAX
		AMMO1 = _AMMO1
		AMMO2 = _AMMO2
	else
		CLIP1 = 0
		CLIP2 = 0
		CLIP1_MAX = 0
		CLIP2_MAX = 0

		CLIP1_CHANGE = 0
		CLIP2_CHANGE = 0
		CLIP1_MAX_CHANGE = 0
		CLIP2_MAX_CHANGE = 0
	end
end

local function HUDShouldDraw(elem)
	if not ENABLE:GetBool() then return end
	if not ENABLE2:GetBool() then return end

	local reply = elem == 'CHudHealth' or
		elem == 'CHudSecondaryAmmo' or
		elem == 'CHudBattery' or
		elem == 'CHudAmmo'

	if reply then return false end
end

hook.Add('Tick', 'FreakmanHUD', Tick)
hook.Add('HUDPaint', 'FreakmanHUD', HUDPaint, -3)
hook.Add('HUDShouldDraw', 'FreakmanHUD', HUDShouldDraw)
