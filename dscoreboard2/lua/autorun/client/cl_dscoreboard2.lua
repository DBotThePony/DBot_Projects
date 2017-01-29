
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

DScoreBoard2 = DScoreBoard2 or {}
local board = DScoreBoard2
board.SHOW_AUTHOR = CreateConVar('dscoreboard_showauthor', '1', FCVAR_ARCHIVE, 'Show DScoreBoard/2 author')

local Colors = {
	bg = Color(0, 0, 0, 150),
	textcolor = Color(255, 255, 255, 255),
}

local plyMeta = FindMetaTable('Player')

function plyMeta:DBoardNick()
	return self:Nick() .. (self.SteamName and (' (Steam Name: ' .. self:SteamName() .. ')') or '')
end

board.Colors = Colors

for k, v in pairs(Colors) do
	local r = CreateConVar('cl_dboard_color_' .. k .. '_r', v.r, FCVAR_ARCHIVE, 'Sets ' .. k .. ' color red channel')
	local g = CreateConVar('cl_dboard_color_' .. k .. '_g', v.g, FCVAR_ARCHIVE, 'Sets ' .. k .. ' color green channel')
	local b = CreateConVar('cl_dboard_color_' .. k .. '_b', v.b, FCVAR_ARCHIVE, 'Sets ' .. k .. ' color blue channel')
	local a = CreateConVar('cl_dboard_color_' .. k .. '_a', v.a, FCVAR_ARCHIVE, 'Sets ' .. k .. ' color alpha channel')
	
	local function update()
		Colors[k] = Color(r:GetInt(), g:GetInt(), b:GetInt(), a:GetInt())
	end
	
	cvars.AddChangeCallback('cl_dboard_color_' .. k .. '_r', update, 'DScoreBoard2')
	cvars.AddChangeCallback('cl_dboard_color_' .. k .. '_g', update, 'DScoreBoard2')
	cvars.AddChangeCallback('cl_dboard_color_' .. k .. '_b', update, 'DScoreBoard2')
	cvars.AddChangeCallback('cl_dboard_color_' .. k .. '_a', update, 'DScoreBoard2')
end

function board.GetPlayerCountry(ply)
	if ply == LocalPlayer() then return system.GetCountry() end
	return ply.DSCOREBOARD_FLAG or 'Unknown'
end

local FONT_SERVERTITLE = 'DScoreBoard2.ServerTitle'
local FONT_MOUSENOTIFY = 'DScoreBoard2.MouseNotify'
local FONT_TOPINFO = 'DScoreBoard2.TopInfoText'
local FONT_BOTTOMINFO = 'DScoreBoard2.BottomInfoText'
local FONT_PLAYERINFO = 'DScoreBoard2.PlayerInfoText'
local FONT_BUTTONFONT = 'DScoreBoard2.Button'
local FONT_RATING = 'DScoreBoard2.Ratings'

surface.CreateFont(FONT_SERVERTITLE, {
	font = 'Roboto',
	size = 50,
	extended = true,
	weight = 800,
})

surface.CreateFont(FONT_MOUSENOTIFY, {
	font = 'Roboto',
	size = 30,
	extended = true,
	weight = 500,
})

surface.CreateFont(FONT_TOPINFO, {
	font = 'Roboto',
	size = 16,
	extended = true,
	weight = 600,
})

surface.CreateFont(FONT_BOTTOMINFO, {
	font = 'Roboto',
	size = 13,
	extended = true,
	weight = 500,
})

surface.CreateFont(FONT_PLAYERINFO, {
	font = 'Roboto',
	size = 16,
	extended = true,
	weight = 500,
})

surface.CreateFont(FONT_BUTTONFONT, {
	font = 'Roboto',
	size = 16,
	extended = true,
	weight = 500,
})

surface.CreateFont(FONT_RATING, {
	font = 'Roboto',
	size = 12,
	extended = true,
	weight = 500,
})

local PANEL = {}

function PANEL:AvatarHide()
	self.havatar:SetVisible(false)
	self.havatar:KillFocus()
	self.havatar:SetMouseInputEnabled(false)
	self.havatar:SetKeyboardInputEnabled(false)
	self.havatar.hover = false
end

function PANEL:OnMousePressed(key)
	self.hover = true
	self.havatar:SetVisible(true)
	self.havatar:MakePopup()
	self.havatar:SetMouseInputEnabled(false)
	self.havatar:SetKeyboardInputEnabled(false)
	
	if IsValid(self.ply) and self.ply:IsBot() then return end
	
	if key == MOUSE_LEFT then
		if IsValid(self.ply) then
			gui.OpenURL('https://steamcommunity.com/profiles/' .. self.ply:SteamID64() .. '/')
		elseif self.steamid64 and self.steamid64 ~= '0' then
			gui.OpenURL('https://steamcommunity.com/profiles/' .. self.steamid64 .. '/')
		end
	end
end

function PANEL:Init()
	self:SetCursor('hand')
	
	local avatar = self:Add('AvatarImage')
	self.avatar = avatar
	avatar:Dock(FILL)
	
	local havatar = vgui.Create('AvatarImage')
	self.havatar = havatar
	havatar:SetVisible(false)
	havatar:SetSize(184, 184)
	
	hook.Add('DScoreBoard2_Hide', self, self.AvatarHide)
	
	self:SetMouseInputEnabled(true)
	avatar:SetMouseInputEnabled(false)
	avatar:SetKeyboardInputEnabled(false)
	havatar:SetMouseInputEnabled(false)
	havatar:SetKeyboardInputEnabled(false)
end

