
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
local math = math

DLib.RegisterAddonName('Kleiner-Life HUD')

local ENABLE = CreateConVar('cl_klife_hud', '1', {FCVAR_ARCHIVE}, 'Enable Kleiner Life HUD')
local ENABLE2 = CreateConVar('sv_klife_hud', '1', {FCVAR_REPLICATED}, 'Enable Kleiner Life HUD')

local rainbowText = DLib.Rainbow(480, 0.02, math.pi / 4, false, 0.6)
local pattern = HUDCommons.Pattern(true, 'KLEINER_LIFE_AMMO_COUNTER_SECONDARY', 24, -2, 2)

local BAR_FULL_FRONT = Color(0, 216, 255)
local BAR_FULL_BEHIND = Color(39, 161, 183)
local BAR_EMPTY = Color(0, 0, 0, 150)
local AMMO_BACKGROUND = Color(0, 165, 195, 20)
local TEXT_COLOR = Color(0, 165, 195)
local TEXT_COLOR_SHADOW = Color(0, 70, 100)
local ARMOR_BAR_COLOR1 = Color(22, 208, 131, 200)
local ARMOR_BAR_COLOR2 = Color(127, 30, 237, 200)

local TEXT_FONT_SMALL = 'KleinerLifeHUD_Small'
local TEXT_FONT = 'KleinerLifeHUD'
local TEXT_FONT_BIG = 'KleinerLifeHUD_BIG'
local TEXT_FONT_BLUR = 'KleinerLifeHUD_BLUR'
local TEXT_FONT_BIG_BLUR = 'KleinerLifeHUD_BIG_BLUR'
local TEXT_FONT2 = 'KleinerLifeHUD2'
local TEXT_FONT2_BLUR = 'KleinerLifeHUD2_BLUR'

surface.CreateFont(TEXT_FONT_SMALL, {
	-- font = 'Somic Sans MS',
	font = 'Comic Sans MS',
	size = 24,
	weight = 400
})

surface.CreateFont(TEXT_FONT, {
	font = 'Perfect DOS VGA 437',
	size = 46,
	weight = 500
})

surface.CreateFont(TEXT_FONT_BIG, {
	font = 'Perfect DOS VGA 437',
	size = 60,
	weight = 500
})

surface.CreateFont(TEXT_FONT2, {
	font = 'Perfect DOS VGA 437',
	size = 34,
	weight = 500
})

surface.CreateFont(TEXT_FONT_BLUR, {
	font = 'Perfect DOS VGA 437',
	size = 46,
	weight = 500,
	scanlines = 4,
	blursize = 8
})

surface.CreateFont(TEXT_FONT_BIG_BLUR, {
	font = 'Perfect DOS VGA 437',
	size = 60,
	weight = 500,
	scanlines = 4,
	blursize = 24
})

surface.CreateFont(TEXT_FONT2_BLUR, {
	font = 'Perfect DOS VGA 437',
	size = 34,
	weight = 500,
	scanlines = 4,
	blursize = 8
})

local HPBARS = 20
local ARMORBARS1 = 0
local ARMORBARS2 = 0
local CURRENT_HPBARS = 20

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

local BAR_WIDTH = 7
local BAR_HEIGHT = ScrHL() / 20
local BAR_AMPLITUDE = ScrHL() / 150
local BAR_SPEED_MULTIPLIER = 4
local BAR_SIN_SPACING = 2
local BAR_SPACING = BAR_WIDTH * 3 + 4

local function drawBarPiece(x, y, colFirst, colSecond)
	surface.SetDrawColor(colFirst)
	surface.DrawRect(x, y, BAR_WIDTH, BAR_HEIGHT)
	surface.SetDrawColor(colFirst)
	surface.DrawRect(x + BAR_WIDTH, y - 8, BAR_WIDTH, BAR_HEIGHT)
	surface.SetDrawColor(colSecond)
	surface.DrawRect(x + BAR_WIDTH * 2, y - 8, BAR_WIDTH * 0.75, BAR_HEIGHT)
end

local AMMO1_WIDTH = 300
local AMMO2_WIDTH = 180
local AMMO_HEIGHT = 100

local function colDiff(colIn, diff)
	return Color(colIn.r, colIn.g, colIn.b, 255 * (diff - RealTimeL()) / 2)
end

