
--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

export DTF2
DTF2 = DTF2 or {}

if not _G.HUDCommons
	include 'autorun/hudcommons.lua'

DRAW_LIGHT = CreateConVar('tf_hud_draw_light', '1', {FCVAR_ARCHIVE}, 'Always draw status about builded buildables')

eng_build_sentry_blueprint = Material('hud/eng_build_sentry_blueprint')
eng_build_tele_entrance_blueprint = Material('hud/eng_build_tele_entrance_blueprint')
eng_build_tele_exit_blueprint = Material('hud/eng_build_tele_exit_blueprint')
eng_build_dispenser_blueprint = Material('hud/eng_build_dispenser_blueprint')

ico_demolish = Material('hud/ico_demolish')
ico_metal = Material('hud/ico_metal')
ico_metal_mask = Material('hud/ico_metal_mask')
hud_obj_status_sentry_1 = Material('hud/hud_obj_status_sentry_1')
hud_obj_status_sentry_2 = Material('hud/hud_obj_status_sentry_2')
hud_obj_status_sentry_3 = Material('hud/hud_obj_status_sentry_3')
hud_obj_status_tele_entrance = Material('hud/hud_obj_status_tele_entrance')
hud_obj_status_tele_exit = Material('hud/hud_obj_status_tele_exit')
hud_obj_status_dispenser = Material('hud/hud_obj_status_dispenser')
hud_obj_status_sapper = Material('hud/hud_obj_status_sapper')
hud_obj_status_rockets_64 = Material('hud/hud_obj_status_rockets_64')
hud_obj_status_kill_64 = Material('hud/hud_obj_status_kill_64')
hud_obj_status_teleport_64 = Material('hud/hud_obj_status_teleport_64')
hud_obj_status_ammo_64 = Material('hud/hud_obj_status_ammo_64')

surface.CreateFont('DTF2.BuildUpFont', {
	'font': 'Roboto'
	'size': 32
	'weight': 800
})

surface.CreateFont('DTF2.BuildSmallFont', {
	'font': 'Roboto'
	'size': 16
	'weight': 500
})

surface.CreateFont('DTF2.BuildMediumFont', {
	'font': 'Roboto'
	'size': 18
	'weight': 500
})

surface.CreateFont('DTF2.NotBuilt', {
	'font': 'Roboto'
	'size': 24
	'weight': 500
})

surface.CreateFont('DTF2.BuildableName', {
	'font': 'Roboto'
	'size': 20
	'weight': 800
})

surface.CreateFont('DTF2.SentryKills', {
	'font': 'Roboto'
	'size': 16
	'weight': 400
})

WIDTH = 510
HEIGHT = 190
HEIGHT_COSTS = 210
ICON_WIDTH = 96
ICON_HEIGHT = 96
ICONS_SPACING = 36
BUILD_FONT_AFFORD = HUDCommons.CreateColor('tf_build_can_build', 'TF Can Build Font', 255, 255, 255)
BUILD_FONT_NOT_AFFORD = HUDCommons.CreateColor('tf_build_cant_build', 'TF Cant Build Font', 200, 40, 40)
BUILD_FONT_COLOR = HUDCommons.CreateColor('tf_build_font', 'TF Build Font', 255, 255, 255)
BUILD_FONT_COLOR_INACTIVE = HUDCommons.CreateColor('tf_build_fontin', 'TF Build Font Inactive', 170, 170, 170)
BUILD_POSITION = HUDCommons.DefinePosition('tf_build_clr', 0.5, 0.4)

