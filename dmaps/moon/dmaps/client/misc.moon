
--
-- Copyright (C) 2017-2019 DBotThePony

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.


import CreateConVar, math, DMaps from _G
import Clamp from math

DLib.RegisterAddonName('DMaps')

DMaps.FLAGS = ["icon16/flag_#{color}.png" for color in *{'blue', 'green', 'orange', 'pink', 'purple', 'red', 'yellow'}]
DMaps.TAGS_ICONS = ["icon16/tag_#{color}.png" for color in *{'blue', 'green', 'orange', 'pink', 'purple', 'red', 'yellow'}]
DMaps.BUGS_ICONS = ["icon16/#{n}.png" for n in *{'bug', 'bug_go', 'bug_delete', 'bug_error'}]

DMaps.CONVARS_SETTINGS = {}

DMaps.ClientsideOption = (cvar, default, desc) ->
	object = CreateConVar("cl_dmaps_#{cvar}", default, {FCVAR_ARCHIVE}, desc)
	hit = false
	for data in *DMaps.CONVARS_SETTINGS
		if data[1] == cvar
			hit = true
			break
	if not hit
		table.insert(DMaps.CONVARS_SETTINGS, {cvar, desc})
	return object

DMaps.CONVARS_COLORS = {}
DMaps.CONVARS_COLORS_GROUP = {}
DMaps.CONVARS_COLORS_ARRAY = {}

DMaps.CreateColor = (r = 220, g = 220, b = 220, name = 'generic', desc = 'ERROR_COLOR_NAME', group = 'generic') ->
	if DMaps.CONVARS_COLORS[name] return -> DMaps.GetColor(name)
	RED = CreateConVar("cl_dmaps_color_#{name}_r", tostring(r), {FCVAR_ARCHIVE}, "#{desc} 'Red' channel color")
	GREEN = CreateConVar("cl_dmaps_color_#{name}_g", tostring(g), {FCVAR_ARCHIVE}, "#{desc} 'Green' channel color")
	BLUE = CreateConVar("cl_dmaps_color_#{name}_b", tostring(b), {FCVAR_ARCHIVE}, "#{desc} 'Blue' channel color")
	DMaps.CONVARS_COLORS[name] = {
		:name, :desc, :group
		:r, :g, :b
		:RED, :GREEN, :BLUE
	}
	DMaps.CONVARS_COLORS_GROUP[group] = DMaps.CONVARS_COLORS_GROUP[group] or {}
	DMaps.CONVARS_COLORS_GROUP[group][name] = DMaps.CONVARS_COLORS[name]
	table.insert(DMaps.CONVARS_COLORS_ARRAY, DMaps.CONVARS_COLORS[name])
	return -> DMaps.GetColor(name)
DMaps.GetColor = (name, r = 0, g = 0, b = 0) ->
	return r, g, b if not DMaps.CONVARS_COLORS[name]
	{:RED, :GREEN, :BLUE} = DMaps.CONVARS_COLORS[name]
	return Clamp(RED\GetInt(), 0, 255), Clamp(GREEN\GetInt(), 0, 255), Clamp(BLUE\GetInt(), 0, 255)

DMapsIconData =
	title: 'DMaps',
	icon: 'dmaps/map.png',
	width: 960,
	height: 700,
	onewindow: true,
	init: (icon, window) ->
		window\Remove()
		RunConsoleCommand('dmaps_open')

list.Set('DesktopWindows', 'DMaps', DMapsIconData)
CreateContextMenu() if IsValid(g_ContextMenu)
