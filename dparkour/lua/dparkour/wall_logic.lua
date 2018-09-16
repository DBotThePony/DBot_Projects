
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

local IN_ATTACK = IN_ATTACK
local IN_JUMP = IN_JUMP
local IN_DUCK = IN_DUCK
local IN_FORWARD = IN_FORWARD
local IN_BACK = IN_BACK
local IN_USE = IN_USE
local IN_CANCEL = IN_CANCEL
local IN_LEFT = IN_LEFT
local IN_RIGHT = IN_RIGHT
local IN_MOVELEFT = IN_MOVELEFT
local IN_MOVERIGHT = IN_MOVERIGHT
local IN_ATTACK2 = IN_ATTACK2
local IN_RUN = IN_RUN
local IN_RELOAD = IN_RELOAD
local IN_ALT1 = IN_ALT1
local IN_ALT2 = IN_ALT2
local IN_SCORE = IN_SCORE
local IN_SPEED = IN_SPEED
local IN_WALK = IN_WALK
local IN_ZOOM = IN_ZOOM
local IN_WEAPON1 = IN_WEAPON1
local IN_WEAPON2 = IN_WEAPON2
local IN_BULLRUSH = IN_BULLRUSH
local IN_GRENADE1 = IN_GRENADE1
local IN_GRENADE2 = IN_GRENADE2

local MOVETYPE_NONE = MOVETYPE_NONE
local MOVETYPE_WALK = MOVETYPE_WALK
local WorldToLocal = WorldToLocal

function DParkour.HandleWallHang(ply, movedata, data)
	if data.hanging_on_edge then
		if not data.IN_JUMP_changes then return end
		if data.last_hung and data.last_hung > RealTimeL() then return end
		movedata:SetVelocity(data.hanging_trace.HitNormal * 200 * (1 / data.hanging_trace.Fraction:clamp(0.75, 1)):clamp(2, 3))
		ply:EmitSound('DParkour.HangOver')
		data.hanging_on_edge = false
		data.last_hung = RealTimeL() + 0.4
		return
	end

	if data.last_hung and data.last_hung > RealTimeL() then return end
	if not data.first then return end

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

	if checkReach.Hit or checkReach.HitSky then return end

	local checkWall = util.TraceHull({
		start = checkpos2,
		endpos = checkpos2 - Vector(0, 0, 35),
		mins = Vector(-8, -8, 0),
		maxs = Vector(8, 8, 0),
		filter = ply
	})

	if not checkWall.Hit or checkWall.HitSky then return end
	local hangingOn = checkWall.Entity

	local ourvel = movedata:GetVelocity()
	local theirvel = Vector()

	if IsValid(hangingOn) and (hangingOn:IsNPC() or hangingOn:IsPlayer()) then return end
	if IsValid(hangingOn) then theirvel = hangingOn:GetVelocity() end

	if theirvel:Distance(ourvel) > 700 then
		if data.first then
			ply:PrintMessage(HUD_PRINTCENTER, 'Torn off your hands then')
		end

		return
	end

	data.hanging_on_edge = true
	data.hanging_on = hangingOn
	data.hanging_on_valid = IsValid(hangingOn)
	data.hanging_trace = checkWall
	data.haning_ang = movedata:GetAngles()

	if IsValid(hangingOn) then
		data.local_origin, data.local_angle = WorldToLocal(movedata:GetOrigin(), movedata:GetAngles(), hangingOn:GetPos(), hangingOn:GetAngles())
	else
		data.local_origin, data.local_angle = nil, nil
	end

	data.last_hung = RealTimeL() + 0.4

	if not data.hanging_on_valid then
		data.hang_origin = movedata:GetOrigin()
	end

	movedata:SetVelocity(Vector())

	ply:EmitSound('DParkour.Hang')
end

local LocalToWorld = LocalToWorld

function DParkour.HangEventLoop(ply, movedata, data)
	if not data.hanging_on_edge then return end

	if not data.alive then
		data.hanging_on_edge = false
		return
	end

	if data.hanging_on_valid and not IsValid(data.hanging_on) then
		data.hanging_on_edge = false
		return
	end

	if not data.hanging_on_valid then
		movedata:SetOrigin(data.hang_origin)
		movedata:SetVelocity(Vector())
		movedata:SetButtons(movedata:GetButtons():band(
			IN_FORWARD:bor(IN_LEFT, IN_RIGHT, IN_BACK, IN_SPEED, IN_DUCK, IN_RUN):bnot()
		))
		return
	end

	local newpos, newang = LocalToWorld(data.local_origin, data.local_angle, data.hanging_on:GetPos(), data.hanging_on:GetAngles())
	movedata:SetOrigin(newpos)
	movedata:SetVelocity(Vector())
	movedata:SetButtons(movedata:GetButtons():band(
		IN_FORWARD:bor(IN_LEFT, IN_RIGHT, IN_BACK, IN_SPEED, IN_DUCK, IN_RUN):bnot()
	))

	if newang.p < -40 or newang.p > 40 then
		if SERVER then
			ply:PrintMessage(HUD_PRINTCENTER, 'You slipped down from edge!')
		end

		data.hanging_on_edge = false

		movedata:SetVelocity(data.hanging_on:GetVelocity())
	end
