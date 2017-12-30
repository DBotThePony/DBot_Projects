
--
-- Copyright (C) 2016-2018 DBot
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
