
-- Copyright (C) 2019 DBotThePony

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

local LocalPlayer = LocalPlayer

if IsValid(DLibLegsModel) then
	DLibLegsModel:Remove()
end

if IsValid(DLibLegsModel2) then
	DLibLegsModel2:Remove()
end

local DLibLegsModel, DLibLegsModel2, lastModel

local function CreateNewLegs(ply)
	if IsValid(DLibLegsModel) then
		DLibLegsModel:Remove()
	end

	if IsValid(DLibLegsModel2) then
		DLibLegsModel2:Remove()
	end

	local function GetPlayerColor()
		return ply:GetPlayerColor()
	end

	lastModel = ply:GetModel()

	DLibLegsModel = ClientsideModel(lastModel)
	_G.DLibLegsModel = DLibLegsModel

	DLibLegsModel2 = ClientsideModel(lastModel)
	_G.DLibLegsModel2 = DLibLegsModel2

	DLibLegsModel:SetNoDraw(true)
	DLibLegsModel2:SetNoDraw(true)
	DLibLegsModel.GetPlayerColor = GetPlayerColor
	DLibLegsModel2.GetPlayerColor = GetPlayerColor

	return DLibLegsModel, DLibLegsModel2
end

local sincosalign = 16
local sincosalign_vehicle = 6
local sincosalign_boat = 4
local sincosalign_jeep = 8
local duck_offset_hack = Vector(0, 0, 0)
local lastDuck = 0
local clipPlane = Vector(0, 0, -1)
local clipPlaneStraight = Vector(0, 0, -1)
local clipPlaneStraightInv = Vector(0, 0, 1)
local clipPlaneDot = 0
local shouldClip = true
local shouldDrawSecond = false

local clipPlane2_1, clipPlane2_2 = Vector(0, 0, -1), Vector(0, 0, 1)
local clipPlane2_1Plane, clipPlane2_2Plane, clipPlane2_3Plane = 0, 0, 0

