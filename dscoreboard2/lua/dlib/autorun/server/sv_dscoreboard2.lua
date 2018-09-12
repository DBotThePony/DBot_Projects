
--[[
Copyright (C) 2016-2018 DBot


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

]]

local LINK = DMySQL3.Connect('dscoreboard')

net.pool('DScoreBoard2.ServerMemory')
net.pool('DScoreBoard2.ServerTime')
net.pool('DScoreBoard2.Flags')
net.pool('DScoreBoard2.ChatPrint')
net.pool('DScoreBoard2.Connect')
net.pool('DScoreBoard2.Disconnect')

CreateConVar('sv_dscoreboard2_thirdperson', '1', {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Allow scoreboard thirdperson')

gameevent.Listen('player_disconnect')

timer.Create('DScoreBoard2.ServerMemory', 1, 0, function()
    net.Start('DScoreBoard2.ServerMemory', true)
    net.WriteUInt(math.floor(collectgarbage('count') / 1024), 12)
    net.Broadcast()
end)

timer.Create('DScoreBoard2.ServerTime', 1, 0, function()
    net.Start('DScoreBoard2.ServerTime', true)
    net.WriteUInt(os.time(), 32)
    net.Broadcast()
end)

local chat = DLib.chat.generateWithMessages({}, 'DScoreBoard2')
local ChatPrint = chat.chatPlayer

local function SavePly(ply)
    local steamid = ply:SteamID64()

    for k, v in ipairs(ply.DSCOREBOARD_RATE) do
        LINK:Query(string.format('REPLACE INTO dscoreboard2_rate (ply, rate, val) VALUES (%q, %q, %q)', steamid, k, v))
    end
end

local function SetRate(ply, id, value)
    ply.DSCOREBOARD_RATE[id] = value
    ply:SetNWInt('DScoreBoard2.Rating' .. id, value)
end

local function GetRate(ply, id)
    return ply.DSCOREBOARD_RATE[id]
end

local function AddRate(ply, id)
    return SetRate(ply, id, GetRate(ply, id) + 1)
end

local function PlayerInitialSpawn(ply)
    local steamid64 = ply:SteamID64()

    ply.DSCOREBOARD_RATE = {}

    LINK:Query(string.format('SELECT rate, val FROM dscoreboard2_rate WHERE ply = %q', steamid64), function(data)
        for k, row in ipairs(data) do
            ply.DSCOREBOARD_RATE[tonumber(row.rate)] = tonumber(row.val)
        end

        for i = 1, #DScoreBoard2Ratings.Ratings do
            if not ply.DSCOREBOARD_RATE[i] then
                ply.DSCOREBOARD_RATE[i] = 0
                LINK:Query(string.format('INSERT INTO dscoreboard2_rate (ply, rate, val) VALUES (%q, %q, %q)', steamid64, i, 0))
            end
        end

        for k, v in ipairs(ply.DSCOREBOARD_RATE) do
            ply:SetNWInt('DScoreBoard2.Rating' .. k, v)
        end
    end)
end

timer.Simple(0, function()
    for i, ply in ipairs(player.GetAll()) do
        PlayerInitialSpawn(ply)
    end
end)

local function BroadcastFlags()
    local plys = player.GetAll()
    local count = #plys

    net.Start('DScoreBoard2.Flags', true)

    net.WriteUInt(count, 12)

    for k, v in ipairs(plys) do
        net.WriteEntity(v)
        net.WriteString(v.DSCOREBOARD_FLAG or 'Unknown')
    end

    net.Broadcast()
end

--Network failures
timer.Create('DScoreBoard2.Flags', 180, 0, BroadcastFlags)

net.Receive('DScoreBoard2.Flags', function(len, ply)
    ply.DSCOREBOARD_FLAG = net.ReadString()
    BroadcastFlags()
end)

local ChatColor = Color(200, 200, 200)

local COOLDOWN = CreateConVar('dscoreboard_rate_cooldown', '180', FCVAR_ARCHIVE, 'Rating cooldown in seconds')

local function RatePlayer(ply, cmd, args)
    if not IsValid(ply) then return end
    local target = tonumber(args[1])
    if not target then return end
    target = Player(target)
    if not IsValid(target) then return end

    local rating = tonumber(args[2])
    if not rating then return end
    if not DScoreBoard2Ratings.Ratings[rating] then return end

    if target == ply then
        ChatPrint(ply, ChatColor, 'You can not rate yourself.')
        return
    end

    if not target.DSCOREBOARD_RATE then PlayerInitialSpawn(target) return end

    local i1 = target:UserID()

    ply.DSCOREBOARD_RATE_COOLDOWN = ply.DSCOREBOARD_RATE_COOLDOWN or {}
    ply.DSCOREBOARD_RATE_COOLDOWN[i1] = ply.DSCOREBOARD_RATE_COOLDOWN[i1] or 0

    local ctime = CurTimeL()
    if ply.DSCOREBOARD_RATE_COOLDOWN[i1] > ctime then
        ChatPrint(ply, ChatColor, 'You must wait ' .. math.floor(ply.DSCOREBOARD_RATE_COOLDOWN[i1] - ctime) .. ' seconds before rating this player again.')
        return
    end

    ply.DSCOREBOARD_RATE_COOLDOWN[i1] = ctime + COOLDOWN:GetInt()

    ChatPrint(ply, team.GetColor(ply:Team()), 'You', ChatColor,' gave rating ' .. DScoreBoard2Ratings.Names[rating] .. ' to ', team.GetColor(target:Team()), target:Nick())
    ChatPrint(target, team.GetColor(ply:Team()), ply:Nick(), ChatColor,' gave rating ' .. DScoreBoard2Ratings.Names[rating] .. ' to ', team.GetColor(target:Team()), 'You')

    AddRate(target, rating)
    SavePly(target)
end

concommand.Add('dscoreboard_rate', RatePlayer)

local Connect

local function PlayerConnect(nick, ip)
    if not Connect then return end
    if Connect.frame ~= CurTimeL() then Connect = nil return end

    net.Start('DScoreBoard2.Connect')
    net.WriteString(Connect.steamid)
    net.WriteString(Connect.nick)
    net.Broadcast()
end

local function player_disconnect(data)
    local name = data.name
    local steamid = data.networkid
    local userid = tonumber(data.userid)
    local isBot = data.bot
    local reason = data.reason

    local ply = player.GetBySteamID(steamid)

    if not ply then
        net.Start('DScoreBoard2.Disconnect', true)
        net.WriteString(steamid)
        net.WriteString(name)
        net.WriteString('Unknown')
        net.Broadcast()
    else
        net.Start('DScoreBoard2.Disconnect', true)
        net.WriteString(steamid)
        net.WriteString(name)
        net.WriteString(ply.DSCOREBOARD_FLAG or 'Unknown')
        net.Broadcast()
    end
end

local function CheckPassword(steamid64, ip, svpass, clpass, nick)
    local realip = string.Explode(':', ip)[1]
    local steamid = util.SteamIDFrom64(steamid64)

    Connect = {
        ip = ip,
        steamid64 = steamid64,
        nick = nick,
        frame = CurTimeL(),
        steamid = steamid,
    }
end

for k, v in ipairs(player.GetAll()) do
    PlayerInitialSpawn(v)
end

hook.Add('PlayerInitialSpawn', 'DSCOREBOARD_RATE', PlayerInitialSpawn)
hook.Add('player_disconnect', 'DScoreBoard2.Hooks', player_disconnect)
hook.Add('PlayerConnect', 'DScoreBoard2.Hooks', PlayerConnect)
hook.Add('CheckPassword', 'DScoreBoard2.Hooks', CheckPassword)

LINK:Query([[
CREATE TABLE IF NOT EXISTS dscoreboard2_rate (
    ply VARCHAR(26) NOT NULL,
    rate INT NOT NULL,
    val INT NOT NULL,
    PRIMARY KEY (ply, rate)
)
]])

AddCSLuaFile('dlib/autorun/client/dscoreboard2/fonts.lua')
AddCSLuaFile('dlib/autorun/client/dscoreboard2/avatar.lua')
AddCSLuaFile('dlib/autorun/client/dscoreboard2/flag.lua')
AddCSLuaFile('dlib/autorun/client/dscoreboard2/panels.lua')
AddCSLuaFile('dlib/autorun/client/dscoreboard2/player_info.lua')
AddCSLuaFile('dlib/autorun/client/dscoreboard2/player_row.lua')
AddCSLuaFile('dlib/autorun/client/dscoreboard2/dplayer_row.lua')
AddCSLuaFile('dlib/autorun/client/dscoreboard2/cplayer_row.lua')
AddCSLuaFile('dlib/autorun/client/dscoreboard2/player_hover.lua')
AddCSLuaFile('dlib/autorun/client/dscoreboard2/player_list.lua')
AddCSLuaFile('dlib/autorun/client/dscoreboard2/rating.lua')
AddCSLuaFile('dlib/autorun/client/dscoreboard2/mainframe.lua')
AddCSLuaFile('dlib/autorun/client/dscoreboard2/network.lua')
AddCSLuaFile('dlib/autorun/client/dscoreboard2/hooks.lua')