function PANEL:Think()
	if not IsValid(self.ply) and not self.steamid then return end
	local x, y = gui.MousePos()
	
	local hover = self:IsHovered()
	
	local w, h = ScrW(), ScrH()
	
	if x + 204 >= w then
		x = x - 214
	end
	
	if y + 204 >= h then
		y = y - 214
	end
	
	if hover then
		if not self.hover then
			self.hover = true
			self.havatar:SetVisible(true)
			self.havatar:MakePopup()
			self.havatar:SetMouseInputEnabled(false)
			self.havatar:SetKeyboardInputEnabled(false)
		end
		
		self.havatar:SetPos(x + 20, y + 10)
	else
		if self.hover then
			self.havatar:SetVisible(false)
			self.havatar:KillFocus()
			self.hover = false
		end
	end
end

function PANEL:SetPlayer(ply, size)
	self.ply = ply
	
	self.avatar:SetPlayer(ply, size)
	self.havatar:SetPlayer(ply, 184)
end

function PANEL:SetSteamID(steamid, size)
	local steamid64 = util.SteamIDTo64(steamid)
	self.steamid = steamid
	self.steamid64 = steamid64
	
	self.avatar:SetSteamID(steamid64, size)
	self.havatar:SetSteamID(steamid64, 184)
end

function PANEL:OnRemove()
	if IsValid(self.havatar) then
		self.havatar:Remove()
	end
end

vgui.Register('DScoreBoard2_Avatar', PANEL, 'EditablePanel')

local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
	self.BaseClass.Init(self)
	self:SetFont(FONT_SERVERTITLE)
	self:SetTextColor(Colors.textcolor)
	self._Text = ''
end

function PANEL:Think()
	local name = GetHostName()
	
	if self._Text ~= name then
		self:SetText(name)
		self:SizeToContents()
		self:DockMargin(15, 0, 0, 0)
	end
	
	self.BaseClass.Think(self)
end

vgui.Register('DScoreBoard2_ServerTitle', PANEL, 'DLabel')

local PANEL = {}

function PANEL:Init()
	self.BaseClass.Init(self)
	self:SetTextColor(color_white)
end

function PANEL:Paint(w, h)
	self.TSize = self.TSize or 0
	surface.SetDrawColor(Colors.bg)
	draw.NoTexture()
	surface.DrawRect(0, 0, self.TSize, h)
end

function PANEL:SetText(text)
	surface.SetFont(self:GetFont())
	self.TSize = surface.GetTextSize(' ' .. text .. ' ')
	self.BaseClass.SetText(self, ' ' .. text)
end

vgui.Register('DScoreBoard2_SpecialLabel', PANEL, 'DLabel')

local PANEL = {}
PANEL.Mat = Material('models/debug/debugwhite')

board.MAT_CACHE = board.MAT_CACHE or {}

function PANEL:Init()
	self:SetSize(23, 11)
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
	
	self.CurrentImage = ''
	self.FlagSetup = true
end

function PANEL:SetupFlag(code)
	local country = code or board.GetPlayerCountry(self.ply)
	
	if country == 'Unknown' then return end
	
	self.FlagSetup = true
	
	if board.MAT_CACHE[country] == nil then
		local path = string.lower(country)
		
		if not file.Exists('materials/flags16/' .. path .. '.png', 'GAME') then
			board.MAT_CACHE[country] = false
			return
		end
		
		board.MAT_CACHE[country] = Material('flags16/' .. path .. '.png')
	end
	
	if not board.MAT_CACHE[country] then return end
	
	self.Mat = board.MAT_CACHE[country]
end

function PANEL:Think()
	if not self.FlagSetup and IsValid(self.ply) then
		self:SetupFlag()
	end
end

function PANEL:SetPlayer(ply)
	self.FlagSetup = false
	self.ply = ply
	
	self:SetupFlag()
end

function PANEL:SetFlagCode(code)
	self.FlagSetup = false
	
	self:SetupFlag(code)
end

function PANEL:Paint(w, h)
	if not self.FlagSetup then
		surface.SetTextColor(color_white)
		surface.SetTextPos(0, 0)
		surface.SetFont(FONT_PLAYERINFO)
		surface.DrawText('???')
	else
		surface.SetDrawColor(color_white)
		surface.SetMaterial(self.Mat)
		surface.DrawTexturedRect(0, 0, w, h)
		draw.NoTexture()
	end
end

vgui.Register('DScoreBoard2_CountryFlag', PANEL, 'EditablePanel')

function board.GetSortedPlayerList()
	return player.GetAll()
end

local PANEL = {}

function PANEL:Init()
	self:SetSize(16, 28)
	self.count = 0
	self:SetCursor('hand')
end

function PANEL:SetPlayer(ply)
	self.ply = ply
	
	if self.ratingid then
		self.count = ply:GetNWInt('DScoreBoard2.Rating' .. self.ratingid)
	end
end

function PANEL:SetRating(id)
	self.ratingid = id
	self.rating = DScoreBoard2Ratings.Ratings[id]
	self.help = DScoreBoard2Ratings.Help[id]
	self.name = DScoreBoard2Ratings.Names[id]
	self.icon = DScoreBoard2Ratings.IconsCache[self.rating]
	
	self:SetTooltip(self.name .. '\n' .. self.help)
	
	if self.ply then
		self.count = self.ply:GetNWInt('DScoreBoard2.Rating' .. id)
	end
end

function PANEL:Think()
	if IsValid(self.ply) and self.ratingid then
		self.count = self.ply:GetNWInt('DScoreBoard2.Rating' .. self.ratingid)
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(Colors.bg)
	surface.DrawRect(0, 0, w, h)
	
	draw.DrawText(self.count, FONT_RATING, w / 2, 16, color_white, TEXT_ALIGN_CENTER)
	
	if self.icon then
		surface.SetMaterial(self.icon)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawTexturedRect(0, 0, 16, 16)
	end
end

function PANEL:OnMousePressed(id)
	if not IsValid(self.ply) then return end
	if id == MOUSE_LEFT then
		RunConsoleCommand('dscoreboard_rate', self.ply:UserID(), self.ratingid)
	end
end

vgui.Register('DScoreBoard2_RatingButton', PANEL, 'EditablePanel')

local PANEL = {}

