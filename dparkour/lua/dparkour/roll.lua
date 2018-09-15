
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
local CurTimeL = CurTimeL

local rollMask =
	IN_FORWARD:bnot()
	:band(IN_BACK:bnot())
	:band(IN_LEFT:bnot())
	:band(IN_RIGHT:bnot())
	:band(IN_CANCEL:bnot())
	:band(IN_SPEED:bnot())
	:band(IN_WALK:bnot())
	:band(IN_ZOOM:bnot())
	:band(IN_WEAPON1:bnot())
	:band(IN_WEAPON2:bnot())
	:band(IN_GRENADE1:bnot())
	:band(IN_GRENADE2:bnot())
	:band(IN_ATTACK:bnot())
	:band(IN_ATTACK2:bnot())
	:band(IN_RUN:bnot())
	:band(IN_RELOAD:bnot())
	:band(IN_ALT1:bnot())
	:band(IN_ALT2:bnot())
	:bor(IN_DUCK)

function DParkour.HandleRolling(ply, movedata, data)
	data.rolls = data.rolls or 0

	if not data.last_on_ground and data.rolling then
		data.rolls = 0
	elseif not data.last_on_ground and not data.rolling then
		data.rolls = data.rolls:min(1)
	end

	if data.first and data.rolling and data.rolling_end < UnPredictedCurTime() then
		data.rolling = false
	end

	if data.rolls <= 0 and not data.rolling then return end

	if not data.rolling and data.first then
		data.rolling = true
		data.rolling_start = UnPredictedCurTime()
		data.rolling_end = UnPredictedCurTime() + 0.6
		data.rolls = data.rolls - 1
	end

	if not data.rolling then return end

	movedata:SetVelocity(data.roll_dir)
end

function DParkour.RollingCMD(ply, cmd, data)
	if not data.rolling then return end
	cmd:SetButtons(IN_DUCK)
	cmd:SetMouseX(0)
	cmd:SetMouseY(0)
end

function DParkour.HandleRollFall(ply, movedata, data)
	if not data.first then return end
	if data.rolling then return end
	if not data.IN_DUCK then return end
	if ply:EyeAngles().p < 45 then return end
	local velocity = data.last_velocity

	if velocity:Length() < 300 then return end

	local direction

	if velocity.x:abs() < 10 and velocity.y:abs() < 10 then
		direction = ply:EyeAngles()
		direction.p = 0
		direction.r = 0
	else
		direction = Vector(velocity.x, velocity.y):Angle()
	end

	local rolls = (velocity:Length() / 1400):ceil():max(1)

	data.rolls = rolls
	data.roll_dir = direction:Forward() * 400
	data.roll_ang = direction

	DParkour.HandleRolling(ply, movedata, data)
end
