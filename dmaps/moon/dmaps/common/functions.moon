
--
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


import DMaps, Color, tostring, color_white, type, table, team from _G
import player from _G
import insert from table

DMaps.FormatMetre = (m = 0) -> DLib.string.fdistance(m)
DMaps.DeltaColor = (first = Color(255, 255, 255), endColor = Color(0, 0, 0), delta = 0.5) -> first\Lerp(delta, endColor)

DLib.CMessage(DMaps, 'DMaps')

DMaps.GetAdmins = ->
	output = {}
	for ply in *player.GetAll() do insert(output, ply) if ply\IsAdmin()
	return output

PARSE_PATTERNS = {
	{
		pattern: '-?[0-9.]+, ?-?[0-9.]+, ?-?[0-9.]+'
		func: (str = '', X = false, Y, Z) ->
			local x, y, z
			{x, y, z} = [tonumber(exp\Trim()) for exp in *string.Explode(',', str)]
			return x or X, y or Y, z or Z
	}

	{
		pattern: '-?[0-9.]+ -?[0-9.]+ -?[0-9.]+'
		func: (str = '', X = false, Y, Z) ->
			local x, y, z
			{x, y, z} = [tonumber(exp\Trim()) for exp in *string.Explode(' ', str)]
			return x or X, y or Y, z or Z
	}

	{
		pattern: '-?[0-9.]+; ?-?[0-9.]+; ?-?[0-9.]+'
		func: (str = '', X = false, Y, Z) ->
			local x, y, z
			{x, y, z} = [tonumber(exp\Trim()) for exp in *string.Explode(';', str)]
			return x or X, y or Y, z or Z
	}

	{
		pattern: 'X:? ?-?[0-9.]+, ?Y:? ?-?[0-9.]+, ?Z:? ?-?[0-9.]+'
		func: (str = '', X = false, Y, Z) ->
			local x, y, z
			exps = string.Explode(',', str)
			{x, y, z} = [tonumber(exp\match('[0-9.]+')\Trim()) for exp in *exps]
			return x or X, y or Y, z or Z
	}

	{
		pattern: 'X:? ?-?[0-9.]+, ?Z:? ?-?[0-9.]+, ?Y:? ?-?[0-9.]+'
		func: (str = '', X = false, Y, Z) ->
			local x, y, z
			exps = string.Explode(',', str)
			{x, z, y} = [tonumber(exp\match('[0-9.]+')\Trim()) for exp in *exps]
			return x or X, y or Y, z or Z
	}
}

DMaps.ParseCoordinates = (str = '', x = false, y, z) ->
	for {:pattern, :func} in *PARSE_PATTERNS
		match = str\match(pattern)
		if not match continue
		return func(match, x, y, z)
	return x, y, z
