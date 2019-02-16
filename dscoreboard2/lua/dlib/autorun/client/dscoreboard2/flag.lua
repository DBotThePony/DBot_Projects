
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
        surface.SetFont(DScoreBoard2.FONT_PLAYERINFO)
        surface.DrawText('???')
    else
        surface.SetDrawColor(color_white)
        surface.SetMaterial(self.Mat)
        surface.DrawTexturedRect(0, 0, w, h)
        draw.NoTexture()
    end
end

vgui.Register('DScoreBoard2_CountryFlag', PANEL, 'EditablePanel')
