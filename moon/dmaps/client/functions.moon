
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

DMaps.DeltaString = (z = 0, newline = true) ->
	delta = LocalPlayer()\GetPos().z - z
	return "#{DMaps.FormatMetre(delta)} lower" if delta > 200 and not newline
	return "\n#{DMaps.FormatMetre(delta)} lower" if delta > 200 and newline
	return "#{DMaps.FormatMetre(-delta)} upper" if -delta > 200 and not newline
	return "\n#{DMaps.FormatMetre(-delta)} upper" if -delta > 200 and newline
	return ''
DMaps.ChatPrint = (...) ->
	formated = DMaps.Format(...)
	chat.AddText(DMaps.CHAT_PREFIX_COLOR, DMaps.CHAT_PREFIX, DMaps.CHAT_COLOR, unpack(formated))
DMaps.WaypointAction = (x = 0, y = 0, z = 0) ->
	x, y, z = math.floor(x), math.floor(y), math.floor(z)
	data, id = DMaps.ClientsideWaypoint.DataContainer\CreateWaypoint("New Waypoint At X: #{x}, Y: #{y}, Z: #{z}", x, y, z)
	DMaps.OpenWaypointEditMenu(id, DMaps.ClientsideWaypoint.DataContainer, (-> DMaps.ClientsideWaypoint.DataContainer\DeleteWaypoint(id))) if id
DMaps.CopyMenus = (menu, x = 0, y = 0, z = 0, text = 'Copy...') ->
	Pos = Vector(x, y, z)
	subCopy = menu\AddSubMenu(text)
	pos = LocalPlayer()\GetPos()
	with subCopy
		\AddOption 'Copy X', -> SetClipboardText("#{math.floor x}")
		\AddOption 'Copy Y', -> SetClipboardText("#{math.floor y}")
		\AddOption 'Copy Z', -> SetClipboardText("#{math.floor z}")
		\AddOption 'Copy Vector(x, y, z)', -> SetClipboardText("Vector(#{math.floor x}, #{math.floor y}, #{math.floor z})")
		\AddOption 'Copy Vector(x.x, y.y, z.z)', -> SetClipboardText("Vector(#{x}, #{y}, #{z})")
		\AddOption 'Copy X: x, Y: y, Z: z', -> SetClipboardText("X: #{math.floor x} Y: #{math.floor y} Z: #{math.floor z}")
		\AddOption 'Copy X: x.x, Y: y.y, Z: z.z', -> SetClipboardText("X: #{x} Y: #{y} Z: #{z}")
		\AddOption 'Copy distance to in Hammer units', -> SetClipboardText(tostring(math.floor(pos\Distance(Pos))))
		\AddOption 'Copy distance to in Metres', -> SetClipboardText(tostring(math.floor(pos\Distance(Pos) / DMaps.HU_IN_METRE * 10) / 10))
		\AddSpacer()
		\AddOption 'Copy Angle(p, y, r)', ->
			{:p, y: Yaw, :r} = (Pos - pos)\Angle()
			SetClipboardText("Angle(#{math.floor p}, #{math.floor Yaw}, #{math.floor r})")
		\AddOption 'Copy Pitch: P, Yaw: Y, Roll: R', ->
			{:p, y: Yaw, :r} = (Pos - pos)\Angle()
			SetClipboardText("Pitch: #{math.floor p}, Yaw: #{math.floor Yaw}, Roll: #{math.floor r}")
		\AddOption 'Copy Angle(p, y, r) reversed', ->
			{:p, y: Yaw, :r} = (pos - Pos)\Angle()
			SetClipboardText("Angle(#{math.floor p}, #{math.floor Yaw}, #{math.floor r})")
		\AddOption 'Copy Pitch: P, Yaw: Y, Roll: R reversed', ->
			{:p, y: Yaw, :r} = (pos - Pos)\Angle()
			SetClipboardText("Pitch: #{math.floor p}, Yaw: #{math.floor Yaw}, Roll: #{math.floor r}")
	return subCopy

vehMeta = FindMetaTable('Vehicle')
vehMeta.GetDriver = => @GetNWEntity('DMaps.Driver')
