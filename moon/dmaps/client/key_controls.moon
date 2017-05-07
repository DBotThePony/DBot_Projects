
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

DMaps.KeyMap = {
	[KEY_FIRST]: 'FIRST'
	[KEY_NONE]: 'NONE'
	[KEY_0]: '0'
	[KEY_1]: '1'
	[KEY_2]: '2'
	[KEY_3]: '3'
	[KEY_4]: '4'
	[KEY_5]: '5'
	[KEY_6]: '6'
	[KEY_7]: '7'
	[KEY_8]: '8'
	[KEY_9]: '9'
	[KEY_A]: 'A'
	[KEY_B]: 'B'
	[KEY_C]: 'C'
	[KEY_D]: 'D'
	[KEY_E]: 'E'
	[KEY_F]: 'F'
	[KEY_G]: 'G'
	[KEY_H]: 'H'
	[KEY_I]: 'I'
	[KEY_J]: 'J'
	[KEY_K]: 'K'
	[KEY_L]: 'L'
	[KEY_M]: 'M'
	[KEY_N]: 'N'
	[KEY_O]: 'O'
	[KEY_P]: 'P'
	[KEY_Q]: 'Q'
	[KEY_R]: 'R'
	[KEY_S]: 'S'
	[KEY_T]: 'T'
	[KEY_U]: 'U'
	[KEY_V]: 'V'
	[KEY_W]: 'W'
	[KEY_X]: 'X'
	[KEY_Y]: 'Y'
	[KEY_Z]: 'Z'
	[KEY_PAD_0]: 'PAD_0'
	[KEY_PAD_1]: 'PAD_1'
	[KEY_PAD_2]: 'PAD_2'
	[KEY_PAD_3]: 'PAD_3'
	[KEY_PAD_4]: 'PAD_4'
	[KEY_PAD_5]: 'PAD_5'
	[KEY_PAD_6]: 'PAD_6'
	[KEY_PAD_7]: 'PAD_7'
	[KEY_PAD_8]: 'PAD_8'
	[KEY_PAD_9]: 'PAD_9'
	[KEY_PAD_DIVIDE]: 'PAD_DIVIDE'
	[KEY_PAD_MULTIPLY]: 'PAD_MULTIPLY'
	[KEY_PAD_MINUS]: 'PAD_MINUS'
	[KEY_PAD_PLUS]: 'PAD_PLUS'
	[KEY_PAD_ENTER]: 'PAD_ENTER'
	[KEY_PAD_DECIMAL]: 'PAD_DECIMAL'
	[KEY_LBRACKET]: 'LBRACKET'
	[KEY_RBRACKET]: 'RBRACKET'
	[KEY_SEMICOLON]: 'SEMICOLON'
	[KEY_APOSTROPHE]: 'APOSTROPHE'
	[KEY_BACKQUOTE]: 'BACKQUOTE'
	[KEY_COMMA]: 'COMMA'
	[KEY_PERIOD]: 'PERIOD'
	[KEY_SLASH]: 'SLASH'
	[KEY_BACKSLASH]: 'BACKSLASH'
	[KEY_MINUS]: 'MINUS'
	[KEY_EQUAL]: 'EQUAL'
	[KEY_ENTER]: 'ENTER'
	[KEY_SPACE]: 'SPACE'
	[KEY_BACKSPACE]: 'BACKSPACE'
	[KEY_TAB]: 'TAB'
	[KEY_CAPSLOCK]: 'CAPSLOCK'
	[KEY_NUMLOCK]: 'NUMLOCK'
	[KEY_ESCAPE]: 'ESCAPE'
	[KEY_SCROLLLOCK]: 'SCROLLLOCK'
	[KEY_INSERT]: 'INSERT'
	[KEY_DELETE]: 'DELETE'
	[KEY_HOME]: 'HOME'
	[KEY_END]: 'END'
	[KEY_PAGEUP]: 'PAGEUP'
	[KEY_PAGEDOWN]: 'PAGEDOWN'
	[KEY_BREAK]: 'BREAK'
	[KEY_LSHIFT]: 'LSHIFT'
	[KEY_RSHIFT]: 'RSHIFT'
	[KEY_LALT]: 'LALT'
	[KEY_RALT]: 'RALT'
	[KEY_LCONTROL]: 'LCONTROL'
	[KEY_RCONTROL]: 'RCONTROL'
	[KEY_LWIN]: 'LWIN'
	[KEY_RWIN]: 'RWIN'
	[KEY_APP]: 'APP'
	[KEY_UP]: 'UP'
	[KEY_LEFT]: 'LEFT'
	[KEY_DOWN]: 'DOWN'
	[KEY_RIGHT]: 'RIGHT'
	[KEY_F1]: 'F1'
	[KEY_F2]: 'F2'
	[KEY_F3]: 'F3'
	[KEY_F4]: 'F4'
	[KEY_F5]: 'F5'
	[KEY_F6]: 'F6'
	[KEY_F7]: 'F7'
	[KEY_F8]: 'F8'
	[KEY_F9]: 'F9'
	[KEY_F10]: 'F10'
	[KEY_F11]: 'F11'
	[KEY_F12]: 'F12'
	[KEY_CAPSLOCKTOGGLE]: 'CAPSLOCKTOGGLE'
	[KEY_NUMLOCKTOGGLE]: 'NUMLOCKTOGGLE'
	[KEY_LAST]: 'LAST'
	[KEY_SCROLLLOCKTOGGLE]: 'SCROLLLOCKTOGGLE'
	[KEY_COUNT]: 'COUNT'
	[KEY_XBUTTON_A]: 'XBUTTON_A'
	[KEY_XBUTTON_B]: 'XBUTTON_B'
	[KEY_XBUTTON_X]: 'XBUTTON_X'
	[KEY_XBUTTON_Y]: 'XBUTTON_Y'
	[KEY_XBUTTON_LEFT_SHOULDER]: 'XBUTTON_LEFT_SHOULDER'
	[KEY_XBUTTON_RIGHT_SHOULDER]: 'XBUTTON_RIGHT_SHOULDER'
	[KEY_XBUTTON_BACK]: 'XBUTTON_BACK'
	[KEY_XBUTTON_START]: 'XBUTTON_START'
	[KEY_XBUTTON_STICK1]: 'XBUTTON_STICK1'
	[KEY_XBUTTON_STICK2]: 'XBUTTON_STICK2'
	[KEY_XBUTTON_UP]: 'XBUTTON_UP'
	[KEY_XBUTTON_RIGHT]: 'XBUTTON_RIGHT'
	[KEY_XBUTTON_DOWN]: 'XBUTTON_DOWN'
	[KEY_XBUTTON_LEFT]: 'XBUTTON_LEFT'
	[KEY_XSTICK1_RIGHT]: 'XSTICK1_RIGHT'
	[KEY_XSTICK1_LEFT]: 'XSTICK1_LEFT'
	[KEY_XSTICK1_DOWN]: 'XSTICK1_DOWN'
	[KEY_XSTICK1_UP]: 'XSTICK1_UP'
	[KEY_XBUTTON_LTRIGGER]: 'XBUTTON_LTRIGGER'
	[KEY_XBUTTON_RTRIGGER]: 'XBUTTON_RTRIGGER'
	[KEY_XSTICK2_RIGHT]: 'XSTICK2_RIGHT'
	[KEY_XSTICK2_LEFT]: 'XSTICK2_LEFT'
	[KEY_XSTICK2_DOWN]: 'XSTICK2_DOWN'
	[KEY_XSTICK2_UP]: 'XSTICK2_UP'
}