function PANEL:Init()
	local grid = self:Add('DGrid')
	self.grid = grid
	grid:SetColWide(20)
	
	self.pnls = {}
	
	for k, v in pairs(DScoreBoard2Ratings.Ratings) do
		local rate = grid:Add('DScoreBoard2_RatingButton')
		rate:SetRating(k)
		grid:AddItem(rate)
		table.insert(self.pnls, rate)
	end
end

function PANEL:SetPlayer(ply)
	self.ply = ply
	
	for k, v in ipairs(self.pnls) do
		v:SetPlayer(ply)
	end
end

function PANEL:Resize()
	self.grid:SetCols(math.floor(self:GetWide() / 20))
end

vgui.Register('DScoreBoard2_Rating', PANEL, 'EditablePanel')

local PANEL = {}

PANEL.Panels = {
	'nick',
	'health',
	'maxhealth',
	'armor',
	'frags',
	'deaths',
	'team',
	'steamid',
	'steamid64',
	'usergroup',
}

PANEL.Funcs = {
	nick = 'DBoardNick',
	health = 'Health',
	maxhealth = 'GetMaxHealth',
	armor = 'Armor',
	steamid = 'SteamID',
	steamid64 = 'SteamID64',
	usergroup = 'GetUserGroup',
	frags = 'Frags',
	deaths = 'Deaths',
}

PANEL.Names = {
	nick = 'Nick: ',
	health = 'Health: ',
	maxhealth = 'Max Health: ',
	armor = 'Armor: ',
	team = 'Team: ',
	steamid = 'SteamID: ',
	steamid64 = 'SteamID64: ',
	usergroup = 'User Group: ',
	frags = 'Kills: ',
	deaths = 'Deaths: ',
}

function PANEL:Think()
	local ply = self.ply
	
	if not IsValid(ply) then self.board:BuildPlayerList() return end
	
	for k, v in pairs(self.Funcs) do
		local val = ply[v](ply)
		if not val then self.pnls[k]:SetText(self.Names[k] .. '(error)') continue end
		
		self.pnls[k]:SetText(self.Names[k] .. val)
		self.pnls[k].val = val
	end
	
	self.pnls.team:SetText('Team: ' .. team.GetName(ply:Team()))
	self.pnls.team.val = team.GetName(ply:Team())
	
	hook.Run('DUpdateUserLabels', self, ply, self.pnls)
end

do
	local function LabelClick(self)
		SetClipboardText(self.val or self:GetText())
	end
	
	local function LabelPaint(self, w, h)
		if self:IsHovered() then
			surface.SetDrawColor(150, 150, 150, 100)
			surface.DrawRect(0, 0, w, h)
		end
	end
	
	local function advSetText(self, text)
		return self:SetText(self.name .. ' ' .. text)
	end
	
	function PANEL:CreateInfoLabel(id, name)
		local lab = self.topright:Add('DLabel')
		self.pnls[id] = lab
		lab:Dock(TOP)
		lab:SetFont(FONT_PLAYERINFO)
		lab:SetText(id)
		lab:SetTextColor(color_white)
		lab:SetHeight(14)
		lab:SetTooltip('Click to copy field to clipboard!')
		lab.DoClick = LabelClick
		lab:SetMouseInputEnabled(true)
		lab.Paint = LabelPaint
		lab.DSetText = advSetText
		lab.name = name
		lab.infos = self
		
		return lab
	end

	function PANEL:Init()
		local button = self:Add('DScoreBoard2_Button')
		button:SetText('Go Back!')
		button.DoClick = function()
			self.board:BuildPlayerList()
		end
		button:Dock(TOP)
		
		local top = self:Add('EditablePanel')
		top:Dock(TOP)
		top:SetHeight(128)
		
		self.avatar = top:Add('DScoreBoard2_Avatar')
		self.avatar:Dock(LEFT)
		self.avatar:SetSize(128, 128)
		self.avatar:SetMouseInputEnabled(true)
		
		local ratings = top:Add('DScoreBoard2_Rating')
		ratings:Dock(RIGHT)
		ratings:SetWidth(160)
		ratings:Resize()
		self.ratings = ratings
		
		local topright = top:Add('DScrollPanel')
		topright:Dock(FILL)
		topright:DockMargin(4, 4, 4, 4)
		topright.Paint = function() end
		self.topright = topright
		
		self.pnls = {}
		
		for k, v in pairs(self.Panels) do
			self:CreateInfoLabel(v)
		end
		
		hook.Run('DPopulateUserLabels', self)
		
		local canvas = self:Add('EditablePanel')
		self.canvas = canvas
		canvas:Dock(FILL)
		canvas:DockMargin(4, 4, 4, 4)
		
		--Fixing GMod bugs
		local w, h = self:GetSize()
		canvas:SetSize(w - 8, h - 8)
	end
end

function PANEL:DefaultActions(canvas)
	local ply = self.ply
	
	local top = canvas:Add('EditablePanel')
	top:Dock(TOP)
	top:SetHeight(20)
	
	local button = top:Add('DScoreBoard2_Button')
	
	button.Think = function()
		if self.ply:IsMuted() then
			button:SetText('Unmute voice')
		else
			button:SetText('Mute voice')
		end
	end
	
	button:Think()
	button:Dock(LEFT)
	button:SizeToContents()
	button:SetWide(button:GetSize() + 16)
	button:SetText('Voice')
	
	button.DoClick = function()
		if self.ply:IsMuted() then
			self.ply:SetMuted(false)
		else
			self.ply:SetMuted(true)
		end
		
		button:Think()
	end
end

function PANEL:SetPlayer(ply)
	self.ply = ply
	self.avatar:SetPlayer(ply, 128)
	self.ratings:SetPlayer(ply)
	
	--Fixing GMod bugs
	local w, h = self:GetSize()
	self.canvas:SetSize(w - 8, h - 8)
	
	self:DefaultActions(self.canvas)
	hook.Run('DScoreBoard2_PlayerInfo', self.canvas, self, ply)
