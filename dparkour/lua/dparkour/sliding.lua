
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

function DParkour.HandleSlide(ply, movedata, data)
	if CLIENT and data.slide_hit and data.slide_hit > UnPredictedCurTime() then
		movedata:SetButtons(movedata:GetButtons()
			:band(IN_FORWARD:bnot())
			:band(IN_BACK:bnot())
			:band(IN_LEFT:bnot())
			:band(IN_RIGHT:bnot())
		)

		movedata:SetVelocity(Vector())

		return
	end

	if data.sliding then
		if data.slide_velocity_start:Length() < 150 or not data.alive then
			DParkour.HandleSlideStop(ply, movedata, data, false)
			return
		end
	elseif movedata:GetVelocity():Length() < 175 then
		return
	end

	if not data.alive then return end

	if not data.sliding then
		if ply:EyeAngles().p > 48 then return end

		if movedata:GetVelocity():Length() < 400 then
			movedata:SetVelocity(movedata:GetVelocity():GetNormalized() * 400)
		end

		data.sliding = true
		data.sliding_start = CurTimeL()
		data.slide_side = movedata:GetVelocity():Angle().yaw:angleDifference(ply:EyeAngles():Forward().yaw) >= 0
		data.slide_velocity_start = movedata:GetVelocity()
		DParkour.__SendSlideStart(data.slide_velocity_start)
		ply:EmitSound('DParkour.Sliding')
	elseif data.first and data.slide_velocity_start:Length() > 350 then
		local mins, maxs = ply:GetHull()
		maxs.z = maxs.z * 0.4

		local tr = util.TraceHull({
			start = ply:GetPos() + Vector(0, 0, 6),
			endpos = ply:GetPos() + Vector(0, 0, 6) + data.slide_velocity_start:GetNormalized() * 30,
			filter = ply,
			mins = mins,
			maxs = maxs
		})

		if tr.Hit then
			ply:EmitSound('DParkour.WallImpactHard')

			if CLIENT then
				data.slide_hit = CurTime()
			else
				movedata:SetVelocity(Vector())

				if IsValid(tr.Entity) then
					if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
						ply:EmitSound('DParkour.NPCImpact')

						if data.slide_velocity_start:Length() > 800 then
							ply:EmitSound('DParkour.NPCImpactHard')
						end
					end

					local info = DamageInfo()
					info:SetAttacker(ply)
					info:SetInflictor(ply)
					info:SetDamageType(DMG_CRUSH:bor(DMG_CLUB))
					info:SetDamage((data.slide_velocity_start:Length() - 300) / 20)
					tr.Entity:TakeDamageInfo(info)
				end
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

	if data.first then
		data.last_slide_origin = data.last_slide_origin or movedata:GetOrigin()
		local delta = movedata:GetOrigin().z - data.last_slide_origin.z
		data.last_slide_origin = movedata:GetOrigin()

		data.slide_velocity_start = data.slide_velocity_start - data.slide_velocity_start:GetNormalized() * FrameTime() * (230 + delta * 256)
	end

	movedata:SetVelocity(data.slide_velocity_start)
end

function DParkour.HandleSlideStop(ply, movedata, data, standup)
	if data.sliding then
		data.sliding = false
		data.slide_velocity_start = Vector()
		data.slide_hit = nil
		data.last_slide_origin = nil

		if standup then
			--ply:EmitSound('DParkour.SlidingInterrupt')
		end

		DParkour.__SendSlideStop()

		ply:StopSound('DParkour.Sliding')
	end
end
