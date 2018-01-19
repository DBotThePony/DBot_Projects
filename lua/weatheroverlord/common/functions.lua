
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
local WOverlord = WOverlord
local util = util
local MASK_BLOCKLOS = MASK_BLOCKLOS
local Vector = Vector

function WOverlord.CheckOutdoorPoint(posIn)
	local tr = util.TraceLine({
		start = posIn + Vector(0, 0, 10),
		endpos = posIn + Vector(0, 0, 16000),
		mask = MASK_BLOCKLOS
	})

	return not tr.Hit or tr.HitSky
end

function WOverlord.CheckOutdoorPointHalf(posIn)
	local tr = util.TraceLine({
		start = posIn + Vector(0, 0, 10),
		endpos = posIn + Vector(0, 0, 8000),
		mask = MASK_BLOCKLOS
	})

	return not tr.Hit or tr.HitSky
end

function WOverlord.TraceSky(posIn)
	return util.TraceLine({
		start = posIn + Vector(0, 0, 10),
		endpos = posIn + Vector(0, 0, 16000),
		mask = MASK_BLOCKLOS
	})
end

function WOverlord.TraceSkyHalf(posIn)
	return util.TraceLine({
		start = posIn + Vector(0, 0, 10),
		endpos = posIn + Vector(0, 0, 8000),
		mask = MASK_BLOCKLOS
	})
end

function WOverlord.GetSkyPosition(posIn)
	local tr = WOverlord.TraceSky(posIn)
	if tr.Hit and not tr.HitSky then return false end

	if tr.Fraction <= 0.125 then
		return tr.HitPos + Vector(0, 0, -5)
	else
		return posIn + Vector(0, 0, 2000)
	end
end

function WOverlord.GetSkyPositionHalf(posIn)
	local tr = WOverlord.TraceSkyHalf(posIn)
	if tr.Hit and not tr.HitSky then return false end

	if tr.Fraction <= 0.25 then
		return tr.HitPos + Vector(0, 0, -5)
	else
		return posIn + Vector(0, 0, 2000)
	end
end