end

function PANEL:CreateGrid(wide)
	wide = wide or 80
	
	local grid = self.canvas:Add('DGrid')
	grid:Dock(TOP)
	grid:DockMargin(4, 4, 4, 4)
	grid:SetColWide(wide + 5)
	grid:SetRowHeight(25)
	grid:SetCols(math.floor(self.canvas:GetWide() / (wide + 5)))
	
	return grid
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(Colors.bg)
	draw.NoTexture()
	surface.DrawTexturedRect(0, 0, w, h)
end

vgui.Register('DScoreBoard2_PlayerInfo', PANEL, 'EditablePanel')

local PANEL = {}
local PLAYEROW_PANEL = PANEL

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
	self.nick:SetFont(FONT_PLAYERINFO)
	self.nick:SetText('nick')
	self.nick:Dock(LEFT)
	self.nick:DockMargin(4, 0, 0, 0)
	self.nick:SetWidth(300)
	
	for k, v in pairs(self.RIGHT) do
		self[v] = self:Add('DScoreBoard2_SpecialLabel')
		self[v]:SetFont(FONT_PLAYERINFO)
		self[v]:SetText(v)
		self[v]:Dock(RIGHT)
		self[v]:DockMargin(4, 0, 4, 0)
		self[v]:SetWidth(50)
	end
	
	self.health = self:Add('DScoreBoard2_SpecialLabel')
	self.health:SetFont(FONT_PLAYERINFO)
	self.health:SetText('health')
	self.health:Dock(RIGHT)
	self.health:DockMargin(4, 0, 4, 0)
	self.health:SetWidth(80)
	
	self.teamname = self:Add('DScoreBoard2_SpecialLabel')
	self.teamname:SetFont(FONT_PLAYERINFO)
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

local PANEL = {}

function PANEL:Init()
	local avatar = self:Add('DScoreBoard2_Avatar')
	self.avatar = avatar
	avatar:Dock(LEFT)
	avatar:SetSize(16, 16)
	self:SetHeight(16)
	
	self.stamp = 0
	
	self.nick = self:Add('DScoreBoard2_SpecialLabel')
	self.nick:SetFont(FONT_PLAYERINFO)
	self.nick:SetText('nick')
	self.nick:Dock(LEFT)
	self.nick:DockMargin(4, 0, 4, 0)
	self.nick:SetWidth(200)
	
	self.ping = self:Add('DScoreBoard2_SpecialLabel')
	self.ping:SetFont(FONT_PLAYERINFO)
	self.ping:SetText('0:00')
	self.ping:Dock(RIGHT)
	self.ping:DockMargin(4, 0, 4, 0)
	self.ping:SetWidth(50)
	
	local lab = self:Add('DScoreBoard2_SpecialLabel')
	lab:SetFont(FONT_PLAYERINFO)
	lab:SetText('Disconnected')
	lab:Dock(RIGHT)
	lab:DockMargin(4, 0, 4, 0)
	lab:SetWidth(50)
	lab:SizeToContents()
	
	local flag = self:Add('DScoreBoard2_CountryFlag')
	self.flag = flag
	flag:Dock(RIGHT)
	flag:DockMargin(4, 0, 4, 0)
end

function PANEL:Think()
	if not self.steamid then return end
	
	if self.stamp + 180 < CurTime() then
		self:Remove()
		return
	end
	
	local delta = math.floor(CurTime() - self.stamp)
	
	local seconds = delta % 60
	delta = delta - seconds
	local minutes = math.floor(delta / 60)
	
	if seconds < 10 then
		self.ping:SetText(minutes .. ':0' .. seconds)
	else
		self.ping:SetText(minutes .. ':' .. seconds)
	end
end

function PANEL:SetCountry(str)
	self.flag:SetFlagCode(str)
end

function PANEL:SetSteamID(id)
	self.steamid = id
	self.stamp = CurTime()
	self.avatar:SetSteamID(id, 32)
end

function PANEL:SetNick(nick)
	self.nick:SetText(nick)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(200, 200, 200)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register('DScoreBoard2_DPlayerRow', PANEL, 'EditablePanel')

local PANEL = {}

function PANEL:Init()
	local avatar = self:Add('DScoreBoard2_Avatar')
	self.avatar = avatar
	avatar:Dock(LEFT)
	avatar:SetSize(16, 16)
	self:SetHeight(16)
	
	self.stamp = 0
	
	self.nick = self:Add('DScoreBoard2_SpecialLabel')
	self.nick:SetFont(FONT_PLAYERINFO)
	self.nick:SetText('nick')
	self.nick:Dock(LEFT)
	self.nick:DockMargin(4, 0, 4, 0)
	self.nick:SetWidth(200)
	
	self.ping = self:Add('DScoreBoard2_SpecialLabel')
	self.ping:SetFont(FONT_PLAYERINFO)
	self.ping:SetText('0:00')
	self.ping:Dock(RIGHT)
	self.ping:DockMargin(4, 0, 4, 0)
	self.ping:SetWidth(50)
	
	local lab = self:Add('DScoreBoard2_SpecialLabel')
	lab:SetFont(FONT_PLAYERINFO)
	lab:SetText('Connecting')
	lab:Dock(RIGHT)
	lab:DockMargin(4, 0, 4, 0)
	lab:SetWidth(50)
	lab:SizeToContents()
end

function PANEL:Think()
	if not self.steamid then return end
	
	local delta = math.floor(CurTime() - self.stamp)
	
	local seconds = delta % 60
	delta = delta - seconds
	local minutes = math.floor(delta / 60)
	
	if seconds < 10 then
		self.ping:SetText(minutes .. ':0' .. seconds)
	else
		self.ping:SetText(minutes .. ':' .. seconds)
	end
end

function PANEL:SetSteamID(id)
	self.steamid = id
	self.stamp = CurTime()
	self.avatar:SetSteamID(id, 32)
