
--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

import DMaps, Color, tostring, color_white, type, table, team from _G
import player from _G
import insert from table

DMaps.FormatMetre = (m = 0) -> "#{math.floor(m / DMaps.HU_IN_METRE * 10) / 10}m"
DMaps.DeltaColor = (first = Color(255, 255, 255), endColor = Color(0, 0, 0), delta = 0.5) -> DLib.LerpColor(delta, first, endColor)

DLib.CMessage(DMaps, 'DMaps')

DMaps.Message = (...) ->
	MsgC(PREFIX_COLOR, PREFIX_STRING, DEFAULT_COLOR, unpack(DMaps.Format(...)))
	MsgC('\n')
DMaps.MessageRaw = (tab) ->
	MsgC(PREFIX_COLOR, PREFIX_STRING, DEFAULT_COLOR, unpack(tab))
	MsgC('\n')
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
