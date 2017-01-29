
--[[
Copyright (C) 2016-2017 DBot

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

util.AddNetworkString('DAFK.StatusChanges')
util.AddNetworkString('DAFK.Heartbeat')
util.AddNetworkString('DAFK.HasFocus')

local function Awake(ply)
	local oldTime = ply:GetAFKTime()
	ply:SetAFKTime(0)
	if not ply:IsAFK() then return end
	ply:SetIsAFK(false)
	
	
	net.Start('DAFK.StatusChanges')
	net.WriteEntity(ply)
	net.WriteBool(false)
	net.WriteUInt(oldTime, 32)
	net.Broadcast()
	
	MsgC(unpack(ply:GenerateAFKMessage(false, oldTime)))
	MsgC('\n')
end

local function Sleep(ply)
	ply:SetIsAFK(true)
	net.Start('DAFK.StatusChanges')
	net.WriteEntity(ply)
	net.WriteBool(true)
	net.Broadcast()
	MsgC(unpack(ply:GenerateAFKMessage(true)))
	MsgC('\n')
end

local function KeyPress(ply)
	Awake(ply)
end

local function Heartbeat(len, ply)
	Awake(ply)
end

local function Timer()
	local min = DAFK_MINTIMER:GetInt()
	
	for k, v in ipairs(player.GetAll()) do
		v:SetAFKTime(v:GetAFKTime() + 1)
		if not v:IsAFK() and v:GetAFKTime() >= min then
			Sleep(v)
		end
	end
end

local function HasFocus(len, ply)
	local status = net.ReadBool()
	
	ply.__DAFK_TabbedOut = not status
	
	net.Start('DAFK.HasFocus')
	net.WriteEntity(ply)
	net.WriteBool(status)
	net.Broadcast()
end

net.Receive('DAFK.Heartbeat', Heartbeat)
net.Receive('DAFK.HasFocus', HasFocus)
hook.Add('KeyPress', 'DAFK.Hooks', KeyPress)
timer.Create('DAFK.Timer', 1, 0, Timer)
