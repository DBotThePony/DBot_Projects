
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

import vgui, DMaps, Color, FILL, hook from _G
import Icon from DMaps

PANEL_ICON =
	Init: =>
		@valid = false
		@SetSize(32, 32)
		@SetMouseInputEnabled(true)
		@hoverTime = 0
		@lastTick = RealTime()
		@hold = false
	
	OnMousePressed: (code) =>
		@hold = true
	
	OnMouseReleased: (code) =>
		@hold = false
		@GetParent()\OnIconPress(@) if @IsHovered()
	
	Think: =>
		time = RealTime()
		delta = time - @lastTick
		@lastTick = time
		
		if @IsHovered()
			@hoverTime = math.Clamp(@hoverTime + delta, 0, 1)
		else
			@hoverTime = math.Clamp(@hoverTime - delta, 0, 1)
	
	IsValid: => @valid
	SetIcon: (name = Icon\GetIcons()[1]) =>
		@icon = Icon(name)
		@valid = @icon\IsValid()
	
	Paint: (w, h) =>
		surface.SetDrawColor(140 + @hoverTime * 80, 140 + @hoverTime * 80, 140 + @hoverTime * 80) if not @hold
		surface.SetDrawColor(220, 220, 220) if @hold
		surface.DrawRect(0, 0, w, h)
		@icon\Draw(0, 0, 1, false)

PANEL = 
	Close: =>
		hook.Remove('VGUIMousePressed', @hookID)
		@Remove()
	
	Init: =>
		@icons = {}
		@color = Color(255, 255, 255)
		@w, @h = 32 * 5 + 12, 400 -- 5 icons per row + scrollbar
		@SetSize(@w, @h)
		@SetMouseInputEnabled(true)
		@DockPadding(5, 5, 5, 5)
		@scroll = vgui.Create('DScrollPanel', @)
		@scroll\Dock(FILL)
		
		@hookID = tostring(@)
		hookID = tostring(@)
		
		mouse = (p) ->
			return hook.Remove('VGUIMousePressed', hookID) if not @IsValid()
			@Close() if p ~= @
		
		hook.Add('VGUIMousePressed', hookID, mouse)
		
		for icon in *Icon\GetIcons()
			pnl = vgui.Create('DMapsIcon', @scroll)
			pnl\SetIcon(icon)
			table.insert(@icons, pnl)
	
	Register: (parent) => @parent = parent
	OnIconPress: (icon) => @parent\OnIconPress(icon)
	
	OpenAt: (x, y) =>
		x += @w + 5
		y -= @h / 2
		@SetPos(x, y)
		@RequestFocus()
	
	PerformLayout: (w, h) =>
		x = 0
		line = 0
		
		for icon in *@icons
			if x + 32 > w - 12
				line += 1
				x = 0
			icon\SetPos(x, line * 32)
			x += 32
	
	Paint: (w, h) =>
		surface.SetDrawColor(200, 200, 200)
		surface.DrawRect(0, 0, w, h)
	
	Think: =>
		return @Close() if not @parent
		return @Close() if not @parent\IsValid()
		return @Close() if not @parent\IsVisible()

vgui.Register('DMapsIcon', PANEL_ICON, 'EditablePanel')
vgui.Register('DMapsIconList', PANEL, 'EditablePanel')
return PANEL, PANEL_ICON