end

function DParkour.HangEventLoop2(ply, cmd, data)
	if not data.hanging_on_edge then return end

	cmd:SetButtons(cmd:GetButtons():band(
		IN_FORWARD:bor(IN_LEFT, IN_RIGHT, IN_BACK, IN_ALT1, IN_ALT2, IN_DUCK, IN_USE):bnot()
	))
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

local CurTimeL = CurTimeL

function DParkour.WallJumpLoop(ply, movedata, data)
	data.avaliable_jumps = data.avaliable_jumps or 3

	if data.last_on_ground or not data.alive then
		data.avaliable_jumps = 3
	end

	if not data.alive then return end
	if not data.IN_JUMP_changes or not data.IN_JUMP_last then return end

	if data.avaliable_jumps < 0 then return end

	local eang = ply:EyeAngles()
	eang.p = 0
	eang.r = 0
	local mins, maxs = ply:GetHull()

	mins.z = 0
	maxs.z = 0

	local trWall = util.TraceHull({
		start = ply:GetPos() + ply:OBBCenter(),
		endpos = ply:GetPos() + ply:OBBCenter() - eang:Forward() * 30,
		mins = mins,
		maxs = maxs,
		filter = ply
	})

	if not trWall.Hit then return end

	eang.p = -70

	if data.first then
		data.avaliable_jumps = data.avaliable_jumps - 1
		data.wall_jump_vel = eang:Forward() * 400
		data.wall_pred_until = CurTimeL()
	end

	ply:EmitSound('DParkour.WallStep')
	movedata:SetVelocity(data.wall_jump_vel)
end

local FrameNumberL = FrameNumberL

function DParkour.WallClimbLoop(ply, movedata, data)
	data.avaliable_climbs = data.avaliable_climbs or 3

	if data.first and (data.last_on_ground or not data.alive) then
		data.avaliable_climbs = 3
	end

	if not data.alive then return end

	if not data.IN_JUMP or not data.IN_FORWARD then
		if data.first then
			data.wall_climp_heatup = CurTimeL() + 0.2
		end

		return
	elseif not data.wall_climp_heatup or data.wall_climp_heatup > CurTimeL() then
		return
	end

	local mins, maxs = ply:GetHull()
	maxs.z = 0
	mins.z = 0

	local trWall = util.TraceHull({
		start = ply:GetPos() + ply:OBBCenter(),
		endpos = ply:GetPos() + ply:OBBCenter() + ply:EyeAngles():Forward() * 20,
		mins = mins / 2,
		maxs = maxs / 2,
		filter = ply
	})

	if not trWall.Hit then return end

	if IsValid(trWall.Entity) then
		if trWall.Entity:IsNPC() or trWall.Entity:IsRagdoll() or trWall.Entity:IsPlayer() then return end
		local phys = trWall.Entity:GetPhysicsObject()

		if not IsValid(phys) then return end
		if phys:IsMoveable() and phys:IsMotionEnabled() and trWall.Entity:GetMoveType() ~= MOVETYPE_NONE then return end

	else
		local hit = -trWall.HitNormal
		local dot = ply:EyeAngles():Forward():Dot(hit)
		if dot < 0.8 then return end
	end

	data.next_wall_climb = data.next_wall_climb or 0

	if data.first then
		if data.next_wall_climb > CurTimeL() then
			data.wall_climb_ignore = false
			return
		end

		if data.avaliable_climbs <= 0 then return end

		data.avaliable_climbs = data.avaliable_climbs - 1

		data.next_wall_climb = CurTimeL() + 0.24
		data.wall_climb_ignore = true
		data.wall_climb_lock = movedata:GetVelocity() + Vector(0, 0, 180)
		data.remove_jump = data.IN_JUMP
	elseif not data.wall_climb_ignore then
		return
	end

	ply:EmitSound('DParkour.WallStep')
	movedata:SetVelocity(data.wall_climb_lock)

	if data.remove_jump then
		movedata:SetButtons(movedata:GetButtons():band(IN_JUMP:bnot()))
	end
end
