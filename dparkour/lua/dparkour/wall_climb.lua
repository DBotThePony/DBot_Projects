
-- Copyright (C) 2018-2019 DBot

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
