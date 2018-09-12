
--
-- Copyright (C) 2016-2018 DBot

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


DScoreBoard2 = DScoreBoard2 or {}
local board = DScoreBoard2

board.SHOW_AUTHOR = CreateConVar('dscoreboard_showauthor', '1', FCVAR_ARCHIVE, 'Show DScoreBoard/2 author')
board.SORT_BY = CreateConVar('dscoreboard_sort_by', 'nickname', {FCVAR_ARCHIVE}, 'Sort by (none, nickname, team, kills, deaths, ratio, ping, health)')
board.SORT_BY_ORDER = CreateConVar('dscoreboard_sort_by_order', 'asc', {FCVAR_ARCHIVE}, 'Sort by order (desc, asc)')

local Colors = {
    bg = Color(0, 0, 0, 150),
    textcolor = Color(255, 255, 255, 255),
}

local plyMeta = FindMetaTable('Player')

function plyMeta:DBoardNick()
    return self:Nick() .. (self.SteamName and (' (Steam Name: ' .. self:SteamName() .. ')') or '')
end

board.Colors = Colors

for k, v in pairs(DScoreBoard2.Colors) do
    local r = CreateConVar('cl_dboard_color_' .. k .. '_r', v.r, FCVAR_ARCHIVE, 'Sets ' .. k .. ' color red channel')
    local g = CreateConVar('cl_dboard_color_' .. k .. '_g', v.g, FCVAR_ARCHIVE, 'Sets ' .. k .. ' color green channel')
    local b = CreateConVar('cl_dboard_color_' .. k .. '_b', v.b, FCVAR_ARCHIVE, 'Sets ' .. k .. ' color blue channel')
    local a = CreateConVar('cl_dboard_color_' .. k .. '_a', v.a, FCVAR_ARCHIVE, 'Sets ' .. k .. ' color alpha channel')

    local function update()
        DScoreBoard2.Colors[k] = Color(r:GetInt(), g:GetInt(), b:GetInt(), a:GetInt())
    end

    cvars.AddChangeCallback('cl_dboard_color_' .. k .. '_r', update, 'DScoreBoard2')
    cvars.AddChangeCallback('cl_dboard_color_' .. k .. '_g', update, 'DScoreBoard2')
    cvars.AddChangeCallback('cl_dboard_color_' .. k .. '_b', update, 'DScoreBoard2')
    cvars.AddChangeCallback('cl_dboard_color_' .. k .. '_a', update, 'DScoreBoard2')
end

function board.GetPlayerCountry(ply)
    if ply == LocalPlayer() then return system.GetCountry() end
    return ply.DSCOREBOARD_FLAG or 'Unknown'
end

function board.RefreshDCache()
    for k, v in pairs(board.Connecting) do
        if player.GetBySteamID(k) then
            board.Connecting[k] = nil
        end
    end

    for k, v in pairs(board.Disconnected) do
        if v.timestamp + 180 < CurTimeL() or
            player.GetBySteamID(k)
        then
            board.Disconnected[k] = nil
        end
    end
end

cvars.AddChangeCallback('dscoreboard_sort_by', function()
    hook.Run('DScoreBoard2_UpdateSorting')
end, 'DScoreBoard2')

cvars.AddChangeCallback('dscoreboard_sort_by_order', function()
    hook.Run('DScoreBoard2_UpdateSorting')
end, 'DScoreBoard2')

include('dlib/autorun/client/dscoreboard2/fonts.lua')
include('dlib/autorun/client/dscoreboard2/avatar.lua')
include('dlib/autorun/client/dscoreboard2/flag.lua')
include('dlib/autorun/client/dscoreboard2/panels.lua')
include('dlib/autorun/client/dscoreboard2/player_info.lua')
include('dlib/autorun/client/dscoreboard2/player_row.lua')
include('dlib/autorun/client/dscoreboard2/dplayer_row.lua')
include('dlib/autorun/client/dscoreboard2/cplayer_row.lua')
include('dlib/autorun/client/dscoreboard2/player_hover.lua')
include('dlib/autorun/client/dscoreboard2/player_list.lua')
include('dlib/autorun/client/dscoreboard2/rating.lua')
include('dlib/autorun/client/dscoreboard2/mainframe.lua')
include('dlib/autorun/client/dscoreboard2/network.lua')
include('dlib/autorun/client/dscoreboard2/hooks.lua')

if IsValid(board.Board) then board.Board:Remove() end
