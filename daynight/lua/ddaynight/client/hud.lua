
-- Copyright (C) 2017-2019 DBot

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

local DISPLAY_AT_CORNER = CreateConVar('cl_ddaynight_small', '1', {FCVAR_ARCHIVE}, 'Display time at corner of screen')
local DISPLAY_AT_SCOREBOARD = CreateConVar('cl_ddaynight_scoreboard', '1', {FCVAR_ARCHIVE}, 'Display time when opening scoreboard')

timer.Simple(0, function()
	surface.CreateFont('DDayNight_TopTimeTip', {
		font = 'Roboto Mono Medium',
		weight = 500,
		extended = true,
		size = ScreenSize(20):max(34)
	})

	surface.CreateFont('DDayNight_TopTime', {
		font = 'Hack',
		weight = 500,
		extended = true,
		size = ScreenSize(20):max(34)
	})

	surface.CreateFont('DDayNight_BottomTime', {
		font = 'Source Sans Pro',
		weight = 500,
		extended = true,
		size = ScreenSize(23):max(46)
	})

	surface.CreateFont('DDayNight_SunsetSunrise', {
		font = 'Exo 2',
		weight = 400,
		extended = true,
		size = ScreenSize(15):max(28)
	})

	surface.CreateFont('DDayNight_Night', {
		font = 'Exo 2',
		weight = 400,
		extended = true,
		size = ScreenSize(12):max(20)
	})

	surface.CreateFont('DDayNight_Temperature', {
		font = 'Exo 2 Thin',
		weight = 500,
		extended = true,
		size = ScreenSize(12):max(20)
	})

	surface.CreateFont('DDayNight_WindSpeed', {
		font = 'Exo 2',
		weight = 500,
		extended = true,
		size = ScreenSize(12):max(20)
	})

	surface.CreateFont('DDayNight_RegularTime', {
		font = 'Roboto Mono Medium',
		weight = 500,
		extended = true,
		size = ScreenSize(9):max(14)
	})

	surface.CreateFont('DDayNight_TopTimeTip2', {
		font = 'Roboto Mono Medium',
		weight = 500,
		extended = true,
		size = ScreenSize(16):max(14)
	})

	surface.CreateFont('DDayNight_TopTime2', {
		font = 'Hack',
		weight = 500,
		extended = true,
		size = ScreenSize(16):max(14)
	})

	surface.CreateFont('DDayNight_BottomTime2', {
		font = 'Source Sans Pro',
		weight = 500,
		extended = true,
		size = ScreenSize(14):max(14)
	})

	surface.CreateFont('DDayNight_SunsetSunrise2', {
		font = 'Exo 2',
		weight = 400,
		extended = true,
		size = ScreenSize(12):max(14)
	})

	surface.CreateFont('DDayNight_Night2', {
		font = 'Exo 2',
		weight = 400,
		extended = true,
		size = ScreenSize(10):max(14)
	})

	surface.CreateFont('DDayNight_Temperature2', {
		font = 'Exo 2 Thin',
		weight = 500,
		extended = true,
		size = ScreenSize(10):max(14)
	})

	surface.CreateFont('DDayNight_WindSpeed2', {
		font = 'Exo 2',
		weight = 500,
		extended = true,
		size = ScreenSize(10):max(14)
	})
end)

local GET_FULL_POSITION = DLib.HUDCommons.DefinePosition('ddaynight_timefull', 0.5, 0.07)
local GET_FULL_POSITION_SCOREBOARD = DLib.HUDCommons.DefinePosition('ddaynight_timefull', 0.5, 0.7)
local GET_REGULAR_POSITION = DLib.HUDCommons.DefinePosition('ddaynight_time', 0.99, 0.99)

local function HUDPaintFULL()
	if not self.SCOREBOARD_IS_SHOWN then return end
	local x, y = GET_FULL_POSITION_SCOREBOARD()
	self.HUDPaintFULL(x, y)
