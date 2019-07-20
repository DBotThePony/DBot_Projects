
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
local FrameTime = FrameTime
local CurTime = CurTime
local UnPredictedCurTime = UnPredictedCurTime
local IsFirstTimePredicted = IsFirstTimePredicted
local FrameNumberL = FrameNumberL

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

local IsValid = IsValid
local DMG_CRUSH = DMG_CRUSH
local DMG_CLUB = DMG_CLUB

local ENABLED = DLib.util.CreateSharedConvar('sv_dparkour_sliding', '1', 'Enable sliding')
local MIN_SLIDING_VELOCITY = DLib.util.CreateSharedConvar('sv_dparkour_sliding_initvel', '400', 'Minimal sliding velocity for sliding. If player got less than this velocity, his velocity is boosted.')
local DSLIDING_VELOCITY = DLib.util.CreateSharedConvar('sv_dparkour_sliding_sp', '350', 'If player velocity is higher than this value, he can damage on hit entities in front of his sliding.')
local FRITCTION_MUL = DLib.util.CreateSharedConvar('sv_dparkour_sliding_friction', '1', 'Adjuct this to set desired friction.')

local sv_friction = GetConVar('sv_friction')

DLib.pred.Define('DParkourSliding', 'Bool', false)
DLib.pred.Define('DParkourSlideVelStart', 'Vector', Vector())
DLib.pred.Define('DParkourSlideLastOrigin', 'Vector', Vector())
DLib.pred.Define('DParkourSlideStart', 'Float', 0)
DLib.pred.Define('DParkourSlideSide', 'Bool', 0)

function DParkour.HandleSlide(ply, movedata, data)
	if not ENABLED:GetBool() then return end

	if ply:GetDParkourSliding() then
		if ply:GetDParkourSlideVelStart():Length() < 150 or not data.alive then
			DParkour.HandleSlideStop(ply, movedata, data, false)
			return
		end
	elseif movedata:GetVelocity():Length() < 175 then
		return
	end

	if not data.alive then return end

	if not ply:GetDParkourSliding() then
		if ply:EyeAngles().p > 48 then return end

		if movedata:GetVelocity():Length() < MIN_SLIDING_VELOCITY:GetFloat() then
			movedata:SetVelocity(movedata:GetVelocity():GetNormalized() * MIN_SLIDING_VELOCITY:GetFloat())
		end

		ply:SetDParkourSliding(true)
		ply:SetDParkourSlideStart(CurTime())
		ply:SetDParkourSlideSide(movedata:GetVelocity():Angle().yaw:angleDifference(ply:EyeAngles():Forward().yaw) >= 0)
		ply:SetDParkourSlideVelStart(movedata:GetVelocity())
		ply:SetDParkourSlideLastOrigin(movedata:GetOrigin())

		ply:EmitSoundPredicted('DParkour.Sliding')
	elseif ply:GetDParkourSlideVelStart():Length() > DSLIDING_VELOCITY:GetFloat() then
		local mins, maxs = ply:GetHull()
		maxs.z = maxs.z * 0.4

		local tr = util.TraceHull({
			start = ply:GetPos() + Vector(0, 0, 6),
			endpos = ply:GetPos() + Vector(0, 0, 6) + ply:GetDParkourSlideVelStart():GetNormalized() * 30,
			filter = ply,
			mins = mins,
			maxs = maxs
		})

		if tr.Hit then
			ply:EmitSoundPredicted('DParkour.WallImpactHard')

			movedata:SetVelocity(Vector())

			if SERVER and IsValid(tr.Entity) then
				if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
					ply:EmitSoundPredicted('DParkour.NPCImpact')

					if ply:GetDParkourSlideVelStart():Length() > 800 then
						ply:EmitSoundPredicted('DParkour.NPCImpactHard')
					end
				end

				local info = DamageInfo()
				info:SetAttacker(ply)
				info:SetInflictor(ply)
				info:SetDamageType(DMG_CRUSH:bor(DMG_CLUB))
				info:SetDamage((data.slide_velocity_start:Length() - 300) / 20)
				tr.Entity:TakeDamageInfo(info)
			end

			DParkour.HandleSlideStop(ply, movedata, data, false)

			return
		end
	end

	movedata:SetButtons(movedata:GetButtons()
		:band(IN_FORWARD:bnot())
		:band(IN_BACK:bnot())
		:band(IN_LEFT:bnot())
		:band(IN_RIGHT:bnot())
	)

	local delta = movedata:GetOrigin().z - ply:GetDParkourSlideLastOrigin().z
	ply:SetDParkourSlideLastOrigin(movedata:GetOrigin())
	ply:SetDParkourSlideVelStart(ply:GetDParkourSlideVelStart() - ply:GetDParkourSlideVelStart():GetNormalized() * FrameTime() * (230 * sv_friction:GetFloat() / 8 * FRITCTION_MUL:GetFloat() + delta * 256))

	movedata:SetVelocity(ply:GetDParkourSlideVelStart())
end

function DParkour.HandleSlideStop(ply, movedata, data, standup)
	if ply:GetDParkourSliding() then
		ply:SetDParkourSliding(false)
		ply:SetDParkourSlideVelStart(Vector())

		if standup then
			--ply:EmitSound('DParkour.SlidingInterrupt')
		end

		ply:StopSound('DParkour.Sliding')
	end
end