local function HUDPaint()
	if not ENABLE:GetBool() then return end
	if not ENABLE2:GetBool() then return end
	if not FIRST_THINK then return end
	local x, y = 40, ScrHL() - 120
	local ctime = (RealTimeL() % (math.pi * 50)) * BAR_SPEED_MULTIPLIER
	local rtime = RealTimeL()

	for i = 1, CURRENT_HPBARS do
		local sin = math.sin(ctime + i / BAR_SIN_SPACING)
		drawBarPiece(x, y + sin * BAR_AMPLITUDE, BAR_FULL_FRONT, BAR_FULL_BEHIND)
		x = x + BAR_SPACING
	end

	for i = CURRENT_HPBARS + 1, HPBARS do
		local sin = math.sin(ctime + i / BAR_SIN_SPACING)
		drawBarPiece(x, y + sin * BAR_AMPLITUDE, BAR_EMPTY, BAR_EMPTY)
		x = x + BAR_SPACING
	end

	x, y = 40, ScrHL() - 120

	for i = 1, ARMORBARS1 do
		local sin = math.sin(ctime + i / BAR_SIN_SPACING)
		drawBarPiece(x, y + sin * BAR_AMPLITUDE, ARMOR_BAR_COLOR1, ARMOR_BAR_COLOR1)
		x = x + BAR_SPACING
	end

	x, y = 40, ScrHL() - 120

	for i = 1, ARMORBARS2 do
		local sin = math.sin(ctime + i / BAR_SIN_SPACING)
		drawBarPiece(x, y + sin * BAR_AMPLITUDE, ARMOR_BAR_COLOR1, ARMOR_BAR_COLOR2)
		x = x + BAR_SPACING
	end

	x = ScrWL() - 60
	y = ScrHL() - 40 - AMMO_HEIGHT

	if CLIP2_MAX > 0 or CLIP2 > 0 or AMMO2 > 0 then
		local touse = math.max(CLIP2, AMMO2)

		x = x - AMMO2_WIDTH

		HUDCommons.DrawBox(x, y, AMMO2_WIDTH, AMMO_HEIGHT, AMMO_BACKGROUND)
		HUDCommons.SimpleText('CLICKS', TEXT_FONT_SMALL, x + 20, y + 60, TEXT_COLOR)
		HUDCommons.DrawWeaponSecondaryAmmoIcon(AWEAPON, x + 30, y + 10, TEXT_COLOR)

		HUDCommons.SimpleText(touse, TEXT_FONT, x + 110, y + 40, TEXT_COLOR_SHADOW)
		local rcolor = rainbowText:Next()
		local X, Y = x + 110 + math.sin(ctime / 2) * 10, y + 40 + math.cos(ctime / 2) * 10
		HUDCommons.SimpleText(touse, TEXT_FONT, X, Y, rcolor)

		if AMMO2_CHANGE > rtime then
			HUDCommons.SimpleText(touse, TEXT_FONT_BLUR, x + 110, y + 40, colDiff(TEXT_COLOR_SHADOW, AMMO2_CHANGE))
			HUDCommons.SimpleText(touse, TEXT_FONT_BLUR, X, Y, colDiff(rcolor, AMMO2_CHANGE))
		end

		x = x - 40
	end

	if CLIP1 > 0 or CLIP1_MAX > 0 or AMMO1 > 0 then
		x = x - AMMO1_WIDTH

		HUDCommons.DrawBox(x, y, AMMO1_WIDTH, AMMO_HEIGHT, AMMO_BACKGROUND)
		HUDCommons.SimpleText('AMMO', TEXT_FONT_SMALL, x + 20, y + 60, TEXT_COLOR)
		HUDCommons.DrawWeaponAmmoIcon(AWEAPON, x + 30, y + 20, TEXT_COLOR)

		if CLIP1_MAX > 0 then
			pattern:Next()

			HUDCommons.SimpleText(CLIP1, TEXT_FONT, x + 110, y + 40, TEXT_COLOR_SHADOW)
			local rcolor = rainbowText:Next()
			local X, Y = x + 110 + math.sin(ctime / 2) * 10, y + 40 + math.cos(ctime / 2) * 10
			HUDCommons.SimpleText(CLIP1, TEXT_FONT, X, Y, rcolor)

			if CLIP1_CHANGE > rtime then
				HUDCommons.SimpleText(CLIP1, TEXT_FONT_BLUR, x + 110, y + 40, colDiff(TEXT_COLOR_SHADOW, CLIP1_CHANGE))
				HUDCommons.SimpleText(CLIP1, TEXT_FONT_BLUR, X, Y, colDiff(rcolor, CLIP1_CHANGE))
			end

			pattern:SimpleText(AMMO1, TEXT_FONT2, x + 220, y + 55, TEXT_COLOR)

			if AMMO1_CHANGE > rtime then
				pattern:SimpleText(AMMO1, TEXT_FONT2_BLUR, x + 220, y + 55, colDiff(TEXT_COLOR, AMMO1_CHANGE))
			end
		else
			HUDCommons.SimpleText(AMMO1, TEXT_FONT_BIG, x + 140, y + 20, TEXT_COLOR_SHADOW)
			local rcolor = rainbowText:Next()
			local X, Y = x + 140 + math.sin(ctime / 2) * 10, y + 20 + math.cos(ctime / 2) * 10
			HUDCommons.SimpleText(AMMO1, TEXT_FONT_BIG, X, Y, rcolor)

			if AMMO1_CHANGE > rtime then
				HUDCommons.SimpleText(AMMO1, TEXT_FONT_BIG_BLUR, x + 110, y + 40, colDiff(TEXT_COLOR_SHADOW, CLIP1_CHANGE))
				HUDCommons.SimpleText(AMMO1, TEXT_FONT_BIG_BLUR, X, Y, colDiff(rcolor, CLIP1_CHANGE))
			end
		end
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

	CURRENT_HPBARS = math.min(20, HEALTH / ply:GetMaxHealth() * HPBARS)
	ARMORBARS1 = math.min(20, ARMOR / 100 * HPBARS)
	ARMORBARS2 = math.max(math.min(40, ARMOR / 100 * HPBARS) - 20, 0)
	AWEAPON = weapon

	HEALTH = newhp
	ARMOR = _ARMOR

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

hook.Add('Tick', 'KleinerLifeHUD', Tick)
hook.Add('HUDPaint', 'KleinerLifeHUD', HUDPaint, -3)
hook.Add('HUDShouldDraw', 'KleinerLifeHUD', HUDShouldDraw)
