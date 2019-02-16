
-- Copyright (C) 2018-2019 DBot

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

local DToyBox = DToyBox
local net = net
local assert = assert
local type = type

if DToyBox.ReceivedListing == nil then
	DToyBox.ReceivedListing = false
end

net.receive('dtoybox.listing', function(len)
	DToyBox.ReceivedListing = true

	for i = 1, len / 32 do
		DToyBox.LoadAddon(net.ReadUInt32())
	end
end)

net.receive('dtoybox.addaddon', function(len)
	local wsid = net.ReadUInt32()

	if DToyBox.ShouldLoadAddon(wsid) then
		DToyBox.LoadAddon(wsid)
	end
end)

function DToyBox.RequestServerLoadAddon(wsid)
	assert(type(wsid) == 'number', 'WorkshopID must be a number!')
	assert(wsid > 0, 'Invalid workshopid')

	net.Start('dtoybox.addaddon')
	net.WriteUInt32(wsid)
	net.SendToServer()
end

local frames = 0
local moveframes = 0
local LocalPlayer = LocalPlayer

hook.Add('Think', 'DToyBox.Request', function()
	local ply = LocalPlayer()
	if not ply:IsValid() then return end

	frames = frames + 1

	if ply:GetVelocity():Length() > 30 then
		moveframes = moveframes + 1
	end

	if moveframes > 50 or frames > 300 then
		net.Start('dtoybox.listing')
		net.SendToServer()

		hook.Remove('Think', 'DToyBox.Request')
	end
end)
