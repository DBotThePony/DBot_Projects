
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

local ENABLE = CreateConVar('dhud_voice', '1', FCVAR_ARCHIVE, 'Enable custom voice panel')
DHUD2.AddConVar('dhud_voice', 'Enable custom voice panel', ENABLE)

DHUD2.VoicePanels = DHUD2.VoicePanels or {}
local VoicePanel = DHUD2.VoicePanel
local VoicePanels = DHUD2.VoicePanels

if IsValid(VoicePanel) then
	VoicePanel:Remove()
end

DHUD2.PlayerStartVoice = DHUD2.PlayerStartVoice or GAMEMODE.PlayerStartVoice
DHUD2.PlayerEndVoice = DHUD2.PlayerEndVoice or GAMEMODE.PlayerEndVoice

DHUD2.DefinePosition('voice', ScrW() - 300, 100)
DHUD2.CreateColor('voice_wave', 'Voice Waves', 27, 160, 218, 255)

surface.CreateFont('DHUD2.Voice', {
	font = 'Roboto',
	size = 18,
	weight = 500,
	extended = true
})

local PANEL = {}

function PANEL:Init()
	self.Waves = {}

	for i = 1, 50 do
		table.insert(self.Waves, 0)
	end

	self.Avatar = vgui.Create('AvatarImage', self)
	self.Avatar:Dock(LEFT)
	self.Avatar:DockMargin(4, 4, 4, 4)
	self.Avatar:SetSize(32, 32)

	self.Nick = vgui.Create('DLabel', self)
	self.Nick:Dock(FILL)
	self.Nick:DockMargin(10, 0, 0, 0)
	self.Nick:SetFont('DHUD2.Voice')
	self.Nick:SetText('Sample Text')

	self.IsFadingOut = false
	self.FadeAt = 0

	self:Dock(BOTTOM)
	self:SetHeight(40)
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
end

function PANEL:SetPlayer(ply)
	self.ply = ply
	self.Avatar:SetPlayer(ply, 32)
	self.col = team.GetColor(ply:Team())

	self.col.r = self.col.r * .6
	self.col.g = self.col.g * .6
	self.col.b = self.col.b * .6
end

function PANEL:Think()
	if not IsValid(self.ply) then self:Remove() return end
	if not ENABLE:GetBool() then self:Remove() return end
	if not DHUD2.ServerConVar('voice') then self:Remove() return end

	self.Nick:SetText(self.ply:Nick())

	if self.IsFadingOut then
		table.insert(self.Waves, 0)
		local coff = self.FadeAt - RealTime()
		self:SetAlpha(coff * 127)

		if coff <= 0 then
			self:Remove()
		end
	else
		table.insert(self.Waves, self.ply:VoiceVolume())

		if #self.Waves > 150 then -- gc
			local new = {}

			for i = #self.Waves - 60, #self.Waves do
				table.insert(new, self.Waves[i])
			end

			self.Waves = new
		end

		self:SetAlpha(255)
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(self.col.r, self.col.g, self.col.b, 175)
	surface.DrawRect(0, 0, w, h)

	local waveColor = DHUD2.GetColor('voice_wave')
	surface.SetDrawColor(waveColor)
	local hh = h / 2

	local int = 0

	for i = #self.Waves, math.max(#self.Waves - 60, 1), -1 do
		local cc = self.Waves[i] * 40

		surface.DrawRect(40 + int * 6, hh - cc / 2, 4, cc)
		int = int + 1
	end
end

vgui.Register('DHUD2Voice', PANEL)

local function BuildVoicePanel()
	if IsValid(VoicePanel) then
		VoicePanel:Remove()
	end

	if IsValid(DHUD2.VoicePanel) then
		DHUD2.VoicePanel:Remove()
	end

	VoicePanel = vgui.Create('EditablePanel')
	DHUD2.VoicePanel = VoicePanel
	VoicePanel:KillFocus()
	VoicePanel:SetRenderInScreenshots(false)
	VoicePanel:SetMouseInputEnabled(false)
	VoicePanel:SetKeyboardInputEnabled(false)
	VoicePanel:ParentToHUD()
	VoicePanel:SetPos(DHUD2.GetPosition('voice'))
	VoicePanel:SetSize(250, ScrH() - 350)
	VoicePanel.Think = function() VoicePanel:SetPos(DHUD2.GetPosition('voice')) end