KEY_LIST = [key for key, str in pairs DMaps.KeyMap]
DMaps.KeyMapReverse = {v, k for k, v in pairs DMaps.KeyMap}

DMaps.KeybindingsMap =
	left:
		name: 'Left'
		desc: 'Move map to left side'
		primary: {KEY_A}
		secondary: {KEY_LEFT}
	right:
		name: 'Right'
		desc: 'Move map to right side'
		primary: {KEY_D}
		secondary: {KEY_RIGHT}
	up:
		name: 'Up'
		desc: 'Move map to up side'
		primary: {KEY_W}
		secondary: {KEY_UP}
	down:
		name: 'Down'
		desc: 'Move map to down side'
		primary: {KEY_S}
		secondary: {KEY_DOWN}

	duck:
		name: 'Duck'
		desc: 'Move map slower using WASD'
		primary: {KEY_LCONTROL}
		secondary: {KEY_RCONTROL}
	speed:
		name: 'Speed'
		desc: 'Move map faster using WASD'
		primary: {KEY_LSHIFT}
		secondary: {KEY_RSHIFT}
	reset:
		name: 'Reset'
		desc: 'Quick reset map zoom, clip and position'
		primary: {KEY_R}
	quick_navigation:
		name: 'Quick navigation'
		desc: 'Quick navigate to hovered point'
		primary: {KEY_N}
	
	help:
		name: 'Help label'
		desc: ''
		primary: {KEY_F1}
	
	copy_vector:
		name: 'Copy a vector'
		desc: 'Copies Vector(x.x, y.y, z.z) of hovered position'
		primary: {KEY_LCONTROL, KEY_C}
	
	teleport:
		name: 'Teleport'
		desc: 'Quick teleport to hovered position'
		primary: {KEY_T}
	
	zoomin:
		name: 'Zoom in'
		desc: 'Zoom in hovered location'
		primary: {KEY_Q}
	zoomout:
		name: 'Zoom out'
		desc: 'Zoom out hovered location'
		primary: {KEY_E}
	new_point:
		name: 'New waypoint'
		desc: 'Quickly create a new clientside waypoint at hovered location'
		primary: {KEY_F}

