
-- Copyright (C) 2017-2018 DBot

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
local WOverlord = WOverlord
local self = WOverlord
local surface = surface
local string = string

local ALWAYS_DISPLAY_TIME = CreateConVar('cl_woverlord_display', '1', {FCVAR_ARCHIVE}, 'Always display server time')

surface.CreateFont('WOverlord_TopTimeTip', {
	font = 'Roboto Mono Medium',
	weight = 500,
	size = 34
})

surface.CreateFont('WOverlord_TopTime', {
	font = 'Hack',
	weight = 500,
	size = 34
})

surface.CreateFont('WOverlord_BottomTime', {
	font = 'Source Sans Pro',
	weight = 500,
	size = 46
})

surface.CreateFont('WOverlord_SunsetSunrise', {
	font = 'Exo 2',
	weight = 400,
	size = 28
})

surface.CreateFont('WOverlord_Night', {
	font = 'Exo 2',
	weight = 400,
	size = 20
})

surface.CreateFont('WOverlord_Temperature', {
	font = 'Exo 2 Thin',
	weight = 500,
	size = 20
})

surface.CreateFont('WOverlord_WindSpeed', {
	font = 'Exo 2',
	weight = 500,
	size = 20
})

surface.CreateFont('WOverlord_RegularTime', {
	font = 'Roboto Mono Medium',
	weight = 500,
	size = 14
})

self.DISPLAY_FULL_TIME = false

local GET_FULL_POSITION = DLib.HUDCommons.DefinePosition('woverlord_timefull', 0.5, 0.07)
local GET_FULL_POSITION_SCOREBOARD = DLib.HUDCommons.DefinePosition('woverlord_timefull', 0.5, 0.4)
local GET_REGULAR_POSITION = DLib.HUDCommons.DefinePosition('woverlord_time', 0.99, 0.99)

local function HUDPaintFULL()
	if not self.DISPLAY_FULL_TIME and not self.SCOREBOARD_IS_SHOWN then return end

	local x, y

	if self.SCOREBOARD_IS_SHOWN then
		x, y = GET_FULL_POSITION_SCOREBOARD()
	else
		x, y = GET_FULL_POSITION()
	end

	surface.SetTextColor(255, 255, 255)
	surface.SetFont('WOverlord_TopTimeTip')

	local text = 'HH:MM:SS'
	local w2, h2 = surface.GetTextSize(text)
	surface.SetTextPos(x - w2 / 2, y)
	surface.DrawText(text)

	surface.SetFont('WOverlord_TopTime')

	text = self.DATE_OBJECT_ACCURATE:FormatTime()
	local w, h = surface.GetTextSize(text)
	surface.SetTextPos(x - w / 2, y + h2)
	surface.DrawText(text)

	surface.SetFont('WOverlord_BottomTime')
	text = self.DATE_OBJECT_ACCURATE:FormatDateYear()
	local w, h3 = surface.GetTextSize(text)

	y = y + h + 4 + h2
	surface.SetTextPos(x - w / 2, y)
	surface.DrawText(text)
	y = y + h3

	if not self.DISPLAY_SUNRISE and not self.SCOREBOARD_IS_SHOWN then return end

	surface.SetFont('WOverlord_SunsetSunrise')
	text = 'Sunrise: ' .. self.DATE_OBJECT_ACCURATE:FormatSunrise() .. '   Sunset: ' .. self.DATE_OBJECT_ACCURATE:FormatSunset()
	local w, h = surface.GetTextSize(text)

	surface.SetTextPos(x - w / 2, y)
	surface.DrawText(text)

	y = y + h

	surface.SetFont('WOverlord_Night')
	text = 'Night end: ' .. self.DATE_OBJECT_ACCURATE:FormatNightEnd() .. '   Night start: ' .. self.DATE_OBJECT_ACCURATE:FormatNightStart()
	w, h = surface.GetTextSize(text)

	surface.SetTextPos(x - w / 2, y)
	surface.DrawText(text)

	y = y + h + 2

	surface.SetFont('WOverlord_Temperature')
	text = string.format('Temperature: %.1f°C', self.DATE_OBJECT_ACCURATE:GetTemperature())
	w, h = surface.GetTextSize(text)

	surface.SetTextPos(x - w / 2, y)
	surface.DrawText(text)

	if not self.SCOREBOARD_IS_SHOWN then return end

	y = y + h + 2

	surface.SetFont('WOverlord_WindSpeed')
	text = string.format('Wind speed: %.2f m/s; Beaufort Score: %i (%s)', self.DATE_OBJECT_ACCURATE:GetWindSpeedCI():GetMetres(), self.DATE_OBJECT_ACCURATE:GetBeaufortScore(), self.DATE_OBJECT_ACCURATE:GetBeaufortName())
	w, h = surface.GetTextSize(text)

	surface.SetTextPos(x - w / 2, y)
	surface.DrawText(text)
end

local function HUDPaint()
	if self.DISPLAY_FULL_TIME or not ALWAYS_DISPLAY_TIME:GetBool() or self.SCOREBOARD_IS_SHOWN then return end

	local x, y = GET_REGULAR_POSITION()
	surface.SetTextColor(255, 255, 255)
	surface.SetFont('WOverlord_RegularTime')
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
hook.Add('HUDPaint', 'WeatherOverlord_DisplayTimeFull', HUDPaintFULL)
hook.Add('ScoreboardShow', 'WeatherOverlord_DisplayTimeFull', ScoreboardShow, -10)
hook.Add('ScoreboardHide', 'WeatherOverlord_DisplayTimeFull', ScoreboardHide, -10)
hook.Add('HUDPaint', 'WeatherOverlord_DisplayTime', HUDPaint)
