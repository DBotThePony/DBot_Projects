
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

BACKGROUND_COLOR = Color(0, 0, 0, 150)
FONT_COLOR = Color(255, 255, 255)
FONT_COLOR_GREEN = Color(88, 183, 56)
FONT_COLOR_RED = Color(217, 101, 83)
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
        color: event and FONT_COLOR_GREEN or FONT_COLOR_RED
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
    text = "Avaliable Metal: #{LocalPlayer()\GetTF2Metal()}"
    surface.SetFont(FONT)
    surface.SetDrawColor(BACKGROUND_COLOR)
    surface.SetTextColor(FONT_COLOR)
    W, H = surface.GetTextSize(text)
    surface.DrawRect(x - 4, y - 4, W + 8, H + 8)
    surface.SetTextPos(x, y)
    surface.DrawText(text)
    
    x += 110
    for data in *METAL_HISTORY
        W, H = surface.GetTextSize(data.text)
        surface.SetDrawColor(Color(0, 0, 0, 150 * data.fade))
        surface.DrawRect(x - 4, y - 4 - data.slide, W + 8, H + 8)
        surface.SetTextPos(x, y - data.slide)
        surface.SetTextColor(data.r, data.g, data.b, data.a)
        surface.DrawText(data.text)