BUILD_BG_NOTBUILT = HUDCommons.CreateColor('tf_bg_notbuilt', 'TF Not built background', 70, 70, 70, 150)
BUILD_BG_BUILT = HUDCommons.CreateColor('tf_bg_built', 'TF built background', 0, 0, 0, 150)
BAR_BACKGROUND = HUDCommons.CreateColor('tf_bar_bg', 'TF bars background', 170, 170, 170)
AMMO_BAR = HUDCommons.CreateColor('tf_bar_ammo', 'TF sentry ammo bar', 255, 255, 255)
DISPERNSER_AMMO_BAR = HUDCommons.CreateColor('tf_bar_disammo', 'TF dispenser ammo bar', 255, 255, 255)
TELEPORTER_BAR = HUDCommons.CreateColor('tf_bar_teleport', 'TF teleporter recharge bar', 255, 255, 255)
UPGRADE_BAR = HUDCommons.CreateColor('tf_bar_upgrade', 'TF teleporter upgrade bar', 255, 255, 255)
ROCKETS_BAR = HUDCommons.CreateColor('tf_bar_rockets', 'TF sentry rockets bar', 255, 255, 255)
KILLS = HUDCommons.CreateColor('tf_sentry_kills', 'TF sentry kills', 255, 255, 255)
TELEPORTS = HUDCommons.CreateColor('tf_sentry_kills', 'TF teleporter teleports', 255, 255, 255)
BUILDABLES_POSITION = HUDCommons.DefinePosition('tf_buildables', 10, 10)

BUILDABLES_WIDTH = 300
BUILDABLES_HEIGHT = 70
BUILDABLES_HEIGHT_SENTRY = 100

DTF2.DrawSentryHUD = (sentry, x, y, centered = false, isHUD = false) ->
	x -= BUILDABLES_WIDTH / 2 if centered
	lvl = sentry\GetLevel()
	hp, mhp = sentry\Health(), sentry\GetMaxHealth()
	local icon
	switch lvl
		when 1
			icon = hud_obj_status_sentry_1
		when 2
			icon = hud_obj_status_sentry_2
		when 3
			icon = hud_obj_status_sentry_3
	surface.SetDrawColor(BUILD_BG_BUILT())
	surface.DrawRect(x, y, BUILDABLES_WIDTH, BUILDABLES_HEIGHT_SENTRY)
	surface.SetTextColor(BUILD_FONT_COLOR())
	if isHUD
		surface.SetTextPos(x + BUILDABLES_WIDTH / 2 - 30, y + 3)
		surface.SetFont('DTF2.BuildableNameSmall')
		text = 'DISPENSER ' .. lvl
		if IsValid(sentry\GetTFPlayer()) and sentry\GetTFPlayer()\IsPlayer()
			text ..= ' built by ' .. sentry\GetTFPlayer()\Nick()
		surface.DrawText()
	else
		surface.SetTextPos(x + BUILDABLES_WIDTH / 2, y + 3)
		surface.SetFont('DTF2.BuildableName')
		surface.DrawText('SENTRY GUN ' .. lvl)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(icon)
	surface.DrawTexturedRect(x + 30, y + 5, 90, 90)
	HUDCommons.VerticalStripped({
		x: x + 3
		y: y + 3
		bars: 11
		spacing: 4
		width: 20
		mult: hp / mhp
	})
	x += 120
	y += 30

	isBuild, left, buildMult = sentry\GetBuildingStatus()

	if not isBuild
		surface.SetDrawColor(KILLS())
		surface.SetMaterial(hud_obj_status_kill_64)
		surface.DrawTexturedRect(x, y, 16, 16)
		surface.SetTextColor(KILLS())
		surface.SetTextPos(x + 22, y)
		surface.SetFont('DTF2.SentryKills')
		surface.DrawText(sentry\GetKills())
		y += 24
		switch lvl
			when 1, 2
				surface.SetDrawColor(AMMO_BAR())
				surface.SetMaterial(hud_obj_status_ammo_64)
				surface.DrawTexturedRect(x, y, 16, 16)
				HUDCommons.SoftBarMult(x + 22, y, 130, 16, sentry\GetAmmoAmount() / sentry\GetMaxAmmo(), AMMO_BAR(), BAR_BACKGROUND(), 'tf_sentry_ammo')
				
				y += 24
				surface.SetDrawColor(UPGRADE_BAR())
				surface.SetMaterial(ico_metal_mask)
				surface.DrawTexturedRect(x, y, 16, 16)
				HUDCommons.SoftBarMult(x + 22, y, 130, 16, sentry\GetUpgradeAmount() / sentry\GetMaxUpgrade(), UPGRADE_BAR(), BAR_BACKGROUND(), 'tf_sentry_upgrade')
			when 3
				surface.SetDrawColor(AMMO_BAR())
				surface.SetMaterial(hud_obj_status_ammo_64)
				surface.DrawTexturedRect(x, y, 16, 16)
				HUDCommons.SoftBarMult(x + 22, y, 130, 16, sentry\GetAmmoAmount() / sentry\GetMaxAmmo(), AMMO_BAR(), BAR_BACKGROUND(), 'tf_sentry_ammo')
				
				y += 24
				surface.SetDrawColor(ROCKETS_BAR())
				surface.SetMaterial(hud_obj_status_rockets_64)
				surface.DrawTexturedRect(x, y, 16, 16)
				HUDCommons.SoftBarMult(x + 22, y, 130, 16, sentry\GetRocketsPercent(), ROCKETS_BAR(), BAR_BACKGROUND(), 'tf_sentry_rockets')
	else
		y += 12
		surface.SetDrawColor(UPGRADE_BAR())
		surface.SetMaterial(ico_metal_mask)
		surface.DrawTexturedRect(x, y, 16, 16)
		HUDCommons.SoftBarMult(x + 22, y, 130, 16, buildMult, UPGRADE_BAR(), BAR_BACKGROUND(), 'tf_sentry_built')

