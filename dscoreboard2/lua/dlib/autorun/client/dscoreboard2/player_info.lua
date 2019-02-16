
--
-- Copyright (C) 2016-2019 DBot

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
        lab:SetFont(DScoreBoard2.FONT_PLAYERINFO)
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
    surface.SetDrawColor(DScoreBoard2.Colors.bg)
    draw.NoTexture()
    surface.DrawTexturedRect(0, 0, w, h)
end

vgui.Register('DScoreBoard2_PlayerInfo', PANEL, 'EditablePanel')
