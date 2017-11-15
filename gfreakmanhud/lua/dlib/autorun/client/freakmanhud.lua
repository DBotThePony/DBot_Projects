
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

local ENABLE = CreateConVar('cl_freakman_hud', '1', {FCVAR_ARCHIVE}, 'Enable Gordon Freakman HUD')
local pattern = HUDCommons.Pattern(true, 'GordonFreakman', 24, -1.5, 1.5)
local rainbow = DLib.Rainbow(64, 0.4, 2, true, 0.5)

local BACKGROUND_COLOR = Color(0, 0, 0, 60)
local TEXT_COLOR = Color(228, 230, 68)
local TEXT_COLOR_ALPHA = Color(228, 230, 68)

local HEALTH_WIDTH = 210
local HEALTH_HEIGHT = 70

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

local FONT_NUMBERS = 'Freakman_HudNumbers'
local FONT = 'HudHintTextLarge'
local FONT_NUMBERS_GLOWING = 'Freakman_HudNumbersGlow'

local FIRST_THINK = false

local HEALTH = 0
local LAST_HEALTH_CHANGE = 0

local function HUDPaint()
	if not ENABLE:GetBool() then return end
	if not FIRST_THINK then return end

	pattern:Next()

	local x, y = 40, ScrH() - 30 - HEALTH_HEIGHT

	draw.RoundedBox(8, x, y, HEALTH_WIDTH, HEALTH_HEIGHT, BACKGROUND_COLOR)

	x = x + 19
	y = y + HEALTH_HEIGHT - 30

	HUDCommons.SimpleText('SANITY', FONT, x, y, TEXT_COLOR)

	x = x + 75
	y = y - 40

	pattern:SimpleText(HEALTH, FONT_NUMBERS, x, y, rainbow:Next())

	local time = RealTime()

	if LAST_HEALTH_CHANGE > time then
		TEXT_COLOR_ALPHA.a = (LAST_HEALTH_CHANGE - time) / 2 * 255
		pattern:SimpleText(HEALTH, FONT_NUMBERS_GLOWING, x, y, TEXT_COLOR_ALPHA)
	end
end

local function Tick()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	FIRST_THINK = true

	local newhp = ply:Health()

	if HEALTH ~= newhp then
		LAST_HEALTH_CHANGE = RealTime() + 2
	end

	HEALTH = newhp
end

local function HUDShouldDraw(elem)
	if not ENABLE:GetBool() then return end

	local reply = elem == 'CHudHealth' or
		elem == 'CHudSecondaryAmmo' or
		elem == 'CHudWeapon'

	if reply then return false end
end

hook.Add('Tick', 'FreakmanHUD', Tick)
hook.Add('HUDPaint', 'FreakmanHUD', HUDPaint, -3)
hook.Add('HUDShouldDraw', 'FreakmanHUD', HUDShouldDraw)
