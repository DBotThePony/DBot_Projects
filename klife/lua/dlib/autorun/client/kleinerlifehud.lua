
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

local BAR_FULL_FRONT = Color(0, 216, 255)
local BAR_FULL_BEHIND = Color(39, 161, 183)
local BAR_EMPTY = Color(0, 0, 0, 150)

local HPBARS = 20
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
end

local function Tick()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	FIRST_THINK = true

	local newhp = ply:Health()
	local weapon = ply:GetActiveWeapon()
	local _ARMOR = ply:Armor()

	if HEALTH ~= newhp then
		LAST_HEALTH_CHANGE = RealTime() + 2
	end

	if ARMOR ~= _ARMOR then
		LAST_ARMOR_CHANGE = RealTime() + 2
	end

	HEALTH = newhp
	ARMOR = _ARMOR

	CURRENT_HPBARS = math.min(20, HEALTH / ply:GetMaxHealth() * HPBARS)

	AWEAPON = weapon

	if IsValid(weapon) then
		local _CLIP1 = weapon:Clip1()
		local _CLIP2 = weapon:Clip2()
		local _CLIP1_MAX = weapon:GetMaxClip1()
		local _CLIP2_MAX = weapon:GetMaxClip2()

		local _AMMO1 = ply:GetAmmoCount(weapon:GetPrimaryAmmoType())
		local _AMMO2 = ply:GetAmmoCount(weapon:GetSecondaryAmmoType())

		if CLIP1 ~= _CLIP1 then
			CLIP1_CHANGE = RealTime() + 2
		end

		if CLIP2 ~= _CLIP2 then
			CLIP2_CHANGE = RealTime() + 2
		end

		if CLIP1_MAX ~= _CLIP1_MAX then
			CLIP1_MAX_CHANGE = RealTime() + 2
		end

		if CLIP2_MAX ~= _CLIP2_MAX then
			CLIP2_MAX_CHANGE = RealTime() + 2
		end

		if CLIP2_MAX ~= _CLIP2_MAX then
			CLIP2_MAX_CHANGE = RealTime() + 2
		end

		if AMMO1 ~= _AMMO1 then
			AMMO1_CHANGE = RealTime() + 2
		end

		if AMMO2 ~= _AMMO2 then
			AMMO1_CHANGE = RealTime() + 2
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
