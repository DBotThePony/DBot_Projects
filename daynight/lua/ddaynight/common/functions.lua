
-- Copyright (C) 2017-2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

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
