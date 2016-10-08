
--[[
Copyright (C) 2016 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

if not DMySQL3 then include('autorun/server/sv_dmysql3.lua') end

local KICK_NOT_RESPONDING = CreateConVar('sv_dconn_kick', '1', {FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Kick not responding clients')
local PREVENT_CONNECTION_SPAM = CreateConVar('sv_dconn_spam', '1', {FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Prevent connection spam')
local SPAM_TRIES = CreateConVar('sv_dconn_spamtries', '3', {FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Max connection tries before ban player')
local SPAM_DELAY = CreateConVar('sv_dconn_spamdelay', '60', {FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Connection spam delay in seconds')
local DISPLAY_NICKS = CreateConVar('sv_dconn_hoverdisplay', '1', {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, 'Display players nicks on hovering')

DConn = DConn or {}

util.AddNetworkString('DConnecttt.ChatPrint')
util.AddNetworkString('DConnecttt.PlayerTick')

local EMPTY_FUNC = function() end

local LINK = DMySQL3.Connect('dconnecttt')

function DConn.Query(q, callback)
	LINK:Query(q, callback, callback)
end

--Listen for advanced disconnect event
gameevent.Listen('player_disconnect')

local function ChatPrint(...)
	net.Start('DConnecttt.ChatPrint')
	net.WriteTable({...})
	net.Broadcast()
end

local PendingDisconnects = {}

local PrefixColor = Color(0, 200, 0)
local Prefix = '[DConnecttt] '
local ChatColor = Color(255, 214, 74)
local ConsoleColor = Color(200, 200, 200)

local PendingConnect

local function PlayerConnect(nick, ip)
	if not PendingConnect then
		ChatPrint(PrefixColor, Prefix, ChatColor, nick, ChatColor, ' connected to the server')
		DConn.Message(nick, ' connected to the server')
	else
		local PendingConnect = PendingConnect
		DConn.Query('SELECT * FROM dconnecttt WHERE steamid64 = "' .. PendingConnect.steamid64 .. '";', function(data)
			if not data[1] then
				ChatPrint(PrefixColor, Prefix, ChatColor, PendingConnect.nick, '<' .. PendingConnect.steamid .. '> connected to the server')
				DConn.Message(PendingConnect.nick, '<' .. PendingConnect.steamid .. '> connected to the server')
			else
				local db_steamid = data[1].steamid
				local db_steamid64 = data[1].steamid64
				local lastname = data[1].lastname
				local steamname = data[1].steamname
				
				local PrintNick = PendingConnect.nick
				
				if steamname ~= nick then
					PrintNick = PrintNick .. string.format(' (known as %s)', steamname)
				end
				
				ChatPrint(PrefixColor, Prefix, ChatColor, PrintNick, ChatColor, '<' .. PendingConnect.steamid .. '> connected to the server')
				DConn.Message(PrintNick, '<' .. PendingConnect.steamid .. '> connected to the server')
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
			ply.DConnecttt_Total,
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
	
	DConn.Message(team.GetColor(ply:Team()), realnick, ConsoleColor, '<', steamid, '> is authed')
	
	--Give player time to initialize
	timer.Simple(0, function()
		if not IsValid(ply) then return end
		
		DConn.Query('SELECT * FROM dconnecttt WHERE steamid64 = "' .. steamid64 .. '";', function(data)
			if not IsValid(ply) then return end
			
			if not data[1] then
				ChatPrint(PrefixColor, Prefix, team.GetColor(ply:Team()), nick, ChatColor, '<' .. steamid .. '> joined the server for first time')
				DConn.Message(team.GetColor(ply:Team()), nick, ConsoleColor, '<' .. steamid .. '> joined the server for first time')
				
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
				
				local PrintNick = nick
				
				if steamname ~= realnick then
					PrintNick = PrintNick .. string.format(' (known as %s)', steamname)
				end
				
				ChatPrint(PrefixColor, Prefix, team.GetColor(ply:Team()), PrintNick, ChatColor, '<' .. steamid .. '> joined the server')
				ChatPrint(PrefixColor, Prefix, team.GetColor(ply:Team()), PrintNick, ChatColor, '<' .. steamid .. '> was last seen at ' .. os.date('%H:%M:%S - %d/%m/%Y', lastseen))
				
				DConn.Message(team.GetColor(ply:Team()), PrintNick, ConsoleColor, '<' .. steamid .. '> joined the server')
				DConn.Message(team.GetColor(ply:Team()), PrintNick, ConsoleColor, '<' .. steamid .. '> was last seen at ' .. os.date('%H:%M:%S - %d/%m/%Y', lastseen))
				
				DConn.SavePlayerData(ply)
			end
			
			ply.DCONNECT_INITIALIZE = true
		end)
	end)
end

local IPBuffer = {}

function DConn.Message(...)
	MsgC(PrefixColor, Prefix, ConsoleColor, ...)
	MsgC('\n')
end

local function CheckPassword(steamid64, ip, svpass, clpass, nick)
	local realip = string.Explode(':', ip)[1]
	local steamid = util.SteamIDFrom64(steamid64)
	
	IPBuffer[realip] = IPBuffer[realip] or {0, CurTime()}
	
	if IPBuffer[realip][2] + SPAM_DELAY:GetInt() > CurTime() then
		IPBuffer[realip][1] = IPBuffer[realip][1] + 1
	else
		IPBuffer[realip][1] = 0
	end
	
	if PREVENT_CONNECTION_SPAM:GetBool() and IPBuffer[realip][1] > SPAM_TRIES:GetInt() then
		DConn.Message(nick, '<', steamid, '> was kicked because of connection spam')
		return false, '[DConnecttt] Connection Spam!'
	end
	
	PendingConnect = {
		steamid = steamid,
		steamid64 = steamid64,
		nick = nick,
		ip = ip,
	}
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
		ChatPrint(PrefixColor, Prefix, ChatColor, name, ChatColor, '<', steamid, '> diconnected from server (' .. reason .. ')')
		DConn.Message(ChatColor, name, ConsoleColor, '<', steamid, '> diconnected from server (' .. reason .. ')')
		return
	end
	
	--data.name always shows real player nick
	name = ply:Nick()
	
	DConn.SavePlayerData(ply)
	
	if ply.SteamName and ply:SteamName() ~= name then --DarkRP
		name = name .. ' (' .. ply:SteamName() .. ')'
	end
	
	ChatPrint(PrefixColor, Prefix, ChatColor, team.GetColor(ply:Team()), name, ChatColor, '<', steamid, '> diconnected from server (' .. reason .. ')')
	DConn.Message(team.GetColor(ply:Team()), name, ConsoleColor, '<', steamid, '> diconnected from server (' .. reason .. ')')
end

local function Timer()
	local KICK_NOT_RESPONDING = KICK_NOT_RESPONDING:GetBool()
	
	for k, ply in pairs(player.GetAll()) do
		if not ply.DCONNECT_INITIALIZE then continue end
		
		ply.DConnecttt_Session = (ply.DConnecttt_Session or 0) + 1
		ply.DConnecttt_Total = (ply.DConnecttt_Total or 0) + 1
		ply:SetNWInt('DConnecttt_Session', ply.DConnecttt_Session)
		ply:SetNWInt('DConnecttt_Total', ply.DConnecttt_Total)
		
		ply.DConnecttt_LastTick = ply.DConnecttt_LastTick or CurTime()
		
		if ply:IsBot() then
			ply.DConnecttt_LastTick = CurTime()
		end
		
		ply:SetNWInt('DConnecttt_DeadTime', CurTime() - ply.DConnecttt_LastTick)
		
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
end

local plyMeta = FindMetaTable('Player')

function plyMeta:TotalTimeConnected()
	return self:GetNWInt('DConnecttt_Total')
end

function plyMeta:SessionTime()
	return self:GetNWInt('DConnecttt_Session')
end

--UTime interface
function plyMeta:GetUTimeSessionTime()
	return self:SessionTime()
end

--???
function plyMeta:GetUTime()
	return self:TotalTimeConnected()
end
--???
function plyMeta:GetUTimeTotalTime()
	return self:TotalTimeConnected()
end
--???

function plyMeta:SetUTime()
	--Do nothing
end

function plyMeta:SetUTimeStart()
	--Do nothing
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
