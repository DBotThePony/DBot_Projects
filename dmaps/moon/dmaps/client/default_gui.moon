
--
-- Copyright (C) 2017-2019 DBotThePony
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

MINIMAP_ZOOM = CreateConVar('cl_dmaps_minimap_zoom', '1000', {FCVAR_ARCHIVE}, 'Minimal "minimap mode" zoom')
MINIMAP_SIZE = CreateConVar('cl_dmaps_minimap_size', '25', {FCVAR_ARCHIVE}, 'Size in percents of minimap')
MINIMAP_DYNAMIC = CreateConVar('cl_dmaps_minimap_dynamic', '1', {FCVAR_ARCHIVE}, 'Is minimap dynamic in size')
MINIMAP_DYNAMIC_MULT = CreateConVar('cl_dmaps_minimap_dynamic_mult', '1', {FCVAR_ARCHIVE}, 'Minimap dynamic speed multiplier')
MINIMAP_DYNAMIC_MIN = CreateConVar('cl_dmaps_minimap_dynamic_min', '1', {FCVAR_ARCHIVE}, 'Minimap dynamic size')
MINIMAP_DYNAMIC_MAX = CreateConVar('cl_dmaps_minimap_dynamic_max', '5', {FCVAR_ARCHIVE}, 'Maximal dynamic size')

MINIMAP_POSITION_X = CreateConVar('cl_dmaps_minimap_pos_x', '98', {FCVAR_ARCHIVE}, 'Minimap % position of X')
MINIMAP_POSITION_Y = CreateConVar('cl_dmaps_minimap_pos_y', '40', {FCVAR_ARCHIVE}, 'Maximal % position of Y')

