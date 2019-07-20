
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

local MOVETYPE_NOCLIP = MOVETYPE_NOCLIP
local MOVETYPE_FLY = MOVETYPE_FLY
local MOVETYPE_OBSERVER = MOVETYPE_OBSERVER
local MOVETYPE_CUSTOM = MOVETYPE_CUSTOM
local MOVETYPE_NONE = MOVETYPE_NONE
local RealTimeL = RealTimeL
local CurTime = CurTime
local IsFirstTimePredicted = IsFirstTimePredicted

local SuppressHostEvents = SuppressHostEvents or function() end

DLib.pred.Define('DParkourLastGround', 'Bool', false)
DLib.pred.Define('DParkourLastVelocity', 'Vector', Vector())

local function SetupMove(ply, movedata, cmd)
	local mvtype = ply:GetMoveType()
	ply:DLibInvalidatePrediction(true)

	local ptab = ply:GetTable()
	ptab._parkour = ptab._parkour or {}
	local data = ptab._parkour

	if
		mvtype == MOVETYPE_NOCLIP
		or mvtype == MOVETYPE_FLY
		or mvtype == MOVETYPE_OBSERVER
		or mvtype == MOVETYPE_CUSTOM
		-- or mvtype == MOVETYPE_NONE
	then
		DParkour.InterruptRoll(ply, movedata, data)
		DParkour.HandleSlideStop(ply, movedata, data, true)
		DParkour.WallHangDrop(ply, movedata, data)
		ply:DLibInvalidatePrediction(false)
		return
	end

	data.alive = ply:Alive()

	local ground = ply:OnGround()
	local groundChange = ply:GetDParkourLastGround() ~= ground
	ply:SetDParkourLastGround(ground)
	data.last_on_ground = ground

	if not ground and (movedata:KeyDown(IN_DUCK) or movedata:KeyDown(IN_JUMP)) then
		DParkour.HandleWallHang(ply, movedata, data)
	end

	if ground and movedata:KeyDown(IN_DUCK) and movedata:KeyDown(IN_SPEED) then
		DParkour.HandleSlide(ply, movedata, data)
	else
		DParkour.HandleSlideStop(ply, movedata, data, true)
	end

	if ground and groundChange then
		DParkour.HandleRollFall(ply, movedata, data)
	end

	DParkour.HandleRolling(ply, movedata, data)

	DParkour.HangEventLoop(ply, movedata, data)
	DParkour.WallClimbLoop(ply, movedata, data)
	DParkour.WallJumpLoop(ply, movedata, data)

	DParkour.HandleWallRun(ply, movedata, data)

	ply:SetDParkourLastVelocity(movedata:GetVelocity())
	ply:DLibInvalidatePrediction(false)
end

local function StartCommand(ply, cmd)
	local mvtype = ply:GetMoveType()

	if
		mvtype == MOVETYPE_NOCLIP
		or mvtype == MOVETYPE_FLY
		or mvtype == MOVETYPE_OBSERVER
		or mvtype == MOVETYPE_CUSTOM
		-- or mvtype == MOVETYPE_NONE
	then
		return
	end

	ply:DLibInvalidatePrediction(true)

	local ptab = ply:GetTable()
	ptab._parkour = ptab._parkour or {}
	local data = ptab._parkour

	DParkour.RollingCMD(ply, cmd, data)
	DParkour.HangEventLoop2(ply, cmd, data)
	ply:DLibInvalidatePrediction(false)
end

hook.Add('SetupMove', 'DParkourEventLoop', SetupMove, -1)
hook.Add('StartCommand', 'DParkourEventLoop', StartCommand, -1)