local function MoveModel(ply, inRender)
	local pos = inRender and EyePos() or ply:EyePos()
	local pos2 = Vector(pos)
	local ang = inRender and EyeAngles() or ply:EyeAngles()
	local ctime = CurTime()
	local delta = (ctime - lastDuck) * 19
	lastDuck = ctime
	local pitch, yaw, roll = 0, 0, 0
	local vehicle = ply:InVehicle()
	local posFor2, angFor2

	if vehicle then
		local act = ply:GetSequenceActivity(ply:GetSequence())

		ang = ply:GetVehicle():GetAngles()
		ang:RotateAroundAxis(ang:Up(), 90)
		pitch, roll, yaw = ang.p, ang.r, ang.y

		local sin, cos = yaw:rad():sin(), yaw:rad():cos()

		local add = Vector(0, 0, -24)
		add:Rotate(ang)
		pos:Add(add)
		local clip = Vector(0, 0, -1)
		clip:Rotate(ang)
		clipPlane = clip

		shouldDrawSecond = false
		shouldClip = true

		if act == ACT_DRIVE_JEEP then
			pos.x = pos.x - cos * sincosalign_jeep
			pos.y = pos.y - sin * sincosalign_jeep
			pos.z = pos.z - 4

			--[[shouldDrawSecond = true

			angFor2 = Angle(pitch, yaw + 3, roll - 13)
			posFor2 = Vector(pos)

			local add = Vector(3, -6, -3)
			add:Rotate(ang)
			posFor2:Add(add)

			clipPlane2_1, clipPlane2_2 = Vector(0, 0, -1), Vector(0, 0, 1)
			clipPlane2_1:Rotate(ang)
			clipPlane2_2:Rotate(ang)

			local cpos = Vector(pos2)
			cpos.z = cpos.z - 13
			clipPlane2_1Plane = clipPlane2_1:Dot(cpos)
			clipPlane2_2Plane = clipPlane2_2:Dot(cpos)
			cpos.z = cpos.z + 10
			clipPlane2_3Plane = clipPlane2_1:Dot(cpos)]]
		elseif act == ACT_DRIVE_AIRBOAT then
			shouldDrawSecond = true
			pos.z = pos.z - 4
			angFor2 = Angle(pitch, yaw + 3, roll - 13)
			posFor2 = Vector(pos)

			local add = Vector(0, -6, 0.7)
			add:Rotate(ang)
			posFor2:Add(add)

			clipPlane2_1, clipPlane2_2 = Vector(0, 0, -1), Vector(0, 0, 1)
			clipPlane2_1:Rotate(ang)
			clipPlane2_2:Rotate(ang)

			local cpos = Vector(pos2)
			cpos.z = cpos.z - 13
			clipPlane2_1Plane = clipPlane2_1:Dot(cpos)
			clipPlane2_2Plane = clipPlane2_2:Dot(cpos)
			cpos.z = cpos.z + 10
			clipPlane2_3Plane = clipPlane2_1:Dot(cpos)

			pos.x = pos.x - cos * sincosalign_boat
			pos.y = pos.y - sin * sincosalign_boat
		else
			pos.x = pos.x - cos * sincosalign_vehicle
			pos.y = pos.y - sin * sincosalign_vehicle
		end

		pos2.z = pos2.z - 8
		clipPlaneDot = clipPlane:Dot(pos2)
	else
		clipPlane = clipPlaneStraight
		local offset, duck = ply:GetViewOffset(), ply:GetViewOffsetDucked()

		if ply:Crouching() and ply:OnGround() then
			local target = Vector(duck.x, duck.y, duck.z * 1.5)
			duck_offset_hack = LerpVector(delta, duck_offset_hack, target)

			if duck_offset_hack:Length() > 10000 then
				-- wtf gmod?
				duck_offset_hack = target
			end
		else
			duck_offset_hack = LerpVector(delta, duck_offset_hack, offset)

			if duck_offset_hack:Length() > 10000 then
				-- wtf gmod?
				duck_offset_hack = offset
			end
		end

		pos:Sub(duck_offset_hack)
		yaw = ang.y - ply:GetPoseParameter('head_yaw') * 180 + 90

		local sin, cos = yaw:rad():sin(), yaw:rad():cos()
		pos.x = pos.x - cos * sincosalign
		pos.y = pos.y - sin * sincosalign
		pos.z = pos.z + 7

		clipPlaneDot = clipPlane:Dot(pos2)
	end

	DLibLegsModel:SetPos(pos)
	local fang = Angle(pitch, yaw, roll)
	DLibLegsModel:SetAngles(fang)

	DLibLegsModel2:SetPos(posFor2 or pos)
	DLibLegsModel2:SetAngles(angFor2 or fang)
end

local function Draw()
	if shouldDrawSecond then
		local oldClip

		if shouldClip then
			oldClip = render.EnableClipping(true)
			render.PushCustomClipPlane(clipPlane2_1, clipPlane2_1Plane)
		end

		DLibLegsModel:DrawModel()

		if shouldClip then
			render.PopCustomClipPlane()
			render.PushCustomClipPlane(clipPlane2_1, clipPlane2_3Plane)
			render.PushCustomClipPlane(clipPlane2_2, clipPlane2_2Plane)
		end

		DLibLegsModel2:DrawModel()

		if shouldClip then
			render.PopCustomClipPlane()
			render.PopCustomClipPlane()
			render.EnableClipping(oldClip)
		end
	else
		local oldClip

		if shouldClip then
			oldClip = render.EnableClipping(true)
			render.PushCustomClipPlane(clipPlane, clipPlaneDot)
		end

		DLibLegsModel:DrawModel()

		if shouldClip then
			render.PopCustomClipPlane()
			render.EnableClipping(oldClip)
		end
	end
end

local function UpdatePoseParams(ply)
	DLibLegsModel:SetPoseParameter('move_x',       (ply:GetPoseParameter('move_x')     * 2) 	- 1)
	DLibLegsModel:SetPoseParameter('move_y',       (ply:GetPoseParameter('move_y')     * 2) 	- 1)
	DLibLegsModel:SetPoseParameter('move_yaw',     (ply:GetPoseParameter('move_yaw')   * 360) 	- 180)
	DLibLegsModel:SetPoseParameter('body_yaw',     (ply:GetPoseParameter('body_yaw')   * 180) 	- 90)
	DLibLegsModel:SetPoseParameter('spine_yaw',    (ply:GetPoseParameter('spine_yaw')  * 180) 	- 90)
	DLibLegsModel:SetPoseParameter('vehicle_steer', ply:GetPoseParameter('vehicle_steer'))

	DLibLegsModel2:SetPoseParameter('move_x',       (ply:GetPoseParameter('move_x')     * 2) 	- 1)
	DLibLegsModel2:SetPoseParameter('move_y',       (ply:GetPoseParameter('move_y')     * 2) 	- 1)
	DLibLegsModel2:SetPoseParameter('move_yaw',     (ply:GetPoseParameter('move_yaw')   * 360) 	- 180)
	DLibLegsModel2:SetPoseParameter('body_yaw',     (ply:GetPoseParameter('body_yaw')   * 180) 	- 90)
	DLibLegsModel2:SetPoseParameter('spine_yaw',    (ply:GetPoseParameter('spine_yaw')  * 180) 	- 90)
	DLibLegsModel2:SetPoseParameter('vehicle_steer', ply:GetPoseParameter('vehicle_steer'))