DTF2.DrawDispenserHUD = (dispenser, x, y, centered = false, isHUD = false) ->
	x -= BUILDABLES_WIDTH / 2 if centered
	lvl = dispenser\GetLevel()
	hp, mhp = dispenser\Health(), dispenser\GetMaxHealth()
	icon = hud_obj_status_dispenser
	surface.SetDrawColor(BUILD_BG_BUILT())
	surface.DrawRect(x, y, BUILDABLES_WIDTH, BUILDABLES_HEIGHT)
	surface.SetTextColor(BUILD_FONT_COLOR())
	if isHUD
		surface.SetTextPos(x + BUILDABLES_WIDTH / 2 - 30, y + 3)
		surface.SetFont('DTF2.BuildableNameSmall')
		text = 'DISPENSER ' .. lvl
		if IsValid(dispenser\GetTFPlayer()) and dispenser\GetTFPlayer()\IsPlayer()
			text ..= ' built by ' .. dispenser\GetTFPlayer()\Nick()
		surface.DrawText()
	else
		surface.SetTextPos(x + BUILDABLES_WIDTH / 2, y + 3)
		surface.SetFont('DTF2.BuildableName')
		surface.DrawText('DISPENSER ' .. lvl)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(icon)
	surface.DrawTexturedRect(x + 30, y + 5, 60, 60)
	HUDCommons.VerticalStripped({
		x: x + 3
		y: y + 5
		bars: 8
		spacing: 3
		width: 20
		mult: hp / mhp
	})
	x += 120
	y += 24
	isBuild, left, buildMult = dispenser\GetBuildingStatus()

	if not isBuild
		switch lvl
			when 1, 2
				surface.SetDrawColor(DISPERNSER_AMMO_BAR())
				surface.SetMaterial(hud_obj_status_ammo_64)
				surface.DrawTexturedRect(x, y, 16, 16)
				HUDCommons.SoftBarMult(x + 22, y, 130, 16, dispenser\GetRessuplyAmount() / dispenser\GetMaxRessuply(), DISPERNSER_AMMO_BAR(), BAR_BACKGROUND(), 'tf_dispenser_ammo')
				
				y += 24
				surface.SetDrawColor(UPGRADE_BAR())
				surface.SetMaterial(ico_metal_mask)
				surface.DrawTexturedRect(x, y, 16, 16)
				HUDCommons.SoftBarMult(x + 22, y, 130, 16, dispenser\GetUpgradeAmount() / dispenser\GetMaxUpgrade(), UPGRADE_BAR(), BAR_BACKGROUND(), 'tf_dispenser_upgrade')
			when 3
				surface.SetDrawColor(DISPERNSER_AMMO_BAR())
				surface.SetMaterial(hud_obj_status_ammo_64)
				surface.DrawTexturedRect(x, y + 10, 16, 16)
				HUDCommons.SoftBarMult(x + 22, y + 10, 130, 16, dispenser\GetRessuplyAmount() / dispenser\GetMaxRessuply(), DISPERNSER_AMMO_BAR(), BAR_BACKGROUND(), 'tf_dispenser_ammo')
	else
		y += 12
		surface.SetDrawColor(UPGRADE_BAR())
		surface.SetMaterial(ico_metal_mask)
		surface.DrawTexturedRect(x, y, 16, 16)
		HUDCommons.SoftBarMult(x + 22, y, 130, 16, buildMult, UPGRADE_BAR(), BAR_BACKGROUND(), 'tf_dispenser_built')

