
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
local LocalToWorld = LocalToWorld
local CurTimeL = CurTimeL
local FrameNumberL = FrameNumberL

local game = game
local net = net

if SERVER then
	net.pool('dparkour.sendhang')
end

function DParkour.WallHangInterrupt(ply, movedata, data)
	if not data.hanging_on_edge then return end
	movedata:SetVelocity(data.hanging_trace.HitNormal * 200 * (1 / data.hanging_trace.Fraction:clamp(0.75, 1)):clamp(2, 3))

	-- fuck off sorse's prediction
	data.fuckoff_velocity = true

	if data.hanging_on_valid and not IsValid(data.hanging_on) then
		movedata:SetVelocity(movedata:GetVelocity() + data.hanging_on:GetVelocity() * 3)
	end

	data.fuckoff_vel_amount = movedata:GetVelocity()

	ply:EmitSound('DParkour.HangOver')
	data.hanging_on_edge = false
	data.last_hung = RealTimeL() + 0.4
end

function DParkour.WallHangDrop(ply, movedata, data)
	if not data.hanging_on_edge then return end
	movedata:SetVelocity(Vector())

	-- fuck off sorse's prediction
	data.fuckoff_velocity = true
	data.fuckoff_vel_amount = movedata:GetVelocity()

	data.hanging_on_edge = false
	data.last_hung = RealTimeL() + 0.4
end

function DParkour.HandleWallHang(ply, movedata, data)
	if data.first then
		data.fuckoff_velocity = false
	elseif data.fuckoff_velocity then
		movedata:SetVelocity(data.fuckoff_vel_amount)
		return
	end

	if data.hanging_on_edge then
		if data.last_hung and data.last_hung > RealTimeL() then return end

		if data.first then
			if data.IN_JUMP_changes then
				DParkour.WallHangInterrupt(ply, movedata, data)
			elseif data.IN_DUCK then
				DParkour.WallHangDrop(ply, movedata, data)
			end
		end

		return
	end

	if not data.IN_JUMP or data.IN_DUCK then return end
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

	if not IsValid(hangingOn) then
		local mins, maxs = ply:GetHull()
		local vec = Vector(0, 0, (maxs.z - mins.z) / 2)
		local wide = (mins.x - maxs.x):abs():max((mins.y - maxs.y):abs())

		local checkNearWall = util.TraceHull({
			start = epos - vec,
			endpos = epos + yaw:Forward() * 80 - vec,
			mins = Vector(-8, -8, 0),
			maxs = Vector(8, 8, 0),
			filter = ply
		})

		if checkNearWall.Hit then
			local origin = checkNearWall.HitPos + checkNearWall.HitNormal * (wide / 2)
			origin.z = checkWall.HitPos.z - (maxs.z - mins.z) * 0.9

			if checkNearWall.Fraction > 0.1 then
				movedata:SetOrigin(origin)
			end
		end
	end

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

	if SERVER and not game.SinglePlayer() then
		net.Start('dparkour.sendhang')
		net.WriteEntity(data.hanging_on)
		net.WriteAngleDouble(data.haning_ang)
		net.WriteVectorDouble(movedata:GetOrigin())
		net.WriteTable(checkWall)

		net.WriteBool(data.local_origin ~= nil)

		if data.local_origin then
			net.WriteVectorDouble(data.local_origin)
		end

		net.WriteBool(data.local_angle ~= nil)

		if data.local_angle then
			net.WriteAngleDouble(data.local_angle)
		end

		net.Send(ply)
	end
end

if CLIENT then
	local LocalPlayer = LocalPlayer

	net.receive('dparkour.sendhang', function()
		local data = LocalPlayer()._parkour

		data.hanging_on_edge = true
		data.hanging_on = net.ReadEntity()
		data.haning_ang = net.ReadAngleDouble()
		data.hang_origin = net.ReadVectorDouble()

		data.hanging_on_valid = IsValid(data.hanging_on)

		data.hanging_trace = net.ReadTable()

		if net.ReadBool() then
			data.local_origin = net.ReadVectorDouble()
		else
			data.local_origin = nil
		end

		if net.ReadBool() then
			data.local_angle = net.ReadAngleDouble()
		else
			data.local_angle = nil
		end
	end)
end

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
			IN_FORWARD:bor(IN_LEFT, IN_RIGHT, IN_BACK, IN_SPEED, IN_RUN):bnot()
		))
		return
	end

	local newpos, newang = LocalToWorld(data.local_origin, data.local_angle, data.hanging_on:GetPos(), data.hanging_on:GetAngles())
	movedata:SetOrigin(newpos)
	movedata:SetVelocity(Vector())
	movedata:SetButtons(movedata:GetButtons():band(
		IN_FORWARD:bor(IN_LEFT, IN_RIGHT, IN_BACK, IN_SPEED, IN_RUN):bnot()
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
		IN_FORWARD:bor(IN_LEFT, IN_RIGHT, IN_BACK, IN_ALT1, IN_ALT2, IN_USE):bnot()
	))
end