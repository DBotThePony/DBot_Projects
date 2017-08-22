
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

eng_build_sentry_blueprint = Material('hud/eng_build_sentry_blueprint')
eng_build_tele_entrance_blueprint = Material('hud/eng_build_tele_entrance_blueprint')
eng_build_tele_exit_blueprint = Material('hud/eng_build_tele_exit_blueprint')
eng_build_dispenser_blueprint = Material('hud/eng_build_dispenser_blueprint')

ico_demolish = Material('hud/ico_demolish')
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

WIDTH = 510
HEIGHT = 190
HEIGHT_COSTS = 210
ICON_WIDTH = 96
ICON_HEIGHT = 96
ICONS_SPACING = 36
BUILD_FONT_AFFORD = HUDCommons.CreateColor('dtf2_build_can_build', 'DTF2 Can Build Font', 255, 255, 255)
BUILD_FONT_NOT_AFFORD = HUDCommons.CreateColor('dtf2_build_cant_build', 'DTF2 Cant Build Font', 200, 40, 40)
BUILD_FONT_COLOR = HUDCommons.CreateColor('dtf2_build_font', 'DTF2 Build Font', 255, 255, 255)
BUILD_FONT_COLOR_INACTIVE = HUDCommons.CreateColor('dtf2_build_fontin', 'DTF2 Build Font Inactive', 170, 170, 170)
BUILD_POSITION = HUDCommons.DefinePosition('dtf2_build', 0.5, 0.4)

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
            surface.SetTextPos(x + 36, y + ICON_HEIGHT / 2 - 4)
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