DTF2.DrawTeleporterEntranceHUD = (teleporter, x, y, centered = false, isHUD = false) ->
	x -= BUILDABLES_WIDTH / 2 if centered
	lvl = teleporter\GetLevel()
	hp, mhp = teleporter\Health(), teleporter\GetMaxHealth()
	icon = hud_obj_status_tele_entrance
	surface.SetDrawColor(BUILD_BG_BUILT())
	surface.DrawRect(x, y, BUILDABLES_WIDTH, BUILDABLES_HEIGHT)
	surface.SetTextColor(BUILD_FONT_COLOR())
	if isHUD
		surface.SetTextPos(x + BUILDABLES_WIDTH / 2 - 70, y + 3)
		surface.SetFont('DTF2.BuildableNameSmall')
		text = 'TELEPORTER ENTRANCE ' .. lvl
		if IsValid(teleporter\GetTFPlayer()) and teleporter\GetTFPlayer()\IsPlayer()
			text ..= ' built by ' .. teleporter\GetTFPlayer()\Nick()
		surface.DrawText()
	else
		surface.SetTextPos(x + BUILDABLES_WIDTH / 2 - 70, y + 3)
		surface.SetFont('DTF2.BuildableName')
		surface.DrawText('TELEPORTER ENTRANCE ' .. lvl)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(icon)
	surface.DrawTexturedRect(x + 30, y + 5, 60, 60)
	HUDCommons.VerticalStripped({
		x: x + 3
		y: y + 5
		bars: 8
		spacing: 3
		width: 20
		mult: hp / mhp
	})
	x += 120
	y += 24

	isBuild, left, buildMult = teleporter\GetBuildingStatus()

	if not isBuild
		if lvl < 3
			surface.SetDrawColor(UPGRADE_BAR())
			surface.SetMaterial(ico_metal_mask)
			surface.DrawTexturedRect(x, y, 16, 16)
			HUDCommons.SoftBarMult(x + 22, y, 130, 16, teleporter\GetUpgradeAmount() / teleporter\GetMaxUpgrade(), UPGRADE_BAR(), BAR_BACKGROUND(), 'tf_tele_upgrade')
			y += 24
		else
			y += 9
		
		surface.SetDrawColor(TELEPORTER_BAR())
		surface.SetMaterial(hud_obj_status_teleport_64)
		surface.DrawTexturedRect(x, y, 16, 16)
		surface.DrawTexturedRect(x, y, 16, 16)

		if teleporter\GetResetAt() > CurTime()
			HUDCommons.SoftBarMult(x + 22, y, 130, 16, 1 - (teleporter\GetResetAt() - CurTime()) / teleporter\GetReloadTime(), TELEPORTER_BAR(), BAR_BACKGROUND(), 'tf_tele_charge')
		else
			surface.SetTextColor(TELEPORTS())
			surface.SetTextPos(x + 22, y)
			surface.SetFont('DTF2.SentryKills')
			surface.DrawText(teleporter\GetUses())
	else
		y += 12
		surface.SetDrawColor(UPGRADE_BAR())
		surface.SetMaterial(ico_metal_mask)
		surface.DrawTexturedRect(x, y, 16, 16)
		HUDCommons.SoftBarMult(x + 22, y, 130, 16, buildMult, UPGRADE_BAR(), BAR_BACKGROUND(), 'tf_teleporter_entrance_built')

