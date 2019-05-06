
--[[
Copyright (C) 2016-2019 DBotThePony


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

	for i, ply in pairs(player.GetHumans()) do
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
