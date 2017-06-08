
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
    surface.SetDrawColor(DScoreBoard2.Colors.bg)
    surface.DrawRect(0, 0, w, h)
    
    draw.DrawText(self.count, DScoreBoard2.FONT_RATING, w / 2, 16, color_white, TEXT_ALIGN_CENTER)
    
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

