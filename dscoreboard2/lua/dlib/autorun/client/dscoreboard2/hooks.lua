
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

local function Create(force)
    if force and IsValid(board.Board) then board.Board:Remove() end
    if IsValid(board.Board) then return end

    local status, board2 = xpcall(vgui.Create, function(err) print(debug.traceback(err)) end, 'DScoreBoard2')
    if status then
        board.Board = board2
    end
end

local function Open()
    Create()

    if IsValid(board.Board) then
        board.Board:DoShow()
    end

    return true
end

local function Close()
    Create()

    if IsValid(board.Board) then
        board.Board:DoHide()
    end

    return true
end

local function checkBoardStuff()
    return IsValid(board.Board) and board.Board:IsVisible()
end

local function KeyPress()
    if not IsValid(board.Board) then return false end
    if not board.Board:IsVisible() then return false end
    if board.Board.FOCUSED then return false end
    board.Board:Focus()
    return true
end

board.ServerMem = 0
board.ServerTime = 0

timer.Simple(0, function()
    net.Start('DScoreBoard2.Flags')
    net.WriteString(system.GetCountry())
    net.SendToServer()
end)

concommand.Add('dscoreboard_rebuild', function()
    Create(true)
    board.Board:DoShow()
    board.Board:Focus()
end)

concommand.Add('dscoreboard_rebuildplys', function()
    Create()
    board.Board.list:BuildPlayerList()
end)

hook.Add('ScoreboardShow', 'DScoreBoard2', Open)
hook.Add('ScoreboardHide', 'DScoreBoard2', Close)
hook.Add('CreateMove', 'DScoreBoard2', function(cmd)
    if cmd:KeyDown(IN_ATTACK2) and checkBoardStuff() then
        KeyPress()
        cmd:SetButtons(cmd:GetButtons() - IN_ATTACK2)
    end
end)

board.Connecting = board.Connecting or {}
board.Disconnected = board.Disconnected or {}
