
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

local function updatebuttons(buttons, data)
	local rtime = RealTimeL()

	data.IN_ATTACK = buttons:band(IN_ATTACK) == IN_ATTACK
	data.IN_ATTACK_changes2 = data.IN_ATTACK ~= data.IN_ATTACK_last2
	data.IN_ATTACK_last2 = data.IN_ATTACK

	if not data.IN_ATTACK_time or data.IN_ATTACK_time < rtime then
		data.IN_ATTACK_time = rtime + 0.1
		data.IN_ATTACK_changes = data.IN_ATTACK ~= data.IN_ATTACK_last
		data.IN_ATTACK_last = data.IN_ATTACK
	else
		data.IN_ATTACK_changes = false
	end

	data.IN_JUMP = buttons:band(IN_JUMP) == IN_JUMP
	data.IN_JUMP_changes2 = data.IN_JUMP ~= data.IN_JUMP_last2
	data.IN_JUMP_last2 = data.IN_JUMP

	if not data.IN_JUMP_time or data.IN_JUMP_time < rtime then
		data.IN_JUMP_time = rtime + 0.1
		data.IN_JUMP_changes = data.IN_JUMP ~= data.IN_JUMP_last
		data.IN_JUMP_last = data.IN_JUMP
	else
		data.IN_JUMP_changes = false
	end

	data.IN_DUCK = buttons:band(IN_DUCK) == IN_DUCK
	data.IN_DUCK_changes2 = data.IN_DUCK ~= data.IN_DUCK_last2
	data.IN_DUCK_last2 = data.IN_DUCK

	if not data.IN_DUCK_time or data.IN_DUCK_time < rtime then
		data.IN_DUCK_time = rtime + 0.1
		data.IN_DUCK_changes = data.IN_DUCK ~= data.IN_DUCK_last
		data.IN_DUCK_last = data.IN_DUCK
	else
		data.IN_DUCK_changes = false
	end

	data.IN_FORWARD = buttons:band(IN_FORWARD) == IN_FORWARD
	data.IN_FORWARD_changes2 = data.IN_FORWARD ~= data.IN_FORWARD_last2
	data.IN_FORWARD_last2 = data.IN_FORWARD

	if not data.IN_FORWARD_time or data.IN_FORWARD_time < rtime then
		data.IN_FORWARD_time = rtime + 0.1
		data.IN_FORWARD_changes = data.IN_FORWARD ~= data.IN_FORWARD_last
		data.IN_FORWARD_last = data.IN_FORWARD
	else
		data.IN_FORWARD_changes = false
	end

	data.IN_BACK = buttons:band(IN_BACK) == IN_BACK
	data.IN_BACK_changes2 = data.IN_BACK ~= data.IN_BACK_last2
	data.IN_BACK_last2 = data.IN_BACK

	if not data.IN_BACK_time or data.IN_BACK_time < rtime then
		data.IN_BACK_time = rtime + 0.1
		data.IN_BACK_changes = data.IN_BACK ~= data.IN_BACK_last
		data.IN_BACK_last = data.IN_BACK
	else
		data.IN_BACK_changes = false
	end

	data.IN_USE = buttons:band(IN_USE) == IN_USE
	data.IN_USE_changes2 = data.IN_USE ~= data.IN_USE_last2
	data.IN_USE_last2 = data.IN_USE

	if not data.IN_USE_time or data.IN_USE_time < rtime then
		data.IN_USE_time = rtime + 0.1
		data.IN_USE_changes = data.IN_USE ~= data.IN_USE_last
		data.IN_USE_last = data.IN_USE
	else
		data.IN_USE_changes = false
	end

	data.IN_LEFT = buttons:band(IN_LEFT) == IN_LEFT
	data.IN_LEFT_changes2 = data.IN_LEFT ~= data.IN_LEFT_last2
	data.IN_LEFT_last2 = data.IN_LEFT

	if not data.IN_LEFT_time or data.IN_LEFT_time < rtime then
		data.IN_LEFT_time = rtime + 0.1
		data.IN_LEFT_changes = data.IN_LEFT ~= data.IN_LEFT_last
		data.IN_LEFT_last = data.IN_LEFT
	else
		data.IN_LEFT_changes = false
	end

	data.IN_RIGHT = buttons:band(IN_RIGHT) == IN_RIGHT
	data.IN_RIGHT_changes2 = data.IN_RIGHT ~= data.IN_RIGHT_last2
	data.IN_RIGHT_last2 = data.IN_RIGHT

	if not data.IN_RIGHT_time or data.IN_RIGHT_time < rtime then
		data.IN_RIGHT_time = rtime + 0.1
		data.IN_RIGHT_changes = data.IN_RIGHT ~= data.IN_RIGHT_last
		data.IN_RIGHT_last = data.IN_RIGHT
	else
		data.IN_RIGHT_changes = false
	end

	data.IN_MOVELEFT = buttons:band(IN_MOVELEFT) == IN_MOVELEFT
	data.IN_MOVELEFT_changes2 = data.IN_MOVELEFT ~= data.IN_MOVELEFT_last2
	data.IN_MOVELEFT_last2 = data.IN_MOVELEFT

	if not data.IN_MOVELEFT_time or data.IN_MOVELEFT_time < rtime then
		data.IN_MOVELEFT_time = rtime + 0.1
		data.IN_MOVELEFT_changes = data.IN_MOVELEFT ~= data.IN_MOVELEFT_last
		data.IN_MOVELEFT_last = data.IN_MOVELEFT
	else
		data.IN_MOVELEFT_changes = false
	end

	data.IN_MOVERIGHT = buttons:band(IN_MOVERIGHT) == IN_MOVERIGHT
	data.IN_MOVERIGHT_changes2 = data.IN_MOVERIGHT ~= data.IN_MOVERIGHT_last2
	data.IN_MOVERIGHT_last2 = data.IN_MOVERIGHT

	if not data.IN_MOVERIGHT_time or data.IN_MOVERIGHT_time < rtime then
		data.IN_MOVERIGHT_time = rtime + 0.1
		data.IN_MOVERIGHT_changes = data.IN_MOVERIGHT ~= data.IN_MOVERIGHT_last
		data.IN_MOVERIGHT_last = data.IN_MOVERIGHT
	else
		data.IN_MOVERIGHT_changes = false
	end

	data.IN_ATTACK2 = buttons:band(IN_ATTACK2) == IN_ATTACK2
	data.IN_ATTACK2_changes2 = data.IN_ATTACK2 ~= data.IN_ATTACK2_last2
	data.IN_ATTACK2_last2 = data.IN_ATTACK2

	if not data.IN_ATTACK2_time or data.IN_ATTACK2_time < rtime then
		data.IN_ATTACK2_time = rtime + 0.1
		data.IN_ATTACK2_changes = data.IN_ATTACK2 ~= data.IN_ATTACK2_last
		data.IN_ATTACK2_last = data.IN_ATTACK2
	else
		data.IN_ATTACK2_changes = false
	end

	data.IN_RUN = buttons:band(IN_RUN) == IN_RUN
	data.IN_RUN_changes2 = data.IN_RUN ~= data.IN_RUN_last2
	data.IN_RUN_last2 = data.IN_RUN

	if not data.IN_RUN_time or data.IN_RUN_time < rtime then
		data.IN_RUN_time = rtime + 0.1
		data.IN_RUN_changes = data.IN_RUN ~= data.IN_RUN_last
		data.IN_RUN_last = data.IN_RUN
	else
		data.IN_RUN_changes = false
	end

	data.IN_RELOAD = buttons:band(IN_RELOAD) == IN_RELOAD
	data.IN_RELOAD_changes2 = data.IN_RELOAD ~= data.IN_RELOAD_last2
	data.IN_RELOAD_last2 = data.IN_RELOAD

	if not data.IN_RELOAD_time or data.IN_RELOAD_time < rtime then
		data.IN_RELOAD_time = rtime + 0.1
		data.IN_RELOAD_changes = data.IN_RELOAD ~= data.IN_RELOAD_last
		data.IN_RELOAD_last = data.IN_RELOAD
	else
		data.IN_RELOAD_changes = false
	end

	data.IN_ALT1 = buttons:band(IN_ALT1) == IN_ALT1
	data.IN_ALT1_changes2 = data.IN_ALT1 ~= data.IN_ALT1_last2
	data.IN_ALT1_last2 = data.IN_ALT1

	if not data.IN_ALT1_time or data.IN_ALT1_time < rtime then
		data.IN_ALT1_time = rtime + 0.1
		data.IN_ALT1_changes = data.IN_ALT1 ~= data.IN_ALT1_last
		data.IN_ALT1_last = data.IN_ALT1
	else
		data.IN_ALT1_changes = false
	end

	data.IN_ALT2 = buttons:band(IN_ALT2) == IN_ALT2
	data.IN_ALT2_changes2 = data.IN_ALT2 ~= data.IN_ALT2_last2
	data.IN_ALT2_last2 = data.IN_ALT2

	if not data.IN_ALT2_time or data.IN_ALT2_time < rtime then
		data.IN_ALT2_time = rtime + 0.1
		data.IN_ALT2_changes = data.IN_ALT2 ~= data.IN_ALT2_last
		data.IN_ALT2_last = data.IN_ALT2
	else
		data.IN_ALT2_changes = false
	end

	data.IN_SPEED = buttons:band(IN_SPEED) == IN_SPEED
	data.IN_SPEED_changes2 = data.IN_SPEED ~= data.IN_SPEED_last2
	data.IN_SPEED_last2 = data.IN_SPEED

	if not data.IN_SPEED_time or data.IN_SPEED_time < rtime then
		data.IN_SPEED_time = rtime + 0.1
		data.IN_SPEED_changes = data.IN_SPEED ~= data.IN_SPEED_last
		data.IN_SPEED_last = data.IN_SPEED
	else
		data.IN_SPEED_changes = false
	end

	data.IN_WALK = buttons:band(IN_WALK) == IN_WALK
	data.IN_WALK_changes2 = data.IN_WALK ~= data.IN_WALK_last2
	data.IN_WALK_last2 = data.IN_WALK

	if not data.IN_WALK_time or data.IN_WALK_time < rtime then
		data.IN_WALK_time = rtime + 0.1
		data.IN_WALK_changes = data.IN_WALK ~= data.IN_WALK_last
		data.IN_WALK_last = data.IN_WALK
	else
		data.IN_WALK_changes = false
	end
