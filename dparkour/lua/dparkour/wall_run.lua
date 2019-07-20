
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

DLib.pred.Define('DParkourAWallRun', 'Int', 5)

function DParkour.HandleWallRun(ply, movedata, data)
	if ply:GetDParkourHangingOnEdge() then return end

	if data.last_on_ground or not data.alive then
		ply:SetDParkourAWallRun(5)
	end

	if not data.alive or data.last_on_ground then return end
	if not movedata:KeyPressed(IN_JUMP) or not movedata:KeyDown(IN_JUMP) or not movedata:KeyDown(IN_SPEED) then return end

	local center = movedata:GetOrigin() + ply:OBBCenter()
	local eyes = movedata:GetAngles():Right()

	local mins, maxs = ply:GetHull()
	maxs.z = 0
	mins.z = 0

	local trWall = util.TraceHull({
		start = center,
		endpos = center + eyes * 20,
		mins = mins / 2,
		maxs = maxs / 2,
		filter = ply
	})

	local trWall2 = util.TraceHull({
		start = center,
		endpos = center - eyes * 20,
		mins = mins / 2,
		maxs = maxs / 2,
		filter = ply
	})

	if not trWall.Hit and not trWall2.Hit then return end

	local usetrace = trWall.Hit and trWall or trWall2

	if IsValid(usetrace.Entity) then
		if usetrace.Entity:IsNPC() or usetrace.Entity:IsRagdoll() or usetrace.Entity:IsPlayer() then return end
		local phys = usetrace.Entity:GetPhysicsObject()

		if not IsValid(phys) then return end
		if phys:IsMoveable() and phys:IsMotionEnabled() and usetrace.Entity:GetMoveType() ~= MOVETYPE_NONE then return end
	else
		local hit = -usetrace.HitNormal
		local dot = movedata:GetAngles():Forward():Dot(hit)
		if dot > 0.6 or dot < -0.2 then return end
	end

	if ply:GetDParkourAWallRun() <= 0 then return end
	ply:AddDParkourAWallRun(-1)

	local wall_run_vel = movedata:GetVelocity()
	wall_run_vel.z = 140

	ply:EmitSoundPredicted('DParkour.WallStep')
	movedata:SetVelocity(wall_run_vel)
end
