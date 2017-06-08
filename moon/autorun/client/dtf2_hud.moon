
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

BACKGROUND_COLOR =          HUDCommons.CreateColor('dtf2_background', 'DTF2 HUD Background', 0, 0, 0, 150)
FONT_COLOR =                HUDCommons.CreateColor('dtf2_font', 'DTF2 Font', 255, 255, 255)
FONT_COLOR_GREEN =          HUDCommons.CreateColor('dtf2_font_positive', 'DTF2 HUD positive text', 88, 183, 56)
FONT_COLOR_RED =            HUDCommons.CreateColor('dtf2_font_negative', 'DTF2 HUD negative text', 217, 101, 83)
COLOR_HP_BAR_BACKGROUND =   HUDCommons.CreateColor('dtf2_hpbar_background', 'DTF2 HUD HP Bar Background', 176, 176, 176)
COLOR_HP_BAR =              HUDCommons.CreateColor('dtf2_hpbar', 'DTF2 HUD HP Bar', 167, 197, 92)
HUD_BAR_BACKGROUND =        HUDCommons.CreateColor('dtf2_bar_bg', 'DTF2 HUD generic bar background', 168, 168, 168)
HUD_BAR_COLOR =             HUDCommons.CreateColor('dtf2_bar', 'DTF2 HUD generic bar', 235, 235, 235)

FONT = 'DTF2.HUDFont'

surface.CreateFont(FONT, {
    'font': 'Roboto'
    'size': 18
    'weight': 400
})

METAL_HISTORY = {}
UPDATE_HISTORY = false

hook.Add 'Think', 'DTF2.UpdateMetalHistory', ->
    rTime = RealTime()

    if UPDATE_HISTORY
        METAL_HISTORY = [data for data in *METAL_HISTORY when data.endtime > rTime]
        UPDATE_HISTORY = false

    for data in *METAL_HISTORY
        if data.endtime < rTime
            UPDATE_HISTORY = true
        data.fade = (data.endtime - rTime) / 5
        data.a = data.fade * 255
        data.slide += FrameTime() * 25

hook.Add 'DTF2.MetalEffect', 'DTF2.MetalHistory', (event = true, amount = 0) ->
    return if amount == 0

    data = {
        start: RealTime()
        endtime: RealTime() + 5
        slide: 0
        fade: 1
        text: event and "+#{amount}" or "-#{amount}"
        color: event and FONT_COLOR_GREEN() or FONT_COLOR_RED()
    }

    table.insert(METAL_HISTORY, data)
    {:r, :g, :b} = data.color
    data.r = r
    data.g = g
    data.b = b
    data.a = 255

DTF2.DrawMetalCounter = ->
    w, h = ScrW(), ScrH()
    x, y = w * .8, h * .95
    HUDCommons.WordBox("Avaliable Metal: #{LocalPlayer()\GetTF2Metal()}", FONT, x, y, FONT_COLOR, BACKGROUND_COLOR())
    
    x += 110
    for data in *METAL_HISTORY
        HUDCommons.WordBox(data.text, nil, x, y - data.slide, Color(data.r, data.g, data.b, data.a), Color(0, 0, 0, 150 * data.fade))

DTF2.DrawCenteredBar = (mult = 0.5, text) ->
    w, h = ScrW(), ScrH()
    x, y = w * .5, h * .65

    surface.SetTextColor(FONT_COLOR())
    surface.SetFont(FONT)
    HUDCommons.BarWithTextCentered(x, y, 300, 25, mult, BACKGROUND_COLOR(), HUD_BAR_BACKGROUND(), HUD_BAR_COLOR(), text)

DTF2.DrawBuildingInfo = =>
    w, h = ScrW(), ScrH()
    x, y = w * .5, h * .6
    text = @PrintName
    if IsValid(@GetPlayer()) and @GetPlayer()\IsPlayer()
        text ..= " built by #{@GetPlayer()\Nick()}"
    hp, mhp = @Health(), @GetMaxHealth()
    text ..= "\nHealth: #{hp}/#{mhp}"
    text ..= "\nUpgrade level: #{@GetUpgradeAmount()}/#{@MAX_UPGRADE}" if @GetLevel() < 3
    text ..= '\n'
    text ..= @GetHUDText()

    W, H = HUDCommons.AdvancedWordBox(text, FONT, x, y, FONT_COLOR(), BACKGROUND_COLOR(), true)

    surface.SetDrawColor(COLOR_HP_BAR_BACKGROUND())
    surface.DrawRect(x - W / 2, y + H - 12, W, 12)
    surface.SetDrawColor(COLOR_HP_BAR())
    surface.DrawRect(x - W / 2, y + H - 12, W * math.Clamp(hp / mhp, 0, 1), 12)

hook.Add 'HUDPaint', 'DTF2.BuildablesHUD', ->
    self = LocalPlayer()\GetEyeTrace().Entity
    return if not IsValid(@)
    return if not @IsTF2Building
    @DrawHUD()