end

local function Check()
	if IsValid(VoicePanel) then
		return
	end

	BuildVoicePanel()

	if not IsValid(VoicePanel) then
		error('WTF')
	end
end

timer.Simple(0, BuildVoicePanel)

local PlayerStartVoice
local PlayerEndVoice

local function Draw()
	if not ENABLE:GetBool() or not DHUD2.ServerConVar('voice') then return end
	if not IsValid(LocalPlayer()) then return end
	if not LocalPlayer().DHUD2Talk then return end

	local ctime = RealTime()

	local funcs = {
		math.sin(ctime + ctime % 3) * 6,
		math.cos(ctime / 4) * 20,
		math.sin(ctime + math.cos(ctime)) * 12,
		math.cos(ctime + math.sin(ctime)) * 15,
		math.cos(ctime) * 10,
		math.cos(ctime / 1.5) * 15,
		math.cos(ctime + 1) * 13,
		math.cos(ctime * 2) * 20,
		math.cos(ctime * 3) * 6,
		math.sin(ctime + 4) * 18,
		math.sin(ctime - 2) * 14,
		math.cos(ctime / 2) * 40,
	}

	local cnt = #funcs

	surface.SetDrawColor(DHUD2.GetColor('voice_wave'))
	local x, y = DHUD2.GetPosition('voice')
	y = y + ScrH() - 370

	for i, val in ipairs(funcs) do
		val = math.abs(val)
		surface.DrawRect(x + i * 5 - cnt * 5 - 20, y - val / 2, 4, val)
	end
end

function PlayerStartVoice(_, ply)
	if not DHUD2.ServerConVar('voice') then -- Oops
		return DHUD2.PlayerStartVoice(_, ply)
	end

	if ply == LocalPlayer() then
		ply.DRPIsTalking = true -- DarkRP support
		-- But why DRPIsTalking is still used?
		-- DarkRP should really use PlayerStartVoice and PlayerEndVoice hooks instead
		ply.DHUD2Talk = true

		return
	end

	Check()

	if not IsValid(VoicePanels[ply]) then
		local pnl = vgui.Create('DHUD2Voice', VoicePanel)
		VoicePanels[ply] = pnl
		pnl:SetPlayer(ply)
	else
		VoicePanels[ply].IsFadingOut = false
	end
end

function PlayerEndVoice(_, ply)
	if not DHUD2.ServerConVar('voice') then -- Oops
		return DHUD2.PlayerEndVoice(_, ply)
	end

	if ply == LocalPlayer() then
		ply.DRPIsTalking = false -- DarkRP support
		-- But why DRPIsTalking is still used?
		-- DarkRP should really use PlayerStartVoice and PlayerEndVoice hooks instead
		ply.DHUD2Talk = false

		return
	end

	Check()

	if IsValid(VoicePanels[ply]) then
		VoicePanels[ply].IsFadingOut = true
		VoicePanels[ply].FadeAt = RealTime() + 2
	end
end

local function Update()
	if ENABLE:GetBool() and DHUD2.ServerConVar('voice') then
		timer.Stop('VoiceClean')
		GAMEMODE.PlayerStartVoice = PlayerStartVoice
		GAMEMODE.PlayerEndVoice = PlayerEndVoice
	else
		timer.Start('VoiceClean')
		GAMEMODE.PlayerStartVoice = DHUD2.PlayerStartVoice
		GAMEMODE.PlayerEndVoice = DHUD2.PlayerEndVoice
	end
end

cvars.AddChangeCallback('dhud_voice', Update, 'DHUD2.Voice')

Update()

DHUD2.DrawHook('voice', Draw)
