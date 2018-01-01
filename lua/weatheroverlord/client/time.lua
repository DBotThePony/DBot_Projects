
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
local timer = timer
local hook = hook
local CurTime = CurTime
local self = WOverlord
local math = math
local net = net

self.INITIALIZE = false
self.BOUND_TIME = 0
self.BOUND_TIME_TO = 0
local lastThink = 0
self.DATE_OBJECT = self.Date(0)
self.DATE_OBJECT_ACCURATE = self.Date(self.TIME)

function self.GetAccurateTime()
	return self.BOUND_TIME + (CurTime() - self.BOUND_TIME_TO) * self.TIME_MULTIPLIER:GetInt()
end

local function Think()
	if not self.INITIALIZE then return end
	self.DATE_OBJECT_ACCURATE:SetStamp(self.GetAccurateTime())

	if math.floor(lastThink) == math.floor(CurTime()) then return end
	lastThink = CurTime()

	local old = self.TIME
	self.TIME = math.floor(self.GetAccurateTime())
	local new = self.TIME
	self.DATE_OBJECT:SetStamp(self.TIME)

	if math.floor(old) < math.floor(new) then
		hook.Run('WOverlord_NewSecond')
	end

	if math.floor(old / self.timeTypes.minute) < math.floor(new / self.timeTypes.minute) then
		hook.Run('WOverlord_NewMinute')
	end

	if math.floor(old / self.timeTypes.hour) < math.floor(new / self.timeTypes.hour) then
		hook.Run('WOverlord_NewHour')
	end

	if math.floor(old / self.timeTypes.midday) < math.floor(new / self.timeTypes.midday) then
		hook.Run('WOverlord_NewHalfofday')
	end

	if math.floor(old / self.timeTypes.day) < math.floor(new / self.timeTypes.day) then
		hook.Run('WOverlord_NewDay')
	end

	if math.floor(old / self.timeTypes.week) < math.floor(new / self.timeTypes.week) then
		hook.Run('WOverlord_NewWeek')
	end

	if math.floor(old / self.timeTypes.year) < math.floor(new / self.timeTypes.year) then
		hook.Run('WOverlord_NewYear')
	end

	if math.floor(old / self.timeTypes.age) < math.floor(new / self.timeTypes.age) then
		hook.Run('WOverlord_NewAge')
	end
end

local surface = surface
local ScrW, ScrH = ScrW, ScrH

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

surface.CreateFont('WOverlord_RegularTime', {
	font = 'Roboto Mono Medium',
	weight = 500,
	size = 14
})

self.DISPLAY_FULL_TIME = false

local GET_FULL_POSITION = DLib.HUDCommons.DefinePosition('woverlord_timefull', 0.5, 0.07)
local GET_REGULAR_POSITION = DLib.HUDCommons.DefinePosition('woverlord_time', 0.99, 0.99)

local function HUDPaintFULL()
	if not self.DISPLAY_FULL_TIME then return end
	local x, y = GET_FULL_POSITION()
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
	w = surface.GetTextSize(text)
	surface.SetTextPos(x - w / 2, y + h + 4 + h2)
	surface.DrawText(text)
end

local function HUDPaint()
	if self.DISPLAY_FULL_TIME or not ALWAYS_DISPLAY_TIME:GetBool() then return end

	local x, y = GET_REGULAR_POSITION()
	surface.SetTextColor(255, 255, 255)
	surface.SetFont('WOverlord_RegularTime')
	local text = self.DATE_OBJECT_ACCURATE:Format()
	local w, h = surface.GetTextSize(text)
	surface.SetTextPos(x - w, y - h)
	surface.DrawText(text)
end

net.receive('weatheroverlord.replicatetime', function()
	self.INITIALIZE = true
	local time = net.ReadUInt(64)
	local validAt = net.ReadDouble()

	self.BOUND_TIME = time
	self.BOUND_TIME_TO = validAt
	lastThink = validAt
end)

hook.Add('Think', 'WeatherOverlord_UpdateTime', Think)
hook.Add('HUDPaint', 'WeatherOverlord_DisplayTimeFull', HUDPaintFULL)
hook.Add('HUDPaint', 'WeatherOverlord_DisplayTime', HUDPaint)
