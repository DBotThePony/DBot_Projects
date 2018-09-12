
--Player HUD Icon

--[[
Copyright (C) 2016-2018 DBot


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

]]

local ENABLE = CreateConVar('dhud_playericon', '1', FCVAR_ARCHIVE, 'Enable player icon')
DHUD2.AddConVar('dhud_playericon', 'Enable player icon', ENABLE)

if IsValid(DHUD2.PlayerIconModel) then
	DHUD2.PlayerIconModel:Remove()
end

local Ang = Angle(-30, 90, -15)
local Pos = Vector(20, -40, -20)

local DAng = Angle(-30, 90, -15)
local DPos = Vector(20, -40, -20)

local LastFrame = 0

local debugwtite = Material("models/debug/debugwhite")

local drawPosition = Vector(50, 50, 50)
local drawLookAt = Vector(0, 0, 40)
local drawLookAt2 = Vector(20, 20, 40)
local drawAngles = (drawLookAt - drawPosition):Angle()

local function Create()
	if IsValid(DHUD2.PlayerIconModel) then
		DHUD2.PlayerIconModel:Remove()
	end

	local model = LocalPlayer():GetModel()
	DHUD2.PlayerIconModel = ClientsideModel(model, RENDERGROUP_BOTH)
	DHUD2.PlayerIconModel:SetNoDraw(true)
	DHUD2.PlayerIconModel.LastBonesSetup = 0
	DHUD2.PlayerIconModel.LastModel = model
end

local function Draw()
	if not ENABLE:GetBool() or not DHUD2.ServerConVar('playericon') then return end
	local ply = DHUD2.SelectPlayer()
	if not ply:Alive() or ply:GetNWBool('Spectator') then return end

	if not IsValid(DHUD2.PlayerIconModel) then
		Create()
	end

	cam.Start3D(drawPosition, drawAngles, 70, 0, ScrHL() - 200, 200, 200)

	render.SuppressEngineLighting(true)
	render.ModelMaterialOverride(debugwtite)
	render.ResetModelLighting(1, 1, 1)
	render.SetBlend(1)

	cam.IgnoreZ(true)

	local col = team.GetColor(ply:Team())
	render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)

	local ply = DHUD2.SelectPlayer()
	local drawAsShould = false
	local ent = DHUD2.PlayerIconModel

	if ply == LocalPlayer() and DHUD2.PredictedEntity ~= ply and IsValid(DHUD2.PredictedEntity) then
		ply = DHUD2.PredictedEntity
		drawAsShould = true
	end

	if not drawAsShould then
		drawPosition = Vector(50, 50, 50)
		drawAngles = (drawLookAt - drawPosition):Angle()
		Pos = DPos - Vector(DHUD2.ShiftX * .3 + DHUD2.GetDamageShift(), -DHUD2.ShiftX * .3 + DHUD2.GetDamageShift(), DHUD2.ShiftY * .5 + DHUD2.GetDamageShift())

		local lmodel = ply:GetModel()

		ent:SetAngles(Ang)
		ent:SetPos(Pos)

		if lmodel ~= ent.LastModel then
			ent.LastModel = lmodel
			ent:SetModel(lmodel)
		end

		if not IsValid(ent) then return end

		ent:SetPlaybackRate(1.5)

		ent:FrameAdvance(CurTimeL() - LastFrame)
		LastFrame = CurTimeL()

		local sq = ply:GetSequence()

		if ent.LastBonesSetup < CurTimeL() then
			if ent:GetModel() ~= ply:GetModel() then ent:SetModel(ply:GetModel()) end

			ent:SetMaterial(ply:GetMaterial())
			ent:SetSkin(ply:GetSkin())

			if not ent.IsPony or (ent.IsPony and not ent:IsPony()) then
				for boneId = 0, ent:GetBoneCount() do
					ent:ManipulateBoneScale(boneId, ply:GetManipulateBoneScale(boneId))
					ent:ManipulateBonePosition(boneId, ply:GetManipulateBonePosition(boneId))
				end
			else
				if PPM then
					PPM.RescaleModel(ent, ply.ponydata)
				end
			end

			for _, group in pairs(ply:GetBodyGroups()) do
				ent:SetBodygroup(group.id, ply:GetBodygroup(group.id))
			end

			ent.LastBonesSetup = CurTimeL() + 1
		end

		if sq ~= ent.LastSQ then
			ent.LastSQ = sq
			ent:SetSequence(sq)
		end

		ent:SetPoseParameter('move_x', ply:GetPoseParameter('move_x') * 2 - 1)
		ent:SetPoseParameter('move_y', ply:GetPoseParameter('move_y') * 2 - 1)
		ent:SetPoseParameter('move_yaw', ply:GetPoseParameter('move_yaw') * 360 - 180)
		ent:SetPoseParameter('body_yaw', ply:GetPoseParameter('body_yaw') * 180 - 90)
		ent:SetPoseParameter('spine_yaw', ply:GetPoseParameter('spine_yaw') * 180 - 90)
		ent:SetPoseParameter('head_yaw', ply:GetPoseParameter('head_yaw') * (-225) + 100)
		ent:SetPoseParameter('head_pitch', ply:GetPoseParameter('head_pitch') * 60 - 30)
		ent:SetPoseParameter('head_roll', ply:GetPoseParameter('head_roll') * 60 - 30)

		ent:DrawModel()
	else
		local oldPos = ply:GetPos()
		local shouldDraw = ply:GetNoDraw()
		local mins, maxs = ply:OBBMins(), ply:OBBMaxs()
		local dist = mins:Distance(maxs)
		local mult = dist / 50

		local rePosition = oldPos + drawLookAt2 * mult
		drawPosition = rePosition
		drawAngles = (oldPos - rePosition):Angle()

		ply:SetNoDraw(false)

		ply:DrawModel()

		ply:SetNoDraw(shouldDraw)
	end

	render.SuppressEngineLighting(false)
	render.ModelMaterialOverride()
	cam.IgnoreZ(false)

	cam.End3D()

	-- Fix Vector:ToScreen()
	cam.Start3D()
	cam.End3D()
end

DHUD2.DrawHook('playericon', Draw)

