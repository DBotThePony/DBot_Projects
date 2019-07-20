
-- Copyright (C) 2018-2019 DBotThePony

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
local DLib = DLib
local hook = hook

local IN_ALT1 = IN_ALT1
local IN_ALT2 = IN_ALT2
local IN_ATTACK = IN_ATTACK
local IN_ATTACK2 = IN_ATTACK2
local IN_BACK = IN_BACK
local IN_BULLRUSH = IN_BULLRUSH
local IN_CANCEL = IN_CANCEL
local IN_DUCK = IN_DUCK
local IN_FORWARD = IN_FORWARD
local IN_GRENADE1 = IN_GRENADE1
local IN_GRENADE2 = IN_GRENADE2
local IN_JUMP = IN_JUMP
local IN_LEFT = IN_LEFT
local IN_MOVELEFT = IN_MOVELEFT
local IN_MOVERIGHT = IN_MOVERIGHT
local IN_RELOAD = IN_RELOAD
local IN_RIGHT = IN_RIGHT
local IN_RUN = IN_RUN
local IN_SCORE = IN_SCORE
local IN_SPEED = IN_SPEED
local IN_USE = IN_USE
local IN_WALK = IN_WALK
local IN_WEAPON1 = IN_WEAPON1
local IN_WEAPON2 = IN_WEAPON2
local IN_ZOOM = IN_ZOOM

local CurTime = CurTime
local IsValid = IsValid
local timer = timer
local UnPredictedCurTime = UnPredictedCurTime
local CurTimeL = CurTimeL

DLib.pred.Define('DParkourRolls', 'Int', 0)
DLib.pred.Define('DParkourRolling', 'Bool', false)
DLib.pred.Define('DParkourRollStart', 'Float', 0)
DLib.pred.Define('DParkourRollEnd', 'Float', 0)
DLib.pred.Define('DParkourNextRoll', 'Float', 0)
DLib.pred.Define('DParkourRollDir', 'Vector', Vector())
DLib.pred.Define('DParkourRollAng', 'Angle', Angle())

local ENABLE_ROLLING = DLib.util.CreateSharedConvar('sv_dparkour_rolling', '1', 'Enable ability to roll on ground')
local ROLLING_TIMING_BETWEEN = DLib.util.CreateSharedConvar('sv_dparkour_roll_timing_b', '0.2', 'Time between roll sounds')
local ROLLING_TIME = DLib.util.CreateSharedConvar('sv_dparkour_roll_time', '0.6', 'time required for one roll')

function DParkour.HandleRolling(ply, movedata, data)
	if not ENABLE_ROLLING:GetBool() then return end

	if not ply:OnGround() and ply:GetDParkourRolling() then
		ply:SetDParkourRolls(0)
	elseif not ply:OnGround() and not ply:GetDParkourRolling() then
		ply:SetDParkourRolls(ply:GetDParkourRolls():min(1))
	end

	if not data.alive then
		DParkour.InterruptRoll(ply, movedata, data)
		return
	end

	if ply:GetDParkourRolling() and ply:GetDParkourRollEnd() < CurTime() then
		ply:SetDParkourRolling(false)
		data.rolling = false
	end

	if ply:GetDParkourRolls() <= 0 and not ply:GetDParkourRolling() then return end

	if not ply:GetDParkourRolling() then
		ply:SetDParkourRolling(true)
		ply:SetDParkourRollStart(CurTime())
		ply:SetDParkourRollEnd(CurTime() + ROLLING_TIME:GetFloat())
		ply:SetDParkourRolls(ply:GetDParkourRolls() - 1)
		ply:SetDParkourNextRoll(CurTime() + ROLLING_TIMING_BETWEEN:GetFloat())

		if CLIENT and IsFirstTimePredicted() then
			data.rolling = true
			data.roll_start = RealTime()
			data.roll_end = RealTime() + ROLLING_TIME:GetFloat()
		end

		ply:EmitSoundPredicted('DParkour.Roll')
	end

	if not ply:GetDParkourRolling() then return end

	if ply:GetDParkourNextRoll() < CurTime() then
		ply:EmitSoundPredicted('DParkour.Roll')
		ply:SetDParkourNextRoll(CurTime() + ROLLING_TIMING_BETWEEN:GetFloat())
	end

	movedata:SetVelocity(ply:GetDParkourRollDir())
end

function DParkour.InterruptRoll(ply, movedata, data)
	ply:SetDParkourRolls(0)
	ply:SetDParkourRolling(false)

	if CLIENT then
		data.rolling = false
		data.roll_start = 0
		data.roll_end = 0
	end
end

function DParkour.RollingCMD(ply, cmd, data)
	if not ply:GetDParkourRolling() then return end
	cmd:SetButtons(IN_DUCK)
	cmd:SetMouseX(0)
	cmd:SetMouseY(0)
end

local ROLL_MIN_VELOCITY = DLib.util.CreateSharedConvar('sv_dparkour_roll_minvel', '300', 'Minimal velocity vector required for rolling start')
local ROLL_SPEED = DLib.util.CreateSharedConvar('sv_dparkour_roll_speed', '400', 'Speed at which player rolls')
local ROLLS_DIVIER = DLib.util.CreateSharedConvar('sv_dparkour_roll_divier', '1400', 'Inernal divider to determine roll count')

function DParkour.HandleRollFall(ply, movedata, data)
	if not ENABLE_ROLLING:GetBool() then return end
	if ply:GetDParkourRolling() then return end

	if not ply:KeyDown(IN_DUCK) then return end
	if not data.alive then return end
	if ply:EyeAngles().p < 40 then return end
	local velocity = ply:GetDParkourLastVelocity()

	if velocity:Length() < ROLL_MIN_VELOCITY:GetFloat() then return end

	local direction

	if velocity.x:abs() < 10 and velocity.y:abs() < 10 then
		direction = ply:EyeAngles()
		direction.p = 0
		direction.r = 0
	else
		direction = Vector(velocity.x, velocity.y):Angle()
	end

	local rolls = (velocity:Length() / ROLLS_DIVIER:GetFloat()):ceil():max(1)

	ply:SetDParkourRolls(rolls)
	ply:SetDParkourRollDir(direction:Forward() * ROLL_SPEED:GetFloat())
	ply:SetDParkourRollAng(direction)
end
