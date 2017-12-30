
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

local BUTTON_BASECLASS = baseclass.Get('DButton')
local PANEL = {}

function PANEL:Init()
    self.Neon = 0
    BUTTON_BASECLASS.Init(self)
    self:SetTextColor(DScoreBoard2.Colors.textcolor)
    self:SizeToContents()
    local w, h = self:GetSize()
    self:SetWidth(w + 8)
    self:SetHeight(20)
    self:SetFont(DScoreBoard2.FONT_BUTTONFONT)
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

    surface.SetDrawColor(DScoreBoard2.Colors.bg.r + self.Neon, DScoreBoard2.Colors.bg.g + self.Neon, DScoreBoard2.Colors.bg.b + self.Neon, DScoreBoard2.Colors.bg.a)
    draw.NoTexture()
    surface.DrawRect(0, 0, w, h)
end

vgui.Register('DScoreBoard2_Button', PANEL, 'DButton')

local PANEL = {}

function PANEL:Init()
    self.BaseClass.Init(self)
    self.affectedMode = 'none'
    self.realText = 'None'
    self:SetSize(80, 20)
end

function PANEL:SetAffectedMode(text)
    self.affectedMode = text:lower()
end

function PANEL:GetAffectedMode()
    return self.affectedMode
end

function PANEL:SetRealText(text)
    self.realText = text
end

function PANEL:GetRealText()
    return self.realText
end

function PANEL:Think()
    if DScoreBoard2.SORT_BY:GetString():lower() == self.affectedMode then
        if DScoreBoard2.SORT_BY_ORDER:GetString():lower() == 'asc' then
            self:SetText(self.realText .. ' ▼')
        else
            self:SetText(self.realText .. ' ▲')
        end
    else
        self:SetText(self.realText .. ' ─')
    end
end

function PANEL:DoClick()
    if DScoreBoard2.SORT_BY:GetString():lower() == self.affectedMode then
        if DScoreBoard2.SORT_BY_ORDER:GetString():lower() == 'asc' then
            RunConsoleCommand('dscoreboard_sort_by_order', 'desc')
        else
            RunConsoleCommand('dscoreboard_sort_by_order', 'asc')
        end
    else
        RunConsoleCommand('dscoreboard_sort_by', self.affectedMode)
        RunConsoleCommand('dscoreboard_sort_by_order', 'asc')
    end
end

vgui.Register('DScoreBoard2_SorterButton', PANEL, 'DScoreBoard2_Button')

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)
    self.BaseClass.Init(self)
    self:SetFont(DScoreBoard2.FONT_SERVERTITLE)
    self:SetTextColor(DScoreBoard2.Colors.textcolor)
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
    surface.SetDrawColor(DScoreBoard2.Colors.bg)
    draw.NoTexture()
    surface.DrawRect(0, 0, self.TSize, h)
end

function PANEL:SetText(text)
    surface.SetFont(self:GetFont())
    self.TSize = surface.GetTextSize(' ' .. text .. ' ')
    self.BaseClass.SetText(self, ' ' .. text)
end

vgui.Register('DScoreBoard2_SpecialLabel', PANEL, 'DLabel')
