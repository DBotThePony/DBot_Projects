
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

import DMaps, util, file, input, table from _G

DMaps.KeybindingsMap =
	left:
		name: 'Left'
		desc: 'Move map to left side'
		primary: {KEY_A}
		secondary: {KEY_LEFT}
		order: 2
	right:
		name: 'Right'
		desc: 'Move map to right side'
		primary: {KEY_D}
		secondary: {KEY_RIGHT}
		order: 3
	up:
		name: 'Up'
		desc: 'Move map to up side'
		primary: {KEY_W}
		secondary: {KEY_UP}
		order: 0
	down:
		name: 'Down'
		desc: 'Move map to down side'
		primary: {KEY_S}
		secondary: {KEY_DOWN}
		order: 1

	duck:
		name: 'Duck'
		desc: 'Move map slower using WASD'
		primary: {KEY_LCONTROL}
		secondary: {KEY_RCONTROL}
		order: 5
	speed:
		name: 'Speed'
		desc: 'Move map faster using WASD'
		primary: {KEY_LSHIFT}
		secondary: {KEY_RSHIFT}
		order: 4
	reset:
		name: 'Reset'
		desc: 'Quick reset map zoom, clip and position'
		primary: {KEY_R}
		order: 6
	quick_navigation:
		name: 'Quick navigation'
		desc: 'Quick navigate to hovered point'
		primary: {KEY_N}
		order: 8

	help:
		name: 'Help label'
		desc: ''
		primary: {KEY_F1}
		order: 7

	copy_vector:
		name: 'Copy a vector'
		desc: 'Copies Vector(x.x, y.y, z.z) of hovered position'
		primary: {KEY_LCONTROL, KEY_C}
		order: 13

	teleport:
		name: 'Teleport'
		desc: 'Quick teleport to hovered position'
		primary: {KEY_T}
		order: 9

	zoomin:
		name: 'Zoom in'
		desc: 'Zoom in hovered location'
		primary: {KEY_Q}
		order: 10
	zoomout:
		name: 'Zoom out'
		desc: 'Zoom out hovered location'
		primary: {KEY_E}
		order: 11
	new_point:
		name: 'New waypoint'
		desc: 'Quickly create a new clientside waypoint at hovered location'
		primary: {KEY_F}
		order: 12
	cave:
		name: 'Switch cave mode'
		desc: 'Quicky switch cave mode ON/OFF'
		primary: {KEY_X}
		order: 20

DMaps.KeybindsClass = DLib.bind.KeyBindsAdapter('DMaps', DMaps.KeybindingsMap)
DLib.bind.exportBinds(DMaps.KeybindsClass, DMaps)