end

function self.HUDPaintFULL(x, y, useSmallerText)
	local suffix = useSmallerText and '2' or ''
	surface.SetTextColor(255, 255, 255)
	surface.SetFont('DDayNight_TopTimeTip')

	local text = DLib.i18n.localize('gui.daynight.time.format')
	local w2, h2 = surface.GetTextSize(text)
	surface.SetTextPos(x - w2 / 2, y)
	surface.DrawText(text)

	surface.SetFont('DDayNight_TopTime' .. suffix)

	text = self.DATE_OBJECT:FormatTime()
	local w, h = surface.GetTextSize(text)
	surface.SetTextPos(x - w / 2, y + h2)
	surface.DrawText(text)

	surface.SetFont('DDayNight_BottomTime' .. suffix)
	text = self.DATE_OBJECT:FormatDateYear()
	local w, h3 = surface.GetTextSize(text)

	y = y + h + 4 + h2
	surface.SetTextPos(x - w / 2, y)
	surface.DrawText(text)
	y = y + h3

	surface.SetFont('DDayNight_SunsetSunrise' .. suffix)
	text =  DLib.i18n.localize('gui.daynight.time.sun', self.DATE_OBJECT:FormatSunrise(), self.DATE_OBJECT:FormatSunset())
	local w, h = surface.GetTextSize(text)

	surface.SetTextPos(x - w / 2, y)
	surface.DrawText(text)

	y = y + h

	surface.SetFont('DDayNight_Night' .. suffix)
	text = DLib.i18n.localize('gui.daynight.time.night', self.DATE_OBJECT:FormatNightEnd(), self.DATE_OBJECT:FormatNightStart())
	w, h = surface.GetTextSize(text)

	surface.SetTextPos(x - w / 2, y)
	surface.DrawText(text)

	y = y + h + 2

	surface.SetFont('DDayNight_Temperature' .. suffix)
	text = DLib.i18n.localize('gui.daynight.time.temperature', self.DATE_OBJECT:GetTemperature())
	w, h = surface.GetTextSize(text)

	surface.SetTextPos(x - w / 2, y)
	surface.DrawText(text)

	y = y + h + 2

	text = DLib.i18n.localize('gui.daynight.time.wind', self.DATE_OBJECT:GetWindSpeedSI():GetMetres(), self.DATE_OBJECT:GetBeaufortScore(), self.DATE_OBJECT:GetBeaufortName())
	draw.DrawText(text, 'DDayNight_WindSpeed' .. suffix, x, y, color_white, TEXT_ALIGN_CENTER)
end

local function HUDPaint()
	if IsValid(g_SpawnMenu) and g_SpawnMenu:IsVisible() then
		return
	end

	if not DISPLAY_AT_CORNER:GetBool() or self.SCOREBOARD_IS_SHOWN then return end

	local x, y = GET_REGULAR_POSITION()
	surface.SetTextColor(255, 255, 255)
	surface.SetFont('DDayNight_RegularTime')
	local text = self.DATE_OBJECT:Format()
	local w, h = surface.GetTextSize(text)
	surface.SetTextPos(x - w, y - h)
	surface.DrawText(text)
end

local function ScoreboardShow()
	if not DISPLAY_AT_SCOREBOARD:GetBool() then return end
	self.SCOREBOARD_IS_SHOWN = true
end

local function ScoreboardHide()
	self.SCOREBOARD_IS_SHOWN = false
end

hook.Add('HUDPaint', 'DDayNight_DisplayTimeFull', HUDPaintFULL)
hook.Add('ScoreboardShow', 'DDayNight_DisplayTimeFull', ScoreboardShow, -10)
hook.Add('ScoreboardHide', 'DDayNight_DisplayTimeFull', ScoreboardHide, -10)
hook.Add('HUDPaint', 'DDayNight_DisplayTime', HUDPaint)
