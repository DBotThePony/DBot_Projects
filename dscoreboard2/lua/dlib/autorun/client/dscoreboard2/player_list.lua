
--
-- Copyright (C) 2016-2019 DBotThePony

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


local board = DScoreBoard2

local PANEL = {}

function PANEL:AddDisconnected(steamid, nick, country)
    if IsValid(self.DROWS[steamid]) then self.DROWS[steamid]:Remove() end

    local w, h = self:GetSize()
    local row = self.status:Add('DScoreBoard2_DPlayerRow')
    row:SetSteamID(steamid)
    row:SetNick(nick)
    row:SetCountry(country)
    row:Dock(TOP)
    row:SetSize(w, 16)

    self.DROWS[steamid] = row
end

function PANEL:AddConnecting(steamid, nick)
    if IsValid(self.DROWS[steamid]) then self.DROWS[steamid]:Remove() end

    local w, h = self:GetSize()
    local row = self.status:Add('DScoreBoard2_CPlayerRow')
    row:SetSteamID(steamid)
    row:SetNick(nick)
    row:Dock(TOP)
    row:SetSize(w, 16)

    self.DROWS[steamid] = row
end

function PANEL:Init()
    local top = self:Add('EditablePanel')
    top:Dock(TOP)
    top:SetHeight(18)

    local lab = top:Add('DScoreBoard2_SorterButton')
    lab:SetFont(DScoreBoard2.FONT_PLAYERINFO)
    lab:SetRealText('Nickname')
    lab:SetAffectedMode('nickname')
    lab:Dock(LEFT)
    lab:DockMargin(4, 0, 4, 0)
    lab:SetWidth(100)

    for k, v in pairs(DScoreBoard2.PLAYEROW_PANEL.RIGHT) do
        local lab = top:Add('DScoreBoard2_SorterButton')
        lab:SetFont(DScoreBoard2.FONT_PLAYERINFO)
        lab:SetRealText(string.upper(v[1]) .. string.sub(v, 2))
        lab:SetAffectedMode(v)
        lab:Dock(RIGHT)
        lab:DockMargin(2, 0, 2, 0)
        lab:SetWidth(54)
    end

    local lab = top:Add('DScoreBoard2_SorterButton')
    lab:SetFont(DScoreBoard2.FONT_PLAYERINFO)
    lab:SetRealText('Health')
    lab:SetAffectedMode('health')
    lab:Dock(RIGHT)
    lab:DockMargin(4, 0, 4, 0)
    lab:SetWidth(80)

    local lab = top:Add('DScoreBoard2_SorterButton')
    lab:SetFont(DScoreBoard2.FONT_PLAYERINFO)
    lab:SetRealText('Team')
    lab:SetAffectedMode('team')
    lab:Dock(RIGHT)
    lab:DockMargin(4, 0, 4, 0)
    lab:SetWidth(100)

    local status = self:Add('DScrollPanel')
    self.status = status
    status:Dock(BOTTOM)
    status:SetHeight(60)

    self.DROWS = {}
    self.scroll = self:Add('DScrollPanel')
    self.scroll:Dock(FILL)
    self.ROWS = {}

    hook.Add('DScoreBoard2_UpdateSorting', self, self.DoSort)
    hook.Add('DScoreBoard2_PlayerDisconnect', self, self.AddDisconnected)
    hook.Add('DScoreBoard2_PlayerConnect', self, self.AddConnecting)
end

local function PanelsSorter(first, second)
    local sortby = DScoreBoard2.SORT_BY:GetString():lower()
    local toReturn = false
    local hit = false

    if sortby == 'nickname' then
        toReturn = first.vars.nick < second.vars.nick
        hit = true
    elseif sortby == 'team' then
        toReturn = first.vars.team < second.vars.team
        hit = true
    elseif sortby == 'kills' then
        toReturn = first.vars.kills < second.vars.kills
        hit = true
    elseif sortby == 'deaths' then
        toReturn = first.vars.deaths < second.vars.deaths
        hit = true
    elseif sortby == 'ratio' then
        toReturn = first.vars.ratio < second.vars.ratio
        hit = true
    elseif sortby == 'ping' then
        toReturn = first.vars.ping < second.vars.ping
        hit = true
    elseif sortby == 'health' then
        toReturn = first.vars.health < second.vars.health
        hit = true
    end

    if hit then
        if DScoreBoard2.SORT_BY_ORDER:GetString():lower() == 'asc' then
            return toReturn
        else
            return not toReturn
        end
    else
        return true
    end
end

function PANEL:DoSort()
    local sortOut = {}

    for i, pnl in pairs(self.ROWS) do
        table.insert(sortOut, pnl)
    end

    table.sort(sortOut, PanelsSorter)

    for i, pnl in pairs(sortOut) do
        pnl:SetPos(0, i * 16 - 16)
    end
end

function PANEL:PerformLayout(w, h)
    if self.ROWS then
        for i, row in pairs(self.ROWS) do
            row:SetSize(w, 16)
        end
    end

    if self.DROWS then
        for i, row in pairs(self.DROWS) do
            if IsValid(row) then
                row:SetSize(w, 16)
            end
        end
    end
end

function PANEL:BuildPlayerList()
    for k, v in pairs(self.ROWS) do
        self.ROWS[k] = nil

        if IsValid(v) then
            v:Remove()
        end
    end

    local plys = player.GetAll()

    board.RefreshDCache()
    local w, h = self:GetSize()

    for k, ply in pairs(plys) do
        local row = self.scroll:Add('DScoreBoard2_PlayerRow')
        self.scroll:AddItem(row)
        row:SetPlayer(ply)
        -- row:Dock(TOP)
        row.pnl = self
        row:SetSize(w, 16)
        row:Think()

        if self.DROWS[ply:SteamID()] then
            self.DROWS[ply:SteamID()]:Remove()
        end

        table.insert(self.ROWS, row)
    end

    self:DoSort()

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