DTF2.DrawTeleporterExitHUD = (teleporter, x, y, centered = false, isHUD = false) ->
	x -= BUILDABLES_WIDTH / 2 if centered
	lvl = teleporter\GetLevel()
	hp, mhp = teleporter\Health(), teleporter\GetMaxHealth()
	icon = hud_obj_status_tele_exit
	surface.SetDrawColor(BUILD_BG_BUILT())
	surface.DrawRect(x, y, BUILDABLES_WIDTH, BUILDABLES_HEIGHT)
	surface.SetTextColor(BUILD_FONT_COLOR())
	if isHUD
		surface.SetTextPos(x + BUILDABLES_WIDTH / 2 - 70, y + 3)
		surface.SetFont('DTF2.BuildableNameSmall')
		text = 'TELEPORTER EXIT ' .. lvl
		if IsValid(teleporter\GetTFPlayer()) and teleporter\GetTFPlayer()\IsPlayer()
			text ..= ' built by ' .. teleporter\GetTFPlayer()\Nick()
		surface.DrawText()
	else
		surface.SetTextPos(x + BUILDABLES_WIDTH / 2 - 70, y + 3)
		surface.SetFont('DTF2.BuildableName')
		surface.DrawText('TELEPORTER EXIT ' .. lvl)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(icon)
	surface.DrawTexturedRect(x + 30, y + 5, 60, 60)
	HUDCommons.VerticalStripped({
		x: x + 3
		y: y + 5
		bars: 8
		spacing: 3
		width: 20
		mult: hp / mhp
	})
	x += 120
	y += 24

	isBuild, left, buildMult = teleporter\GetBuildingStatus()

	if not isBuild
		if lvl < 3
			surface.SetDrawColor(UPGRADE_BAR())
			surface.SetMaterial(ico_metal_mask)
			surface.DrawTexturedRect(x, y, 16, 16)
			HUDCommons.SoftBarMult(x + 22, y, 130, 16, teleporter\GetUpgradeAmount() / teleporter\GetMaxUpgrade(), UPGRADE_BAR(), BAR_BACKGROUND(), 'tf_tele_upgrade')
			y += 24
		else
			y += 9

		if teleporter\GetResetAt() > CurTime()
			surface.SetDrawColor(TELEPORTER_BAR())
			surface.SetMaterial(hud_obj_status_teleport_64)
			surface.DrawTexturedRect(x, y, 16, 16)
			surface.DrawTexturedRect(x, y, 16, 16)
			HUDCommons.SoftBarMult(x + 22, y, 130, 16, 1 - (teleporter\GetResetAt() - CurTime()) / teleporter\GetReloadTime(), TELEPORTER_BAR(), BAR_BACKGROUND(), 'tf_tele_charge')
	else
		y += 12
		surface.SetDrawColor(UPGRADE_BAR())
		surface.SetMaterial(ico_metal_mask)
		surface.DrawTexturedRect(x, y, 16, 16)
		HUDCommons.SoftBarMult(x + 22, y, 130, 16, buildMult, UPGRADE_BAR(), BAR_BACKGROUND(), 'tf_teleporter_exit_built')

LAST_FRAME = 0

