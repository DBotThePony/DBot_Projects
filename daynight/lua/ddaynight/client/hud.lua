
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
local DDayNight = DDayNight
local self = DDayNight
local surface = surface
local string = string

local ALWAYS_DISPLAY_TIME = CreateConVar('cl_ddaynight_display', '1', {FCVAR_ARCHIVE}, 'Always display server time')

surface.CreateFont('DDayNight_TopTimeTip', {
	font = 'Roboto Mono Medium',
	weight = 500,
	size = 34
})

surface.CreateFont('DDayNight_TopTime', {
	font = 'Hack',
	weight = 500,
	size = 34
})

surface.CreateFont('DDayNight_BottomTime', {
	font = 'Source Sans Pro',
	weight = 500,
	size = 46
})

surface.CreateFont('DDayNight_SunsetSunrise', {
	font = 'Exo 2',
	weight = 400,
	size = 28
})

surface.CreateFont('DDayNight_Night', {
	font = 'Exo 2',
	weight = 400,
	size = 20
})

surface.CreateFont('DDayNight_Temperature', {
	font = 'Exo 2 Thin',
	weight = 500,
	size = 20
})

surface.CreateFont('DDayNight_WindSpeed', {
	font = 'Exo 2',
	weight = 500,
	size = 20
})

surface.CreateFont('DDayNight_RegularTime', {
	font = 'Roboto Mono Medium',
	weight = 500,
	size = 14
})

self.DISPLAY_FULL_TIME = false

local GET_FULL_POSITION = DLib.HUDCommons.DefinePosition('ddaynight_timefull', 0.5, 0.07)
local GET_FULL_POSITION_SCOREBOARD = DLib.HUDCommons.DefinePosition('ddaynight_timefull', 0.5, 0.4)
local GET_FULL_POSITION_SCOREBOARD2 = DLib.HUDCommons.DefinePosition('ddaynight_timefull2', 0.5, 0.7)
local GET_REGULAR_POSITION = DLib.HUDCommons.DefinePosition('ddaynight_time', 0.99, 0.99)

local function HUDPaintFULL()
	local x, y

	if not IsValid(g_SpawnMenu) or not g_SpawnMenu:IsVisible() then
		if not self.DISPLAY_FULL_TIME and not self.SCOREBOARD_IS_SHOWN then return end

		if self.SCOREBOARD_IS_SHOWN then
			x, y = GET_FULL_POSITION_SCOREBOARD2()
		else
			x, y = GET_FULL_POSITION()
		end
	else
		x, y = GET_FULL_POSITION_SCOREBOARD()
	end

	surface.SetTextColor(255, 255, 255)
	surface.SetFont('DDayNight_TopTimeTip')

	local text = DLib.i18n.localize('gui.daynight.time.format')
	local w2, h2 = surface.GetTextSize(text)
	surface.SetTextPos(x - w2 / 2, y)
	surface.DrawText(text)

	surface.SetFont('DDayNight_TopTime')

	text = self.DATE_OBJECT_ACCURATE:FormatTime()
	local w, h = surface.GetTextSize(text)
	surface.SetTextPos(x - w / 2, y + h2)
	surface.DrawText(text)

	surface.SetFont('DDayNight_BottomTime')
	text = self.DATE_OBJECT_ACCURATE:FormatDateYear()
	local w, h3 = surface.GetTextSize(text)

	y = y + h + 4 + h2
	surface.SetTextPos(x - w / 2, y)
	surface.DrawText(text)
	y = y + h3

	if not self.DISPLAY_SUNRISE and not self.SCOREBOARD_IS_SHOWN then return end

	surface.SetFont('DDayNight_SunsetSunrise')
	text =  DLib.i18n.localize('gui.daynight.time.sun', self.DATE_OBJECT_ACCURATE:FormatSunrise(), self.DATE_OBJECT_ACCURATE:FormatSunset())
	local w, h = surface.GetTextSize(text)

	surface.SetTextPos(x - w / 2, y)
	surface.DrawText(text)

	y = y + h

	surface.SetFont('DDayNight_Night')
	text = DLib.i18n.localize('gui.daynight.time.night', self.DATE_OBJECT_ACCURATE:FormatNightEnd(), self.DATE_OBJECT_ACCURATE:FormatNightStart())
	w, h = surface.GetTextSize(text)

	surface.SetTextPos(x - w / 2, y)
	surface.DrawText(text)

	y = y + h + 2

	surface.SetFont('DDayNight_Temperature')
	text = DLib.i18n.localize('gui.daynight.time.temperature', self.DATE_OBJECT_ACCURATE:GetTemperature())
	w, h = surface.GetTextSize(text)

	surface.SetTextPos(x - w / 2, y)
	surface.DrawText(text)

	if not self.SCOREBOARD_IS_SHOWN then return end

	y = y + h + 2

	surface.SetFont('DDayNight_WindSpeed')
	text = DLib.i18n.localize('gui.daynight.time.wind', self.DATE_OBJECT_ACCURATE:GetWindSpeedSI():GetMetres(), self.DATE_OBJECT_ACCURATE:GetBeaufortScore(), self.DATE_OBJECT_ACCURATE:GetBeaufortName())
	w, h = surface.GetTextSize(text)

	surface.SetTextPos(x - w / 2, y)
	surface.DrawText(text)
end

local function HUDPaint()
	if IsValid(g_SpawnMenu) and g_SpawnMenu:IsVisible() then
		return
	end

	if self.DISPLAY_FULL_TIME or not ALWAYS_DISPLAY_TIME:GetBool() or self.SCOREBOARD_IS_SHOWN then return end

	local x, y = GET_REGULAR_POSITION()
	surface.SetTextColor(255, 255, 255)
	surface.SetFont('DDayNight_RegularTime')
	local text = self.DATE_OBJECT_ACCURATE:Format()
	local w, h = surface.GetTextSize(text)
	surface.SetTextPos(x - w, y - h)
	surface.DrawText(text)
end

local function ScoreboardShow()
	self.SCOREBOARD_IS_SHOWN = true
end

local function ScoreboardHide()
	self.SCOREBOARD_IS_SHOWN = false
end

hook.Add('HUDPaint', 'DDayNight_DisplayTimeFull', HUDPaintFULL)
hook.Add('ScoreboardShow', 'DDayNight_DisplayTimeFull', ScoreboardShow, -10)
hook.Add('ScoreboardHide', 'DDayNight_DisplayTimeFull', ScoreboardHide, -10)
hook.Add('HUDPaint', 'DDayNight_DisplayTime', HUDPaint)
