
-- Copyright (C) 2018-2019 DBotThePony

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

_G.DParkour = DParkour or {}

local function shared(luafile)
	include(luafile)
	AddCSLuaFile(luafile)
end

local function client(luafile)
	if CLIENT then
		include(luafile)
	else
		AddCSLuaFile(luafile)
	end
end

local function server(luafile)
	if CLIENT then return end
	include(luafile)
end

shared('dparkour/sounds.lua')
shared('dparkour/eventloop.lua')
shared('dparkour/wall_climb.lua')
shared('dparkour/wall_hang.lua')
shared('dparkour/wall_jump.lua')
shared('dparkour/wall_run.lua')
shared('dparkour/sliding.lua')
client('dparkour/cl_sliding.lua')
shared('dparkour/roll.lua')
client('dparkour/cl_roll.lua')
server('dparkour/sv_roll.lua')

--_G.DParkour = nil