DTF2.DrawBuildablesHUD = (ply = LocalPlayer()) =>
	LAST_FRAME = FrameNumber()
	sentry = ply\GetBuildedSentry()
	dispenser = ply\GetBuildedDispenser()
	entrance = ply\GetBuildedTeleporterIn()
	exit = ply\GetBuildedTeleporterOut()
	x, y = BUILDABLES_POSITION()

	if not IsValid(sentry)
		surface.SetDrawColor(BUILD_BG_NOTBUILT())
		surface.DrawRect(x, y, BUILDABLES_WIDTH, BUILDABLES_HEIGHT_SENTRY)
		surface.SetTextColor(BUILD_FONT_COLOR())
		surface.SetTextPos(x + BUILDABLES_WIDTH / 2, y + 3)
		surface.SetFont('DTF2.BuildableName')
		surface.DrawText('SENTRY GUN')
		surface.SetTextPos(x + BUILDABLES_WIDTH / 2 - 20, y + BUILDABLES_HEIGHT_SENTRY / 2 - 10)
		surface.SetFont('DTF2.NotBuilt')
		surface.DrawText('Not Built')
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(hud_obj_status_sentry_1)
		surface.DrawTexturedRect(x + 30, y + 5, 90, 90)
	else
		DTF2.DrawSentryHUD(sentry, x, y)

	y += BUILDABLES_HEIGHT_SENTRY + 10

	if not IsValid(dispenser)
		surface.SetDrawColor(BUILD_BG_NOTBUILT())
		surface.DrawRect(x, y, BUILDABLES_WIDTH, BUILDABLES_HEIGHT)
		surface.SetTextColor(BUILD_FONT_COLOR())
		surface.SetTextPos(x + BUILDABLES_WIDTH / 2, y + 3)
		surface.SetFont('DTF2.BuildableName')
		surface.DrawText('DISPENSER')
		surface.SetTextPos(x + BUILDABLES_WIDTH / 2 - 20, y + BUILDABLES_HEIGHT / 2 - 10)
		surface.SetFont('DTF2.NotBuilt')
		surface.DrawText('Not Built')
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(hud_obj_status_dispenser)
		surface.DrawTexturedRect(x + 30, y + 5, 60, 60)
	else
		DTF2.DrawDispenserHUD(dispenser, x, y)

	y += BUILDABLES_HEIGHT + 10

	if not IsValid(entrance)
		surface.SetDrawColor(BUILD_BG_NOTBUILT())
		surface.DrawRect(x, y, BUILDABLES_WIDTH, BUILDABLES_HEIGHT)
		surface.SetTextColor(BUILD_FONT_COLOR())
		surface.SetTextPos(x + BUILDABLES_WIDTH / 2 - 70, y + 3)
		surface.SetFont('DTF2.BuildableName')
		surface.DrawText('TELEPORT ENTRANCE')
		surface.SetTextPos(x + BUILDABLES_WIDTH / 2 - 20, y + BUILDABLES_HEIGHT / 2 - 10)
		surface.SetFont('DTF2.NotBuilt')
		surface.DrawText('Not Built')
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(hud_obj_status_tele_entrance)
		surface.DrawTexturedRect(x + 30, y + 5, 60, 60)
	else
		DTF2.DrawTeleporterEntranceHUD(entrance, x, y)

	y += BUILDABLES_HEIGHT + 10

	if not IsValid(exit)
		surface.SetDrawColor(BUILD_BG_NOTBUILT())
		surface.DrawRect(x, y, BUILDABLES_WIDTH, BUILDABLES_HEIGHT)
		surface.SetTextColor(BUILD_FONT_COLOR())
		surface.SetTextPos(x + BUILDABLES_WIDTH / 2 - 70, y + 3)
		surface.SetFont('DTF2.BuildableName')
		surface.DrawText('TELEPORT EXIT')
		surface.SetTextPos(x + BUILDABLES_WIDTH / 2 - 20, y + BUILDABLES_HEIGHT / 2 - 10)
		surface.SetFont('DTF2.NotBuilt')
		surface.DrawText('Not Built')
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(hud_obj_status_tele_exit)
		surface.DrawTexturedRect(x + 30, y + 5, 60, 60)
	else
		DTF2.DrawTeleporterExitHUD(exit, x, y)