ALLOW_MINIMAP = CreateConVar('sv_dmaps_allow_minimap', '1', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Allow minimap mode')

MINIMAP_BORDER = DMaps.CreateColor(160, 160, 160, 'minimap_border', 'Minimap border color')

if IsValid(DMaps.MainFrame)
	DMaps.MainFrame\Remove!

DMaps.DISPLAY_AS_MINIMAP = false

AVERAGE_SPEED = [0 for i = 1, 100]
AVERAGE_SPEED_INDEX = 1

DMaps.GetMainMap = ->
	return false if not IsValid(DMaps.MainFrame)
	return false if not IsValid(DMaps.MainFrame.mapHolder)
	return false if not IsValid(DMaps.MainFrame.mapHolder\GetMap())
	return DMaps.MainFrame.mapHolder\GetMap()

svPoints = {
	{'basic', 'Basic', 'dmaps_serverwaypoints'}
	{'cami', 'CAMI usergroups', 'dmaps_serverwaypoints_cami'}
	{'ugroup', 'usergroups', 'dmaps_serverwaypoints_ugroup'}
	{'team', 'teams', 'dmaps_serverwaypoints_teams'}
}

DBUTTON_DO_CLICK = =>
	mapHolder = @frame.mapHolder
	x, y = @LocalToScreen(0, 20)
	menu = DermaMenu()

	with menu
		\AddOption('Close', -> @frame\Close())\SetIcon('icon16/cross.png')
		\AddOption('Options', DMaps.OpenOptions)\SetIcon('icon16/wrench.png')
		\AddOption('Keybindings', DMaps.OpenKeybindsMenu)\SetIcon('icon16/wrench.png')
		\AddOption('Waypoints shared with you', DMaps.OpenSharedMenu)\SetIcon('icon16/heart.png')
		\AddSpacer()
		\AddOption('Clientside waypoints', DMaps.OpenWaypointsMenu)\SetIcon(table.Random(DMaps.FLAGS))
		for {name, Desc, conCommand} in *svPoints
			\AddOption("Serverside #{Desc} waypoints", -> RunConsoleCommand(conCommand))\SetIcon(table.Random(DMaps.FLAGS)) if DMaps.HasPermission("dmaps_view_#{name}_waypoints")
		\AddSpacer()
		if not mapHolder.compass.followingPlayer then \AddOption('Follow player angles', -> mapHolder.compass.followingPlayer = true)\SetIcon('icon16/user_go.png')
		if mapHolder.compass.followingPlayer then \AddOption('Stop following player angles', -> mapHolder.compass.followingPlayer = false)\SetIcon('icon16/user_delete.png')
		\AddOption('Reset map Zoom', -> mapHolder\GetMap()\LockZoom(false))\SetIcon('icon16/zoom_out.png')
		\AddOption('Reset map Clip', -> mapHolder\GetMap()\LockClip(false))\SetIcon('icon16/magifier_zoom_out.png')
		\AddOption('Reset map Position', -> mapHolder\GetMap()\LockView(false))\SetIcon('icon16/vector_delete.png')
		\AddOption('Reset map Angles', -> mapHolder.compass.targetyaw = 0)\SetIcon('icon16/arrow_refresh.png')
		\AddOption('Disable cave mode', -> mapHolder\GetMap()\SetIsCaveMode(false))\SetIcon('icon16/map_delete.png') if mapHolder\GetMap()\IsCaveModeEnabled()
		\AddOption('Enable cave mode', -> mapHolder\GetMap()\SetIsCaveMode(true))\SetIcon('icon16/map_magnify.png') if not mapHolder\GetMap()\IsCaveModeEnabled()
		\AddSpacer()
		\AddOption('GitLab (sources)', -> gui.OpenURL('https://git.dbot.serealia.ca/dbot/DMaps'))\SetIcon('icon16/script_code.png')
		\AddOption('Changelog (commits)', -> gui.OpenURL('https://git.dbot.serealia.ca/dbot/DMaps/commits/master'))\SetIcon('icon16/page_white_stack.png')
		\AddOption('Issues/suggestions', -> gui.OpenURL('https://git.dbot.serealia.ca/dbot/DMaps/issues'))\SetIcon(table.Random(DMaps.BUGS_ICONS))
		\AddOption('Workshop (please ★★★★★)', -> gui.OpenURL('https://steamcommunity.com/sharedfiles/filedetails/?id=916067750'))\SetIcon('icon16/heart.png')
		\AddOption('Discord (q/s)', -> gui.OpenURL('https://discord.gg/HG9eS79'))\SetIcon('icon16/application_view_detail.png')
		\AddOption('Creator of DMaps', -> gui.OpenURL('https://steamcommunity.com/id/roboderpy/'))\SetIcon('icon16/page_code.png')
		\Open()
		\SetPos(x, y)

DFRAME_ON_CLOSE = =>
	DMaps.DISPLAY_AS_MINIMAP = @LAST_MINIMAP_STATUS
	if not @LAST_MINIMAP_STATUS
		@displayAsMinimap\SetText('Display as Minimap')
		@displayAsMinimap\SetTooltip('Display as Minimap')
	else
		@displayAsMinimap\SetText('Stop displaying as Minimap')
		@displayAsMinimap\SetTooltip('Stop displaying as Minimap')
		map = @mapHolder\GetMap()
		map\LockZoom(false)
		map\LockClip(false)
		map\LockView(false)
		map\SetMinimalAutoZoom(MINIMAP_ZOOM\GetInt())
		AVERAGE_SPEED = [0 for i = 1, 100]
		AVERAGE_SPEED_INDEX = 1

DMaps.CreateMainFrame = ->
	if IsValid(DMaps.MainFrame)
		DMaps.MainFrame\Remove!

	DMaps.MainFrame = vgui.Create('DFrame')
	self = DMaps.MainFrame
	@GetMap = => @mapHolder\GetMap()

	w, h = ScrW() - 100, ScrH() - 100
	@SetSize(w, h)
	@Center!
	@MakePopup!
	@SetDeleteOnClose(false)
	@SetTitle('')

	@OnKeyCodePressed = (code = KEY_NONE) => @mapHolder\OnKeyCodePressed(code)
	@LAST_MINIMAP_STATUS = false
	@OnClose = DFRAME_ON_CLOSE

	@mapHolder = vgui.Create('DMapsMapHolder', @)
	@mapHolder\Dock(FILL)

	@topMenu = vgui.Create('DButton', @)
	@topMenu.frame = @
	@topMenu\SetPos(4, 4)
	@topMenu\SetSize(80, 20)
	@topMenu\SetText('≡ DMaps')
	@topMenu.DoClick = DBUTTON_DO_CLICK

	@buttons = vgui.Create('DMapButtons', @)
	@buttons\AddMultiButton(@mapHolder\GetButtons())
	@buttons\DoSetup(w, h, -5)

	@displayAsMinimap = vgui.Create('DButton', @)
	with @displayAsMinimap
		.WhatToDo = true
		.isVisible = true
		\SetText('Display as minimap')
		\SetTooltip('Display as minimap')
		\SetSize(200, 20)
		\SetPos(w / 2 - 100, 5)
		.DoClick = ->
			if not ALLOW_MINIMAP\GetBool() return
			if .WhatToDo
				@LAST_MINIMAP_STATUS = true
				@Close()
				map = @mapHolder\GetMap()
				if IsValid(map)
					map\LockZoom(false)
					map\LockClip(false)
					map\LockView(false)
					map\SetMinimalAutoZoom(MINIMAP_ZOOM\GetInt())
					AVERAGE_SPEED = [0 for i = 1, 100]
					AVERAGE_SPEED_INDEX = 1
			else
				@LAST_MINIMAP_STATUS = false
				\SetText('Display as minimap')
				\SetTooltip('Display as minimap')
			.WhatToDo = not .WhatToDo

	@oldThink = @Think
	@Think = =>
		@oldThink() if @oldThink
		minimap = ALLOW_MINIMAP\GetBool()
		if not minimap and @displayAsMinimap.isVisible
			@displayAsMinimap\SetVisible(false)
			@displayAsMinimap.isVisible = false
		elseif minimap and not @displayAsMinimap.isVisible
			@displayAsMinimap\SetVisible(true)
			@displayAsMinimap.isVisible = true
	return @
DMaps.OpenMap = ->
	if not IsValid(DMaps.MainFrame)
		DMaps.CreateMainFrame!

	DMaps.DISPLAY_AS_MINIMAP = false
	with DMaps.MainFrame
		\SetVisible(true)
		\SetMouseInputEnabled(true)
		\SetKeyboardInputEnabled(true)
		\RequestFocus!
		\Center!
		map = .mapHolder\GetMap()
		if IsValid(map)
			map\SetMinimalAutoZoom()
concommand.Add('dmaps_open', DMaps.OpenMap)

timer.Simple 0.1, ->
	timer.Simple 0.1, ->
		timer.Simple 0.1, ->
			timer.Simple 0.1, ->
				DMaps.OpenMap()
				timer.Simple 0.2, -> DMaps.MainFrame\Close()

hook.Add 'Think', 'DMaps.DrawAsMinimap', ->
	if not DMaps.DISPLAY_AS_MINIMAP return
	if not IsValid(DMaps.MainFrame) return
	if not ALLOW_MINIMAP\GetBool() return
	if not IsValid(DMaps.MainFrame.mapHolder) return
	if not IsValid(DMaps.MainFrame.mapHolder\GetMap()) return

	compass = DMaps.MainFrame.mapHolder.compass
	map = DMaps.MainFrame.mapHolder\GetMap()

	if MINIMAP_DYNAMIC\GetBool()
		AVERAGE_SPEED_INDEX += 1
		AVERAGE_SPEED_INDEX = 1 if AVERAGE_SPEED_INDEX > 100
		ply = DMaps.MainFrame.mapHolder.Spectating
		speed = ply\GetVelocity()\Length() if not ply\InVehicle()
		speed = ply\GetVehicle()\GetVelocity()\Length() if ply\InVehicle()
		AVERAGE_SPEED[AVERAGE_SPEED_INDEX] = speed
		average = 0
		average += v for v in *AVERAGE_SPEED
		average /= 20000 * MINIMAP_DYNAMIC_MULT\GetFloat()

		min, max = MINIMAP_DYNAMIC_MIN\GetFloat(), MINIMAP_DYNAMIC_MAX\GetFloat()
		map\SetMinimalAutoZoom(MINIMAP_ZOOM\GetInt() * math.Clamp(average, min, max))
	else
		map\SetMinimalAutoZoom(MINIMAP_ZOOM\GetInt())

	compass\Think()
	map\StandartThink()
	map\ThinkPlayer()
	map\SetMouseActive(false)
	map\LockZoom(false)
	map\LockClip(false)
	map\LockView(false)
	map\Think()

SKIP_FRAME = false
hook.Add 'PostDrawHUD', 'DMaps.DrawAsMinimap', (->
	if SKIP_FRAME return
	if not DMaps.DISPLAY_AS_MINIMAP return
	if not ALLOW_MINIMAP\GetBool() return
	if not IsValid(DMaps.MainFrame) return
	if not IsValid(DMaps.MainFrame.mapHolder) return
	if not IsValid(DMaps.MainFrame.mapHolder\GetMap()) return

	w, h = ScrW(), ScrH()
	min = math.min(w, h)
	size = min * MINIMAP_SIZE\GetInt() / 100
	posx, posy = w * MINIMAP_POSITION_X\GetInt() / 100 - size, h * MINIMAP_POSITION_Y\GetInt() / 100

	surface.SetDrawColor(MINIMAP_BORDER())
	surface.DrawRect(posx - 5, posy - 5, size + 10, size + 10)

	map = DMaps.MainFrame.mapHolder\GetMap()
	map\SetMouseActive(false)
	map\SetWidth(size)
	map\SetHeight(size)
	map\SetDrawPos(posx, posy)
	map\IsDrawnInPanel(false)
	SKIP_FRAME = true
	map\DrawHook()
	SKIP_FRAME = false
), 2