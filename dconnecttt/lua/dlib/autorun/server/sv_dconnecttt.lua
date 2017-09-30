
-- Copyright (C) 2016-2017 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local KICK_NOT_RESPONDING = CreateConVar('sv_dconn_kick', '1', {FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Kick not responding clients')
local PREVENT_CONNECTION_SPAM = CreateConVar('sv_dconn_spam', '1', {FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Prevent connection spam')
local SPAM_TRIES = CreateConVar('sv_dconn_spamtries', '3', {FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Max connection tries before ban player')
local SPAM_DELAY = CreateConVar('sv_dconn_spamdelay', '60', {FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Connection spam delay in seconds')
local DISPLAY_NICKS = CreateConVar('sv_dconn_hoverdisplay', '1', {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, 'Display players nicks on hovering')

DConn = DConn or {}

net.pool('DConnecttt.ChatPrint')
net.pool('DConnecttt.PlayerTick')

local EMPTY_FUNC = function() end

local LINK = DMySQL3.Connect('dconnecttt')

function DConn.Query(q, callback)
	return LINK:Query(q, callback, callback)
end

-- Listen for advanced disconnect event
gameevent.Listen('player_disconnect')

local PrefixColor = Color(0, 200, 0)
local Prefix = '[DConnecttt] '
local TEXT_COLOR = Color(200, 200, 200)

local chat = DLib.chat.generate('DConnecttt')

local function ChatPrint(...)
	chat.chatAll(...)
end

function DConn.Message(...)
	MsgC(PrefixColor, Prefix, TEXT_COLOR, ...)
	MsgC('\n')
end

local function Message(...)
	ChatPrint(...)
	DConn.Message(...)
end

local PendingDisconnects = {}
local PendingConnect

local function PlayerConnect(nick, ip)
	if not PendingConnect then
		Message(nick, ' connected to the server')
	else
		local PendingConnect = PendingConnect
		DConn.Query('SELECT * FROM dconnecttt WHERE steamid64 = "' .. PendingConnect.steamid64 .. '";', function(data)
			if not data[1] then
				Message(PendingConnect.nick, '<' .. PendingConnect.steamid .. '> connected to the server')
			else
				local db_steamid = data[1].steamid
				local db_steamid64 = data[1].steamid64
				local lastname = data[1].lastname
				local steamname = data[1].steamname

				local PrintNick = PendingConnect.nick

				if steamname ~= nick then
					PrintNick = PrintNick .. string.format(' (known as %s)', steamname)
				end

				Message(PrintNick, '<' .. PendingConnect.steamid .. '> connected to the server')
			end
		end)
	end

	PendingConnect = nil
end

function DConn.SavePlayerData(ply)
	if ply:IsBot() then return end
	local steamid64 = ply:SteamID64()
	local nick = ply:Nick()
	local realnick = nick

	local ip = string.Explode(':', ply:IPAddress())[1]

	if ply.SteamName then
		realnick = ply:SteamName()
	end

	DConn.Query(
		string.format(
			'UPDATE dconnecttt SET lastname = %q, steamname = %q, lastip = %q, lastseen = %q, totaltime = %q WHERE steamid64 = %q',
			nick,
			realnick,
			ip,
			os.time(),
			ply.DConnecttt_Total or 0,
			steamid64
		)
	)
end

local function PlayerAuthed(ply, steamid)
	local steamid64 = ply:SteamID64()
	local nick = ply:Nick()
	local realnick = nick

	local ip = string.Explode(':', ply:IPAddress())[1]

	if ply.SteamName then
		realnick = ply:SteamName()
	end

	DConn.Message(team.GetColor(ply:Team()), realnick, TEXT_COLOR, '<' .. steamid .. '> is authed')

	-- Give player time to initialize
	timer.Simple(0, function()
		if not IsValid(ply) then return end

		ply:SetNWFloat('DConnecttt.JoinTime', CurTime())

		DConn.Query('SELECT * FROM dconnecttt WHERE steamid64 = "' .. steamid64 .. '";', function(data)
			if not IsValid(ply) then return end

			if not data[1] then
				Message(team.GetColor(ply:Team()), nick, TEXT_COLOR, '<' .. steamid .. '> joined the server for first time')

				DConn.Query(
					string.format(
						'INSERT INTO dconnecttt (steamid64, steamid, lastname, steamname, lastip, lastseen, firstseen, totaltime) VALUES (%q, %q, %q, %q, %q, %q, %q, %q)',
						steamid64,
						steamid,
						nick,
						realnick,
						ip,
						os.time(),
						os.time(),
						0
					)
				)
			else
				local db_steamid = data[1].steamid
				local db_steamid64 = data[1].steamid64
				local lastname = data[1].lastname
				local steamname = data[1].steamname
				local lastip = data[1].lastip
				local lastseen = data[1].lastseen
				local firstseen = data[1].firstseen
				local totaltime = data[1].totaltime

				ply.DConnecttt_Session = 0
				ply.DConnecttt_Total = tonumber(totaltime)
				ply:SetNWFloat('DConnecttt_Join', CurTime())
				ply:SetNWFloat('DConnecttt_Total_OnJoin', ply.DConnecttt_Total)

				local PrintNick = nick

				if steamname ~= realnick then
					PrintNick = PrintNick .. string.format(' (known as %s)', steamname)
				end

				Message(team.GetColor(ply:Team()), PrintNick, TEXT_COLOR, '<' .. steamid .. '> joined the server')
				Message(team.GetColor(ply:Team()), PrintNick, TEXT_COLOR, '<' .. steamid .. '> was last seen at ' .. DLib.string.qdate(lastseen))

				DConn.SavePlayerData(ply)
			end

			ply.DCONNECT_INITIALIZE = true
		end)
	end)
end

local IPBuffer = {}

local RUNNING = false

local function CheckPassword(steamid64, ip, svpass, clpass, nick)
	if RUNNING then return end
	local realip = string.Explode(':', ip)[1]
	local steamid = util.SteamIDFrom64(steamid64)

	IPBuffer[realip] = IPBuffer[realip] or {0, CurTime()}

	if IPBuffer[realip][2] + SPAM_DELAY:GetInt() > CurTime() then
		IPBuffer[realip][1] = IPBuffer[realip][1] + 1
	else
		IPBuffer[realip][1] = 0
	end

	if PREVENT_CONNECTION_SPAM:GetBool() and IPBuffer[realip][1] > SPAM_TRIES:GetInt() then
		DConn.Message(nick, '<' .. steamid .. '> was kicked because of connection spam')
		return false, '[DConnecttt] Connection Spam!'
	end

	RUNNING = true
	local can, reason = hook.Run('CheckPassword', steamid64, ip, svpass, clpass, nick)
	RUNNING = false

	local can2, reason2

	if can == false then
		return false, reason
	else
		can2, reason2 = svpass == '' or svpass == clpass, 'Server Password ~= Client Password!\nIf you are connecting from console,\nuse "password" console command to set clientside password.'
	end

	PendingConnect = {
		steamid = steamid,
		steamid64 = steamid64,
		nick = nick,
		ip = ip,
	}

	--  Fixing GMod bug
	return can2, reason2
end

local function player_disconnect(data)
	local name = data.name
	local realname = data.name
	local steamid = data.networkid
	local userid = tonumber(data.userid)
	local isBot = data.bot
	local reason = data.reason

	if string.find(reason, 'timed out') then
		reason = 'Crashed/Network problem'
	end

	local ply = player.GetBySteamID(steamid)

	if not ply then
		Message(name, '<' .. steamid .. '> diconnected from server (' .. reason .. ')')
		return
	end

	-- data.name always shows real player nick
	name = ply:Nick()

	DConn.SavePlayerData(ply)

	if ply.SteamName and ply:SteamName() ~= name then -- DarkRP
		name = name .. ' (' .. ply:SteamName() .. ')'
	end

	Message(team.GetColor(ply:Team()), name, TEXT_COLOR, '<' .. steamid .. '> diconnected from server (' .. reason .. ')')
end

local function Timer()
	local KICK_NOT_RESPONDING = KICK_NOT_RESPONDING:GetBool()

	for k, ply in pairs(player.GetAll()) do
		if not ply.DCONNECT_INITIALIZE then continue end

		ply.DConnecttt_Session = (ply.DConnecttt_Session or 0) + 1
		ply.DConnecttt_Total = (ply.DConnecttt_Total or 0) + 1
		ply.DConnecttt_LastTick = ply.DConnecttt_LastTick or CurTime()

		if ply:IsBot() then
			ply.DConnecttt_LastTick = CurTime()
		end

		local deadTime = CurTime() - ply.DConnecttt_LastTick
		ply:SetNWBool('DConnecttt_Dead', deadTime > 5)

		if KICK_NOT_RESPONDING and ply.DConnecttt_LastTick + 360 < CurTime() then
			ply.DConnecttt_Kicked = true
			ply:Kick('[DConnecttt] Your client has failed to reply to a query in time. Please reconnect or restart your game.')
		end
	end
end

local function SaveTimer()
	for k, ply in pairs(player.GetAll()) do
		if not ply.DCONNECT_INITIALIZE then continue end
		xpcall(DConn.SavePlayerData, print, ply)
	end
end

local function PlayerTick(len, ply)
	ply.DConnecttt_LastTick = CurTime()

	if ply:GetNWFloat('DConnecttt.FastInit', 0) == 0 then
		ply:SetNWFloat('DConnecttt.FastInit', CurTime())
	end
end

local plyMeta = FindMetaTable('Player')

function plyMeta:TotalTimeConnected()
	return self:SessionTime() + self:GetNWFloat('DConnecttt_Total_OnJoin')
end

function plyMeta:SessionTime()
	return CurTime() - self:GetNWFloat('DConnecttt_Join')
end

-- UTime interface
function plyMeta:GetUTimeSessionTime()
	return self:SessionTime()
end

-- ???
function plyMeta:GetUTime()
	return self:TotalTimeConnected()
end
-- ???
function plyMeta:GetUTimeTotalTime()
	return self:TotalTimeConnected()
end
-- ???

function plyMeta:SetUTime()
	-- Do nothing
end

function plyMeta:SetUTimeStart()
	-- Do nothing
end

function plyMeta:GetUTimeStart()
	return self:GetNWFloat('DConnecttt_Join')
end

for k, v in pairs(player.GetAll()) do
	PlayerAuthed(v, v:SteamID())
end

timer.Create('DConnecttt.Timer', 1, 0, Timer)
timer.Create('DConnecttt.SaveTimer', 60, 0, SaveTimer)
net.Receive('DConnecttt.PlayerTick', PlayerTick)
hook.Add('player_disconnect', 'DConnecttt', player_disconnect)
hook.Add('CheckPassword', 'DConnecttt', CheckPassword)
hook.Add('PlayerConnect', 'DConnecttt', PlayerConnect)
hook.Add('PlayerAuthed', 'DConnecttt', PlayerAuthed)

DConn.Query([[
	CREATE TABLE IF NOT EXISTS dconnecttt (
		steamid64 VARCHAR(64) not null,
		steamid VARCHAR(32),
		lastname VARCHAR(64),
		steamname VARCHAR(64),
		lastip VARCHAR(32),
		lastseen INT,
		firstseen INT,
		totaltime INT,
		PRIMARY KEY (steamid64)
	);
]])
