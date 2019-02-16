
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

net.Receive('DScoreBoard2.ServerMemory', function()
    board.ServerMem = net.ReadUInt(12)
end)

net.Receive('DScoreBoard2.ServerTime', function()
    board.ServerTime = net.ReadUInt(32)
end)

DLib.chat.registerWithMessages(board, 'DScoreBoard2')

net.Receive('DScoreBoard2.Flags', function()
    local count = net.ReadUInt(12)

    for i = 1, count do
        local ply = net.ReadEntity()
        if IsValid(ply) then
            ply.DSCOREBOARD_FLAG = net.ReadString()
        end
    end
end)

net.Receive('DScoreBoard2.Connect', function()
    local steamid = net.ReadString()
    local nick = net.ReadString()

    hook.Run('DScoreBoard2_PlayerConnect', steamid, nick)

    board.Connecting[steamid] = {
        nick = nick,
        timestamp = CurTimeL()
    }

    board.Disconnected[steamid] = nil

    board.RefreshDCache()
end)

net.Receive('DScoreBoard2.Disconnect', function()
    local steamid = net.ReadString()
    local nick = net.ReadString()
    local country = net.ReadString()

    hook.Run('DScoreBoard2_PlayerDisconnect', steamid, nick, country)

    board.Disconnected[steamid] = {
        nick = nick,
        country = country,
        timestamp = CurTimeL()
    }

    board.Connecting[steamid] = nil

    board.RefreshDCache()
end)
