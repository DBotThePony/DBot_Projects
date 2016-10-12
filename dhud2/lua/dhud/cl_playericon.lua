
--Player HUD Icon

--[[
Copyright (C) 2016 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local ENABLE = CreateConVar('dhud_playericon', '1', FCVAR_ARCHIVE, 'Enable player icon')
DHUD2.AddConVar('dhud_playericon', 'Enable player icon', ENABLE)

local Ang = Angle(-30, 90, -15)
local Pos = Vector(20, -40, -20)

local DAng = Angle(-30, 90, -15)
local DPos = Vector(20, -40, -20)

local LastFrame = 0

local function LayoutEntity(self, ent)
	if not DHUD2.IsEnabled() then return false end
	if not ENABLE:GetBool() then return false end
	if not DHUD2.ServerConVar('playericon') then return false end
	if not IsValid(ent) then return end
	local ply = DHUD2.SelectPlayer()
	local lmodel = ply:GetModel()
	
	Pos = DPos - Vector(DHUD2.ShiftX * .3 + DHUD2.GetDamageShift(), -DHUD2.ShiftX * .3 + DHUD2.GetDamageShift(), DHUD2.ShiftY * .5 + DHUD2.GetDamageShift())
	
	ent:SetAngles(Ang)
	ent:SetPos(Pos)
	
	if lmodel ~= self.LastModel then
		self.LastModel = lmodel
		self:SetModel(lmodel)
	end
	
	if not IsValid(ent) then return end
	
	ent:SetPlaybackRate(1.5)
	
	self:RunAnimation()
	ent:FrameAdvance(CurTime() - LastFrame)
	LastFrame = CurTime()
	
	local sq = ply:GetSequence()
	
	if self.LastBonesSetup < CurTime() then
		if ent:GetModel() ~= ply:GetModel() then ent:SetModel(ply:GetModel()) end
		
		ent:SetMaterial(ply:GetMaterial())
		ent:SetSkin(ply:GetSkin())
		
		if not ent.IsPony or (ent.IsPony and not ent:IsPony()) then
			for boneId = 0, ent:GetBoneCount() do
				ent:ManipulateBoneScale(boneId, ply:GetManipulateBoneScale(boneId))
				ent:ManipulateBonePosition(boneId, ply:GetManipulateBonePosition(boneId))
			end
		else
			PPM.RescaleModel(ent, ply.ponydata)
		end
		
		for _, group in pairs(ply:GetBodyGroups()) do
			ent:SetBodygroup(group.id, ply:GetBodygroup(group.id))
		end
		
		self.LastBonesSetup = CurTime() + 1
	end
	
	if sq ~= self.LastSQ then
		self.LastSQ = sq
		ent:SetSequence(sq)
	end
	
	ent:SetPoseParameter("move_x", ply:GetPoseParameter("move_x") * 2 - 1)
	ent:SetPoseParameter("move_y", ply:GetPoseParameter("move_y") * 2 - 1)
	ent:SetPoseParameter("move_yaw", ply:GetPoseParameter("move_yaw") * 360 - 180)
	ent:SetPoseParameter("body_yaw", ply:GetPoseParameter("body_yaw") * 180 - 90)
	ent:SetPoseParameter("spine_yaw", ply:GetPoseParameter("spine_yaw") * 180 - 90)
	ent:SetPoseParameter("head_yaw", ply:GetPoseParameter("head_yaw") * (-225) + 100)
	ent:SetPoseParameter("head_pitch", ply:GetPoseParameter("head_pitch") * 60 - 30)
	ent:SetPoseParameter("head_roll", ply:GetPoseParameter("head_roll") * 60 - 30)
end

local debugwtite = Material("models/debug/debugwhite")

--Don't trust HUDShouldDraw
local IsDrawing = false

DHUD2.DrawHook('playericon', function()
	IsDrawing = true
end)

local function PreDrawModel(self, ent)
	local ply = DHUD2.SelectPlayer()
	if not (ply:Alive() and not ply:GetNWBool('Spectator') and hook.Run('HUDShouldDraw', 'CHudGMod') ~= false and IsDrawing) then return false end
	IsDrawing = false
	
	render.ModelMaterialOverride(debugwtite)
	render.ResetModelLighting(1, 1, 1)
	
	cam.IgnoreZ(true)
	self:SetColor(team.GetColor(ply:Team()))
	
	return true
end

local function PostDrawModel(self, ent)
	render.ModelMaterialOverride()
	cam.IgnoreZ(false)
end

local function Create()
	DHUD2.PlayerIconInit = true
	if IsValid(DHUD2.PlayerIconPanel) then DHUD2.PlayerIconPanel:Remove() end
	local panel = vgui.Create('EditablePanel')
	local model = panel:Add('DModelPanel')
	
	panel:SetSize(200, 200)
	DHUD2.PlayerIconPanel = panel
	DHUD2.PlayerModelPanel = model
	
	model:Dock(FILL)
	model.LayoutEntity = LayoutEntity
	model.PreDrawModel = PreDrawModel
	model.PostDrawModel = PostDrawModel
	
	local oldPaint = model.Paint
	
	function model:Paint(w, h)
		if not DHUD2.IsEnabled() then return end
		if not ENABLE:GetBool() then return end
		if not DHUD2.ServerConVar('playericon') then return end
		
		oldPaint(self, w, h)
		
		--Fix Vector():ToScreen()
		cam.Start3D()
		cam.End3D()
	end
	
	panel:SetPos(0, ScrH() - 200)
	
	local ply = DHUD2.SelectPlayer()
	local lmodel = ply:GetModel()
	model:SetModel(lmodel)
	model.LastModel = lmodel
	model.LastBonesSetup = 0
end

if not DHUD2.PlayerIconInit then
	timer.Simple(0, function()
		timer.Simple(30, function()
			timer.Simple(10, Create)
		end)
	end)
else
	timer.Simple(0, Create)
end