end

local lastAnimUpdate = 0
local LEG_ANIM_SPEED_CONST = 1
local lastSequence

local function UpdateAnimation(ply)
	local ctime = CurTime()
	DLibLegsModel:FrameAdvance(ctime - lastAnimUpdate)
	DLibLegsModel:SetPlaybackRate(LEG_ANIM_SPEED_CONST * ply:GetPlaybackRate())

	DLibLegsModel2:FrameAdvance(ctime - lastAnimUpdate)
	DLibLegsModel2:SetPlaybackRate(LEG_ANIM_SPEED_CONST * ply:GetPlaybackRate())

	lastAnimUpdate = ctime
	local sequence = ply:GetSequence()

	if sequence ~= lastSequence then
		lastSequence = sequence
		DLibLegsModel:ResetSequence(sequence)
		DLibLegsModel2:ResetSequence(sequence)
	end
end

-- 0	ValveBiped.Bip01_Pelvis
-- 1	ValveBiped.Bip01_Spine
-- 2	ValveBiped.Bip01_Spine1
-- 3	ValveBiped.Bip01_Spine2
-- 4	ValveBiped.Bip01_Spine4
-- 5	ValveBiped.Bip01_Neck1
-- 6	ValveBiped.Bip01_Head1
-- 7	ValveBiped.forward
-- 8	ValveBiped.Bip01_R_Clavicle
-- 9	ValveBiped.Bip01_R_UpperArm
-- 10	ValveBiped.Bip01_R_Forearm
-- 11	ValveBiped.Bip01_R_Hand
-- 12	ValveBiped.Anim_Attachment_RH
-- 13	ValveBiped.Bip01_L_Clavicle
-- 14	ValveBiped.Bip01_L_UpperArm
-- 15	ValveBiped.Bip01_L_Forearm
-- 16	ValveBiped.Bip01_L_Hand
-- 17	ValveBiped.Anim_Attachment_LH
-- 18	ValveBiped.Bip01_R_Thigh
-- 19	ValveBiped.Bip01_R_Calf
-- 20	ValveBiped.Bip01_R_Foot
-- 21	ValveBiped.Bip01_L_Thigh
-- 22	ValveBiped.Bip01_L_Calf
-- 23	ValveBiped.Bip01_L_Foot
-- 24	ValveBiped.Bip01_R_Thigh_Jiggle
-- 25	ValveBiped.Bip01_L_Thigh_Jiggle
-- 26	ValveBiped.Bip01_R_Finger0
-- 27	ValveBiped.Bip01_R_Finger01
-- 28	ValveBiped.Bip01_R_Finger02
-- 29	ValveBiped.Bip01_R_Finger1
-- 30	ValveBiped.Bip01_R_Finger11
-- 31	ValveBiped.Bip01_R_Finger12
-- 32	ValveBiped.Bip01_R_Finger2
-- 33	ValveBiped.Bip01_R_Finger21
-- 34	ValveBiped.Bip01_R_Finger22
-- 35	ValveBiped.Bip01_R_Finger3
-- 36	ValveBiped.Bip01_R_Finger31
-- 37	ValveBiped.Bip01_R_Finger32
-- 38	ValveBiped.Bip01_R_Finger4
-- 39	ValveBiped.Bip01_R_Finger41
-- 40	ValveBiped.Bip01_R_Finger42
-- 41	ValveBiped.Bip01_L_Finger0
-- 42	ValveBiped.Bip01_L_Finger01
-- 43	ValveBiped.Bip01_L_Finger02
-- 44	ValveBiped.Bip01_L_Finger1
-- 45	ValveBiped.Bip01_L_Finger11
-- 46	ValveBiped.Bip01_L_Finger12
-- 47	ValveBiped.Bip01_L_Finger2
-- 48	ValveBiped.Bip01_L_Finger21
-- 49	ValveBiped.Bip01_L_Finger22
-- 50	ValveBiped.Bip01_L_Finger3
-- 51	ValveBiped.Bip01_L_Finger31
-- 52	ValveBiped.Bip01_L_Finger32
-- 53	ValveBiped.Bip01_L_Finger4
-- 54	ValveBiped.Bip01_L_Finger41
-- 55	ValveBiped.Bip01_L_Finger42
-- 56	ValveBiped.Bip01_R_Toe0
-- 57	ValveBiped.Bip01_L_Toe0