end

function PANEL:SetNick(nick)
	self.nick:SetText(nick)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(200, 200, 200)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register('DScoreBoard2_CPlayerRow', PANEL, 'EditablePanel')

local PANEL = {}

PANEL.DefaultVars = table.Copy(PLAYEROW_PANEL.DefaultVars)
PANEL.DefaultFunctions = table.Copy(PLAYEROW_PANEL.DefaultFunctions)

PANEL.DefaultVars.friend = 'Is Your Friend: No'
PANEL.DefaultVars.usergroup = 'Usergroup'
PANEL.DefaultVars.steamid64 = 'SteamID64'
PANEL.DefaultFunctions.steamid64 = 'SteamID64'

function PANEL:UpdateVars()
	PLAYEROW_PANEL.UpdateVars(self)
	local vars = self.vars
	
	if self.ply == LocalPlayer() then
		vars.friend = 'It is you'
	else
		vars.friend = 'Is your Friend: ' .. (self.ply:GetFriendStatus() == 'friend' and 'Yes' or 'No')
	end
	
	vars.usergroup = 'Usergroup: ' .. self.ply:GetUserGroup()
end

function PANEL:UpdatePanels()
	if not IsValid(self.ply) then return end
	PLAYEROW_PANEL.UpdatePanels(self)
	
	if not self.CountrySetup then
		self.country:SetText('Country: ' .. board.GetPlayerCountry(self.ply))
		self.CountrySetup = true
	end
end

function PANEL:Init()
	self.vars = table.Copy(self.DefaultVars)
	
	local top = self:Add('EditablePanel')
	top.Paint = self.Paint
	top:Dock(TOP)
	top:SetHeight(64)
	
	local avatar = top:Add('AvatarImage')
	self.avatar = avatar
	avatar:Dock(LEFT)
	avatar:SetWidth(64)
	
	local lab = top:Add('DLabel')
	self.nick = lab
	lab:SetTextColor(color_white)
	lab:Dock(TOP)
	lab:SetFont(FONT_PLAYERINFO)
	lab:SetText('nick')
	lab:DockMargin(4, 0, 0, 0)
	lab:SetHeight(14)
	
	local lab = top:Add('DLabel')
	self.teamname = lab
	lab:SetTextColor(color_white)
	lab:Dock(TOP)
	lab:SetFont(FONT_PLAYERINFO)
	lab:SetText('team')
	lab:DockMargin(4, 0, 0, 0)
	lab:SetHeight(14)
	
	local lab = top:Add('DLabel')
	self.steamid = lab
	lab:SetTextColor(color_white)
	lab:Dock(TOP)
	lab:SetFont(FONT_PLAYERINFO)
	lab:SetText('steamid')
	lab:DockMargin(4, 0, 0, 0)
	lab:SetHeight(14)
	
	local lab = top:Add('DLabel')
	self.country = lab
	lab:SetTextColor(color_white)
	lab:Dock(TOP)
	lab:SetFont(FONT_PLAYERINFO)
	lab:SetText('country')
	lab:DockMargin(4, 0, 0, 0)
	lab:SetHeight(14)
	
	local countryflag = lab:Add('DScoreBoard2_CountryFlag')
	self.countryflag = countryflag
	countryflag:Dock(RIGHT)
	countryflag:DockMargin(0, 0, 4, 0)
	
	self.CountrySetup = false
	
	local padding = self:Add('EditablePanel')
	padding:Dock(FILL)
	padding:DockMargin(6, 6, 6, 6)
	
	self.health = self:CreateLabel(padding, 'Health')
	self.maxhealth = self:CreateLabel(padding, 'Max Health')
	self.kills = self:CreateLabel(padding, 'Kills')
	self.deaths = self:CreateLabel(padding, 'Deaths')
	self.steamid64 = self:CreateLabel(padding, 'SteamID64')
	self.friend = self:CreateLabel(padding)
	self.usergroup = self:CreateLabel(padding)
	
	self:SetSize(400, 180)
end

do
	local function SetText(self, text)
		if self.name then
			self.OSetText(self, self.name .. ': ' .. text)
		else
			self.OSetText(self, text)
		end
	end

	function PANEL:CreateLabel(parent, name)
		local lab = parent:Add('DLabel')
		lab.OSetText = lab.SetText
		lab.SetText = SetText
		lab.name = name
		
		lab:SetTextColor(color_white)
		lab:Dock(TOP)
		lab:SetFont(FONT_PLAYERINFO)
		lab:SetText(name or '')
		lab:DockMargin(4, 0, 0, 0)
		lab:SetHeight(14)
		
		return lab
	end
end

function PANEL:DoShow()
	self:SetVisible(true)
	self:MakePopup()
	self:KillFocus()
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
end

function PANEL:DoHide()
	self:SetVisible(false)
	self:KillFocus()
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
end

function PANEL:SetPlayer(ply)
	self.ply = ply
	self.avatar:SetPlayer(ply, 64)
	self.steamid:SetText(ply:SteamID())
	self.countryflag:SetPlayer(ply)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(Colors.bg)
	draw.NoTexture()
	surface.DrawRect(0, 0, w, h)
end

function PANEL:Think()
	if not IsValid(self.ROW) then
		self:Remove()
		return
	end
	
	if not self.ROW:IsVisible() then
		self:DoHide()
		return
	end
	
	local x, y = gui.MousePos()
	self:SetPos(x + 20, y + 10)
	
	self:UpdateVars()
	self:UpdatePanels()
end

vgui.Register('DScoreBoard2_PlayerHover', PANEL, 'EditablePanel')

local PANEL = {}

function PANEL:Init()
	self.Neon = 0
	self.BaseClass.Init(self)
	self:SetTextColor(Colors.textcolor)
	self:SizeToContents()
	local w, h = self:GetSize()
	self:SetWidth(w + 8)
	self:SetHeight(20)
	self:SetFont(FONT_BUTTONFONT)
