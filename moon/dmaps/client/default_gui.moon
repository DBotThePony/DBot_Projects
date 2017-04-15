
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

if IsValid(DMaps.MainFrame)
	DMaps.MainFrame\Remove!

ASPECT_RATIO = 1.3
ASPECT_RATIO_R = 1 / ASPECT_RATIO

DMaps.CreateMainFrame = ->
	if IsValid(DMaps.MainFrame)
		DMaps.MainFrame\Remove!
	
	DMaps.MainFrame = vgui.Create('DFrame')
	self = DMaps.MainFrame
	
	mins = math.min(ScrW!, ScrH!) * 0.96
	
	w, h = mins * ASPECT_RATIO, mins
	@SetSize(w, h)
	@Center!
	@MakePopup!
	@SetDeleteOnClose(false)
	@SetTitle('DMap')
	
	@mapHolder = vgui.Create('DMapsMapHolder', @)
	@mapHolder\Dock(FILL)
	
	@buttons = vgui.Create('DMapButtons', @)
	@buttons\AddMultiButton(@mapHolder\GetButtons!)
	@buttons\DoSetup(w, h, -5)
	return @
DMaps.OpenMap = ->
	if not IsValid(DMaps.MainFrame)
		DMaps.CreateMainFrame!
	
	with DMaps.MainFrame
		\SetVisible(true)
		\SetMouseInputEnabled(true)
		\SetKeyboardInputEnabled(true)
		\RequestFocus!
		\Center!
DMaps.OpenOptions = ->
	frame = vgui.Create('DFrame')
	self = frame
	@SetSize(400, ScrH! - 200)
	@SetTitle('DMaps Clientside Options')
	@Center()
	@MakePopup()
	
	scroll = vgui.Create('DScrollPanel', @)
	scroll\Dock(FILL)
	scroll.Paint = (w, h) =>
		surface.SetDrawColor(160, 160, 160)
		surface.DrawRect(0, 0, w, h)
	
	for data in *DMaps.CONVARS_SETTINGS
		checkbox = vgui.Create('DCheckBoxLabel', scroll)
		checkbox\SetText(data[2])
		checkbox\SetConVar(data[1])
		checkbox\Dock(TOP)
		checkbox\DockMargin(3, 3, 3, 3)
	return frame
concommand.Add('dmaps_open', DMaps.OpenMap)
