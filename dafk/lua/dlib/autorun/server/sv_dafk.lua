
--[[
Copyright (C) 2016-2018 DBot

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

net.pool('DAFK.StatusChanges')
net.pool('DAFK.Heartbeat')
net.pool('DAFK.HasFocus')

local function Awake(ply)
	local oldTime = ply:GetAFKTime()
	ply.__DAFK_SLEEP = 0
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

local function Heartbeat(len, ply)
	Awake(ply)
end

local function Timer()
	local min = DAFK_MINTIMER:GetInt()

	for i, ply in pairs(player.GetAll()) do
		ply.__DAFK_SLEEP = (ply.__DAFK_SLEEP or 0) + 1

		if not ply:IsAFK() and ply.__DAFK_SLEEP >= min then
			Sleep(ply)
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

local function StartCommand(self, cmd)
	if not DAFK_USEANGLES:GetBool() then return end

	if cmd:GetMouseX() ~= 0 or cmd:GetMouseY() ~= 0 then
		Awake(self)
	end
end

net.Receive('DAFK.Heartbeat', Heartbeat)
net.Receive('DAFK.HasFocus', HasFocus)
hook.Add('KeyPress', 'DAFK.Hooks', Awake)
hook.Add('StartCommand', 'DAFK.Hooks', StartCommand)
timer.Create('DAFK.Timer', 1, 0, Timer)