end

local function SetupMove(ply, movedata, cmd)
	local mvtype = ply:GetMoveType()

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
		return
	end

	data.first = IsFirstTimePredicted()

	if data.first then
		data.alive = ply:Alive()
		updatebuttons(movedata:GetButtons(), data)
	end

	local ground = ply:OnGround()
	local groundChange = data.last_on_ground ~= ground
	data.last_on_ground = ground

	if not ground and data.IN_JUMP then
		DParkour.HandleWallHang(ply, movedata, data)
	end

	if ground and data.IN_DUCK and data.IN_SPEED then
		DParkour.HandleSlide(ply, movedata, data)
	else
		DParkour.HandleSlideStop(ply, movedata, data, true)
	end

	DParkour.HandleRolling(ply, movedata, data)

	if ground and groundChange then
		DParkour.HandleRollFall(ply, movedata, data)
	end

	DParkour.HangEventLoop(ply, movedata, data)
	DParkour.WallClimbLoop(ply, movedata, data)
	DParkour.WallJumpLoop(ply, movedata, data)

	data.last_velocity = movedata:GetVelocity()
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

	local ptab = ply:GetTable()
	ptab._parkour = ptab._parkour or {}
	local data = ptab._parkour

	DParkour.RollingCMD(ply, cmd, data)
	DParkour.HangEventLoop2(ply, cmd, data)
end

hook.Add('SetupMove', 'DParkourEventLoop', SetupMove, 3)
hook.Add('StartCommand', 'DParkourEventLoop', StartCommand, 3)
