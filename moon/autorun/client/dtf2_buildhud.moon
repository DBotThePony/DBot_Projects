
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
ICON_WIDTH = 96
ICON_HEIGHT = 96
ICONS_SPACING = 36
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
    surface.DrawRect(x, y, WIDTH, HEIGHT)
    w, h = surface.GetTextSize('BUILD')
    surface.DrawRect(x + 4, y + 4, WIDTH - 8, h + 4)
    surface.SetTextPos(rx - w / 2, ry + 5)
    surface.DrawText('BUILD')

    buttons = {
        {eng_build_sentry_blueprint, sentryStatus, 'SENTRY GUN'}
        {eng_build_dispenser_blueprint, dispenserStatus, 'DISPENSER'}
        {eng_build_tele_entrance_blueprint, teleInStatus, 'TELEPORT ENTRANCE'}
        {eng_build_tele_exit_blueprint, teleOutStatus, 'TELEPORT EXIT'}
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
        
        surface.SetFont('DTF2.BuildMediumFont')
        surface.SetDrawColor(DTF2.BACKGROUND_COLOR())
        surface.DrawRect(x + ICON_WIDTH / 2 - 8, y + ICON_HEIGHT + 23, 20, 22)
        surface.SetTextPos(x + ICON_WIDTH / 2 - 3, y + ICON_HEIGHT + 26)
        surface.DrawText(cnt)

        x += ICON_WIDTH + ICONS_SPACING
        cnt += 1

