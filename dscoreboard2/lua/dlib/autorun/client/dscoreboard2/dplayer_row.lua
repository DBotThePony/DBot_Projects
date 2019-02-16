
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

function PANEL:Init()
    local avatar = self:Add('DScoreBoard2_Avatar')
    self.avatar = avatar
    avatar:Dock(LEFT)
    avatar:SetSize(16, 16)
    self:SetHeight(16)

    self.stamp = 0

    self.nick = self:Add('DScoreBoard2_SpecialLabel')
    self.nick:SetFont(DScoreBoard2.FONT_PLAYERINFO)
    self.nick:SetText('nick')
    self.nick:Dock(LEFT)
    self.nick:DockMargin(4, 0, 4, 0)
    self.nick:SetWidth(200)

    self.ping = self:Add('DScoreBoard2_SpecialLabel')
    self.ping:SetFont(DScoreBoard2.FONT_PLAYERINFO)
    self.ping:SetText('0:00')
    self.ping:Dock(RIGHT)
    self.ping:DockMargin(4, 0, 4, 0)
    self.ping:SetWidth(50)

    local lab = self:Add('DScoreBoard2_SpecialLabel')
    lab:SetFont(DScoreBoard2.FONT_PLAYERINFO)
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

    if self.stamp + 180 < CurTimeL() then
        self:Remove()
        return
    end

    local delta = math.floor(CurTimeL() - self.stamp)

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
    self.stamp = CurTimeL()
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
