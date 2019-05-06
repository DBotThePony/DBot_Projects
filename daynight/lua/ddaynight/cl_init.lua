
-- Copyright (C) 2017-2019 DBotThePony

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

local function daynight_fastforward_ambient()
	LocalPlayer():EmitSound('daynight_fastforward_ambient')
end

sound.Add({
	name = 'daynight_fastforward_ambient',
	channel = CHAN_AUTO,
	volume = 0.15,
	level = 75,
	pitch = 100,
	sound = 'ambient/brandon3055/sun_dial_effect.ogg'
})

net.receive('ddaynight.fastforward', function()
	self.TIME_FAST_FORWARD = true
	self.TIME_FAST_FORWARD_SPEED = net.ReadDouble()
	self.TIME_FAST_FORWARD_START = net.ReadDouble()
	self.TIME_FAST_FORWARD_END = net.ReadDouble()
	self.TIME_FAST_FORWARD_LAST = self.TIME_FAST_FORWARD_START

	hook.Run('DDayNight_FastForwardStart')

	daynight_fastforward_ambient()
	timer.Create('daynight_fastforward_ambient', 3.899, 0, daynight_fastforward_ambient)
end)

hook.Add('DDayNight_FastForwardEnd', 'DDayNight_Ambient', function()
	LocalPlayer():StopSound('daynight_fastforward_ambient')
	timer.Remove('daynight_fastforward_ambient')
end)

local startup = Sound('ambient/brandon3055/charge.ogg')
local shutdown = Sound('ambient/brandon3055/discharge.ogg')

net.receive('ddaynight.fastforward_sound', function()
	local toplay = net.ReadBool()
	self.TIME_FAST_FORWARD_SEQ = toplay
	LocalPlayer():EmitSound(toplay and startup or shutdown, 75, 100 + net.ReadInt16(), 0.2)
end)
