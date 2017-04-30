
--
-- Copyright (C) 2017 DBot
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--	 http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 

import vgui, DMaps, Color, concommand, surface from _G

surface.CreateFont('DMaps.ColorOptionHint', {
	font: 'Roboto'
	size: 16
	weight: 500
})

MINIMAP_POSITION_X = CreateConVar('cl_dmaps_minimap_pos_x', '98', {FCVAR_ARCHIVE}, 'Minimap % position of X')
MINIMAP_POSITION_Y = CreateConVar('cl_dmaps_minimap_pos_y', '40', {FCVAR_ARCHIVE}, 'Maximal % position of Y')
MINIMAP_SIZE = CreateConVar('cl_dmaps_minimap_size', '25', {FCVAR_ARCHIVE}, 'Size in percents of minimap')

MINIMAP_BORDER = DMaps.CreateColor(160, 160, 160, 'minimap_border', 'Minimap border color')

PanelMeta =
	NumSlider: (name = 'DNum Slider', cvar = '', min = 0, max = 1, decimals = 0) =>
		slider = vgui.Create('DNumSlider', @)
		with slider
			\Dock(TOP)
			\DockMargin(2, 0, 2, 0)
			\SetTooltip("#{name}\nConVar: #{cvar}")
			\SetText(name)
			\SetConVar(cvar)
			\SetMin(min)
			\SetMax(max)
			\SetDecimals(decimals)
			.TextArea\SetTextColor(color_white)
			.Label\SetTextColor(color_white)
		return slider
	CheckBox: (name, cvar) =>
		checkbox = vgui.Create('DCheckBoxLabel', @)
		with checkbox
			\Dock(TOP)
			\DockMargin(2, 2, 2, 2)
			\SetText(name)
			\SetTextColor(color_white)
			\SetTooltip("#{name}\nConVar: #{cvar}")
			\SetConVar(cvar)
		return checkbox
	Paint: (w, h) =>
		surface.SetDrawColor(130, 130, 130)
		surface.DrawRect(0, 0, w, h)

vgui.Register('DMapsOptionsPanel', PanelMeta, 'EditablePanel')

MINIMAP_DISPLAY_PANEL =
	Init: =>
		@w = ScrW()
		@W = @w
		@h = ScrH()
		@H = @h
		@aspectRatio = @w / @h
		@min = math.min(@w, @h)
		@posx = 0
		@posy = 0
		@SetSize(@wCurrent, @hCurrent)
		@SetMouseInputEnabled(true)
	InitSize: (width = 1, height = 1) =>
		@initWidth = width
		@initHeight = height
		aspectRatio = width / height
		newW, newH = @w * height / @h, height if aspectRatio > @aspectRatio
		newW, newH = width, @h * width / @w if aspectRatio <= @aspectRatio
		@min = math.min(newW, newH)
		@W, @H = newW, newH
		@SetSize(newW, newH)
	OnMousePressed: =>
		@mPosX, @mPosY = gui.MousePos()
		@hold = true
	OnMouseReleased: =>
		@hold = false
	Think: =>
		w, h = @GetSize()
		@InitSize(w, h) if w ~= @initWidth or h ~= @initHeight
		@size = @min * MINIMAP_SIZE\GetInt() / 100
		@posx, @posy = @W * MINIMAP_POSITION_X\GetInt() / 100 - @size, @H * MINIMAP_POSITION_Y\GetInt() / 100
		@posx -= 5
		@posy -= 5
		@size += 10

		if @hold
			deltaW, deltaH = w - @W, h - @H
			deltaW /= 2
			deltaH /= 2
			lX, lY = @LocalToScreen(deltaW, deltaH)
			x, y = gui.MousePos()
			multX = math.Clamp(x - lX + @size + 10, 0, @W) / @W
			multY = math.Clamp(y - lY + 10, 0, @H) / @H
			RunConsoleCommand('cl_dmaps_minimap_pos_x', "#{math.floor multX * 100}")
			RunConsoleCommand('cl_dmaps_minimap_pos_y', "#{math.floor multY * 100}")
	Paint: (w, h) =>
		deltaW, deltaH = w - @W, h - @H
		deltaW /= 2
		deltaH /= 2
		surface.SetDrawColor(70, 70, 70)
		surface.DrawRect(deltaW, deltaH, @W, @H)
		surface.SetDrawColor(MINIMAP_BORDER())
		surface.DrawRect(@posx + deltaW, @posy + deltaH, @size, @size)