DMaps.RegisterBind = (id, name = '#BINDNAME?', desc = '#BINDDESC?', primary = {}, secondary = {}) ->
	error('No ID specified!') if not id
	DMaps.KeybindingsMap[id] = {:name, :desc, :primary, :secondary}

hook.Run('DMaps.RegisterBindings', DMaps.RegisterBind)
for name, data in pairs DMaps.KeybindingsMap
	data.secondary = data.secondary or {}
	data.name = data.name or '#BINDNAME?'
	data.desc = data.desc or '#BINDDESC?'

DMaps.SerealizeKeys = (keys = {}) ->
	output = for k in *keys
		key = DMaps.KeyMap[k]
		if not key continue
		key
	return output
DMaps.UnSerealizeKeys = (keys = {}) ->
	output = for k in *keys
		key = DMaps.KeyMapReverse[k]
		if not key continue
		key
	return output
DMaps.GetDefaultBindings = ->
	output = for id, data in pairs DMaps.KeybindingsMap
		primary = DMaps.SerealizeKeys(data.primary)
		secondary = DMaps.SerealizeKeys(data.secondary)
		{name: id, :primary, :secondary}
	return output

DMaps.UpdateKeysMap = ->
	watchButtons = {key, true for data in *DMaps.Keybindings for key in *data.primary}
	watchButtons[key] = true for data in *DMaps.Keybindings for key in *data.secondary
	DMaps.KeybindingsUserMap = {data.name, data for data in *DMaps.Keybindings}
	DMaps.KeybindingsUserMapCheck = {data.name, {name: data.name, primary: DMaps.UnSerealizeKeys(data.primary), secondary: DMaps.UnSerealizeKeys(data.secondary)} for data in *DMaps.Keybindings}
	DMaps.WatchingButtons = [DMaps.KeyMapReverse[key] for key, bool in pairs watchButtons]
	DMaps.PressedButtons = {key, false for key in *DMaps.WatchingButtons}
	DMaps.WatchingButtonsPerBinding = {key, {} for key in *DMaps.WatchingButtons}
	DMaps.BindPressStatus = {data.name, false for data in *DMaps.Keybindings}

	for {:name, :primary, :secondary} in *DMaps.Keybindings
		for key in *primary
			table.insert(DMaps.WatchingButtonsPerBinding[DMaps.KeyMapReverse[key]], name)
		for key in *secondary
			table.insert(DMaps.WatchingButtonsPerBinding[DMaps.KeyMapReverse[key]], name)