end

function PANEL:Paint(w, h)
	if self:IsHovered() then
		self.Neon = math.Clamp(self.Neon + 350 * FrameTime(), 0, 150)
	else
		self.Neon = math.Clamp(self.Neon - 350 * FrameTime(), 0, 150)
	end
	
	if self:IsDown() then
		self.Neon = 200
	end
	
	surface.SetDrawColor(Colors.bg.r + self.Neon, Colors.bg.g + self.Neon, Colors.bg.b + self.Neon, Colors.bg.a)
	draw.NoTexture()
	surface.DrawRect(0, 0, w, h)
end

vgui.Register('DScoreBoard2_Button', PANEL, 'DButton')

local PANEL = {}

function PANEL:AddDisconnected(steamid, nick, country)
	if IsValid(self.DROWS[steamid]) then self.DROWS[steamid]:Remove() end
	
	local row = self.status:Add('DScoreBoard2_DPlayerRow')
	row:SetSteamID(steamid)
	row:SetNick(nick)
	row:SetCountry(country)
	row:Dock(TOP)
	
	self.DROWS[steamid] = row
end

function PANEL:AddConnecting(steamid, nick)
	if IsValid(self.DROWS[steamid]) then self.DROWS[steamid]:Remove() end
	
	local row = self.status:Add('DScoreBoard2_CPlayerRow')
	row:SetSteamID(steamid)
	row:SetNick(nick)
	row:Dock(TOP)
	
	self.DROWS[steamid] = row
end

function PANEL:Init()
	local top = self:Add('EditablePanel')
	top:Dock(TOP)
	top:SetHeight(30)
	
	for k, v in pairs(PLAYEROW_PANEL.RIGHT) do
		local lab = top:Add('DLabel')
		lab:SetFont(FONT_PLAYERINFO)
		lab:SetText(string.upper(v[1]) .. string.sub(v, 2))
		lab:Dock(RIGHT)
		lab:DockMargin(4, 0, 4, 0)
		lab:SetWidth(50)
	end
	
	local lab = top:Add('DLabel')
	lab:SetFont(FONT_PLAYERINFO)
	lab:SetText('Health')
	lab:Dock(RIGHT)
	lab:DockMargin(4, 0, 4, 0)
	lab:SetWidth(80)
	
	local lab = top:Add('DLabel')
	lab:SetFont(FONT_PLAYERINFO)
	lab:SetText('Team')
	lab:Dock(RIGHT)
	lab:DockMargin(4, 0, 4, 0)
	lab:SetWidth(100)
	
	local status = self:Add('DScrollPanel')
	self.status = status
	status:Dock(BOTTOM)
	status:SetHeight(60)
	
	self.DROWS = {}
	
	hook.Add('DScoreBoard2_PlayerDisconnect', self, self.AddDisconnected)
	hook.Add('DScoreBoard2_PlayerConnect', self, self.AddConnecting)
	
	self.scroll = self:Add('DScrollPanel')
	self.scroll:Dock(FILL)
	self.ROWS = {}
end

function PANEL:BuildPlayerList()
	for k, v in pairs(self.ROWS) do
		self.ROWS[k] = nil
		
		if IsValid(v) then
			v:Remove()
		end
	end
	
	local plys = board.GetSortedPlayerList()
	
	board.RefreshDCache()
	
	for k, ply in pairs(plys) do
		local row = self.scroll:Add('DScoreBoard2_PlayerRow')
		self.scroll:AddItem(row)
		row:SetPlayer(ply)
		row:Dock(TOP)
		row.pnl = self
		row:Think()
		
		if self.DROWS[ply:SteamID()] then
			self.DROWS[ply:SteamID()]:Remove()
		end
		
		table.insert(self.ROWS, row)
	end
	
	for k, v in pairs(board.Connecting) do
		self:AddConnecting(k, v.nick)
		self.DROWS[k].stamp = v.timestamp
	end
	
	for k, v in pairs(board.Disconnected) do
		self:AddDisconnected(k, v.nick, v.country)
		self.DROWS[k].stamp = v.timestamp
	end
end

function PANEL:OpenPlayer(ply)
	self.board:OpenInfo(ply)
end

vgui.Register('DScoreBoard2_PlayerList', PANEL, 'EditablePanel')

local MiscFunctions = {
	CurTimeThink = function(self)
		self:SetText('Your time: ' .. os.date('%H:%M:%S - %d/%m/%y', os.time()))
	end,
	
	ServerTime = function(self)
		self:SetText('Server time: ' .. os.date('%H:%M:%S - %d/%m/%y', board.ServerTime))
	end,
	
	SteamTime = function(self)
		self:SetText('Steam time: ' .. os.date('%H:%M:%S - %d/%m/%y', system.SteamTime()))
	end,
	
	UpTimeThink = function(self)
		self:SetText('Map uptime: ' .. string.NiceTime(CurTime()))
	end,
	
	MemThink = function(self)
		local format = math.floor(collectgarbage('count') / 1024)
		
		self:SetText('Lua memory usage: ' .. format .. ' mb')
	end,
	
	ServerMemThink = function(self)
		self:SetText('Server Lua memory usage: ' .. board.ServerMem .. ' mb')
	end,
}

local PANEL = {}
local CURRENT_PANEL

