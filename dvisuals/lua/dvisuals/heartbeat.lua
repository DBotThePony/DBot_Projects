
-- Enhanced Visuals for GMod
-- Copyright (C) 2018-2019 DBotThePony

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local DVisuals = DVisuals
local type = type
local table = table
local math = math
local ipairs = ipairs
local Color = Color
local HUDCommons = DLib.HUDCommons
local FrameTime = FrameTime
local CurTimeL = CurTimeL
local ScrHL = ScrHL

local function Lerp2(fr, from, to)
	if to < from then
		return to
	end

	return from + fr * (to - from)
end

local targetHealth = 100

local lowhealth = Material('enchancedvisuals/overlay/lowhealth/lowhealth0.png')
local damaged = Material('enchancedvisuals/overlay/damaged/damaged0.png')

local alive = true
local flashStart = 0
local flashEnd = 0
local flash2Start = 0
local flash2End = 0
local flash2Delta = 0
local lowFr = 0
local surface = surface

local nextHeartBeatIn = 0
local nextHeartBeatInPlay = false
local nextHeartBeatOut = 0
local nextHeartBeatWait = 0
local nextHeartBeatOutPlay = false

hook.Add('PostDrawHUD', 'DVisuals.Heartbeat', function()
	if not DVisuals.ENABLE_LOWHEALTH() then return end

	if lowFr ~= 0 then
		local fr = lowFr * 0.6 + CurTimeL():progression(flash2Start, flash2End, flash2Delta) * 0.1
		surface.SetDrawColor(255, 255, 255, 255 * fr)
		surface.SetMaterial(lowhealth)
		surface.DrawTexturedRect(0, 0, ScrWL(), ScrHL())
	end

	if not alive then
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(damaged)
		surface.DrawTexturedRect(0, 0, ScrWL(), ScrHL())
	end
end, 9)

local heartbeatin = Sound('enhancedvisuals/heartbeatin.wav')
local heartbeatout = Sound('enhancedvisuals/heartbeatout.wav')

hook.Add('Think', 'DVisuals.Heartbeat', function()
	if not DVisuals.ENABLE_LOWHEALTH() then return end

	local ply = HUDCommons.SelectPlayer()
	if not IsValid(ply) then return end

	if not ply:Alive() then
		alive = false
		targetHealth = ply:GetMaxHealth()
		lowFr = 0
		return
	else
		alive = true
	end

	local health = ply:Health()
	targetHealth = Lerp2(FrameTime() * 0.3, targetHealth, health)
	local maxhealth = ply:GetMaxHealth()
	maxhealth = maxhealth ~= 0 and maxhealth or 1
	local mult = targetHealth / maxhealth

	lowFr = 1 - mult:progression(-0.1, 0.25)

	local time = CurTimeL()

	if nextHeartBeatInPlay and nextHeartBeatIn < time then
		nextHeartBeatInPlay = false
		ply:EmitSound(heartbeatin, 75, 100, 0.4)
	end

	if nextHeartBeatOutPlay and nextHeartBeatOut < time then
		nextHeartBeatOutPlay = false
		ply:EmitSound(heartbeatout, 75, 100, 0.4)

		if mult < 0.15 then
			flashStart = time
			flashEnd = time + 0.8 * mult:progression(0.01, 0.18)
		end

		if flash2End < time then
			flash2Start = time
			flash2End = time + 0.3 * mult:progression(-0.1, 0.18)
			flash2Delta = time + (flash2End - flash2Start) / 2
		end
	end

	if mult <= 0.35 and nextHeartBeatWait < time then
		local heartBeatNext, heartBeatDelta = (mult:progression(0.1, 0.4) + 0.3) * 0.5, (mult:progression(0.1, 0.35) + 0.25) * 0.4

		if mult < 0.15 then
			heartBeatDelta = heartBeatDelta * 0.6
		end

		heartBeatNext = heartBeatNext:min(0.4)
		heartBeatDelta = heartBeatDelta:max(0.1)

		--print(heartBeatNext, heartBeatDelta)

		nextHeartBeatIn = time + heartBeatNext
		nextHeartBeatOut = nextHeartBeatIn + heartBeatDelta
		nextHeartBeatWait = nextHeartBeatOut + heartBeatDelta * 2

		nextHeartBeatInPlay = true
		nextHeartBeatOutPlay = true
	end
end)