DMaps.SetKeyCombination = (bindid = '', isPrimary = true, keys = {}, update = true, doSave = true) ->
	if not DMaps.KeybindingsMap[bindid] return false
	if not DMaps.KeybindingsUserMap[bindid] return false
	if isPrimary
		for data in *DMaps.Keybindings
			if data.name == bindid
				data.primary = keys
				break
	else
		for data in *DMaps.Keybindings
			if data.name == bindid
				data.secondary = keys
				break
	
	DMaps.UpdateKeysMap() if update
	DMaps.SaveKeybindings() if doSave
	return true

DMaps.IsKeyDown = (keyid = KEY_NONE) -> DMaps.PressedButtons[keyid] or false
DMaps.IsBindPressed = (bindid = '') ->
	if not DMaps.KeybindingsMap[bindid] return false
	if not DMaps.KeybindingsUserMap[bindid] return false
	return DMaps.BindPressStatus[bindid] or false
DMaps.IsBindDown = DMaps.IsBindPressed
DMaps.InternalIsBindPressed = (bindid = '') ->
	if not DMaps.KeybindingsMap[bindid] return false
	if not DMaps.KeybindingsUserMapCheck[bindid] return false
	data = DMaps.KeybindingsUserMapCheck[bindid]
	total = #data.primary
	hits = 0
	total2 = #data.secondary
	hits2 = 0

	for key in *data.primary
		if DMaps.IsKeyDown(key)
			hits += 1
	for key in *data.secondary
		if DMaps.IsKeyDown(key)
			hits2 += 1

	return total ~= 0 and total == hits or total2 ~= 0 and total2 == hits2

DMaps.LocalizedButtons =
	UP: 'UP Arrow'
	DOWN: 'DOWN Arrow'
	LEFT: 'LEFT Arrow'
	RIGHT: 'RIGHT Arrow'

DMaps.GetBindString = (bindid = '') ->
	if not DMaps.KeybindingsMap[bindid] return false
	if not DMaps.KeybindingsUserMap[bindid] return false
	local output
	data = DMaps.KeybindingsUserMap[bindid]
	if #data.primary ~= 0
		output = table.concat([DMaps.LocalizedButtons[key] or key for key in *data.primary], ' + ')
	if #data.secondary ~= 0
		tab = [DMaps.LocalizedButtons[key] or key for key in *data.secondary]
		output ..= ' or ' .. table.concat(tab, ' + ') if output
		output = table.concat(tab, ' + ') if not output

	return output or '<no key found>'

DMaps.SaveKeybindings = -> file.Write('dmaps_keybinds.txt', util.TableToJSON(DMaps.Keybindings, true))
DMaps.LoadKeybindings = ->
	DMaps.Keybindings = nil
	settingsExists = file.Exists('dmaps_keybinds.txt', 'DATA')
	if settingsExists
		read = file.Read('dmaps_keybinds.txt', 'DATA')
		DMaps.Keybindings = util.JSONToTable(read)
		if DMaps.Keybindings
			defaultBinds = DMaps.GetDefaultBindings()
			valid = true
			hits = {}
			for data in *DMaps.Keybindings
				if not data.primary
					valid = false
					break
				if not data.secondary
					valid = false
					break
				if not data.name
					valid = false
					break
				if type(data.primary) ~= 'table'
					valid = false
					break
				if type(data.secondary) ~= 'table'
					valid = false
					break
				if type(data.name) ~= 'string'
					valid = false
					break
				hits[data.name] = true
			shouldSave = false
			if valid
				for data in *defaultBinds
					if not hits[data.name]
						table.insert(DMaps.Keybindings, data)
						shouldSave = true
				DMaps.UpdateKeysMap()
				DMaps.SaveKeybindings() if shouldSave
			else
				DMaps.Keybindings = nil

	if not DMaps.Keybindings
		file.Write('dmaps_keybinds_corrupt.txt', file.Read('dmaps_keybinds.txt', 'DATA')) if settingsExists
		DMaps.Keybindings = DMaps.GetDefaultBindings()
		DMaps.UpdateKeysMap()
		DMaps.SaveKeybindings()
	
	return DMaps.Keybindings

