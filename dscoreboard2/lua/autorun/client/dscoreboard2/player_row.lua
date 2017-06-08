
--
-- Copyright (C) 2016-2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

local board = DScoreBoard2

local PANEL = {}
DScoreBoard2.PLAYEROW_PANEL = PANEL

PANEL.DefaultVars = {
	health = 0,
	team = 0,
	maxhealth = 1,
	ping = 0,
	playtime = 0,
	nick = 'nick',
	teamname = 'teamname',
	kills = 0,
	deaths = 0,
	ratio = 0,
}

PANEL.DefaultFunctions = {
	health = 'Health',
	ping = 'Ping',
	maxhealth = 'GetMaxHealth',
	team = 'Team',
	nick = 'Nick',
	kills = 'Frags',
	deaths = 'Deaths',
}

PANEL.RIGHT = {
	'ping',
	'ratio',
	'deaths',
	'kills',
}

PANEL.DrawColor = Color(200, 200, 200)

function PANEL:Init()
	self.vars = table.Copy(self.DefaultVars)
	
	self:SetCursor('hand')
	
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)
	
	self:SetHeight(16)
	self.Neon = 0
	
	self.avatar = self:Add('DScoreBoard2_Avatar')
	self.avatar:Dock(LEFT)
	self.avatar:SetSize(16, 16)
	
	self.nick = self:Add('DScoreBoard2_SpecialLabel')
	self.nick:SetFont(DScoreBoard2.FONT_PLAYERINFO)
	self.nick:SetText('nick')
	self.nick:Dock(LEFT)
	self.nick:DockMargin(4, 0, 0, 0)
	self.nick:SetWidth(300)
	
	for k, v in pairs(self.RIGHT) do
		self[v] = self:Add('DScoreBoard2_SpecialLabel')
		self[v]:SetFont(DScoreBoard2.FONT_PLAYERINFO)
		self[v]:SetText(v)
		self[v]:Dock(RIGHT)
		self[v]:DockMargin(4, 0, 4, 0)
		self[v]:SetWidth(50)
	end
	
	self.health = self:Add('DScoreBoard2_SpecialLabel')
	self.health:SetFont(DScoreBoard2.FONT_PLAYERINFO)
	self.health:SetText('health')
	self.health:Dock(RIGHT)
	self.health:DockMargin(4, 0, 4, 0)
	self.health:SetWidth(80)
	
	self.teamname = self:Add('DScoreBoard2_SpecialLabel')
	self.teamname:SetFont(DScoreBoard2.FONT_PLAYERINFO)
	self.teamname:SetText('teamname')
	self.teamname:Dock(RIGHT)
	self.teamname:DockMargin(4, 0, 4, 0)
	self.teamname:SetWidth(100)
	
	self.flag = self:Add('DScoreBoard2_CountryFlag')
	self.flag:Dock(RIGHT)
	self.flag:DockMargin(4, 0, 4, 0)
end

function PANEL:Think()
	if not IsValid(self.ply) then
		board.Board:BuildPlayerList()
		return
	end
	
	local hovered = self:IsHovered()
	
	if hovered and not self.hovered then
		self:HoverStart()
		self.hovered = true
	elseif not hovered and self.hovered then
		self:HoverEnd()
		self.hovered = false
	end
	
	if hovered then
		self.Neon = math.Clamp(self.Neon + 130 * FrameTime(), 0, 50)
	else
		self.Neon = math.Clamp(self.Neon - 130 * FrameTime(), 0, 50)
	end
	
	self:UpdateVars()
	self:UpdatePanels()
end

local function DScoreBoard2_PlayerRowErr(err)
	print(err)
	print(debug.traceback())
end

function PANEL:SetPlayer(ply)
	self.ply = ply
	self.avatar:SetPlayer(ply, 32)
	self.avatar.dply = ply
	self.flag:SetPlayer(ply)
	
	xpcall(hook.Run, DScoreBoard2_PlayerRowErr, 'DScoreBoard2_PlayerRow', self, ply)
	self:Think()
end

function PANEL:UpdatePanels()
	local vars = self.vars
	
	for k, v in pairs(vars) do
		if self[k] then self[k]:SetText(v) end
	end
end

function PANEL:HoverStart()
	if not IsValid(self.Hover) then
		local hover = self:Add('DScoreBoard2_PlayerHover')
		self.Hover = hover
		hover.ROW = self
		hover:SetPlayer(self.ply)
	end
	
	self.Hover:DoShow()
	self.Hover:Think()
end

function PANEL:LeftClick()
	self.pnl:OpenPlayer(self.ply)
end

function PANEL:OnMousePressed(m)
	if m == MOUSE_LEFT then
		self:LeftClick()
	end
end

function PANEL:HoverEnd()
	if not IsValid(self.Hover) then
		local hover = self:Add('DScoreBoard2_PlayerHover')
		self.Hover = hover
		hover.ROW = self
		hover:SetPlayer(self.ply)
	end
	
	self.Hover:DoHide()
end

function PANEL:OnRemove()
	if IsValid(self.Hover) then
		self.Hover:Remove()
	end
end

function PANEL:UpdateVars()
	if not IsValid(self.ply) then return end
	local ply = self.ply
	local vars = self.vars
	
	for k, v in pairs(self.DefaultFunctions) do
		vars[k] = ply[v](ply)
	end
	
	if vars.deaths == 0 then
		vars.ratio = 1
	else
		vars.ratio = vars.kills / vars.deaths
	end
	
	vars.teamname = team.GetName(vars.team)
	self.DrawColor = team.GetColor(vars.team)
	
	if vars.ping == 0 then vars.ping = 'BOT' end
	
	hook.Run('DRUpdateUserLabels', self, ply, vars)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(self.DrawColor.r + self.Neon, self.DrawColor.g + self.Neon, self.DrawColor.b + self.Neon, self.DrawColor.a)
	draw.NoTexture()
	surface.DrawRect(0, 0, w, h)
end

vgui.Register('DScoreBoard2_PlayerRow', PANEL, 'EditablePanel')
