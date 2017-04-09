
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

-- A panel that holds the map
-- And user controls

import DMapLocalPlayerPointer from DMaps

PANEL = {}

PANEL.Init = =>
	@SetSize(200, 200)
	@mapObject = DMaps.DMap!
	@UpdateMapSizes!
	@SetCursor('hand')
	@hold = false
	
	@mapObject\AddObject(DMapLocalPlayerPointer!)
	
	@SetMouseInputEnabled(true)
	
	@Spectating = LocalPlayer!
	
	@cursor_lastX = 0
	@cursor_lastY = 0
	
	hookName = @GetHookName!
	
	callFunc = ->
		if IsValid(@) and IsValid(@GetParent!)
			if @GetParent!\IsVisible!
				@DrawOverlay!
		else
			hook.Remove('DrawOverlay', hookName)
	
	hook.Add('DrawOverlay', hookName, callFunc)

PANEL.OnMousePressed = (code) =>
	if code == MOUSE_LEFT
		@hold = true
		x, y = gui.MousePos()
		@SetCursor('sizeall')
		
		@cursor_lastX = x
		@cursor_lastY = y
		
		@mapObject\LockView(true)

PANEL.Release = =>
	@hold = false
	@SetCursor('hand')
	
	@cursor_lastX = 0
	@cursor_lastY = 0

PANEL.OnMouseReleased = (code) =>
	if code == MOUSE_LEFT
		@Release!

PANEL.OnMouseWheeled = (deltaWheel) =>
	@mapObject\LockZoom(true)
	@mapObject\LockView(true)
	@mapObject\AddZoom(-deltaWheel * math.max(math.abs(@mapObject\GetZ!), 100) * 0.1)
	
	mult = @mapObject\GetZoomMultiplier! * 0.017
	
	x, y = gui.MousePos()
	
	deltaX = x - ScrW! / 2
	deltaY = y - ScrH! / 2
	
	if deltaWheel < 0
		@mapObject\AddX(-deltaX * mult)
		@mapObject\AddY(deltaY * mult)
	else
		@mapObject\AddX(deltaX * mult)
		@mapObject\AddY(-deltaY * mult)

PANEL.UpdateMapSizes = =>
	@mapObject\SetSize(@GetSize!)

PANEL.PerformLayout = (w, h) =>
	@mapObject\SetSize(w, h)
	@mapObject\SetDrawPos(@LocalToScreen(0, 0))

PANEL.GetHookName = =>
	if not @__hookName
		@__hookName = tostring(@GetTable!)\sub(8) .. '__mapholder'
	
	return @__hookName

PANEL.Think = =>
	if not @IsHovered!
		@Release!
	
	@mapObject\Think!
	@mapObject\ThinkPlayer(@Spectating)
	
	if @hold
		x, y = gui.MousePos()
		deltaX = x - @cursor_lastX
		deltaY = y - @cursor_lastY
		
		@cursor_lastX = x
		@cursor_lastY = y
		
		mult = @mapObject\GetZoomMultiplier! * 0.125
		
		@mapObject\AddX(-deltaX * mult)
		@mapObject\AddY(deltaY * mult)
		
	
PANEL.Paint = (w, h) =>
	@lastW = w
	@lastH = h
	surface.SetDrawColor(0, 0, 0)
	surface.DrawRect(0, 0, w, h)
	
PANEL.DrawOverlay = =>
	if @lastW then @mapObject\SetWidth(@lastW)
	if @lastH then @mapObject\SetHeight(@lastH)
	
	@mapObject\SetDrawPos(@LocalToScreen(0, 0))
	@mapObject\DrawHook!
	
PANEL.OnRemove = =>
	hook.Remove('DrawOverlay', @GetHookName!)
	@mapObject\Remove!

return PANEL