local spine4_stretch = Vector(200, -60, 0)
local spine4_stretch_veh = Vector(20, -10, 0)

local function UpdateBones(ply)
	for boneid = 0, ply:GetBoneCount() - 1 do
		DLibLegsModel:ManipulateBonePosition(boneid, ply:GetManipulateBonePosition(boneid))
		DLibLegsModel:ManipulateBoneAngles(boneid, ply:GetManipulateBoneAngles(boneid))
		DLibLegsModel:ManipulateBoneScale(boneid, ply:GetManipulateBoneScale(boneid))
		DLibLegsModel2:ManipulateBonePosition(boneid, ply:GetManipulateBonePosition(boneid))
		DLibLegsModel2:ManipulateBoneAngles(boneid, ply:GetManipulateBoneAngles(boneid))
		DLibLegsModel2:ManipulateBoneScale(boneid, ply:GetManipulateBoneScale(boneid))
	end

	-- stretch bones anyway lol
	if not IsValid(ply:GetActiveWeapon()) or not shouldClip then return end
	local findBone = ply:LookupBone('ValveBiped.Bip01_Spine4')
	if not findBone or findBone < 0 then return end

	DLibLegsModel:ManipulateBonePosition(findBone, ply:InVehicle() and spine4_stretch_veh or spine4_stretch)
end

local function UpdateBodygroups(ply)
	for _, group in ipairs(ply:GetBodyGroups()) do
		local bg = ply:GetBodygroup(group.id)

		if DLibLegsModel:GetBodygroup(group.id) ~= bg then
			DLibLegsModel:SetBodygroup(group.id, bg)
		end

		if DLibLegsModel2:GetBodygroup(group.id) ~= bg then
			DLibLegsModel2:SetBodygroup(group.id, bg)
		end
	end
end

local lastPly

local function Think()
	local ply = DLib.HUDCommons.SelectPlayer()

	if not IsValid(ply) or ply.IsPony and ply:IsPony() then
		if IsValid(DLibLegsModel) then
			DLibLegsModel:Remove()
		end

		if IsValid(DLibLegsModel2) then
			DLibLegsModel2:Remove()
		end

		return
	end

	if lastPly ~= ply or not IsValid(DLibLegsModel) or not IsValid(DLibLegsModel2) or lastModel ~= ply:GetModel() then
		CreateNewLegs(ply)
		lastPly = ply
		return
	end

	MoveModel(ply, false)
	UpdatePoseParams(ply)
	UpdateBones(ply)

	if FrameNumber() % 66 == 0 then
		UpdateBodygroups(ply)
	end
end

local function PostDrawTranslucentRenderables(a, b)
	if a or b then return end
	if not IsValid(DLibLegsModel) then return end

	local ply = DLib.HUDCommons.SelectPlayer()

	if ply == LocalPlayer() and ply:ShouldDrawLocalPlayer() or not ply:Alive() then return end

	UpdateAnimation(ply)
	local ang = EyeAngles()
	local vehicle = ply:InVehicle()

	if vehicle then
		MoveModel(ply, false)
	end

	if vehicle or ang.p > 25 or not IsValid(ply:GetActiveWeapon()) and ang.p > 0 then
		Draw()
	end
end

hook.Add('Think', 'DLib_Legs', Think)
hook.Add('PostDrawTranslucentRenderables', 'DLib_Legs', PostDrawTranslucentRenderables)