hook.Add 'HUDPaint', 'DTF2.DrawBuildablesLight', ->
	return if not DRAW_LIGHT\GetBool() or (LAST_FRAME + 5) > FrameNumber()
	ply = LocalPlayer()
	sentry = ply\GetBuildedSentry()
	dispenser = ply\GetBuildedDispenser()
	entrance = ply\GetBuildedTeleporterIn()
	exit = ply\GetBuildedTeleporterOut()
	x, y = BUILDABLES_POSITION()

	if IsValid(sentry)
		DTF2.DrawSentryHUD(sentry, x, y)
		y += BUILDABLES_HEIGHT_SENTRY + 10

	if IsValid(dispenser)
		DTF2.DrawDispenserHUD(dispenser, x, y)
		y += BUILDABLES_HEIGHT + 10

	if IsValid(entrance)
		DTF2.DrawTeleporterEntranceHUD(entrance, x, y)
		y += BUILDABLES_HEIGHT + 10

	if IsValid(exit)
		DTF2.DrawTeleporterExitHUD(exit, x, y)

DTF2.DrawPDAHUD = (ply = LocalPlayer(), sentryStatus = IsValid(ply\GetBuildedSentry()), dispenserStatus = IsValid(ply\GetBuildedDispenser()), teleInStatus = IsValid(ply\GetBuildedTeleporterIn()), teleOutStatus = IsValid(ply\GetBuildedTeleporterOut())) ->
	surface.SetFont('DTF2.BuildUpFont')
	surface.SetTextColor(BUILD_FONT_COLOR())
	x, y = BUILD_POSITION()
	rx, ry = x, y
	x -= WIDTH / 2
	surface.SetDrawColor(DTF2.BACKGROUND_COLOR())
	surface.DrawRect(x, y, WIDTH, DTF2.PDA_CONSUMES_METAL\GetBool() and HEIGHT_COSTS or HEIGHT)
	w, h = surface.GetTextSize('BUILD')
	surface.DrawRect(x + 4, y + 4, WIDTH - 8, h + 4)
	surface.SetTextPos(rx - w / 2, ry + 5)
	surface.DrawText('BUILD')

	buttons = {
		{eng_build_sentry_blueprint, sentryStatus, 'SENTRY GUN', DTF2.PDA_COST_SENTRY\GetInt()}
		{eng_build_dispenser_blueprint, dispenserStatus, 'DISPENSER', DTF2.PDA_COST_DISPENSER\GetInt()}
		{eng_build_tele_entrance_blueprint, teleInStatus, 'TELEPORT ENTRANCE', DTF2.PDA_COST_TELE_IN\GetInt()}
		{eng_build_tele_exit_blueprint, teleOutStatus, 'TELEPORT EXIT', DTF2.PDA_COST_TELE_OUT\GetInt()}
	}

	y += h + 8
	x += 8
	cnt = 1

	for {mat, status, text, cost} in *buttons
		surface.SetFont('DTF2.BuildSmallFont')
		surface.SetTextColor(BUILD_FONT_COLOR())
		surface.SetDrawColor(DTF2.BACKGROUND_COLOR())
		w, h = surface.GetTextSize(text)
		surface.SetTextPos(x + ICON_WIDTH / 2 - w / 2, y)
		surface.DrawText(text)
		surface.DrawRect(x, y + h + 2, ICON_WIDTH, ICON_HEIGHT)
		
		if not status
			surface.SetMaterial(mat)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(x, y + h + 4, ICON_WIDTH, ICON_HEIGHT)
			surface.SetTextColor(BUILD_FONT_COLOR())
		else
			surface.SetTextPos(x + 23, y + ICON_HEIGHT / 2 - 4)
			surface.DrawText('ALREADY')
			surface.SetTextPos(x + 33, y + ICON_HEIGHT / 2 + h)
			surface.DrawText('BUILT')
			surface.SetTextColor(BUILD_FONT_COLOR_INACTIVE())
		
		lx, ly = x, y
		if DTF2.PDA_CONSUMES_METAL\GetBool()
			surface.SetTextColor(ply\CanAffordTF2Metal(cost) and BUILD_FONT_AFFORD() or BUILD_FONT_NOT_AFFORD())
			ctxt = 'COST: ' .. cost
			w, h = surface.GetTextSize(ctxt)
			surface.SetTextPos(lx + ICON_WIDTH / 2 - 3 - w / 2, ly + ICON_HEIGHT + 23)
			surface.DrawText(ctxt)
			ly += 22
			surface.SetTextColor(BUILD_FONT_COLOR())
		
		surface.SetFont('DTF2.BuildMediumFont')
		surface.SetDrawColor(DTF2.BACKGROUND_COLOR())
		surface.DrawRect(lx + ICON_WIDTH / 2 - 10, ly + ICON_HEIGHT + 23, 20, 22)
		surface.SetTextPos(lx + ICON_WIDTH / 2 - 5, ly + ICON_HEIGHT + 26)
		surface.DrawText(cnt)

		x += ICON_WIDTH + ICONS_SPACING
		cnt += 1

