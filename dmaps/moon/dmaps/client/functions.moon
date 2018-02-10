
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

DMaps.DeltaString = (z = 0, newline = true) -> DLib.string.ddistance(z, newline)

DMaps.WaypointAction = (x = 0, y = 0, z = 0) ->
	x, y, z = math.floor(x), math.floor(y), math.floor(z)
	data, id = DMaps.ClientsideWaypoint.DataContainer\CreateWaypoint("New Waypoint At X: #{x}, Y: #{y}, Z: #{z}", x, y, z)
	DMaps.OpenWaypointEditMenu(id, DMaps.ClientsideWaypoint.DataContainer, (-> DMaps.ClientsideWaypoint.DataContainer\DeleteWaypoint(id))) if id

DMaps.CopyMenus = (menu, x = 0, y = 0, z = 0, text = 'Copy...') ->
	Pos = Vector(x, y, z)
	subCopy = menu\AddSubMenu(text)
	pos = LocalPlayer()\GetPos()
	with subCopy
		\AddOption('Copy X', -> SetClipboardText("#{math.floor x}"))\SetIcon('icon16/vector.png')
		\AddOption('Copy Y', -> SetClipboardText("#{math.floor y}"))\SetIcon('icon16/vector.png')
		\AddOption('Copy Z', -> SetClipboardText("#{math.floor z}"))\SetIcon('icon16/vector.png')
		\AddOption('Copy Vector(x, y, z)', -> SetClipboardText("Vector(#{math.floor x}, #{math.floor y}, #{math.floor z})"))\SetIcon('icon16/vector_add.png')
		\AddOption('Copy Vector(x.x, y.y, z.z)', -> SetClipboardText("Vector(#{x}, #{y}, #{z})"))\SetIcon('icon16/vector_add.png')
		\AddOption('Copy X: x, Y: y, Z: z', -> SetClipboardText("X: #{math.floor x} Y: #{math.floor y} Z: #{math.floor z}"))\SetIcon('icon16/vector.png')
		\AddOption('Copy X: x.x, Y: y.y, Z: z.z', -> SetClipboardText("X: #{x} Y: #{y} Z: #{z}"))\SetIcon('icon16/vector.png')
		\AddOption('Copy distance to in Hammer units', -> SetClipboardText(tostring(math.floor(pos\Distance(Pos)))))\SetIcon('icon16/lorry_go.png')
		\AddOption('Copy distance to in Metres', -> SetClipboardText(tostring(math.floor(pos\Distance(Pos) / DMaps.HU_IN_METRE * 10) / 10)))\SetIcon('icon16/lorry_go.png')
		\AddSpacer()
		\AddOption('Copy Angle(p, y, r)', ->
			{:p, y: Yaw, :r} = (Pos - pos)\Angle()
			SetClipboardText("Angle(#{math.floor p}, #{math.floor Yaw}, #{math.floor r})")
		)\SetIcon(table.Random(DMaps.TAGS_ICONS))
		\AddOption('Copy Pitch: P, Yaw: Y, Roll: R', ->
			{:p, y: Yaw, :r} = (Pos - pos)\Angle()
			SetClipboardText("Pitch: #{math.floor p}, Yaw: #{math.floor Yaw}, Roll: #{math.floor r}")
		)\SetIcon(table.Random(DMaps.TAGS_ICONS))
		\AddOption('Copy Angle(p, y, r) reversed', ->
			{:p, y: Yaw, :r} = (pos - Pos)\Angle()
			SetClipboardText("Angle(#{math.floor p}, #{math.floor Yaw}, #{math.floor r})")
		)\SetIcon(table.Random(DMaps.TAGS_ICONS))
		\AddOption('Copy Pitch: P, Yaw: Y, Roll: R reversed', ->
			{:p, y: Yaw, :r} = (pos - Pos)\Angle()
			SetClipboardText("Pitch: #{math.floor p}, Yaw: #{math.floor Yaw}, Roll: #{math.floor r}")
		)\SetIcon(table.Random(DMaps.TAGS_ICONS))
	return subCopy

LastSound = 0

DMaps.Notify = (message, Type, time = 5) ->
	if LastSound < RealTime()
		if Type == NOTIFY_ERROR
			surface.PlaySound('buttons/button10.wav')
		elseif Type == NOTIFY_UNDO
			surface.PlaySound('buttons/button15.wav')
		else
			surface.PlaySound('npc/turret_floor/click1.wav')
		LastSound = RealTime() + 0.1

	if type(message) == 'table'
		DMaps.Message(unpack(message))
		str = ''

		for v in *message
			if type(v) == 'string'
				if v\sub(1, 6) ~= '<STEAM'
					str ..= v
		notification.AddLegacy(str, Type, time)
	else
		DMaps.Message(message)
		notification.AddLegacy(message, Type, time)

