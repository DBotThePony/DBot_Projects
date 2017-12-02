
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

local DLib = DLib
local HUDCommons = DLib.HUDCommons
local surface = surface
local draw = draw
local RealTime = RealTime
local CurTime = CurTime
local hook = hook
local IsValid = IsValid
local LocalPlayer = LocalPlayer
local ScrW = ScrW
local ScrH = ScrH
local math = math

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

local TEXT_FONT_SMALL = 'KleinerLifeHUD_Small'
local TEXT_FONT = 'KleinerLifeHUD'
local TEXT_FONT2 = 'KleinerLifeHUD2'

surface.CreateFont(TEXT_FONT_SMALL, {
	-- font = 'Somic Sans MS',
	font = 'Comic Sans MS',
	size = 24,
	weight = 400
})

surface.CreateFont(TEXT_FONT, {
	font = 'Perfect DOS VGA 437',
	size = 46,
	weight = 400
})

surface.CreateFont(TEXT_FONT2, {
	font = 'Perfect DOS VGA 437',
	size = 34,
	weight = 400
})

local HPBARS = 20
local CURRENT_HPBARS = 20

local FIRST_THINK = false

local HEALTH = 0

local ARMOR = 0
local AWEAPON

local CLIP1 = 0
local CLIP2 = 0
local CLIP1_MAX = 0
local CLIP2_MAX = 0
local AMMO1 = 0
local AMMO2 = 0

local BAR_WIDTH = 7
local BAR_HEIGHT = ScrH() / 20
local BAR_AMPLITUDE = ScrH() / 150
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
local AMMO_HEIGHT = 100

local function HUDPaint()
	if not ENABLE:GetBool() then return end
	if not ENABLE2:GetBool() then return end
	if not FIRST_THINK then return end
	local x, y = 40, ScrH() - 120
	local ctime = (RealTime() % (math.pi * 50)) * BAR_SPEED_MULTIPLIER

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

	x = ScrW() - 60
	y = ScrH() - 40 - AMMO_HEIGHT

	if CLIP1 > 0 or CLIP1_MAX > 0 or AMMO1 > 0 then
		x = x - AMMO1_WIDTH

		HUDCommons.DrawBox(x, y, AMMO1_WIDTH, AMMO_HEIGHT, AMMO_BACKGROUND)
		HUDCommons.SimpleText('AMMO', TEXT_FONT_SMALL, x + 20, y + 60, TEXT_COLOR)
		HUDCommons.DrawWeaponAmmoIcon(AWEAPON, x + 30, y + 20, TEXT_COLOR)

		if CLIP1_MAX > 0 then
			pattern:Next()
			HUDCommons.SimpleText(CLIP1, TEXT_FONT, x + 110, y + 40, TEXT_COLOR_SHADOW)
			HUDCommons.SimpleText(CLIP1, TEXT_FONT, x + 110 + math.sin(ctime / 2) * 10, y + 40 + math.cos(ctime / 2) * 10, rainbowText:Next())

			pattern:SimpleText(AMMO1, TEXT_FONT2, x + 220, y + 55, TEXT_COLOR)
		end
	end
end

local function Tick()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	FIRST_THINK = true

	local newhp = ply:Health()
	local weapon = ply:GetActiveWeapon()
	ARMOR = ply:Armor()

	HEALTH = newhp
	CURRENT_HPBARS = math.min(20, HEALTH / ply:GetMaxHealth() * HPBARS)
	AWEAPON = weapon

	if IsValid(weapon) then
		CLIP1 = weapon:Clip1()
		CLIP2 = weapon:Clip2()
		CLIP1_MAX = weapon:GetMaxClip1()
		CLIP2_MAX = weapon:GetMaxClip2()

		AMMO1 = ply:GetAmmoCount(weapon:GetPrimaryAmmoType())
		AMMO2 = ply:GetAmmoCount(weapon:GetSecondaryAmmoType())
	else
		CLIP1 = 0
		CLIP2 = 0
		CLIP1_MAX = 0
		CLIP2_MAX = 0
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