function PANEL:Init()
	CURRENT_PANEL = self
	self:SetSize(ScrW() - 100, ScrH() - 100)
	self:Center()
	
	local top = self:Add('EditablePanel')
	top:Dock(TOP)
	top:SetHeight(60)
	
	local topInfo = self:Add('EditablePanel')
	topInfo:Dock(TOP)
	topInfo:SetHeight(30)
	
	local mouseNotify = top:Add('DLabel')
	
	self.mouseNotify = mouseNotify
	mouseNotify:SetText('Right click to activate')
	mouseNotify:SetFont(FONT_MOUSENOTIFY)
	mouseNotify:SizeToContents()
	mouseNotify:Dock(RIGHT)
	mouseNotify:SetTextColor(Colors.textcolor)
	mouseNotify:DockMargin(0, 0, 20, 0)
	
	top:Add('DScoreBoard2_ServerTitle')
	
	local lab = topInfo:Add('DLabel')
	lab:SetFont(FONT_TOPINFO)
	lab:Dock(LEFT)
	lab:DockMargin(4, 0, 4, 0)
	lab:SetWidth(230)
	lab:SetTextColor(Colors.textcolor)
	lab.Think = MiscFunctions.CurTimeThink
	
	local lab = topInfo:Add('DLabel')
	lab:SetFont(FONT_TOPINFO)
	lab:Dock(LEFT)
	lab:DockMargin(4, 0, 4, 0)
	lab:SetWidth(240)
	lab:SetTextColor(Colors.textcolor)
	lab.Think = MiscFunctions.ServerTime
	
	local lab = topInfo:Add('DLabel')
	lab:SetFont(FONT_TOPINFO)
	lab:Dock(LEFT)
	lab:DockMargin(4, 0, 4, 0)
	lab:SetWidth(230)
	lab:SetTextColor(Colors.textcolor)
	lab.Think = MiscFunctions.SteamTime
	
	local rebuild = topInfo:Add('DScoreBoard2_Button')
	rebuild:SetText('Rebuild scoreboard')
	rebuild:SetFont(FONT_TOPINFO)
	rebuild:SizeToContents()
	rebuild:Dock(RIGHT)
	rebuild:DockMargin(0, 0, 20, 0)
	
	rebuild.DoClick = function()
		RunConsoleCommand('dscoreboard_rebuild')
	end
	
	local rebuild = topInfo:Add('DScoreBoard2_Button')
	rebuild:SetText('Rebuild player list')
	rebuild:SetFont(FONT_TOPINFO)
	rebuild:SizeToContents()
	rebuild:Dock(RIGHT)
	rebuild:DockMargin(0, 0, 20, 0)
	
	rebuild.DoClick = function()
		RunConsoleCommand('dscoreboard_rebuildplys')
	end
	
	local lab = topInfo:Add('DLabel')
	lab:SetFont(FONT_TOPINFO)
	lab:Dock(LEFT)
	lab:DockMargin(4, 0, 4, 0)
	lab:SetWidth(200)
	lab:SetTextColor(Colors.textcolor)
	lab.Think = MiscFunctions.UpTimeThink
	
	local bottom = self:Add('EditablePanel')
	bottom:Dock(BOTTOM)
	bottom:SetHeight(30)
	
	local lab = bottom:Add('DLabel')
	lab:SetFont(FONT_BOTTOMINFO)
	lab:Dock(LEFT)
	lab:DockMargin(4, 0, 4, 0)
	lab:SetWidth(140)
	lab:SetTextColor(Colors.textcolor)
	lab.Think = MiscFunctions.MemThink
	
	local lab = bottom:Add('DLabel')
	lab:SetFont(FONT_BOTTOMINFO)
	lab:Dock(LEFT)
	lab:DockMargin(4, 0, 4, 0)
	lab:SetWidth(170)
	lab:SetTextColor(Colors.textcolor)
	lab.Think = MiscFunctions.ServerMemThink
	
	if board.SHOW_AUTHOR:GetBool() then
		local dbot
		
		local lab = bottom:Add('DLabel')
		lab:SetFont(FONT_BOTTOMINFO)
		lab:Dock(RIGHT)
		lab:DockMargin(4, 0, 8, 0)
		lab:SetTextColor(Colors.textcolor)
		lab:SetText('hide')
		lab:SizeToContents()
		lab:SetCursor('hand')
		lab:SetMouseInputEnabled(true)
		lab.OnMousePressed = function()
			dbot:Remove()
			lab:Remove()
			RunConsoleCommand('dscoreboard_showauthor', '0')
		end
		
		local lab = bottom:Add('DLabel')
		dbot = lab
		lab:SetFont(FONT_BOTTOMINFO)
		lab:Dock(RIGHT)
		lab:DockMargin(4, 0, 4, 0)
		lab:SetTextColor(Colors.textcolor)
		lab:SetText('DScoreBoard/2 maded by DBot. All additions belong to their authors.')
		lab:SizeToContents()
		lab.OnMousePressed = function()
			gui.OpenURL('http://steamcommunity.com/id/roboderpy/')
		end
		lab:SetCursor('hand')
		lab:SetMouseInputEnabled(true)
	end
	
	local canvas = self:Add('EditablePanel')
	self.canvas = canvas
	canvas:Dock(FILL)
	
	local list = canvas:Add('DScoreBoard2_PlayerList')
	list:Dock(FILL)
	list:BuildPlayerList()
	self.list = list
	list.board = self
	
	self.infos = {}
	
	self:DoHide()
end

function PANEL:BuildPlayerList()
	for k, v in pairs(self.infos) do
		if not IsValid(v) or not IsValid(v.ply) then self.infos[k] = nil continue end
		v:SetVisible(false)
	end
	
	self.list:SetVisible(true)
	return self.list:BuildPlayerList()
end

function PANEL:OpenInfo(ply)
	self.list:SetVisible(false)
	
	for k, v in pairs(self.infos) do
		if not IsValid(v) or not IsValid(v.ply) then self.infos[k] = nil continue end
		v:SetVisible(false)
	end
	
	if not IsValid(self.infos[ply]) then
		local info = self.canvas:Add('DScoreBoard2_PlayerInfo')
		info:Dock(FILL)
		--Fixing GMod bugs
		info:SetSize(self.canvas:GetSize())
		self.infos[ply] = info
		info:SetPlayer(ply)
		info.board = self
	end
	
	self.infos[ply]:SetVisible(true)
end

