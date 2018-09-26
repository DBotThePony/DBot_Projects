
-- Copyright (C) 2018 DBot

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

-- fix singleplayer

local DParkour = DParkour
local util = util
local net = net
local LocalPlayer = LocalPlayer
local IsValid = IsValid

local message = false

local function roll()
	message = true
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local data = ply._parkour or {}
	ply._parkour = data

	data.rolls = net.ReadUInt8()
	data.roll_dir = net.ReadVectorDouble()
	data.roll_ang = net.ReadAngle()
end

local function slide()
	message = true
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local data = ply._parkour or {}
	ply._parkour = data

	data.sliding = net.ReadBool()

	if data.sliding then
		data.slide_velocity_start = net.ReadVectorDouble()
	end
end

local CurTimeL = CurTimeL

local function Think()
	if not message then return end

	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local data = ply._parkour or {}
	ply._parkour = data
	data.rolls = data.rolls or 0

	if data.rolling_end and data.rolling_end < CurTimeL() then
		data.rolling = false
	end

	if data.rolls <= 0 then return end

	if not data.rolling then
		data.rolling = true
		data.rolls = data.rolls - 1
		data.rolling_start = CurTimeL()
		data.rolling_end = CurTimeL() + 0.6
	end
end

function DParkour.__SendSlideStop() end
function DParkour.__SendSlideStart(velocity) end
function DParkour.__SendRolling(rolls, dir, ang) end

net.Receive('dparkour.roll', roll)
net.Receive('dparkour.slide', slide)
hook.Add('Think', 'DParkour.FixSingleplayer', Think)
