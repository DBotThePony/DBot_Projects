
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

local DParkour = DParkour
local hook = hook
local util = util
local Vector = Vector
local IsValid = IsValid
local Angle = Angle
local RealTimeL = RealTimeL

local MOVETYPE_NONE = MOVETYPE_NONE
local MOVETYPE_WALK = MOVETYPE_WALK

function DParkour.HandleWallHang(ply, movedata, data)
	if data.hanging_on_edge then
		if not data.IN_JUMP_changes then return end
		if data.last_hung and data.last_hung > RealTimeL() then return end
		ply:SetMoveType(MOVETYPE_WALK)
		movedata:SetVelocity(data.hanging_trace.HitNormal * 200 * (1 / data.hanging_trace.Fraction:clamp(0.75, 1)):clamp(1, 3))
		ply:EmitSound('DParkour.HangOver')
		data.hanging_on_edge = false
		data.last_hung = RealTimeL() + 0.4
		return
	end

	if data.last_hung and data.last_hung > RealTimeL() then return end

	local epos = ply:EyePos()
	local eang = ply:EyeAngles()
	local yaw = Angle(0, eang.y, 0)
	local checkpos = epos + Vector(0, 0, 18) + yaw:Forward() * 40
	local checkpos2 = epos + Vector(0, 0, 18) + yaw:Forward() * 32

	local checkReach = util.TraceHull({
		start = epos + Vector(0, 0, 9),
		endpos = checkpos,
		mins = Vector(-8, -8, 0),
		maxs = Vector(8, 8, 0),
		filter = ply
	})

	if checkReach.Hit then return end

	local checkWall = util.TraceHull({
		start = checkpos2,
		endpos = checkpos2 - Vector(0, 0, 35),
		mins = Vector(-8, -8, 0),
		maxs = Vector(8, 8, 0),
		filter = ply
	})

	if not checkWall.Hit then return end
	local hangingOn = checkWall.ent

	if IsValid(hangingOn) and (hangingOn:IsNPC() or hangingOn:IsPlayer() or hangingOn:IsNextBot()) then return end

	data.hanging_on_edge = true
	data.hanging_on = hangingOn
	data.hanging_trace = checkWall

	data.last_hung = RealTimeL() + 0.4

	ply:SetMoveType(MOVETYPE_NONE)
	ply:EmitSound('DParkour.Hang')
end

local LocalPlayer = LocalPlayer
local render = render

function DParkour.DrawWallHang()
	local ply = LocalPlayer()
	local epos = ply:EyePos()
	local eang = ply:EyeAngles()
	local yaw = Angle(0, eang.y, 0)
	local checkpos = epos + Vector(0, 0, 18) + yaw:Forward() * 40
	local checkpos2 = epos + Vector(0, 0, 18) + yaw:Forward() * 32

	local checkReach = util.TraceHull({
		start = epos + Vector(0, 0, 9),
		endpos = checkpos,
		mins = Vector(-8, -8, 0),
		maxs = Vector(8, 8, 0),
		filter = ply
	})

	if checkReach.Hit then
		render.DrawLine(epos + Vector(0, 0, 9), checkpos, color_red)
		return
	else
		render.DrawLine(epos + Vector(0, 0, 9), checkpos, color_green)
	end

	local checkWall = util.TraceHull({
		start = checkpos2,
		endpos = checkpos2 - Vector(0, 0, 35),
		mins = Vector(-8, -8, 0),
		maxs = Vector(8, 8, 0),
		filter = ply
	})

	if not checkWall.Hit then
		render.DrawLine(checkpos2, checkpos2 - Vector(0, 0, 35), color_red)
	else
		render.DrawLine(checkpos2, checkpos2 - Vector(0, 0, 35), color_green)
	end
end
