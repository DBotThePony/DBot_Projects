
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

local MiscFunctions = {
    CurTimeLThink = function(self)
        self:SetText('Your time: ' .. os.date('%H:%M:%S - %d/%m/%y', os.time()))
    end,

    ServerTime = function(self)
        self:SetText('Server time: ' .. os.date('%H:%M:%S - %d/%m/%y', board.ServerTime))
    end,

    SteamTime = function(self)
        self:SetText('Steam time: ' .. os.date('%H:%M:%S - %d/%m/%y', system.SteamTime()))
    end,

    UpTimeThink = function(self)
        self:SetText('Map uptime: ' .. string.NiceTime(CurTimeL()))
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
    self:SetSize(ScrWL() - 100, ScrHL() - 100)
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
    mouseNotify:SetFont(DScoreBoard2.FONT_MOUSENOTIFY)
    mouseNotify:SizeToContents()
    mouseNotify:Dock(RIGHT)
    mouseNotify:SetTextColor(DScoreBoard2.Colors.textcolor)
    mouseNotify:DockMargin(0, 0, 20, 0)

    top:Add('DScoreBoard2_ServerTitle')

    local lab = topInfo:Add('DLabel')
    lab:SetFont(DScoreBoard2.FONT_TOPINFO)
    lab:Dock(LEFT)
    lab:DockMargin(4, 0, 4, 0)
    lab:SetWidth(230)
    lab:SetTextColor(DScoreBoard2.Colors.textcolor)
    lab.Think = MiscFunctions.CurTimeLThink

    local lab = topInfo:Add('DLabel')
    lab:SetFont(DScoreBoard2.FONT_TOPINFO)
    lab:Dock(LEFT)
    lab:DockMargin(4, 0, 4, 0)
    lab:SetWidth(240)
    lab:SetTextColor(DScoreBoard2.Colors.textcolor)
    lab.Think = MiscFunctions.ServerTime

    local lab = topInfo:Add('DLabel')
    lab:SetFont(DScoreBoard2.FONT_TOPINFO)
    lab:Dock(LEFT)
    lab:DockMargin(4, 0, 4, 0)
    lab:SetWidth(230)
    lab:SetTextColor(DScoreBoard2.Colors.textcolor)
    lab.Think = MiscFunctions.SteamTime

    local rebuild = topInfo:Add('DScoreBoard2_Button')
    rebuild:SetText('Rebuild scoreboard')
    rebuild:SetFont(DScoreBoard2.FONT_TOPINFO)
    rebuild:SizeToContents()
    rebuild:Dock(RIGHT)
    rebuild:DockMargin(0, 0, 20, 0)

    rebuild.DoClick = function()
        RunConsoleCommand('dscoreboard_rebuild')
    end

    local rebuild = topInfo:Add('DScoreBoard2_Button')
    rebuild:SetText('Rebuild player list')
    rebuild:SetFont(DScoreBoard2.FONT_TOPINFO)
    rebuild:SizeToContents()
    rebuild:Dock(RIGHT)
    rebuild:DockMargin(0, 0, 20, 0)

    rebuild.DoClick = function()
        RunConsoleCommand('dscoreboard_rebuildplys')
    end

    local lab = topInfo:Add('DLabel')
    lab:SetFont(DScoreBoard2.FONT_TOPINFO)
    lab:Dock(LEFT)
    lab:DockMargin(4, 0, 4, 0)
    lab:SetWidth(200)
    lab:SetTextColor(DScoreBoard2.Colors.textcolor)
    lab.Think = MiscFunctions.UpTimeThink

    local bottom = self:Add('EditablePanel')
    bottom:Dock(BOTTOM)
    bottom:SetHeight(30)

    local lab = bottom:Add('DLabel')
    lab:SetFont(DScoreBoard2.FONT_BOTTOMINFO)
    lab:Dock(LEFT)
    lab:DockMargin(4, 0, 4, 0)
    lab:SetWidth(140)
    lab:SetTextColor(DScoreBoard2.Colors.textcolor)
    lab.Think = MiscFunctions.MemThink

    local lab = bottom:Add('DLabel')
    lab:SetFont(DScoreBoard2.FONT_BOTTOMINFO)
    lab:Dock(LEFT)
    lab:DockMargin(4, 0, 4, 0)
    lab:SetWidth(170)
    lab:SetTextColor(DScoreBoard2.Colors.textcolor)
    lab.Think = MiscFunctions.ServerMemThink

    if board.SHOW_AUTHOR:GetBool() then
        local dbot

        local lab = bottom:Add('DLabel')
        lab:SetFont(DScoreBoard2.FONT_BOTTOMINFO)
        lab:Dock(RIGHT)
        lab:DockMargin(4, 0, 8, 0)
        lab:SetTextColor(DScoreBoard2.Colors.textcolor)
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
        lab:SetFont(DScoreBoard2.FONT_BOTTOMINFO)
        lab:Dock(RIGHT)
        lab:DockMargin(4, 0, 4, 0)
        lab:SetTextColor(DScoreBoard2.Colors.textcolor)
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
    surface.SetDrawColor(DScoreBoard2.Colors.bg)
    draw.NoTexture()
    surface.DrawRect(0, 0, w, h)
end

local function CalcView(ply, pos, ang, fov, znear, zfar)
    local data = {}

    local ang2 = Angle(ang.p, ang.y, 0)

    local add = Vector(0, -ScrWL() * 0.06, 0)
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

local ALLOW_THIRD_PERSON = CreateConVar('sv_dscoreboard2_thirdperson', '1', {FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Allow scoreboard thirdperson')

function PANEL:DoHide()
    self:SetVisible(false)
    self:UnFocus()
    self.VISIBLE = false
    hook.Run('DScoreBoard2_Hide', self)
    hook.Remove('CalcView', 'DScoreBoard2')
end

function PANEL:DoShow()
    if ALLOW_THIRD_PERSON:GetBool() then
        hook.Add('CalcView', 'DScoreBoard2', CalcView)
    end

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
