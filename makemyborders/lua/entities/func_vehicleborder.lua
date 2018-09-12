
-- Copyright (C) 2018 DBot

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


if SERVER then
	AddCSLuaFile()
end

local type = type
local hook = hook

ENT.Type = 'anim'
ENT.Author = 'DBotThePony'
ENT.PrintName = 'Vehicle Border'
ENT.Base = 'func_border'

function ENT:AllowObjectPass(objectIn, ifNothing)
	local typeIn = type(objectIn)

	if typeIn == 'string' then
		return true
	end

	if typeIn == 'number' then
		objectIn = Entity(objectIn)
		typeIn = type(objectIn)
	end

	if objectIn == NULL then
		return true
	end

	if typeIn == 'Vehicle' then
		return false
	end

	return true
end
