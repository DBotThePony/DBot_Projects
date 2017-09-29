
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
        if not IsValid(ply) then continue end
        ply.DSCOREBOARD_FLAG = net.ReadString()
    end
end)

net.Receive('DScoreBoard2.Connect', function()
    local steamid = net.ReadString()
    local nick = net.ReadString()
    
    hook.Run('DScoreBoard2_PlayerConnect', steamid, nick)
    
    board.Connecting[steamid] = {
        nick = nick,
        timestamp = CurTime()
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
        timestamp = CurTime()
    }
    
    board.Connecting[steamid] = nil
    
    board.RefreshDCache()
end)
