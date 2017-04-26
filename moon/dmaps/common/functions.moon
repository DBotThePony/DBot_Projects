
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

PREFIX_COLOR = Color(0, 200, 0)
PREFIX_STRING = '[DMaps] '
DEFAULT_COLOR = Color(200, 200, 200)
NUMBER_COLOR = Color(255, 128, 0)

DMaps.FormatMetre = (m = 0) -> "#{math.floor(m / DMaps.HU_IN_METRE * 10) / 10}m"
DMaps.DeltaColor = (first = Color(255, 255, 255), endColor = Color(0, 0, 0), delta = 0.5) ->
	delta2 = 1 - delta
	r = first.r * delta + endColor.r * delta2
	g = first.g * delta + endColor.g * delta2
	b = first.b * delta + endColor.b * delta2
	a = first.a * delta + endColor.a * delta2
	return Color(r, g, b, a)
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
DMaps.RandomColor = -> Color(math.random(0, 255), math.random(0, 255), math.random(0, 255))
DMaps.Format = (...) ->
	previousColor = DEFAULT_COLOR
	output = {previousColor}
	
	for value in *{...}
		switch type(value)
			when 'table'
				if value.r and value.g and value.b and value.a
					insert(output, value)
					previousColor = value
			when 'Entity'
				insert(output, color_white)
				insert(output, tostring(value))
				insert(output, previousColor)
			when 'string'
				insert(output, tostring(value))
			when 'number'
				insert(output, NUMBER_COLOR)
				insert(output, tostring(value))
				insert(output, previousColor)
			when 'Player'
				tm = value\Team()
				insert(output, team.GetColor(tm))
				insert(output, value\Nick())
				insert(output, color_white)
				insert(output, "<#{value\SteamID()}>")
				insert(output, previousColor)
			when 'NPC'
				insert(output, color_white)
				insert(output, "[NPC:#{value\GetClass()}]")
				insert(output, previousColor)
			when 'Vehicle'
				insert(output, color_white)
				insert(output, "[Vehicle:#{value\GetClass()}|#{value\GetModel()}]")
				insert(output, previousColor)
			else
				insert(output, tostring(value))
	return output
DMaps.WriteArray = (tab) ->
	net.WriteUInt(#tab, 16)
	net.WriteType(val) for val in *tab
DMaps.ReadArray = -> [net.ReadType() for i = 1, net.ReadUInt(16)]