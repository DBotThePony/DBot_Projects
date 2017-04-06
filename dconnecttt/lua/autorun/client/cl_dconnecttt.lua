
--[[
Copyright (C) 2016-2017 DBot

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

local DRAW_NOT_RESPONDING = CreateConVar('cl_dconn_draw', '1', {FCVAR_ARCHIVE}, 'Draw visual effect when player loses connection')
local DRAW_TIME = CreateConVar('cl_dconn_drawtime', '1', {FCVAR_ARCHIVE}, 'Draw time played on server')
local COLOR_R = CreateConVar('cl_dconn_r', '255', {FCVAR_ARCHIVE}, 'Red Channel')
local COLOR_G = CreateConVar('cl_dconn_g', '255', {FCVAR_ARCHIVE}, 'Green Channel')
local COLOR_B = CreateConVar('cl_dconn_b', '255', {FCVAR_ARCHIVE}, 'Blue Channel')
local COLOR_A = CreateConVar('cl_dconn_a', '255', {FCVAR_ARCHIVE}, 'Alpha Channel')
local POS_X = CreateConVar('cl_dconn_x', '0', {FCVAR_ARCHIVE}, 'X Position')
local POS_Y = CreateConVar('cl_dconn_y', '0', {FCVAR_ARCHIVE}, 'Y Position')

local BG_R = CreateConVar('cl_dconn_bg_r', '0', {FCVAR_ARCHIVE}, 'Red Channel')
local BG_G = CreateConVar('cl_dconn_bg_g', '0', {FCVAR_ARCHIVE}, 'Green Channel')
local BG_B = CreateConVar('cl_dconn_bg_b', '0', {FCVAR_ARCHIVE}, 'Blue Channel')
local BG_A = CreateConVar('cl_dconn_bg_a', '200', {FCVAR_ARCHIVE}, 'Alpha Channel')

local DISPLAY_NICKS = CreateConVar('sv_dconn_hoverdisplay', '1', {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, 'Display players nicks on hovering')

timer.Create('DConnecttt.PlayerTick', 1, 0, function()
	net.Start('DConnecttt.PlayerTick')
	net.SendToServer()
end)

net.Receive('DConnecttt.ChatPrint', function()
	chat.AddText(unpack(net.ReadTable()))
end)

local plyMeta = FindMetaTable('Player')

function plyMeta:TotalTimeConnected()
	return self:GetNWInt('DConnecttt_Total')
end

function plyMeta:SessionTime()
	return self:GetNWInt('DConnecttt_Session')
end

--UTime interface
function plyMeta:GetUTimeSessionTime()
	return self:SessionTime()
end

--???
function plyMeta:GetUTime()
	return self:TotalTimeConnected()
end
--???
function plyMeta:GetUTimeTotalTime()
	return self:TotalTimeConnected()
end
--???

function plyMeta:SetUTime()
	--Do nothing
end

function plyMeta:SetUTimeStart()
	--Do nothing
end

function plyMeta:GetUTimeStart()
	return self:GetNWFloat('DConnecttt_Join')
end

surface.CreateFont('DConnecttt.HUD', {
	font = 'Roboto',
	size = 12,
	weight = 500,
})

local function NiceTime(time)
	local seconds = time % 60
	time = time - seconds
	
	local minutes = time % (60 * 60)
	time = time - minutes
	
	local hours = time % (60 * 60 * 24)
	time = time - hours
	
	local days = time % (60 * 60 * 24 * 7)
	time = time - days
	
	local weeks = time % (60 * 60 * 24 * 7)
	time = time - weeks
	
	local str = ''
	
	if weeks ~= 0 then
		str = str .. ' ' .. weeks / (3600 * 24 * 7) .. ' weeks'
	end
	
	if days ~= 0 then
		str = str .. ' ' .. days / (3600 * 24) .. ' days'
	end
	
	if hours ~= 0 then
		str = str .. ' ' .. hours / 3600 .. ' hours'
	end
	
	if minutes ~= 0 then
		str = str .. ' ' .. minutes / 60 .. ' minutes'
	end
	
	if seconds ~= 0 then
		str = str .. ' ' .. seconds .. ' seconds'
	end
	
	return str
end

local function HUDPaint()
	if not DRAW_TIME:GetBool() then return end
	
	local stime = LocalPlayer():SessionTime()
	local ttime = LocalPlayer():TotalTimeConnected()
	
	local ent = LocalPlayer():GetEyeTrace().Entity
	local add = ''
	
	if DISPLAY_NICKS:GetBool() and IsValid(ent) and ent:IsPlayer() then
		local pstime = ent:SessionTime()
		local pttime = ent:TotalTimeConnected()
		local nick = ent:Nick()
		
		add = string.format('\n\n%s\'s session time: %s\n%s\'s total time: %s', nick, NiceTime(pstime), nick, NiceTime(pttime))
	end
	
	local text = 'Session time: ' .. NiceTime(stime) .. '\nTotal time: ' .. NiceTime(ttime) .. add
	surface.SetFont('DConnecttt.HUD')
	local w, h = surface.GetTextSize(text)
	
	surface.SetDrawColor(BG_R:GetInt(), BG_G:GetInt(), BG_B:GetInt(), BG_A:GetInt())
	surface.DrawRect(POS_X:GetInt() - 4, POS_Y:GetInt() - 2, w + 8, h + 4)
	
	draw.DrawText(text, 'DConnecttt.HUD', POS_X:GetInt(), POS_Y:GetInt(), Color(COLOR_R:GetInt(), COLOR_G:GetInt(), COLOR_B:GetInt(), COLOR_A:GetInt()))
end

local function Populate(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	
	local lab = Label('DConnecttt options')
	Panel:AddItem(lab)
	lab:SetDark(true)
	
	Panel:CheckBox('Draw visual effect when player loses connection', 'cl_dconn_draw')
	Panel:CheckBox('Draw time played on server', 'cl_dconn_drawtime')
	
	Panel:NumSlider('X Position of text', 'cl_dconn_x', 0, ScrW(), 1)
	Panel:NumSlider('Y Position of text', 'cl_dconn_y', 0, ScrH(), 1)
	
	local lab = Label('Text color')
	Panel:AddItem(lab)
	lab:SetDark(true)
	
	local mixer = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(mixer)
	mixer:SetConVarR('cl_dconn_r')
	mixer:SetConVarG('cl_dconn_g')
	mixer:SetConVarB('cl_dconn_b')
	mixer:SetConVarA('cl_dconn_a')
	
	local lab = Label('Background color')
	Panel:AddItem(lab)
	lab:SetDark(true)
	
	local mixer = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(mixer)
	mixer:SetConVarR('cl_dconn_bg_r')
	mixer:SetConVarG('cl_dconn_bg_g')
	mixer:SetConVarB('cl_dconn_bg_b')
	mixer:SetConVarA('cl_dconn_bg_a')
end

local disconnect = Material('icon16/disconnect.png')
local connect = Material('icon16/connect.png')
local currentmat = disconnect
local current = false
local lastchange = CurTime()

surface.CreateFont('DConnecttt.Disconnect', {
	font = 'Roboto',
	size = 72,
	weight = 800,
})

local function Draw(ply)
	local eyes = ply:EyePos()
	eyes.z = eyes.z + 20
	
	local delta = EyePos() - eyes
	local ang = delta:Angle()
	
	ang.p = 0
	ang.r = 0
	
	ang:RotateAroundAxis(ang:Right(), -90)
	ang:RotateAroundAxis(ang:Up(), 90)
	
	cam.Start3D2D(eyes, ang, 0.1)
	
	surface.DrawTexturedRect(0, 16, 32, 32)
	surface.DrawText('? Connection lost')
	
	cam.End3D2D()
end

local function PrePlayerDraw(ply)
	local delta = CurTime() - ply:GetNWFloat('DConnecttt.JoinTime', 0)
	
	if delta < 0 or delta >= 20 then return end
	local defaultMult = delta / 20
	local fast = ply:GetNWFloat('DConnecttt.FastInit', 0)
	
	local multToUse = 0
	
	if fast ~= 0 then
		local fastMult = (CurTime() - fast) / 4
		
		if fastMult > defaultMult then
			multToUse = fastMult
		else
			multToUse = defaultMult
		end
	else
		multToUse = defaultMult
	end
	
	if multToUse > 1 or multToUse < 0 then return end
	
	ply.DConnecttt_oldClipping = render.EnableClipping(true)
	ply.DConnecttt_Clip = true
	local getPos, eyePos = ply:GetPos(), ply:EyePos()
	local deltaZ = (eyePos.z - getPos.z) * 1.2
	
	local normal = Vector(0, 0, -1)
	local newPos = Vector(getPos.x, getPos.y, getPos.z + deltaZ * multToUse)
	local dot = normal:Dot(newPos)
	
	render.PushCustomClipPlane(normal, dot)
	
	local mins, maxs = ply:OBBMins(), ply:OBBMaxs()
	ply.DConnecttt_EffectEmmiter = ply.DConnecttt_EffectEmmiter or ParticleEmitter(newPos)
	local emitter = ply.DConnecttt_EffectEmmiter
	
	ply.DConnecttt_lastParticle = ply.DConnecttt_lastParticle or 0
	
	if ply.DConnecttt_lastParticle < RealTime() then
		ply.DConnecttt_lastParticle = RealTime() + 0.05
		local new = newPos + Vector(math.random(mins.x, maxs.x), math.random(mins.y, maxs.y), 0)
		
		local particle = emitter:Add('particle/fire', new)
		particle:SetColor(math.random(1, 255), math.random(1, 255), math.random(1, 255))
		particle:SetVelocity(Vector(math.random(mins.x, maxs.x), math.random(mins.y, maxs.y), math.random(mins.x, maxs.x)))
		particle:SetDieTime(3)
		particle:SetStartSize(math.random(1, 3))
		particle:SetEndSize(0)
		particle:SetGravity(Vector(0, 0, -10))
	end
end

local function PostPlayerDraw(ply)
	if ply.DConnecttt_Clip then
		render.PopCustomClipPlane()
		render.EnableClipping(ply.DConnecttt_oldClipping)
	end
end

local function PostDrawTranslucentRenderables(a, b)
	if a or b then return end
	if not DRAW_NOT_RESPONDING:GetBool() then return end
	
	if lastchange < CurTime() then
		current = not current
		lastchange = CurTime() + 2
		currentmat = current and connect or disconnect
	end
	
	surface.SetDrawColor(255, 255, 255)
	surface.SetTextColor(255, 0, 0)
	surface.SetTextPos(0, 0)
	surface.SetMaterial(currentmat)
	surface.SetFont('DConnecttt.Disconnect')
	
	for k, v in pairs(player.GetAll()) do
		if v:GetNWInt('DConnecttt_DeadTime') < 5 then continue end
		Draw(v)
	end
end

hook.Add('PostDrawTranslucentRenderables', 'DConnecttt.Draw', PostDrawTranslucentRenderables)
hook.Add('HUDPaint', 'DConnecttt.Draw', HUDPaint)
hook.Add('PrePlayerDraw', 'DConnecttt.Draw', PrePlayerDraw)
hook.Add('PostPlayerDraw', 'DConnecttt.Draw', PostPlayerDraw)

hook.Add('PopulateToolMenu', 'DConnecttt.Menus', function()
	spawnmenu.AddToolMenuOption('Utilities', 'User', 'DConnecttt.CVars', 'DConnecttt', '', '', Populate)
end)