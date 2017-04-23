
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

Pages =
	generic:
		name: 'Generic Options'
		func: (sheet, frame) => @CheckBox(text, cvar) for {cvar, text} in *DMaps.CONVARS_SETTINGS
	minimap:
		name: 'Minimap options'
		func: (sheet, frame) =>
			@NumSlider('Default zoom', 'cl_dmap_minimap_zoom', 400, 2000, 0)
			@NumSlider('Size', 'cl_dmap_minimap_size', 1, 80, 0)
			@CheckBox('Dynamic zoom', 'cl_dmap_minimap_dynamic')
			@NumSlider('Dynamic size multiplier', 'cl_dmap_minimap_dynamic_mult', 0, 10, 4)
			@NumSlider('Minimal dynamic size', 'cl_dmap_minimap_dynamic_min', 0, 10, 4)
			@NumSlider('Maximal dynamic size', 'cl_dmap_minimap_dynamic_max', 0, 10, 4)
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
		sheet\AddSheet(page.name, panel)
		panel\Dock(FILL)
		panel\DockMargin(5, 5, 5, 5)
		panel\DockPadding(5, 5, 5, 5)
		page.func(panel, sheet, frame)
		@[id] = panel
	return frame
concommand.Add('dmaps_options', DMaps.OpenOptions)