DMaps.LoadKeybindings()

DMaps.UpdateKeysStatus = ->
	if not DMaps.WatchingButtons return
	for key in *DMaps.WatchingButtons
		oldStatus = DMaps.PressedButtons[key]
		newStatus = input.IsKeyDown(key)
		if oldStatus ~= newStatus
			DMaps.PressedButtons[key] = newStatus
			watching = DMaps.WatchingButtonsPerBinding[key]
			if watching
				for name in *watching
					oldPressStatus = DMaps.BindPressStatus[name]
					newPressStatus = DMaps.InternalIsBindPressed(name)
					if oldPressStatus ~= newPressStatus
						DMaps.BindPressStatus[name] = newPressStatus
						if not newPressStatus
							hook.Run('DMaps.BindReleased', name)
						else
							hook.Run('DMaps.BindPressed', name)

hook.Add 'Think', 'DMaps.Keybinds', DMaps.UpdateKeysStatus

PANEL_BIND_FIELD =
	Init: =>
		@lastMousePress = 0
		@lastMousePressRight = 0
		@primary = true
		@lock = false
		@combination = {}
		@combinationNew = {}
		@SetMouseInputEnabled(true)
		--@SetKeyboardInputEnabled(true)
		@combinationLabel = vgui.Create('DLabel', @)
		@addColor = 0
		with @combinationLabel
			\Dock(FILL)
			\DockMargin(5, 0, 0, 0)
			\SetTextColor(color_white)
			\SetText('#COMBINATION?')
	SetCombinationLabel: (keys = {}) =>
		str = table.concat([DMaps.LocalizedButtons[key] or key for key in *DMaps.SerealizeKeys(keys)], ' + ')
		@combinationLabel\SetText(str)
	StopLock: =>
		@lock = false
		@SetCursor('none')
		if #@combinationNew == 0
			@combinationNew = @combination
			@SetCombinationLabel(@combination)
		else
			@GetParent()\OnCombinationUpdates(@, @combinationNew)
			@combination = keys
			@SetCombinationLabel(@combinationNew)
	OnMousePressed: (code = MOUSE_LEFT) =>
		if code == MOUSE_LEFT
			if @lock
				@StopLock()
				return
			prev = @lastMousePress
			@lastMousePress = RealTime() + 0.4
			return if prev < RealTime()
			@lock = true
			@combinationNew = {}
			@combinationLabel\SetText('???')
			@mouseX, @mouseY = @LocalToScreen(5, 5)
			@SetCursor('blank')
			@pressedKeys = {key, false for key in *KEY_LIST}
		elseif code == MOUSE_RIGHT and not @lock
			prev = @lastMousePressRight
			@lastMousePressRight = RealTime() + 0.4
			return if prev < RealTime()
			@combinationNew = {}
			@GetParent()\OnCombinationUpdates(@, @combinationNew)
			@combination = @combinationNew
			@SetCombinationLabel(@combination)
	OnKeyCodePressed: (code = KEY_NONE) =>
		return if code == KEY_NONE or code == KEY_FIRST
		return if not @lock
		if code == KEY_ESCAPE
			@lock = false
			@combinationNew = @combination
			@SetCombinationLabel(@combination)
			@SetCursor('none')
			return
		elseif code == KEY_ENTER
			@StopLock()
			return
		table.insert(@combinationNew, code)
		@SetCombinationLabel(@combinationNew)
	OnKeyCodeReleased: (code = KEY_NONE) =>
		return if code == KEY_NONE or code == KEY_FIRST
		@StopLock() if @lock
	Paint: (w = 0, h = 0) =>
		surface.SetDrawColor(40 + 90 * @addColor, 40 + 90 * @addColor, 40)
		surface.DrawRect(0, 0, w, h)
		if @lock
			surface.SetDrawColor(137, 130, 104)
			surface.DrawRect(4, 4, w - 8, h - 8)
	Think: =>
		if @IsHovered()
			@addColor = math.min(@addColor + FrameTime() * 10, 1)
		else
			@addColor = math.max(@addColor - FrameTime() * 10, 0)
		if @lock
			input.SetCursorPos(@mouseX, @mouseY)
			for key in *KEY_LIST
				old = @pressedKeys[key]
				new = input.IsKeyDown(key)
				if old ~= new
					@pressedKeys[key] = new
					if new
						@OnKeyCodePressed(key)
					else
						@OnKeyCodeReleased(key)
		

