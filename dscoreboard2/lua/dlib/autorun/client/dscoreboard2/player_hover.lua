
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

PANEL.DefaultVars = table.Copy(DScoreBoard2.PLAYEROW_PANEL.DefaultVars)
PANEL.DefaultFunctions = table.Copy(DScoreBoard2.PLAYEROW_PANEL.DefaultFunctions)

PANEL.DefaultVars.friend = 'Is Your Friend: No'
PANEL.DefaultVars.usergroup = 'Usergroup'
PANEL.DefaultVars.steamid64 = 'SteamID64'
PANEL.DefaultFunctions.steamid64 = 'SteamID64'

function PANEL:UpdateVars()
    DScoreBoard2.PLAYEROW_PANEL.UpdateVars(self)
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
    DScoreBoard2.PLAYEROW_PANEL.UpdatePanels(self)

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
    lab:SetFont(DScoreBoard2.FONT_PLAYERINFO)
    lab:SetText('nick')
    lab:DockMargin(4, 0, 0, 0)
    lab:SetHeight(14)

    local lab = top:Add('DLabel')
    self.teamname = lab
    lab:SetTextColor(color_white)
    lab:Dock(TOP)
    lab:SetFont(DScoreBoard2.FONT_PLAYERINFO)
    lab:SetText('team')
    lab:DockMargin(4, 0, 0, 0)
    lab:SetHeight(14)

    local lab = top:Add('DLabel')
    self.steamid = lab
    lab:SetTextColor(color_white)
    lab:Dock(TOP)
    lab:SetFont(DScoreBoard2.FONT_PLAYERINFO)
    lab:SetText('steamid')
    lab:DockMargin(4, 0, 0, 0)
    lab:SetHeight(14)

    local lab = top:Add('DLabel')
    self.country = lab
    lab:SetTextColor(color_white)
    lab:Dock(TOP)
    lab:SetFont(DScoreBoard2.FONT_PLAYERINFO)
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
        lab:SetFont(DScoreBoard2.FONT_PLAYERINFO)
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
    surface.SetDrawColor(DScoreBoard2.Colors.bg)
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
