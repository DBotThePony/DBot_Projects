
-- Copyright (C) 2017-2018 DBot

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


local DDayNight = DDayNight
local DLib = DLib
local net = net
local hook = hook
local self = DDayNight

net.receive('ddaynight.replicateseed', function()
	local old = DDayNight.SEED_VALID
	DDayNight.SEED_VALID = net.ReadUInt(64)

	if old ~= DDayNight.SEED_VALID then
		hook.Run('DDayNight_SeedChanges', old, DDayNight.SEED_VALID)
	end
end)

if IsValid(LocalPlayer()) then
	net.Start('ddaynight.replicateseed')
	net.SendToServer()
else
	local frame = 0
	hook.Add('Think', 'DDayNight_RequestSeed', function()
		if not IsValid(LocalPlayer()) then return end

		frame = frame + 1
		if frame < 200 then return end

		hook.Remove('Think', 'DDayNight_RequestSeed')
		net.Start('ddaynight.replicateseed')
		net.SendToServer()
	end)
end

local CurTime = CurTimeL

net.receive('ddaynight.fastforward', function()
	self.TIME_FAST_FORWARD = true
	self.TIME_FAST_FORWARD_SPEED = net.ReadDouble()
	self.TIME_FAST_FORWARD_START = net.ReadDouble()
	self.TIME_FAST_FORWARD_END = net.ReadDouble()
	self.TIME_FAST_FORWARD_LAST = self.TIME_FAST_FORWARD_START
end)