PANEL_BIND_INFO =
	Init: =>
		@SetMouseInputEnabled(true)
		@SetKeyboardInputEnabled(true)
		@bindid = ''
		@label = vgui.Create('DLabel', @)
		@SetSize(200, 30)
		with @label
			\SetText(' #HINT?')
			\Dock(LEFT)
			\DockMargin(10, 0, 0, 0)
			\SetSize(200, 0)
			\SetTooltip(' #DESCRIPTION?')
			\SetTextColor(color_white)
		
		@primary = vgui.Create('DMapsBindField', @)
		with @primary
			\Dock(LEFT)
			\DockMargin(10, 0, 0, 0)
			\SetSize(100, 0)
			.Primary = true
			.combination = {}
		
		@secondary = vgui.Create('DMapsBindField', @)
		with @secondary
			\Dock(LEFT)
			\DockMargin(10, 0, 0, 0)
			\SetSize(100, 0)
			.Primary = false
			.combination = {}
	SetBindID: (id = '') =>
		@bindid = id
		data = DMaps.KeybindingsUserMap[id]
		dataLabels = DMaps.KeybindingsMap[id]
		return if not data
		return if not dataLabels
		with @label
			\SetText(dataLabels.name)
			\SetTooltip(dataLabels.desc)
		@primary.combination = [key for key in *DMaps.UnSerealizeKeys(data.primary)]
		@secondary.combination = [key for key in *DMaps.UnSerealizeKeys(data.secondary)]
		@primary\SetCombinationLabel(@primary.combination)
		@secondary\SetCombinationLabel(@secondary.combination)
	OnCombinationUpdates: (pnl, newCombination = {}) =>
		return if @bindid == ''
		DMaps.SetKeyCombination(@bindid, pnl.Primary, DMaps.SerealizeKeys(newCombination))
	Paint: (w = 0, h = 0) =>
		surface.SetDrawColor(106, 122, 120)
		surface.DrawRect(0, 0, w, h)

vgui.Register('DMapsBindField', PANEL_BIND_FIELD, 'EditablePanel')
vgui.Register('DMapsBindRow', PANEL_BIND_INFO, 'EditablePanel')

DMaps.OpenKeybindsMenu = ->
	frame = vgui.Create('DFrame')
	self = frame
	@SetSize(500, ScrH() - 200)
	@SetTitle('DMap Keybinds')
	@Center()
	@MakePopup()
	@SetKeyboardInputEnabled(true)

	@scroll = vgui.Create('DScrollPanel', @)
	@scroll\Dock(FILL)

	@rows = for {:name} in *DMaps.Keybindings
		if not DMaps.KeybindingsMap[name] continue
		row = vgui.Create('DMapsBindRow', @scroll)
		row\SetBindID(name)
		row\Dock(TOP)
		row

	return @
