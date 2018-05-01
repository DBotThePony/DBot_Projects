
--[[
Copyright (C) 2016-2018 DBot

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

local EFFECTS = CreateConVar('cl_dafk_zzz', '1', FCVAR_ARCHIVE, 'Draw ZZZ chars on the top of sleeping player')
local DISPLAY = CreateConVar('cl_dafk_screen', '1', FCVAR_ARCHIVE, 'Draw AFK time on screen')
local DISPLAY_CHAT = CreateConVar('cl_dafk_chat', '1', FCVAR_ARCHIVE, 'Display AFK messages in chat if server is allowing to do it.')
local TEXT = CreateConVar('cl_dafk_text', '1', FCVAR_ARCHIVE, 'Draw text on the top of sleeping player')
local CAMERA_HIDE = CreateConVar('cl_dafk_hide', '1', FCVAR_ARCHIVE, 'Stop drawing AFK effects when camera is deployed')
local FOCUS = CreateConVar('cl_dafk_focus', '1', FCVAR_ARCHIVE, 'Broadcast message whatever your game window is focused')

local freezeTimer = false
local freezeTime = 0
local fadeAt = 0

local function Receive()
	local ply = net.ReadEntity()
	local status = net.ReadBool()
	if not IsValid(ply) then return end

	local time

	if not status then
		time = net.ReadUInt(32)

		if ply == LocalPlayer() then
			freezeTimer = true
			fadeAt = CurTimeL() + 6
			freezeTime = time
		end
	end

	local message = ply:GenerateAFKMessage(status, time)

	if DISPLAY_CHAT:GetBool() and DAFK_SHOWNOTIFICATIONS:GetBool() then
		if DAFK_NOTIFYRADIUS:GetInt() <= 0 or ply:GetPos():Distance(LocalPlayer():GetPos()) <= DAFK_NOTIFYRADIUS:GetInt() then
			chat.AddText(unpack(message))
		else
			MsgC(unpack(message))
			MsgC('\n')
		end
	else
		MsgC(unpack(message))
		MsgC('\n')
	end
end

surface.CreateFont('DAFK.Text', {
	size = 40,
	font = 'Roboto',
	weight = 600,
	extended = true,
})

surface.CreateFont('DAFK.Zzz', {
	size = 72,
	font = 'Roboto',
	weight = 800,
})

surface.CreateFont('DAFK.Away', {
	size = 100,
	font = 'Roboto',
	weight = 500,
	extended = true,
})

local function GetEyePos(ply)
	local eyePos
	local EYES = ply:LookupAttachment('eyes')

	if EYES and EYES ~= 0 then
		local vec = ply:GetAttachment(EYES)
		eyePos = vec.Pos
		eyePos.z = eyePos.z + 40
	else
		eyePos = ply:EyePos()
		eyePos.z = eyePos.z + 40
	end

	return eyePos
end

local function Draw(ply)
	local time = ply:GetAFKTime()
	local eyePos = GetEyePos(ply)

	local lpos = EyePos()

	local delta = (eyePos - lpos):Angle()
	local ang = Angle(0, delta.y - 90, 90)
	local text = DLib.i18n.localize('player.dafk.status.afk', DLib.i18n.tformat(time))
	local add = Vector(-surface.GetTextSize(text) * .05, 0, 0)
	add:Rotate(ang)

	cam.Start3D2D(eyePos + add, ang, 0.1)
	surface.SetTextPos(0, 0)
	surface.DrawText(text)
	cam.End3D2D()
end

local function DrawTabbedOut(ply)
	local eyePos = GetEyePos(ply)

	local lpos = EyePos()

	local delta = (eyePos - lpos):Angle()
	local ang = Angle(0, delta.y - 90, 90)
	local text = DLib.i18n.localize('player.dafk.status.tabbed')
	local add = Vector(-surface.GetTextSize(text) * .05, 0, 0)
	add:Rotate(ang)

	cam.Start3D2D(eyePos + add, ang, 0.1)
	surface.SetTextPos(0, 0)
	surface.DrawText(text)
	cam.End3D2D()
end

local ZZZToDraw = {}

local function PostDrawTranslucentRenderables(a, b)
	if a or b then return end

	if CAMERA_HIDE:GetBool() then
		local can = hook.Run('HUDShouldDraw', 'CHudGMod')
		if can == false then return end
	end

	local lply = LocalPlayer()
	local eyes = EyePos()

	if TEXT:GetBool() then
		surface.SetTextPos(0, 0)
		surface.SetTextColor(255, 255, 255)
		surface.SetFont('DAFK.Text')

		for k, ply in ipairs(player.GetAll()) do
			if ply ~= lply and ply:Alive() and ply:GetPos():Distance(eyes) < 512 then
				if ply:IsAFK() then
					Draw(ply)
				elseif ply:IsTabbedOut() then
					DrawTabbedOut(ply)
				end
			end
		end
	end

	if EFFECTS:GetBool() then
		local toRemove = {}
		local cTime = CurTimeL()

		surface.SetTextPos(0, 0)
		surface.SetFont('DAFK.Zzz')

		for k, data in ipairs(ZZZToDraw) do
			if data.fade < cTime then
				table.insert(toRemove, k)
			else
				local percent = math.min((data.fade - cTime) / 1.5, 1)
				local percent2 = math.min((data.fade - cTime) / 3, 1)

				data.vel.z = data.vel.z + FrameTime() * math.random() * 3
				data.vel.x = data.vel.x * .95 + math.random() - 0.5
				data.vel.y = data.vel.y * .95 + math.random() - 0.5

				data.pos = data.pos + data.vel * FrameTime() * 1.5

				surface.SetTextColor(255, 255, 255, percent * 255)
				local ang1 = (data.pos - eyes):Angle()
				local ang = Angle(0, ang1.y - 90, 90)

				cam.Start3D2D(data.pos, ang, (.3 - percent2 * .3))
				surface.SetTextPos(0, 0)
				surface.DrawText('Z')
				cam.End3D2D()
			end
		end

		for i = #toRemove, 1, -1 do
			table.remove(ZZZToDraw, toRemove[i])
		end
	end
end

local function Zzz(ply)
	local data = {}
	data.pos = GetEyePos(ply)
	data.pos.z = data.pos.z - 20
	data.vel = VectorRand() * 5
	data.vel.z = 4
	data.fade = CurTimeL() + 3

	table.insert(ZZZToDraw, data)
end

local LastHasFocus

local function Timer()
	local focus

	if FOCUS:GetBool() then
		focus = system.HasFocus()
	else
		focus = true
	end

	if LastHasFocus ~= focus then
		net.Start('DAFK.HasFocus')
		net.WriteBool(focus)
		net.SendToServer()
		LastHasFocus = focus
	end

	if CAMERA_HIDE:GetBool() then
		local can = hook.Run('HUDShouldDraw', 'CHudGMod')
		if can == false then return end
	end

	local lply = LocalPlayer()

	for k, ply in ipairs(player.GetAll()) do
		if ply ~= lply and ply:Alive() and ply:IsAFK() then
			timer.Create('DAFK.ZZZ.' .. ply:SteamID(), 0.4, 4, function()
				if not IsValid(ply) then return end
				if not ply:Alive() then return end
				Zzz(ply)
			end)
		end
	end
end

local function PostDrawHUD()
	if not DISPLAY:GetBool() then return end
	if not LocalPlayer():IsValid() then return end
	if not freezeTimer and not LocalPlayer():IsAFK() then return end

	if pace and pace.IsActive() then return end
	local time = freezeTimer and freezeTime or LocalPlayer():GetAFKTime()
	local w, h = ScrWL(), ScrHL()

	surface.SetFont('DAFK.Away')
	local percent = (fadeAt - CurTimeL()) / 6

	if not freezeTimer then
		surface.SetTextColor(255, 255, 255)
		surface.SetDrawColor(0, 0, 0, 150)
	else
		surface.SetTextColor(255, 255, 255, percent * 255)
		surface.SetDrawColor(0, 0, 0, 150 * percent)

		if percent <= 0 then
			freezeTimer = false
			return
		end
	end

	local x, y = w / 2, 200
	local str = DLib.i18n.tformat(time)
	local awayfor = DLib.i18n.localize('player.dafk.status.awayfor')

	local tX, tY = surface.GetTextSize(awayfor)
	local tX2, tY2 = surface.GetTextSize(str)

	surface.DrawRect(x - math.max(tX, tX2) / 2 - 20, y - 20, math.max(tX, tX2) + 20, tY * 2 + 30)

	surface.SetTextPos(x - tX / 2, y)
	surface.DrawText(awayfor)

	surface.SetTextPos(x - tX2 / 2, y + tY + 10)
	surface.DrawText(str)
end

local LastMouseBeat = 0

local function Think()
	if not system.HasFocus() then return end
	if LastMouseBeat > RealTimeL() then return end

	local cond = input.IsMouseDown(MOUSE_LEFT) or
		input.IsMouseDown(MOUSE_RIGHT) or
		input.IsMouseDown(MOUSE_MIDDLE)

	if cond then
		LastMouseBeat = RealTimeL() + 1
		net.Start('DAFK.Heartbeat')
		net.SendToServer()
	end
end

local function PopulateClient(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()

	local lab = Label('gui.dafk.menu.about')
	Panel:AddItem(lab)
	lab:SetDark(true)

	Panel:CheckBox('gui.dafk.menu.cl_dafk_zzz', 'cl_dafk_zzz')
	Panel:CheckBox('gui.dafk.menu.cl_dafk_screen', 'cl_dafk_screen')
	Panel:CheckBox('gui.dafk.menu.cl_dafk_chat', 'cl_dafk_chat')
	Panel:CheckBox('gui.dafk.menu.cl_dafk_text', 'cl_dafk_text')
	Panel:CheckBox('gui.dafk.menu.cl_dafk_hide', 'cl_dafk_hide')
	Panel:CheckBox('gui.dafk.menu.cl_dafk_focus', 'cl_dafk_focus'):SizeToContents()

	local button = Panel:Button('Steam Workshop')
	button.DoClick = function()
		gui.OpenURL('steamcommunity.com/sharedfiles/filedetails/?id=768912833')
	end

	local button = Panel:Button('BitBucket')
	button.DoClick = function()
		gui.OpenURL('https://bitbucket.org/DBotThePony/dafk')
	end
end

local Hooks = {
	'StartChat',
	'FinishChat',
	'OnChatTab',
	'KeyPress',
	'ScoreboardShow',
	'ScoreboardHide',
	'PlayerBindPress',
}

local function HookFunc()
	net.Start('DAFK.Heartbeat')
	net.SendToServer()
end

local function HasFocus()
	local ply = net.ReadEntity()
	local status = net.ReadBool()

	ply.__DAFK_TabbedOut = not status
end

for k, v in ipairs(Hooks) do
	hook.Add(v, 'DAFK.Heartbeat', HookFunc)
end

net.Receive('DAFK.HasFocus', HasFocus)
net.Receive('DAFK.StatusChanges', Receive)
hook.Add('PostDrawTranslucentRenderables', 'DAFK.Hooks', PostDrawTranslucentRenderables)
hook.Add('PostDrawHUD', 'DAFK.Hooks', PostDrawHUD)
hook.Add('Think', 'DAFK.Hooks', Think)
hook.Add('PopulateToolMenu', 'DAFK.Hooks', function()
	spawnmenu.AddToolMenuOption('Utilities', 'User', 'DAFK', 'DAFK', '', '', PopulateClient)
end)

timer.Create('DAFK.ZZZ', 4, 0, Timer)
