
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
local IsValid = IsValid
local self = DDayNight

net.pool('ddaynight.replicateseed')
net.pool('ddaynight.fastforward')

local function DDayNight_SeedChanges()
	net.Start('ddaynight.replicateseed')
	net.WriteBigUInt(DDayNight.SEED_VALID, 64)
	net.Broadcast()
end

net.receive('ddaynight.replicateseed', function(len, ply)
	if not IsValid(ply) then return end

	net.Start('ddaynight.replicateseed')
	net.WriteBigUInt(DDayNight.SEED_VALID, 64)
	net.Send(ply)
end)

hook.Add('DDayNight_SeedChanges', 'DDayNight_ReplicateSeed', DDayNight_SeedChanges)

local assert = assert
local type = type
local CurTime = CurTimeL

function self.FastForwardTime(inGameSeconds, realSeconds)
	assert(not self.TIME_FAST_FORWARD, 'Already fast forwarding!')
	assert(type(inGameSeconds) == 'number', 'Invalid in game seconds provided. typeof ' .. type(inGameSeconds))

	if not realSeconds then
		realSeconds = (inGameSeconds:sqrt() / self.TIME_MULTIPLIER:GetFloat()):max(10)
	end

	if realSeconds < 10 then
		error('Too short fast forward time! ' .. realSeconds)
	end

	self.TIME_FAST_FORWARD = true
	self.TIME_FAST_FORWARD_SPEED = inGameSeconds / realSeconds
	self.TIME_FAST_FORWARD_START = CurTime()
	self.TIME_FAST_FORWARD_END = CurTime() + realSeconds
	self.TIME_FAST_FORWARD_LAST = CurTime()

	net.Start('ddaynight.fastforward')
	net.WriteDouble(self.TIME_FAST_FORWARD_SPEED)
	net.WriteDouble(self.TIME_FAST_FORWARD_START)
	net.WriteDouble(self.TIME_FAST_FORWARD_END)
	net.Broadcast()
end
