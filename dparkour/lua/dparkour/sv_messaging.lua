
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

-- fix singleplayer

local DParkour = DParkour
local util = util
local net = net
local game = game

util.AddNetworkString('dparkour.slide')
util.AddNetworkString('dparkour.roll')

function DParkour.__SendSlideStop()
	if not game.SinglePlayer() then return end
	net.Start('dparkour.slide')
	net.WriteBool(false)
	net.Broadcast()
end

function DParkour.__SendSlideStart(velocity)
	if not game.SinglePlayer() then return end
	net.Start('dparkour.slide')
	net.WriteBool(true)
	net.WriteVectorDouble(velocity)
	net.Broadcast()
end

function DParkour.__SendRolling(rolls, dir, ang)
	if not game.SinglePlayer() then return end
	net.Start('dparkour.roll')
	net.WriteUInt8(rolls)
	net.WriteVectorDouble(dir)
	net.WriteAngle(ang)
	net.Broadcast()
end
