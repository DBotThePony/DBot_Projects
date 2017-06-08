
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
	
	for k, v in pairs(DScoreBoard2.PLAYEROW_PANEL.RIGHT) do
		local lab = top:Add('DLabel')
		lab:SetFont(DScoreBoard2.FONT_PLAYERINFO)
		lab:SetText(string.upper(v[1]) .. string.sub(v, 2))
		lab:Dock(RIGHT)
		lab:DockMargin(4, 0, 4, 0)
		lab:SetWidth(50)
	end
	
	local lab = top:Add('DLabel')
	lab:SetFont(DScoreBoard2.FONT_PLAYERINFO)
	lab:SetText('Health')
	lab:Dock(RIGHT)
	lab:DockMargin(4, 0, 4, 0)
	lab:SetWidth(80)
	
	local lab = top:Add('DLabel')
	lab:SetFont(DScoreBoard2.FONT_PLAYERINFO)
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