
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

local net = net
local DToyBox = DToyBox

net.pool('dtoybox.listing')
net.pool('dtoybox.addaddon')

net.receive('dtoybox.addaddon', function(len, ply)
	if not DToyBox.CanCommand(ply) then
		DToyBox.LMessagePlayer(ply, 'message.toybox.missing_access')
		return
	end

	DToyBox.LoadAddon(net.ReadUInt32())
end)

net.receive('dtoybox.listing', function(len, ply)
	net.Start('dtoybox.listing')

	for i, value in ipairs(DToyBox.DownloadListing) do
		net.WriteUInt32(value.wsid)
	end

	net.Send(ply)
end)