DTF2.DestructionPDAHUD = (ply = LocalPlayer(), sentryStatus = IsValid(ply\GetBuildedSentry()), dispenserStatus = IsValid(ply\GetBuildedDispenser()), teleInStatus = IsValid(ply\GetBuildedTeleporterIn()), teleOutStatus = IsValid(ply\GetBuildedTeleporterOut())) ->
	surface.SetFont('DTF2.BuildUpFont')
	surface.SetTextColor(BUILD_FONT_COLOR())
	x, y = BUILD_POSITION()
	rx, ry = x, y
	x -= WIDTH / 2
	surface.SetDrawColor(DTF2.BACKGROUND_COLOR())
	surface.DrawRect(x, y, WIDTH, HEIGHT)
	w, h = surface.GetTextSize('DEMOLISH')
	surface.DrawRect(x + 4, y + 4, WIDTH - 8, h + 4)
	surface.SetTextPos(rx - w / 2, ry + 5)
	surface.DrawText('DEMOLISH')
	sentry_s = hud_obj_status_sentry_1
	sentry = ply\GetBuildedSentry()
	if IsValid(sentry)
		switch sentry\GetLevel()
			when 1
				sentry_s = hud_obj_status_sentry_1
			when 2
				sentry_s = hud_obj_status_sentry_2
			when 3
				sentry_s = hud_obj_status_sentry_3

	buttons = {
		{sentry_s, sentryStatus, 'SENTRY GUN'}
		{hud_obj_status_dispenser, dispenserStatus, 'DISPENSER'}
		{hud_obj_status_tele_entrance, teleInStatus, 'TELEPORT ENTRANCE'}
		{hud_obj_status_tele_exit, teleOutStatus, 'TELEPORT EXIT'}
	}

	y += h + 8
	x += 8
	cnt = 1

	for {mat, status, text} in *buttons
		surface.SetFont('DTF2.BuildSmallFont')
		surface.SetTextColor(BUILD_FONT_COLOR())
		surface.SetDrawColor(DTF2.BACKGROUND_COLOR())
		w, h = surface.GetTextSize(text)
		surface.SetTextPos(x + ICON_WIDTH / 2 - w / 2, y)
		surface.DrawText(text)
		surface.DrawRect(x, y + h + 2, ICON_WIDTH, ICON_HEIGHT)
		
		if status
			surface.SetMaterial(ico_demolish)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(x, y + h + 4, ICON_WIDTH, ICON_HEIGHT)
			surface.SetMaterial(mat)
			surface.DrawTexturedRect(x, y + h + 4, ICON_WIDTH, ICON_HEIGHT)
			surface.SetTextColor(BUILD_FONT_COLOR())
		else
			surface.SetTextPos(x + 38, y + ICON_HEIGHT / 2 - 4)
			surface.DrawText('NOT')
			surface.SetTextPos(x + 33, y + ICON_HEIGHT / 2 + h)
			surface.DrawText('BUILT')
			surface.SetTextColor(BUILD_FONT_COLOR_INACTIVE())
		
		surface.SetFont('DTF2.BuildMediumFont')
		surface.SetDrawColor(DTF2.BACKGROUND_COLOR())
		surface.DrawRect(x + ICON_WIDTH / 2 - 10, y + ICON_HEIGHT + 23, 20, 22)
		surface.SetTextPos(x + ICON_WIDTH / 2 - 5, y + ICON_HEIGHT + 26)
		surface.DrawText(cnt)

		x += ICON_WIDTH + ICONS_SPACING
		cnt += 1