function PANEL:Think()
	if self.FOCUSED then
		local x, y = gui.MousePos()
		self.MouseX = x
		self.MouseY = y
	end
	
	local build = false
	
	for k, v in pairs(player.GetAll()) do
		if not v.DSCOREBOARD_BUILD then
			v.DSCOREBOARD_BUILD = true
			
			if not build then
				self:BuildPlayerList()
				build = true
			end
		end
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(Colors.bg)
	draw.NoTexture()
	surface.DrawRect(0, 0, w, h)
end

local function CalcView(ply, pos, ang, fov, znear, zfar)
	local data = {}
	
	local ang2 = Angle(ang.p, ang.y, 0)
	
	local add = Vector(0, -ScrW() * 0.06, 0)
	add:Rotate(ang)
	
	local add2 = Vector(-100, 0, 0)
	add2:Rotate(ang2)
	
	local newpos = pos + add + add2
	
	local tr = util.TraceHull{
		start = pos,
		endpos = newpos,
		filter = function(ent)
			if IsValid(ent) then
				if ent:IsPlayer() then return false end
				if ent:IsNPC() then return false end
			end
			
			return true
		end,
		mins = ply:OBBMins(),
		maxs = ply:OBBMaxs(),
	}
	
	pos = tr.HitPos
	pos.z = pos.z + 30
	
	data.angles = ang
	data.fov = fov
	data.znear = znear
	data.zfar = zfar
	data.drawviewer = true
	data.origin = pos
	
	return data
end

function PANEL:DoHide()
	self:SetVisible(false)
	self:UnFocus()
	self.VISIBLE = false
	hook.Run('DScoreBoard2_Hide', self)
	hook.Remove('CalcView', 'DScoreBoard2')
end

function PANEL:DoShow()
	hook.Add('CalcView', 'DScoreBoard2', CalcView)
	self:SetVisible(true)
	self.VISIBLE = true
end

function PANEL:UnFocus()
	self:SetKeyboardInputEnabled(false)
	self:SetMouseInputEnabled(false)
	self:KillFocus()
	self.FOCUSED = false
	self.mouseNotify:SetVisible(true)
end

function PANEL:Focus()
	self:MakePopup()
	self:RequestFocus()
	self:SetKeyboardInputEnabled(false)
	self:SetMouseInputEnabled(true)
	self.FOCUSED = true
	self.mouseNotify:SetVisible(false)
	
	if self.MouseY and self.MouseX then
		gui.SetMousePos(self.MouseX, self.MouseY)
	end
end

vgui.Register('DScoreBoard2', PANEL, 'EditablePanel')

local function Create(force)
	if force and IsValid(board.Board) then board.Board:Remove() end 
	if IsValid(board.Board) then return end
	
	local status, board2 = pcall(vgui.Create, 'DScoreBoard2')
	if status then
		board.Board = board2
	elseif IsValid(CURRENT_PANEL) then
		CURRENT_PANEL:Remove()
	end
end

local function Open()
	Create()
	board.Board:DoShow()
	return true
end

local function Close()
	Create()
	board.Board:DoHide()
	return true
end

local function KeyPress(ply, key)
	if key ~= IN_ATTACK2 then return end
	if not IsValid(board.Board) then return end
	if not board.Board:IsVisible() then return end
	if board.Board.FOCUSED then return end
	board.Board:Focus()
end

board.ServerMem = 0
board.ServerTime = 0

net.Receive('DScoreBoard2.ServerMemory', function()
	board.ServerMem = net.ReadUInt(12)
end)

net.Receive('DScoreBoard2.ServerTime', function()
	board.ServerTime = net.ReadUInt(32)
end)

net.Receive('DScoreBoard2.ChatPrint', function()
	chat.AddText(unpack(net.ReadTable()))
end)

net.Receive('DScoreBoard2.Flags', function()
	local count = net.ReadUInt(12)
	
	for i = 1, count do
		local ply = net.ReadEntity()
		if not IsValid(ply) then continue end
		ply.DSCOREBOARD_FLAG = net.ReadString()
	end
end)

timer.Simple(0, function()
	net.Start('DScoreBoard2.Flags')
	net.WriteString(system.GetCountry())
	net.SendToServer()
end)

concommand.Add('dscoreboard_rebuild', function() 
	Create(true)
	board.Board:DoShow()
	board.Board:Focus()
end)

concommand.Add('dscoreboard_rebuildplys', function() 
	Create()
	board.Board.list:BuildPlayerList()
end)

hook.Add('ScoreboardShow', 'DScoreBoard2', Open)
hook.Add('ScoreboardHide', 'DScoreBoard2', Close)
hook.Add('KeyPress', 'DScoreBoard2', KeyPress)

board.Connecting = board.Connecting or {}
board.Disconnected = board.Disconnected or {}

function board.RefreshDCache()
	for k, v in pairs(board.Connecting) do
		if player.GetBySteamID(k) then
			board.Connecting[k] = nil
		end
	end
	
	for k, v in pairs(board.Disconnected) do
		if v.timestamp + 180 < CurTime() or
			player.GetBySteamID(k)
		then
			board.Disconnected[k] = nil
		end
	end
end

net.Receive('DScoreBoard2.Connect', function()
	local steamid = net.ReadString()
	local nick = net.ReadString()
	
	hook.Run('DScoreBoard2_PlayerConnect', steamid, nick)
	
	board.Connecting[steamid] = {
		nick = nick,
		timestamp = CurTime()
	}
	
	board.Disconnected[steamid] = nil
	
	board.RefreshDCache()
end)

net.Receive('DScoreBoard2.Disconnect', function()
	local steamid = net.ReadString()
	local nick = net.ReadString()
	local country = net.ReadString()
	
	hook.Run('DScoreBoard2_PlayerDisconnect', steamid, nick, country)
	
	board.Disconnected[steamid] = {
		nick = nick,
		country = country,
		timestamp = CurTime()
	}
	
	board.Connecting[steamid] = nil
	
	board.RefreshDCache()
end)

if IsValid(board.Board) then board.Board:Remove() end