vgui.Register('DMapsMinimapPosPreview', MINIMAP_DISPLAY_PANEL, 'EditablePanel')

Pages =
	generic:
		name: 'Generic Options'
		func: (sheet, frame) =>
			scroll = vgui.Create('DScrollPanel', @)
			scroll\Dock(FILL)
			for {cvar, text} in *DMaps.CONVARS_SETTINGS
				checkbox = @CheckBox(text, "cl_dmaps_#{cvar}")
				checkbox\SetParent(scroll)
	minimap:
		name: 'Minimap position'
		func: (sheet, frame) =>
			@NumSlider('X position in % of screen Width', 'cl_dmaps_minimap_pos_x', 0, 100, 0)
			@NumSlider('Y position in % of screen Height', 'cl_dmaps_minimap_pos_y', 0, 100, 0)
			@preview = vgui.Create('DMapsMinimapPosPreview', @)
			@preview\Dock(FILL)
	minimap_pos:
		name: 'Minimap options'
		func: (sheet, frame) =>
			@NumSlider('Default zoom', 'cl_dmaps_minimap_zoom', 400, 2000, 0)
			@NumSlider('Size', 'cl_dmaps_minimap_size', 1, 80, 0)
			@CheckBox('Dynamic zoom', 'cl_dmaps_minimap_dynamic')
			@NumSlider('Dynamic size multiplier', 'cl_dmaps_minimap_dynamic_mult', 0, 10, 4)
			@NumSlider('Minimal dynamic size', 'cl_dmaps_minimap_dynamic_min', 0, 10, 4)
			@NumSlider('Maximal dynamic size', 'cl_dmaps_minimap_dynamic_max', 0, 10, 4)
	colors:
		name: 'Colors'
		func: (sheet, frame) =>
			scroll = vgui.Create('DScrollPanel', @)
			scroll\Dock(FILL)
			for {:name, :desc, :r, :g, :b} in *DMaps.CONVARS_COLORS_ARRAY
				local picker
				label = vgui.Create('DLabel', scroll)
				with label
					\Dock(TOP)
					\SetColor(color_white)
					\SetText("#{desc}\nInternal name: #{name}\nConVar: cl_dmaps_color_#{name}")
					\SetTooltip(label\GetText())
					\SetFont('DMaps.ColorOptionHint')
					\SizeToContents()
					\DockMargin(5, 5, 5, 5)
					\SetMouseInputEnabled(true)
				reset = vgui.Create('DButton', label)
				with reset
					x, y = label\GetPos()
					w, h = label\GetSize()
					\Dock(RIGHT)
					\DockMargin(5, 12, 5, 12)
					\SetText('Reset color')
					reset.DoClick = ->
						RunConsoleCommand("cl_dmaps_color_#{name}_r", tostring(r))
						RunConsoleCommand("cl_dmaps_color_#{name}_g", tostring(g))
						RunConsoleCommand("cl_dmaps_color_#{name}_b", tostring(b))
						picker\SetColor(Color(r, g, b))
				pickerWrapper = vgui.Create('EditablePanel', scroll)
				pickerWrapper\Dock(TOP)
				pickerWrapper\SetSize(0, 250)
				pickerWrapper\DockMargin(5, 5, 5, 5)
				picker = vgui.Create('DColorMixer', pickerWrapper)
				picker\Dock(LEFT)
				picker\SetConVarR("cl_dmaps_color_#{name}_r")
				picker\SetConVarG("cl_dmaps_color_#{name}_g")
				picker\SetConVarB("cl_dmaps_color_#{name}_b")
				picker\SetAlphaBar(false)

DMaps.OpenOptions = ->
	frame = vgui.Create('DFrame')
	self = frame
	@SetSize(ScrW() - 100, ScrH() - 100)
	@SetTitle('DMaps Clientside Options')
	@Center()
	@MakePopup()

	sheet = vgui.Create('DPropertySheet', @)
	sheet\Dock(FILL)
	
	for id, page in pairs Pages
		panel = vgui.Create('DMapsOptionsPanel', sheet)
		addedSheet = sheet\AddSheet(page.name, panel)
		sheet\SetActiveTab(addedSheet.Tab) if id == 'generic'
		panel\Dock(FILL)
		panel\DockMargin(5, 5, 5, 5)
		panel\DockPadding(5, 5, 5, 5)
		page.func(panel, sheet, frame)
		@[id] = panel
	return frame
concommand.Add('dmaps_options', DMaps.OpenOptions)