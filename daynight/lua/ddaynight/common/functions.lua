
-- Copyright (C) 2017-2019 DBot

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


local DLib = DLib
local math = math
local DDayNight = DDayNight
local util = util
local MASK_BLOCKLOS = MASK_BLOCKLOS
local Vector = Vector

function DDayNight.CheckOutdoorPoint(posIn)
	local tr = util.TraceLine({
		start = posIn + Vector(0, 0, 10),
		endpos = posIn + Vector(0, 0, 16000),
		mask = MASK_BLOCKLOS
	})

	return not tr.Hit or tr.HitSky
end

function DDayNight.CheckOutdoorPointHalf(posIn)
	local tr = util.TraceLine({
		start = posIn + Vector(0, 0, 10),
		endpos = posIn + Vector(0, 0, 8000),
		mask = MASK_BLOCKLOS
	})

	return not tr.Hit or tr.HitSky
end

function DDayNight.TraceSky(posIn)
	return util.TraceLine({
		start = posIn + Vector(0, 0, 10),
		endpos = posIn + Vector(0, 0, 16000),
		mask = MASK_BLOCKLOS
	})
end

function DDayNight.TraceSkyHalf(posIn)
	return util.TraceLine({
		start = posIn + Vector(0, 0, 10),
		endpos = posIn + Vector(0, 0, 8000),
		mask = MASK_BLOCKLOS
	})
end

function DDayNight.TraceSkyNear(posIn)
	return util.TraceLine({
		start = posIn + Vector(0, 0, 10),
		endpos = posIn + Vector(0, 0, 4000),
		mask = MASK_BLOCKLOS
	})
end

function DDayNight.GetSkyPosition(posIn)
	local tr = DDayNight.TraceSky(posIn)
	if tr.Hit and not tr.HitSky then return false end

	if tr.Fraction <= 0.1 then
		return tr.HitPos + Vector(0, 0, -5)
	else
		return posIn + Vector(0, 0, 1000)
	end
end

function DDayNight.GetSkyPositionHalf(posIn)
	local tr = DDayNight.TraceSkyHalf(posIn)
	if tr.Hit and not tr.HitSky then return false end

	if tr.Fraction <= 0.1 then
		return tr.HitPos + Vector(0, 0, -5)
	else
		return posIn + Vector(0, 0, 1000)
	end
end

function DDayNight.GetSkyPositionNear(posIn)
	if not DDayNight.CheckOutdoorPointHalf(posIn) then return false end
	local tr = DDayNight.TraceSkyNear(posIn)

	if tr.Fraction <= 0.125 then
		return tr.HitPos + Vector(0, 0, -5)
	else
		return posIn + Vector(0, 0, 500)
	end
end
