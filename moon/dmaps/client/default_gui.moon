
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

MINIMAP_ZOOM = CreateConVar('cl_dmaps_minimap_zoom', '1000', {FCVAR_ARCHIVE}, 'Minimal "minimap mode" zoom')
MINIMAP_SIZE = CreateConVar('cl_dmaps_minimap_size', '25', {FCVAR_ARCHIVE}, 'Size in percents of minimap')
MINIMAP_DYNAMIC = CreateConVar('cl_dmaps_minimap_dynamic', '1', {FCVAR_ARCHIVE}, 'Is minimap dynamic in size')
MINIMAP_DYNAMIC_MULT = CreateConVar('cl_dmaps_minimap_dynamic_mult', '1', {FCVAR_ARCHIVE}, 'Minimap dynamic speed multiplier')
MINIMAP_DYNAMIC_MIN = CreateConVar('cl_dmaps_minimap_dynamic_min', '1', {FCVAR_ARCHIVE}, 'Minimap dynamic size')
MINIMAP_DYNAMIC_MAX = CreateConVar('cl_dmaps_minimap_dynamic_max', '5', {FCVAR_ARCHIVE}, 'Maximal dynamic size')

if IsValid(DMaps.MainFrame)
	DMaps.MainFrame\Remove!

DMaps.DISPLAY_AS_MINIMAP = false

AVERAGE_SPEED = [0 for i = 1, 100]
AVERAGE_SPEED_INDEX = 1

DMaps.CreateMainFrame = ->
	if IsValid(DMaps.MainFrame)
		DMaps.MainFrame\Remove!
	
	DMaps.MainFrame = vgui.Create('DFrame')
	self = DMaps.MainFrame
	
	w, h = ScrW() - 100, ScrH() - 100
	@SetSize(w, h)
	@Center!
	@MakePopup!
	@SetDeleteOnClose(false)
	@SetTitle('DMap')

	@LAST_MINIMAP_STATUS = false
	@OnClose = =>
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
	
	@mapHolder = vgui.Create('DMapsMapHolder', @)
	@mapHolder\Dock(FILL)
	
	@buttons = vgui.Create('DMapButtons', @)
	@buttons\AddMultiButton(@mapHolder\GetButtons!)
	@buttons\DoSetup(w, h, -5)

	@displayAsMinimap = vgui.Create('DButton', @)
	with @displayAsMinimap
		.WhatToDo = true
		\SetText('Display as minimap')
		\SetTooltip('Display as minimap')
		\SetSize(200, 20)
		\SetPos(w / 2 - 100, 5)
		.DoClick = ->
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

hook.Add 'Think', 'DMaps.DrawAsMinimap', ->
	if not DMaps.DISPLAY_AS_MINIMAP return
	if not IsValid(DMaps.MainFrame) return
	if not IsValid(DMaps.MainFrame.mapHolder) return
	if not IsValid(DMaps.MainFrame.mapHolder\GetMap()) return

	compass = DMaps.MainFrame.mapHolder.compass
	map = DMaps.MainFrame.mapHolder\GetMap()

	if MINIMAP_DYNAMIC\GetBool()
		AVERAGE_SPEED_INDEX += 1
		AVERAGE_SPEED_INDEX = 1 if AVERAGE_SPEED_INDEX > 100
		ply = DMaps.MainFrame.mapHolder.Spectating
		speed = ply\GetVelocity()\Length()
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
	map\Think()
hook.Add 'HUDPaint', 'DMaps.DrawAsMinimap', ->
	if not DMaps.DISPLAY_AS_MINIMAP return
	if not IsValid(DMaps.MainFrame) return
	if not IsValid(DMaps.MainFrame.mapHolder) return
	if not IsValid(DMaps.MainFrame.mapHolder\GetMap()) return

	w, h = ScrW(), ScrH()
	min = math.min(w, h)
	size = min * MINIMAP_SIZE\GetInt() / 100
	posx, posy = w - size - 20, 20

	surface.SetDrawColor(160, 160, 160)
	surface.DrawRect(posx - 5, posy - 5, size + 10, size + 10)

	map = DMaps.MainFrame.mapHolder\GetMap()
	map\SetMouseActive(false)
	map\SetWidth(size)
	map\SetHeight(size)
	map\SetDrawPos(posx, posy)
	map\IsDrawnInPanel(false)
	map\DrawHook()